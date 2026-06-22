function cfg = s02_controller_fast_config()
%S02_CONTROLLER_FAST_CONFIG - Fast controller-family comparison on the paper suite.

    cfg = s01_discovery_config();
    cfg.name      = 's02_controller_fast';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S02_controller_family');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S02_controller_family',cfg.name);
    cfg.maxFE     = 20000;
    cfg.runs      = 3;
    cfg.seedBase  = 202000;

    cfg.algorithms = [
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('Equal-AOP','CMOEA_AOP_Lab',{'equal'})
        algorithmSpec('Random-AOP','CMOEA_AOP_Lab',{'random'})
        algorithmSpec('Stage-AOP','CMOEA_AOP_Lab',{'stage'})
        algorithmSpec('Survival-Credit-AOP','CMOEA_AOP_Lab',{'survival_credit'})
    ];
end

function s = algorithmSpec(label, className, parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
