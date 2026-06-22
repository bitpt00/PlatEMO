function cfg = s06_mechanism_config()
%S06_MECHANISM_CONFIG - Diagnostic trace runs for mechanism interpretation.

    cfg = s01_discovery_config();
    cfg.name      = 's06_mechanism';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S06_mechanism_diagnosis');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S06_mechanism_diagnosis',cfg.name);
    cfg.maxFE     = 50000;
    cfg.runs      = 3;
    cfg.seedBase  = 206000;

    cfg.algorithms = [
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('CMOEA-AOP-Trace','CMOEA_AOP_DDPG_Trace',{})
        algorithmSpec('Equal-AOP','CMOEA_AOP_Lab',{'equal'})
        algorithmSpec('Stage-AOP','CMOEA_AOP_Lab',{'stage'})
        algorithmSpec('Survival-Credit-AOP','CMOEA_AOP_Lab',{'survival_credit'})
        algorithmSpec('Objective-Credit-AOP','CMOEA_AOP_Lab',{'objective_credit'})
        algorithmSpec('Dual-Survival-Credit-AOP','CMOEA_AOP_Lab',{'dual_survival_credit'})
        algorithmSpec('Dual-Feasibility-Explore-AOP','CMOEA_AOP_Lab',{'dual_feasibility_explore'})
    ];
end

function s = algorithmSpec(label, className, parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
