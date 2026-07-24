function cfg = s16_reference_baseline_30run_config()
%S16_REFERENCE_BASELINE_30RUN_CONFIG - Supplementary reference baselines.

    cfg = s10_external_fast_config();
    cfg.name      = 's16_reference_baseline_30run';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S16_reference_baseline_30run');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S16_reference_baseline_30run',cfg.name);
    cfg.maxFE     = 100000;
    cfg.runs      = 30;
    cfg.seedBase  = 316000;

    cfg.algorithms = [
        algorithmSpec('BiCo','BiCo',{})
        algorithmSpec('ToP','ToP',{})
        algorithmSpec('CMOEA-MS','CMOEAMS',{})
        algorithmSpec('C3M','C3M',{})
        algorithmSpec('TSTI','TSTI',{})
        algorithmSpec('AGE-MOEA-II','AGEMOEAII',{})
    ];
end

function s = algorithmSpec(label,className,parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
