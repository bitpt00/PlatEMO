function cfg = s13_credit_signal_30run_config()
%S13_CREDIT_SIGNAL_30RUN_CONFIG - Credit-signal ablation.

    cfg = s10_external_fast_config();
    cfg.name      = 's13_credit_signal_30run';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S13_credit_signal_30run');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S13_credit_signal_30run',cfg.name);
    cfg.maxFE     = 100000;
    cfg.runs      = 30;
    cfg.seedBase  = 313000;

    cfg.algorithms = [
        algorithmSpec('SCOP-CMOEA','SCOP_CMOEA',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('Equal-AOP','CMOEA_AOP_Lab',{'equal'})
        algorithmSpec('Feasibility-Credit-AOP','CMOEA_AOP_Lab',{'feasibility_credit'})
        algorithmSpec('CV-Credit-AOP','CMOEA_AOP_Lab',{'cv_credit'})
        algorithmSpec('Objective-Credit-AOP','CMOEA_AOP_Lab',{'objective_credit'})
        algorithmSpec('Mixed-Credit-AOP','CMOEA_AOP_Lab',{'mixed_credit'})
        algorithmSpec('Sliding-Survival-Credit-AOP','CMOEA_AOP_Lab',{'sliding_survival_credit'})
    ];
end

function s = algorithmSpec(label,className,parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
