function cfg = s10_external_fast_config()
%S10_EXTERNAL_FAST_CONFIG - External CMOEA comparison for SCOP-CMOEA.

    cfg = s01_discovery_config();
    cfg.name      = 's10_external_fast';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S10_external_comparison');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S10_external_comparison',cfg.name);
    cfg.maxFE     = 100000;
    cfg.runs      = 10;
    cfg.seedBase  = 210000;

    cfg.algorithms = [
        algorithmSpec('SCOP-CMOEA','SCOP_CMOEA',{})
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('DRLOS-EMCMO','DRLOSEMCMO',{})
        algorithmSpec('C-TAEA','CTAEA',{})
        algorithmSpec('PPS','PPS',{})
        algorithmSpec('ToP','ToP',{})
        algorithmSpec('C3M','C3M',{})
        algorithmSpec('BiCo','BiCo',{})
        algorithmSpec('CMOEA-MS','CMOEAMS',{})
    ];

    cfg.problems = [
        problemSpec('CF1','CF')
        problemSpec('CF2','CF')
        problemSpec('CF3','CF')
        problemSpec('CF4','CF')
        problemSpec('CF5','CF')
        problemSpec('CF6','CF')
        problemSpec('CF7','CF')
        problemSpec('CF8','CF')
        problemSpec('CF9','CF')
        problemSpec('CF10','CF')
        problemSpec('LIRCMOP1','LIR-CMOP')
        problemSpec('LIRCMOP2','LIR-CMOP')
        problemSpec('LIRCMOP3','LIR-CMOP')
        problemSpec('LIRCMOP4','LIR-CMOP')
        problemSpec('LIRCMOP5','LIR-CMOP')
        problemSpec('LIRCMOP6','LIR-CMOP')
        problemSpec('LIRCMOP7','LIR-CMOP')
        problemSpec('LIRCMOP8','LIR-CMOP')
        problemSpec('LIRCMOP9','LIR-CMOP')
        problemSpec('LIRCMOP10','LIR-CMOP')
        problemSpec('LIRCMOP11','LIR-CMOP')
        problemSpec('LIRCMOP12','LIR-CMOP')
        problemSpec('LIRCMOP13','LIR-CMOP')
        problemSpec('LIRCMOP14','LIR-CMOP')
        problemSpec('DASCMOP1','DAS-CMOP')
        problemSpec('DASCMOP2','DAS-CMOP')
        problemSpec('DASCMOP3','DAS-CMOP')
        problemSpec('DASCMOP4','DAS-CMOP')
        problemSpec('DASCMOP5','DAS-CMOP')
        problemSpec('DASCMOP6','DAS-CMOP')
        problemSpec('DASCMOP7','DAS-CMOP')
        problemSpec('DASCMOP8','DAS-CMOP')
        problemSpec('DASCMOP9','DAS-CMOP')
        problemSpec('MW1','MW')
        problemSpec('MW2','MW')
        problemSpec('MW3','MW')
        problemSpec('MW4','MW')
        problemSpec('MW5','MW')
        problemSpec('MW6','MW')
        problemSpec('MW7','MW')
        problemSpec('MW8','MW')
        problemSpec('MW9','MW')
        problemSpec('MW10','MW')
        problemSpec('MW11','MW')
        problemSpec('MW12','MW')
        problemSpec('MW13','MW')
        problemSpec('MW14','MW')
        problemSpec('DOC1','DOC')
        problemSpec('DOC2','DOC')
        problemSpec('DOC3','DOC')
        problemSpec('DOC4','DOC')
        problemSpec('DOC5','DOC')
        problemSpec('DOC6','DOC')
        problemSpec('DOC7','DOC')
        problemSpec('DOC8','DOC')
        problemSpec('DOC9','DOC')
    ];
end

function s = algorithmSpec(label,className,parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end

function s = problemSpec(name,suite)
    s = struct('name',name,'suite',suite);
end

