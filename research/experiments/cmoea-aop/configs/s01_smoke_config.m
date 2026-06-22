function cfg = s01_smoke_config()
%S01_SMOKE_CONFIG - Minimal S01 validation matrix.

    cfg.name          = 's01_smoke';
    cfg.rootDir       = fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))));
    cfg.experimentDir = fullfile(cfg.rootDir,'research','experiments','cmoea-aop');
    cfg.studyDir      = fullfile(cfg.experimentDir,'studies','S01_static_portfolios');
    cfg.resultDir     = fullfile(cfg.experimentDir,'results','S01_static_portfolios',cfg.name);
    cfg.metrics       = {'IGD','HV','Feasible_rate'};
    cfg.saveRaw       = true;
    cfg.overwrite     = false;
    cfg.N             = 100;
    cfg.maxFE         = 5000;
    cfg.runs          = 1;
    cfg.seedBase      = 101000;

    cfg.algorithms = [
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('GA-only','CMOEA_AOP_Lab',{'ga_only'})
        algorithmSpec('DE-rand-only','CMOEA_AOP_Lab',{'de_rand_only'})
        algorithmSpec('DE-best-only','CMOEA_AOP_Lab',{'de_best_only'})
        algorithmSpec('Equal-AOP','CMOEA_AOP_Lab',{'equal'})
        algorithmSpec('GA-heavy','CMOEA_AOP_Lab',{'ga_heavy'})
        algorithmSpec('DE-rand-heavy','CMOEA_AOP_Lab',{'de_rand_heavy'})
        algorithmSpec('DE-best-heavy','CMOEA_AOP_Lab',{'de_best_heavy'})
        algorithmSpec('GA+DE-rand','CMOEA_AOP_Lab',{'ga_de_rand'})
        algorithmSpec('GA+DE-best','CMOEA_AOP_Lab',{'ga_de_best'})
        algorithmSpec('DE-rand+DE-best','CMOEA_AOP_Lab',{'de_rand_de_best'})
    ];

    cfg.problems = [
        problemSpec('CF1','CF')
        problemSpec('LIRCMOP1','LIR-CMOP')
        problemSpec('DASCMOP1','DAS-CMOP')
    ];
end

function s = algorithmSpec(label, className, parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end

function s = problemSpec(name, suite)
    s = struct('name',name,'suite',suite);
end
