import argparse
import csv
import math
from collections import defaultdict, OrderedDict
from pathlib import Path


SUITE_ORDER = {"CF": 0, "LIR-CMOP": 1, "DAS-CMOP": 2, "MW": 3, "DOC": 4}


def parse_float(value):
    if value is None:
        return math.nan
    text = str(value).strip()
    if text == "" or text.lower() == "nan":
        return math.nan
    try:
        return float(text)
    except ValueError:
        return math.nan


def is_bad_run(row):
    igd = parse_float(row.get("IGD"))
    feasible = parse_float(row.get("Feasible_rate"))
    return (not math.isfinite(igd)) or (not math.isfinite(feasible)) or feasible <= 0


def mean(values):
    values = [v for v in values if math.isfinite(v)]
    if not values:
        return math.nan
    return sum(values) / len(values)


def fmt(value, digits=3):
    if value is None:
        return ""
    if isinstance(value, int):
        return str(value)
    if not math.isfinite(value):
        return "Inf"
    return f"{value:.{digits}f}"


def natural_problem_key(name):
    prefix = "".join(ch for ch in name if not ch.isdigit())
    number = "".join(ch for ch in name if ch.isdigit())
    return (prefix, int(number) if number else 0)


def rank_values(values):
    indexed = list(enumerate(values))
    indexed.sort(key=lambda item: (math.inf if not math.isfinite(item[1]) else item[1], item[0]))
    ranks = [math.nan] * len(values)
    pos = 1
    i = 0
    while i < len(indexed):
        j = i + 1
        while j < len(indexed) and same_value(indexed[i][1], indexed[j][1]):
            j += 1
        avg_rank = (pos + pos + (j - i) - 1) / 2
        for k in range(i, j):
            ranks[indexed[k][0]] = avg_rank
        pos += j - i
        i = j
    return ranks


def same_value(a, b):
    if not math.isfinite(a) and not math.isfinite(b):
        return True
    if not math.isfinite(a) or not math.isfinite(b):
        return False
    return abs(a - b) <= 1e-12


