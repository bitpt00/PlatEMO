function cfg = s05_confirmation_config()
%S05_CONFIRMATION_CONFIG - Candidate confirmation on the paper suite.

    cfg = s01_discovery_config();
    cfg.name      = 's05_confirmation';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S05_candidate_confirmation');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S05_candidate_confirmation',cfg.name);
    cfg.maxFE     = 50000;
    cfg.runs      = 5;
    cfg.seedBase  = 205000;

    cfg.algorithms = [
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
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
