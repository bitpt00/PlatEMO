function cfg = s03_credit_fast_config()
%S03_CREDIT_FAST_CONFIG - Fast credit-signal comparison on the paper suite.

    cfg = s01_discovery_config();
    cfg.name      = 's03_credit_fast';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S03_credit_signal');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S03_credit_signal',cfg.name);
    cfg.maxFE     = 20000;
    cfg.runs      = 3;
    cfg.seedBase  = 203000;

    cfg.algorithms = [
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('Equal-AOP','CMOEA_AOP_Lab',{'equal'})
        algorithmSpec('Survival-Credit-AOP','CMOEA_AOP_Lab',{'survival_credit'})
        algorithmSpec('Feasibility-Credit-AOP','CMOEA_AOP_Lab',{'feasibility_credit'})
        algorithmSpec('CV-Credit-AOP','CMOEA_AOP_Lab',{'cv_credit'})
        algorithmSpec('Objective-Credit-AOP','CMOEA_AOP_Lab',{'objective_credit'})
        algorithmSpec('Mixed-Credit-AOP','CMOEA_AOP_Lab',{'mixed_credit'})
        algorithmSpec('Sliding-Survival-Credit-AOP','CMOEA_AOP_Lab',{'sliding_survival_credit'})
    ];
end

function s = algorithmSpec(label, className, parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
