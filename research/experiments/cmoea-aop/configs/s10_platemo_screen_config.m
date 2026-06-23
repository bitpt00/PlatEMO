function cfg = s10_platemo_screen_config()
%S10_PLATEMO_SCREEN_CONFIG - Local PlatEMO baseline screening for SCOP-CMOEA.

    cfg = s10_external_fast_config();
    cfg.name      = 's10_platemo_screen';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S10_external_comparison');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S10_external_comparison',cfg.name);
    cfg.runs      = 5;
    cfg.seedBase  = 211000;

    cfg.algorithms = [
        algorithmSpec('SCOP-CMOEA','SCOP_CMOEA',{})
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('DRLOS-EMCMO','DRLOSEMCMO',{})
        algorithmSpec('BiCo','BiCo',{})
        algorithmSpec('AGE-MOEA-II','AGEMOEAII',{})
        algorithmSpec('TSTI','TSTI',{})
        algorithmSpec('C-TAEA','CTAEA',{})
        algorithmSpec('PPS','PPS',{})
        algorithmSpec('ToP','ToP',{})
        algorithmSpec('C3M','C3M',{})
        algorithmSpec('CCMO','CCMO',{})
        algorithmSpec('CMOEA-MS','CMOEAMS',{})
        algorithmSpec('CMOES','CMOES',{})
        algorithmSpec('CAEAD','CAEAD',{})
        algorithmSpec('APSEA','APSEA',{})
        algorithmSpec('CMOEMT','CMOEMT',{})
        algorithmSpec('MTCMO','MTCMO',{})
        algorithmSpec('ICMA','ICMA',{})
        algorithmSpec('IMTCMO','IMTCMO',{})
        algorithmSpec('DPCPRA','DPCPRA',{})
        algorithmSpec('PRCEA','PRCEA',{})
    ];
end

function s = algorithmSpec(label,className,parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end
