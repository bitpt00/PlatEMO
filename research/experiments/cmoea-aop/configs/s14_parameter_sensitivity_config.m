function cfg = s14_parameter_sensitivity_config()
%S14_PARAMETER_SENSITIVITY_CONFIG - SCOP alpha/floor sensitivity.

    cfg = s01_smoke_config();
    cfg.name      = 's14_parameter_sensitivity';
    cfg.studyDir  = fullfile(cfg.experimentDir,'studies','S14_parameter_sensitivity');
    cfg.resultDir = fullfile(cfg.experimentDir,'results','S14_parameter_sensitivity',cfg.name);
    cfg.maxFE     = 100000;
    cfg.runs      = 20;
    cfg.seedBase  = 314000;

    rates = [1/3,1/3,1/3];
    cfg.algorithms = [
        algorithmSpec('SCOP-a012-f000','CMOEA_AOP_Lab',{'survival_credit',rates,0.12,0.00})
        algorithmSpec('SCOP-a012-f003','CMOEA_AOP_Lab',{'survival_credit',rates,0.12,0.03})
        algorithmSpec('SCOP-a012-f005','CMOEA_AOP_Lab',{'survival_credit',rates,0.12,0.05})
        algorithmSpec('SCOP-a012-f010','CMOEA_AOP_Lab',{'survival_credit',rates,0.12,0.10})
        algorithmSpec('SCOP-a025-f000','CMOEA_AOP_Lab',{'survival_credit',rates,0.25,0.00})
        algorithmSpec('SCOP-a025-f003','CMOEA_AOP_Lab',{'survival_credit',rates,0.25,0.03})
        algorithmSpec('SCOP-a025-f005','CMOEA_AOP_Lab',{'survival_credit',rates,0.25,0.05})
        algorithmSpec('SCOP-a025-f010','CMOEA_AOP_Lab',{'survival_credit',rates,0.25,0.10})
        algorithmSpec('SCOP-a035-f000','CMOEA_AOP_Lab',{'survival_credit',rates,0.35,0.00})
        algorithmSpec('SCOP-a035-f003','CMOEA_AOP_Lab',{'survival_credit',rates,0.35,0.03})
        algorithmSpec('SCOP-a035-f005','CMOEA_AOP_Lab',{'survival_credit',rates,0.35,0.05})
        algorithmSpec('SCOP-a035-f010','CMOEA_AOP_Lab',{'survival_credit',rates,0.35,0.10})
        algorithmSpec('SCOP-a050-f000','CMOEA_AOP_Lab',{'survival_credit',rates,0.50,0.00})
        algorithmSpec('SCOP-a050-f003','CMOEA_AOP_Lab',{'survival_credit',rates,0.50,0.03})
        algorithmSpec('SCOP-a050-f005','CMOEA_AOP_Lab',{'survival_credit',rates,0.50,0.05})
        algorithmSpec('SCOP-a050-f010','CMOEA_AOP_Lab',{'survival_credit',rates,0.50,0.10})
    ];

    cfg.problems = [
        problemSpec('CF3','CF')
        problemSpec('CF6','CF')
        problemSpec('CF8','CF')
        problemSpec('LIRCMOP3','LIR-CMOP')
        problemSpec('LIRCMOP10','LIR-CMOP')
        problemSpec('LIRCMOP13','LIR-CMOP')
        problemSpec('DASCMOP1','DAS-CMOP')
        problemSpec('DASCMOP5','DAS-CMOP')
        problemSpec('DASCMOP8','DAS-CMOP')
        problemSpec('DOC4','DOC')
        problemSpec('DOC6','DOC')
        problemSpec('DOC8','DOC')
        problemSpec('MW5','MW')
        problemSpec('MW9','MW')
        problemSpec('MW12','MW')
    ];
end

function s = algorithmSpec(label,className,parameter)
    s = struct('label',label,'className',className,'parameter',{parameter});
end

function s = problemSpec(name,suite)
    s = struct('name',name,'suite',suite);
end