def read_runs(path):
    with Path(path).open("r", encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def summarize_runs(rows, baseline):
    algorithms = list(OrderedDict((row["algorithm"], None) for row in rows).keys())
    problem_suite = OrderedDict()
    grouped = defaultdict(list)
    fail_rows = defaultdict(int)
    for row in rows:
        alg = row["algorithm"]
        problem = row["problem"]
        suite = row["suite"]
        problem_suite[problem] = suite
        grouped[(alg, problem)].append(row)
        if is_bad_run(row):
            fail_rows[alg] += 1

    problems = sorted(problem_suite.keys(), key=lambda p: (SUITE_ORDER.get(problem_suite[p], 9), natural_problem_key(p)))
    expected_runs = {
        problem: max(len(grouped.get((alg, problem), [])) for alg in algorithms)
        for problem in problems
    }
    problem_stats = {}
    fail_problems = defaultdict(int)
    for alg in algorithms:
        for problem in problems:
            group = grouped.get((alg, problem), [])
            igds = [parse_float(r.get("IGD")) for r in group]
            hvs = [parse_float(r.get("HV")) for r in group]
            feas = [parse_float(r.get("Feasible_rate")) for r in group]
            observed_bad_count = sum(1 for r in group if is_bad_run(r))
            missing_count = max(0, expected_runs[problem] - len(group))
            if missing_count > 0:
                fail_rows[alg] += missing_count
            bad_count = observed_bad_count + missing_count
            strict_score = math.inf if bad_count > 0 or not group else mean(igds)
            if bad_count > 0 or not group:
                fail_problems[alg] += 1
            problem_stats[(alg, problem)] = {
                "strict_igd": strict_score,
                "mean_igd": mean(igds),
                "mean_hv": mean(hvs),
                "mean_feasible": mean(feas),
                "bad_runs": bad_count,
                "runs": len(group),
            }

    ranks_by_problem = {}
    wins = defaultdict(int)
    for problem in problems:
        values = [problem_stats[(alg, problem)]["strict_igd"] for alg in algorithms]
        ranks = rank_values(values)
        ranks_by_problem[problem] = dict(zip(algorithms, ranks))
        finite_values = [v for v in values if math.isfinite(v)]
        if finite_values:
            best = min(finite_values)
            for alg, value in zip(algorithms, values):
                if math.isfinite(value) and abs(value - best) <= 1e-12:
                    wins[alg] += 1

    avg_rank = {
        alg: mean([ranks_by_problem[p][alg] for p in problems])
        for alg in algorithms
    }

    suite_rank = {}
    for suite in sorted(set(problem_suite.values()), key=lambda s: SUITE_ORDER.get(s, 9)):
        suite_problems = [p for p in problems if problem_suite[p] == suite]
        for alg in algorithms:
            suite_rank[(alg, suite)] = mean([ranks_by_problem[p][alg] for p in suite_problems])

    pairwise = {}
    if baseline in algorithms:
        for alg in algorithms:
            if alg == baseline:
                continue
            win = loss = tie = 0
            for problem in problems:
                a = problem_stats[(alg, problem)]["strict_igd"]
                b = problem_stats[(baseline, problem)]["strict_igd"]
                if same_value(a, b):
                    tie += 1
                elif (math.isfinite(a) and not math.isfinite(b)) or a < b:
                    win += 1
                else:
                    loss += 1
            pairwise[alg] = (win, loss, tie)

    return {
        "algorithms": algorithms,
        "problems": problems,
        "problem_suite": problem_suite,
        "problem_stats": problem_stats,
        "avg_rank": avg_rank,
        "suite_rank": suite_rank,
        "wins": wins,
        "pairwise": pairwise,
        "fail_rows": fail_rows,
        "fail_problems": fail_problems,
        "rows": len(rows),
    }


def write_problem_means(summary, out_path):
    algorithms = summary["algorithms"]
    problems = summary["problems"]
    stats = summary["problem_stats"]
    with Path(out_path).open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["algorithm", "problem", "suite", "strict_igd", "mean_igd", "mean_hv", "mean_feasible", "bad_runs", "runs"])
        for alg in algorithms:
            for problem in problems:
                s = stats[(alg, problem)]
                writer.writerow([
                    alg,
                    problem,
                    summary["problem_suite"][problem],
                    fmt(s["strict_igd"], 16),
                    fmt(s["mean_igd"], 16),
                    fmt(s["mean_hv"], 16),
                    fmt(s["mean_feasible"], 16),
                    s["bad_runs"],
                    s["runs"],
                ])


