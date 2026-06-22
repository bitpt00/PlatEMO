function cfg = s04_dual_population_fast_config()
%S04_DUAL_POPULATION_FAST_CONFIG - Fast dual-population portfolio comparison.

    cfg = s01_discovery_config();
    cfg.name      = 's04_dual_population_fast';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S04_dual_population_portfolio');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S04_dual_population_portfolio',cfg.name);
    cfg.maxFE     = 20000;
    cfg.runs      = 3;
    cfg.seedBase  = 204000;

    cfg.algorithms = [
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('Equal-AOP','CMOEA_AOP_Lab',{'equal'})
        algorithmSpec('Dual-Static-Split-AOP','CMOEA_AOP_Lab',{'dual_static_split'})
        algorithmSpec('Dual-Feasibility-Explore-AOP','CMOEA_AOP_Lab',{'dual_feasibility_explore'})
        algorithmSpec('Dual-Survival-Credit-AOP','CMOEA_AOP_Lab',{'dual_survival_credit'})
        algorithmSpec('Dual-Mixed-Credit-AOP','CMOEA_AOP_Lab',{'dual_mixed_credit'})
    ];
end

function s = algorithmSpec(label, className, parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
