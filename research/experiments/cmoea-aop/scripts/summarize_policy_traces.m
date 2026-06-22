function summarize_policy_traces(configName)
%SUMMARIZE_POLICY_TRACES Export compact policyTrace diagnostics.

    if nargin < 1 || isempty(configName)
        configName = 's06_mechanism_config';
    end
    rootDir = findRepoRoot();
    setupExperimentPath(rootDir);
    cfg = feval(str2func(configName));
    files = dir(fullfile(cfg.resultDir,'*.mat'));

    overallFile = fullfile(cfg.studyDir,'trace_summary.csv');
    phaseFile   = fullfile(cfg.studyDir,'trace_phase_summary.csv');
    if exist(cfg.studyDir,'dir') ~= 7
        mkdir(cfg.studyDir);
    end

    fidOverall = fopen(overallFile,'w');
    fidPhase   = fopen(phaseFile,'w');
    writeHeader(fidOverall);
    writeHeader(fidPhase);

    rowsOverall = 0;
    rowsPhase   = 0;
    for i = 1 : numel(files)
        data = load(fullfile(files(i).folder,files(i).name),'metadata','policyTrace');
        if ~isfield(data,'policyTrace') || isempty(data.policyTrace)
            continue;
        end
        row = makeTraceRow(data.metadata,data.policyTrace,'all');
        fprintf(fidOverall,'%s\n',strjoin(row,','));
        rowsOverall = rowsOverall + 1;

        phases = {'early',[0,0.25]; 'middle',[0.25,0.70]; 'late',[0.70,inf]};
        for p = 1 : size(phases,1)
            phaseName = phases{p,1};
            range = phases{p,2};
            idx = phaseIndex(data.policyTrace,range);
            if any(idx)
                row = makeTraceRow(data.metadata,data.policyTrace(idx),phaseName);
                fprintf(fidPhase,'%s\n',strjoin(row,','));
                rowsPhase = rowsPhase + 1;
            end
        end
    end

    fclose(fidOverall);
    fclose(fidPhase);
    fprintf('Wrote %d overall trace rows to %s\n',rowsOverall,overallFile);
    fprintf('Wrote %d phase trace rows to %s\n',rowsPhase,phaseFile);
end

function rootDir = findRepoRoot()
    here = fileparts(mfilename('fullpath'));
    rootDir = fileparts(fileparts(fileparts(fileparts(here))));
end

function setupExperimentPath(rootDir)
    restoredefaultpath;
    addpath(fullfile(rootDir,'PlatEMO'));
    addpath(genpath(fullfile(rootDir,'PlatEMO','Algorithms')));
    addpath(genpath(fullfile(rootDir,'PlatEMO','Metrics')));
    addpath(genpath(fullfile(rootDir,'PlatEMO','Problems')));
    addpath(fullfile(rootDir,'research','experiments','cmoea-aop','configs'));
    addpath(fullfile(rootDir,'research','experiments','cmoea-aop','scripts'));
end

function writeHeader(fid)
    cols = {'config','algorithm','problem','suite','N','maxFE','run','seed','phase','generations','FE_start','FE_end', ...
        'rate_ga','rate_de_rand','rate_de_best', ...
        'pop1_rate_ga','pop1_rate_de_rand','pop1_rate_de_best', ...
        'pop2_rate_ga','pop2_rate_de_rand','pop2_rate_de_best', ...
        'generated_ga','generated_de_rand','generated_de_best', ...
        'survived_ga','survived_de_rand','survived_de_best', ...
        'survival_ga','survival_de_rand','survival_de_best', ...
        'feasible_ga','feasible_de_rand','feasible_de_best', ...
        'cvscore_ga','cvscore_de_rand','cvscore_de_best', ...
        'objscore_ga','objscore_de_rand','objscore_de_best', ...
        'pop1_survival_ga','pop1_survival_de_rand','pop1_survival_de_best', ...
        'pop2_survival_ga','pop2_survival_de_rand','pop2_survival_de_best', ...
        'pop1_feasible_ga','pop1_feasible_de_rand','pop1_feasible_de_best', ...
        'pop2_feasible_ga','pop2_feasible_de_rand','pop2_feasible_de_best'};
    fprintf(fid,'%s\n',strjoin(cols,','));