def read_trace_rows(path):
    if not path or not Path(path).exists():
        return []
    with Path(path).open("r", encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def trace_mechanism_section(trace_summary_path, trace_phase_path):
    rows = read_trace_rows(trace_summary_path)
    phase_rows = read_trace_rows(trace_phase_path)
    if not rows:
        return []

    rate_cols = ["rate_ga", "rate_de_rand", "rate_de_best"]
    pop1_cols = ["pop1_rate_ga", "pop1_rate_de_rand", "pop1_rate_de_best"]
    pop2_cols = ["pop2_rate_ga", "pop2_rate_de_rand", "pop2_rate_de_best"]
    feasible_cols = ["feasible_ga", "feasible_de_rand", "feasible_de_best"]
    survival_cols = ["survival_ga", "survival_de_rand", "survival_de_best"]

    by_alg = defaultdict(list)
    for row in rows:
        by_alg[row["algorithm"]].append(row)

    lines = []
    lines.append("## 机制轨迹摘要")
    lines.append("")
    lines.append("下表只统计存在 `policyTrace` 的算法；EMCMO 如果没有轨迹记录，会自然缺席。")
    lines.append("")
    lines.append("| 算法 | GA比例 | DE/rand比例 | DE/best比例 | 双种群分化度 | 可行率最高算子 | 存活率最高算子 |")
    lines.append("| --- | ---: | ---: | ---: | ---: | --- | --- |")
    for alg, group in by_alg.items():
        rates = [mean([parse_float(r[c]) for r in group]) for c in rate_cols]
        pop1 = [[parse_float(r[c]) for c in pop1_cols] for r in group]
        pop2 = [[parse_float(r[c]) for c in pop2_cols] for r in group]
        gaps = []
        for a, b in zip(pop1, pop2):
            if all(math.isfinite(x) for x in a + b):
                gaps.append(sum(abs(x - y) for x, y in zip(a, b)) / 3)
        gap = mean(gaps)
        feasible = [mean([parse_float(r[c]) for r in group]) for c in feasible_cols]
        survival = [mean([parse_float(r[c]) for r in group]) for c in survival_cols]
        best_feasible = best_operator(feasible)
        best_survival = best_operator(survival)
        lines.append(f"| {alg} | {fmt(rates[0])} | {fmt(rates[1])} | {fmt(rates[2])} | {fmt(gap)} | {best_feasible} | {best_survival} |")

    if phase_rows:
        lines.append("")
        lines.append("### 阶段比例")
        lines.append("")
        lines.append("| 算法 | 阶段 | GA比例 | DE/rand比例 | DE/best比例 |")
        lines.append("| --- | --- | ---: | ---: | ---: |")
        grouped = defaultdict(list)
        for row in phase_rows:
            grouped[(row["algorithm"], row["phase"])].append(row)
        for (alg, phase), group in sorted(grouped.items(), key=lambda item: (item[0][0], phase_order(item[0][1]))):
            rates = [mean([parse_float(r[c]) for r in group]) for c in rate_cols]
            lines.append(f"| {alg} | {phase_name(phase)} | {fmt(rates[0])} | {fmt(rates[1])} | {fmt(rates[2])} |")

    lines.append("")
    lines.append("机制读法：如果某个方法最终指标接近 CMOEA-AOP，同时轨迹更简单、阶段更清晰或双种群分化更明显，它就比单纯排名更有研究价值。")
    return lines


def best_operator(values):
    names = ["GA", "DE/rand", "DE/best"]
    finite = [(i, v) for i, v in enumerate(values) if math.isfinite(v)]
    if not finite:
        return ""
    i, _ = max(finite, key=lambda item: item[1])
    return names[i]


def phase_order(phase):
    return {"early": 0, "middle": 1, "late": 2, "all": 3}.get(phase, 9)


def phase_name(phase):
    return {"early": "早期", "middle": "中期", "late": "后期"}.get(phase, phase)


def write_markdown(summary, out_path, title, baseline, trace_summary=None, trace_phase=None):
    algorithms = summary["algorithms"]
    suites = sorted(set(summary["problem_suite"].values()), key=lambda s: SUITE_ORDER.get(s, 9))
    lines = []
    lines.append(f"# {title}")
    lines.append("")
    lines.append("## 统计口径")
    lines.append("")
    lines.append(f"- 行数：{summary['rows']}。")
    lines.append(f"- 算法数：{len(algorithms)}。")
    lines.append(f"- 问题数：{len(summary['problems'])}。")
    lines.append("- 排名主指标：每个问题上各 run 的 IGD。")
    lines.append("- 严格失败规则：某算法在某问题上只要有一个 run 的 `IGD` 或 `Feasible_rate` 为 NaN，或 `Feasible_rate <= 0`，该算法在该问题的严格 IGD 记为 `Inf`。")
    lines.append("- 该规则偏保守，目的是把可行性不稳定显式暴露出来。")
    lines.append("")
    lines.append("## 总体排名")
    lines.append("")
    lines.append("| 算法 | 平均排名 | 问题胜场 | 失败行数 | 失败问题数 |")
    lines.append("| --- | ---: | ---: | ---: | ---: |")
    for alg in sorted(algorithms, key=lambda a: (summary["avg_rank"][a], a)):
        lines.append(
            f"| {alg} | {fmt(summary['avg_rank'][alg])} | {summary['wins'].get(alg, 0)} | "
            f"{summary['fail_rows'].get(alg, 0)} | {summary['fail_problems'].get(alg, 0)} |"
        )

    lines.append("")
    lines.append("## 分问题族排名")
    lines.append("")
    header = "| 算法 | " + " | ".join(suites) + " |"
    align = "| --- | " + " | ".join(["---:"] * len(suites)) + " |"
    lines.append(header)
    lines.append(align)
    for alg in sorted(algorithms, key=lambda a: (summary["avg_rank"][a], a)):
        values = " | ".join(fmt(summary["suite_rank"][(alg, suite)]) for suite in suites)
        lines.append(f"| {alg} | {values} |")

    if summary["pairwise"]:
        lines.append("")
        lines.append(f"## 相对 {baseline} 的问题级胜负")
        lines.append("")
        lines.append("| 算法 | 胜 | 负 | 平 |")
        lines.append("| --- | ---: | ---: | ---: |")
        for alg, (win, loss, tie) in sorted(summary["pairwise"].items(), key=lambda item: (-item[1][0], item[1][1], item[0])):
            lines.append(f"| {alg} | {win} | {loss} | {tie} |")

    trace_lines = trace_mechanism_section(trace_summary, trace_phase)
    if trace_lines:
        lines.append("")
        lines.extend(trace_lines)

    lines.append("")
    lines.append("## 初步结论")
    lines.append("")
    lines.extend(make_conclusions(summary, baseline, bool(trace_lines)))
    Path(out_path).write_text("\n".join(lines) + "\n", encoding="utf-8")


def make_conclusions(summary, baseline, has_trace):
    algorithms = summary["algorithms"]
    avg_rank = summary["avg_rank"]
    ranked = sorted(algorithms, key=lambda a: (avg_rank[a], a))
    best = ranked[0] if ranked else ""
    lines = []
    if best:
        lines.append(f"- 在严格可行性口径下，当前平均排名最好的方法是 `{best}`。")
    if baseline in algorithms:
        base_rank = avg_rank[baseline]
        better = [a for a in algorithms if a != baseline and avg_rank[a] < base_rank]
        if better:
            lines.append("- 有若干简单或可解释方法的平均排名优于基线，这说明研究重点可以放在机制解释和结构化控制，而不是只复现 DDPG。")
        else:
            lines.append("- 简单方法未明显压过基线时，仍要看失败率和轨迹；它们可能在部分问题族上提供更清楚的机制解释。")
    dual = [a for a in algorithms if a.startswith("Dual-")]
    if dual:
        best_dual = min(dual, key=lambda a: avg_rank[a])
        lines.append(f"- 双种群方向中当前较值得继续看的方法是 `{best_dual}`，它直接对应 EMCMO 两个种群的角色差异。")
    credit = [a for a in algorithms if "Credit" in a and not a.startswith("Dual-")]
    if credit:
        best_credit = min(credit, key=lambda a: avg_rank[a])
        lines.append(f"- 单控制器 credit 方向中当前较值得保留的是 `{best_credit}`。")
    if has_trace:
        lines.append("- 机制轨迹应优先用于解释“为什么接近或优于 CMOEA-AOP”，尤其关注阶段比例变化和两个种群是否自然分化。")
    lines.append("- 这些结果仍属于探索/确认阶段，正式论文级结论还需要更高 runs 和显著性检验。")
    return lines


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs", required=True)
    parser.add_argument("--summary", required=True)
    parser.add_argument("--title", required=True)
    parser.add_argument("--baseline", default="CMOEA-AOP")
    parser.add_argument("--problem-means", default="")
    parser.add_argument("--trace-summary", default="")
    parser.add_argument("--trace-phase", default="")
    args = parser.parse_args()

    rows = read_runs(args.runs)
    summary = summarize_runs(rows, args.baseline)
    if args.problem_means:
        write_problem_means(summary, args.problem_means)
    write_markdown(summary, args.summary, args.title, args.baseline, args.trace_summary, args.trace_phase)


if __name__ == "__main__":
    main()
