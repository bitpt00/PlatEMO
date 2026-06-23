function cfg = s07_dual_role_credit_config()
%S07_DUAL_ROLE_CREDIT_CONFIG - Role-aware dual-population credit variants.

    cfg = s01_discovery_config();
    cfg.name      = 's07_dual_role_credit';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S07_dual_role_credit');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S07_dual_role_credit',cfg.name);
    cfg.maxFE     = 50000;
    cfg.runs      = 5;
    cfg.seedBase  = 207000;

    cfg.algorithms = [
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('Equal-AOP','CMOEA_AOP_Lab',{'equal'})
        algorithmSpec('Survival-Credit-AOP','CMOEA_AOP_Lab',{'survival_credit'})
        algorithmSpec('Objective-Credit-AOP','CMOEA_AOP_Lab',{'objective_credit'})
        algorithmSpec('Dual-Survival-Credit-AOP','CMOEA_AOP_Lab',{'dual_survival_credit'})
        algorithmSpec('Dual-Role-Credit-AOP-v1','CMOEA_AOP_Lab',{'dual_role_credit_v1'})
        algorithmSpec('Dual-Role-Credit-AOP-v2','CMOEA_AOP_Lab',{'dual_role_credit_v2'})
        algorithmSpec('Dual-Role-Credit-AOP-v3','CMOEA_AOP_Lab',{'dual_role_credit_v3'})
    ];
end

function s = algorithmSpec(label, className, parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