end

function idx = phaseIndex(trace,range)
    progress = [trace.progress];
    if isinf(range(2))
        idx = progress >= range(1);
    else
        idx = progress >= range(1) & progress < range(2);
    end
end

function row = makeTraceRow(metadata,trace,phase)
    summary = summarizeTrace(trace);
    row = {
        csv(metadata.configName)
        csv(metadata.algorithmLabel)
        csv(metadata.problem)
        csv(metadata.suite)
        num2str(metadata.N)
        num2str(metadata.maxFE)
        num2str(metadata.run)
        num2str(metadata.seed)
        csv(phase)
        num2str(numel(trace))
        num2str(trace(1).FE)
        num2str(trace(end).FE)
    };
    values = [summary.rate,summary.popRate(1,:),summary.popRate(2,:), ...
        summary.generated,summary.survived,summary.survival, ...
        summary.feasible,summary.cvScore,summary.objScore, ...
        summary.popSurvival(1,:),summary.popSurvival(2,:), ...
        summary.popFeasible(1,:),summary.popFeasible(2,:)];
    for i = 1 : numel(values)
        row{end+1} = num2str(values(i),'%.16g'); %#ok<AGROW>
    end
end

function summary = summarizeTrace(trace)
    rate        = zeros(numel(trace),3);
    popRate     = zeros(2,3,numel(trace));
    generated   = zeros(1,3);
    survived    = zeros(1,3);
    genByPop    = zeros(2,3);
    survByPop   = zeros(2,3);
    countByPop  = zeros(2,3);
    feasByPop   = zeros(2,3);
    cvByPop     = zeros(2,3);
    objByPop    = zeros(2,3);

    for i = 1 : numel(trace)
        rate(i,:) = safeVector(trace(i),'rates',[nan,nan,nan]);
        popRate(:,:,i) = safeMatrix(trace(i),'ratesByPop',repmat(rate(i,:),2,1));
        generated = generated + safeVector(trace(i),'generated',[0,0,0]);
        survived  = survived  + safeVector(trace(i),'survived',[0,0,0]);
        genByPop  = genByPop  + safeMatrix(trace(i),'generatedByPop',zeros(2,3));
        survByPop = survByPop + safeMatrix(trace(i),'survivedByPop',zeros(2,3));
        countByPop = countByPop + safeMatrix(trace(i),'creditCount',zeros(2,3));
        feasByPop  = feasByPop  + safeMatrix(trace(i),'feasibleByPop',zeros(2,3));
        cvByPop    = cvByPop    + safeMatrix(trace(i),'cvScoreByPop',zeros(2,3));
        objByPop   = objByPop   + safeMatrix(trace(i),'objScoreByPop',zeros(2,3));
    end

    count = sum(countByPop,1);
    summary.rate        = mean(rate,1,'omitnan');
    summary.popRate     = mean(popRate,3,'omitnan');
    summary.generated   = generated;
    summary.survived    = survived;
    summary.survival    = safeDivide(survived,generated);
    summary.feasible    = safeDivide(sum(feasByPop,1),count);
    summary.cvScore     = safeDivide(sum(cvByPop,1),count);
    summary.objScore    = safeDivide(sum(objByPop,1),count);
    summary.popSurvival = safeDivide(survByPop,genByPop);
    summary.popFeasible = safeDivide(feasByPop,countByPop);
end

function v = safeVector(s,field,defaultValue)
    if isfield(s,field) && ~isempty(s.(field))
        v = reshape(s.(field),1,[]);
        if numel(v) ~= 3
            v = defaultValue;
        end
    else
        v = defaultValue;
    end
end

function m = safeMatrix(s,field,defaultValue)
    if isfield(s,field) && ~isempty(s.(field))
        m = s.(field);
        if ~isequal(size(m),[2,3])
            m = defaultValue;
        end
    else
        m = defaultValue;
    end
end

function out = safeDivide(a,b)
    out = nan(size(a));
    idx = b > 0;
    out(idx) = a(idx)./b(idx);
end

function s = csv(x)
    x = char(string(x));
    x = strrep(x,'"','""');
    s = ['"',x,'"'];
end
