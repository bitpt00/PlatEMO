function cfg = s12_portfolio_ablation_30run_config()
%S12_PORTFOLIO_ABLATION_30RUN_CONFIG - Portfolio-policy ablation.

    cfg = s10_external_fast_config();
    cfg.name      = 's12_portfolio_ablation_30run';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S12_portfolio_ablation_30run');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S12_portfolio_ablation_30run',cfg.name);
    cfg.maxFE     = 100000;
    cfg.runs      = 30;
    cfg.seedBase  = 312000;

    cfg.algorithms = [
        algorithmSpec('SCOP-CMOEA','SCOP_CMOEA',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('GA-only','CMOEA_AOP_Lab',{'ga_only'})
        algorithmSpec('DE-rand-only','CMOEA_AOP_Lab',{'de_rand_only'})
        algorithmSpec('DE-best-only','CMOEA_AOP_Lab',{'de_best_only'})
        algorithmSpec('Equal-AOP','CMOEA_AOP_Lab',{'equal'})
        algorithmSpec('Random-AOP','CMOEA_AOP_Lab',{'random'})
        algorithmSpec('Stage-AOP','CMOEA_AOP_Lab',{'stage'})
    ];
end

function s = algorithmSpec(label,className,parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
