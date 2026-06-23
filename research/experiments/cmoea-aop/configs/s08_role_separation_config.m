function cfg = s08_role_separation_config()
%S08_ROLE_SEPARATION_CONFIG - Stronger role-separated credit exploration.

    cfg = s01_discovery_config();
    cfg.name      = 's08_role_separation';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S08_role_separation');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S08_role_separation',cfg.name);
    cfg.maxFE     = 50000;
    cfg.runs      = 5;
    cfg.seedBase  = 208000;

    cfg.algorithms = [
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('Equal-AOP','CMOEA_AOP_Lab',{'equal'})
        algorithmSpec('Survival-Credit-AOP','CMOEA_AOP_Lab',{'survival_credit'})
        algorithmSpec('Dual-Survival-Credit-AOP','CMOEA_AOP_Lab',{'dual_survival_credit'})
        algorithmSpec('Dual-Role-Credit-AOP-v2','CMOEA_AOP_Lab',{'dual_role_credit_v2'})
        algorithmSpec('Dual-Role-Credit-AOP-v3','CMOEA_AOP_Lab',{'dual_role_credit_v3'})
        algorithmSpec('Role-Separated-Credit-AOP-v1','CMOEA_AOP_Lab',{'role_separated_credit_v1'})
        algorithmSpec('Role-Separated-Credit-AOP-v2','CMOEA_AOP_Lab',{'role_separated_credit_v2'})
        algorithmSpec('Role-Separated-Credit-AOP-v3','CMOEA_AOP_Lab',{'role_separated_credit_v3'})
        algorithmSpec('Role-Separated-Credit-AOP-v4','CMOEA_AOP_Lab',{'role_separated_credit_v4'})
    ];
end

function s = algorithmSpec(label, className, parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
