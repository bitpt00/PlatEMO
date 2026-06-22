function summarize_s01_results(configName)
%SUMMARIZE_S01_RESULTS Write compact S01 final metrics to runs.csv.

    if nargin < 1 || isempty(configName)
        configName = 's01_smoke_config';
    end
    rootDir = findRepoRoot();
    setupS01Path(rootDir);
    cfg = feval(str2func(configName));
    files = dir(fullfile(cfg.resultDir,'*.mat'));
    rows = {};
    for i = 1 : numel(files)
        data = load(fullfile(files(i).folder,files(i).name),'metric','metadata');
        rows(end+1,:) = makeRow(data.metadata,data.metric,files(i).name,cfg.metrics); %#ok<AGROW>
    end

    outFile = fullfile(cfg.studyDir,'runs.csv');
    fid = fopen(outFile,'w');
    fprintf(fid,'config,algorithm,problem,suite,N,maxFE,run,seed,finishedFE,runtime');
    for i = 1 : numel(cfg.metrics)
        fprintf(fid,',%s',cfg.metrics{i});
    end
    fprintf(fid,',file\n');
    for i = 1 : size(rows,1)
        fprintf(fid,'%s\n',strjoin(rows(i,:),','));
    end
    fclose(fid);

    fprintf('Wrote %d rows to %s\n',size(rows,1),outFile);
end

function rootDir = findRepoRoot()
    here = fileparts(mfilename('fullpath'));
    rootDir = fileparts(fileparts(fileparts(fileparts(here))));
end

function setupS01Path(rootDir)
    restoredefaultpath;
    addpath(fullfile(rootDir,'PlatEMO'));
    addpath(genpath(fullfile(rootDir,'PlatEMO','Algorithms')));
    addpath(genpath(fullfile(rootDir,'PlatEMO','Metrics')));
    addpath(genpath(fullfile(rootDir,'PlatEMO','Problems')));
    addpath(fullfile(rootDir,'research','experiments','cmoea-aop','configs'));
    addpath(fullfile(rootDir,'research','experiments','cmoea-aop','scripts'));
end

function row = makeRow(metadata,metric,fileName,metricNames)
    row = {
        csv(metadata.configName)
        csv(metadata.algorithmLabel)
        csv(metadata.problem)
        csv(metadata.suite)
        num2str(metadata.N)
        num2str(metadata.maxFE)
        num2str(metadata.run)
        num2str(metadata.seed)
        num2str(metadata.finishedFE)
        num2str(metadata.runtime)
    };
    for i = 1 : numel(metricNames)
        name = metricNames{i};
        if isfield(metric,name) && ~isempty(metric.(name))
            value = metric.(name);
            row{end+1} = num2str(value(end),'%.16g'); %#ok<AGROW>
        else
            row{end+1} = ''; %#ok<AGROW>
        end
    end
    row{end+1} = csv(fileName);
end

function s = csv(x)
    x = char(string(x));
    x = strrep(x,'"','""');
    s = ['"',x,'"'];
end
