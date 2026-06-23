function cfg = s09_biscop_confirmation_config()
%S09_BISCOP_CONFIRMATION_CONFIG - BiSCOP-CMOEA confirmation and ablation.

    cfg = s01_discovery_config();
    cfg.name      = 's09_biscop_confirmation';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S09_biscop_confirmation');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S09_biscop_confirmation',cfg.name);
    cfg.maxFE     = 100000;
    cfg.runs      = 10;
    cfg.seedBase  = 209000;

    cfg.algorithms = [
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('Equal-AOP','CMOEA_AOP_Lab',{'equal'})
        algorithmSpec('Random-AOP','CMOEA_AOP_Lab',{'random'})
        algorithmSpec('Stage-AOP','CMOEA_AOP_Lab',{'stage'})
        algorithmSpec('Survival-Credit-AOP','CMOEA_AOP_Lab',{'survival_credit'})
        algorithmSpec('Dual-Survival-Credit-AOP','CMOEA_AOP_Lab',{'dual_survival_credit'})
        algorithmSpec('Role-Separated-Credit-AOP-v1','CMOEA_AOP_Lab',{'role_separated_credit_v1'})
        algorithmSpec('Role-Separated-Credit-AOP-v2','CMOEA_AOP_Lab',{'role_separated_credit_v2'})
        algorithmSpec('BiSCOP-CMOEA','CMOEA_AOP_Lab',{'biscop_cmoea'})
    ];
end

function s = algorithmSpec(label, className, parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
