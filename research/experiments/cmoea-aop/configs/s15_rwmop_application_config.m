function cfg = s15_rwmop_application_config()
%S15_RWMOP_APPLICATION_CONFIG - Real-world RWMOP application check.

    cfg = s01_smoke_config();
    cfg.name      = 's15_rwmop_application';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S15_rwmop_application');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S15_rwmop_application',cfg.name);
    cfg.metrics   = {'HV','Feasible_rate'};
    cfg.maxFE     = 100000;
    cfg.runs      = 30;
    cfg.seedBase  = 315000;

    cfg.algorithms = [
        algorithmSpec('SCOP-CMOEA','SCOP_CMOEA',{})
        algorithmSpec('CMOEA-AOP','CMOEAAOP',{})
        algorithmSpec('EMCMO','EMCMO',{})
        algorithmSpec('ICMA','ICMA',{})
        algorithmSpec('IMTCMO','IMTCMO',{})
        algorithmSpec('DRLOS-EMCMO','DRLOSEMCMO',{})
        algorithmSpec('DPCPRA','DPCPRA',{})
        algorithmSpec('PPS','PPS',{})
    ];

    cfg.problems = [
        problemSpec('RWMOP1','RWMOP')
        problemSpec('RWMOP2','RWMOP')
        problemSpec('RWMOP3','RWMOP')
        problemSpec('RWMOP4','RWMOP')
        problemSpec('RWMOP5','RWMOP')
        problemSpec('RWMOP6','RWMOP')
        problemSpec('RWMOP7','RWMOP')
        problemSpec('RWMOP8','RWMOP')
        problemSpec('RWMOP9','RWMOP')
        problemSpec('RWMOP10','RWMOP')
        problemSpec('RWMOP11','RWMOP')
        problemSpec('RWMOP12','RWMOP')
        problemSpec('RWMOP13','RWMOP')
        problemSpec('RWMOP14','RWMOP')
        problemSpec('RWMOP15','RWMOP')
        problemSpec('RWMOP16','RWMOP')
        problemSpec('RWMOP17','RWMOP')
        problemSpec('RWMOP18','RWMOP')
        problemSpec('RWMOP19','RWMOP')
        problemSpec('RWMOP20','RWMOP')
    ];
end

function s = algorithmSpec(label,className,parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end

function s = problemSpec(name,suite)
    s = struct('name',name,'suite',suite);
end
