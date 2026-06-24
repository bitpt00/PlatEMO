function cfg = s11_main_30run_config()
%S11_MAIN_30RUN_CONFIG - Final 30-run main comparison for SCOP-CMOEA.

    cfg = s10_external_fast_config();
    cfg.name      = 's11_main_30run';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S11_main_30run');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S11_main_30run',cfg.name);
    cfg.maxFE     = 100000;
    cfg.runs      = 30;
    cfg.seedBase  = 311000;

    cfg.algorithms = [
        algorithmSpec('SCOP-CMOEA','SCOP_CMOEA',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('ICMA','ICMA',{})
        algorithmSpec('IMTCMO','IMTCMO',{})
        algorithmSpec('DRLOS-EMCMO','DRLOSEMCMO',{})
        algorithmSpec('CMOES','CMOES',{})
        algorithmSpec('DPCPRA','DPCPRA',{})
        algorithmSpec('PPS','PPS',{})
        algorithmSpec('C-TAEA','CTAEA',{})
    ];
end

function s = algorithmSpec(label,className,parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
