function cfg = s01_discovery_config()
%S01_DISCOVERY_CONFIG - Paper-suite mechanism-discovery matrix.

    cfg = s01_smoke_config();
    cfg.name      = 's01_discovery_fast';
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S01_static_portfolios',cfg.name);
    cfg.maxFE     = 20000;
    cfg.runs      = 3;
    cfg.seedBase  = 102000;
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
    ];
end

function s = problemSpec(name, suite)
    s = struct('name',name,'suite',suite);
end
