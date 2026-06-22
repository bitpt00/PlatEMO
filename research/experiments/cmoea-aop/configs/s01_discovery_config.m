function cfg = s01_discovery_config()
%S01_DISCOVERY_CONFIG - First mechanism-discovery matrix.

    cfg = s01_smoke_config();
    cfg.name      = 's01_discovery_fast';
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S01_static_portfolios',cfg.name);
    cfg.maxFE     = 20000;
    cfg.runs      = 3;
    cfg.seedBase  = 102000;
    cfg.problems = [
        problemSpec('CF2','CF')
        problemSpec('CF6','CF')
        problemSpec('CF9','CF')
        problemSpec('LIRCMOP3','LIR-CMOP')
        problemSpec('LIRCMOP4','LIR-CMOP')
        problemSpec('LIRCMOP12','LIR-CMOP')
        problemSpec('DASCMOP1','DAS-CMOP')
        problemSpec('DASCMOP8','DAS-CMOP')
    ];
end

function s = problemSpec(name, suite)
    s = struct('name',name,'suite',suite);
end
