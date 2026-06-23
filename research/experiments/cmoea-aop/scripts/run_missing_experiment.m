function run_missing_experiment(configName,workerIndex,workerCount,maxNewTasks)
%RUN_MISSING_EXPERIMENT Run missing experiment tasks only.
%
%   This repair runner rebuilds the task matrix, filters out existing MAT
%   files, and partitions only the remaining tasks among workers.

    if nargin < 1 || isempty(configName)
        configName = 's01_smoke_config';
    end
    if nargin < 2 || isempty(workerIndex)
        workerIndex = 1;
    end
    if nargin < 3 || isempty(workerCount)
        workerCount = 1;
    end
    if nargin < 4 || isempty(maxNewTasks)
        maxNewTasks = inf;
    end

    rootDir = findRepoRoot();
    setupS01Path(rootDir);
    cfg = feval(str2func(configName));
    if exist(cfg.resultDir,'dir') ~= 7
        mkdir(cfg.resultDir);
    end

    tasks = buildTasks(cfg);
    missing = false(1,numel(tasks));
    for t = 1 : numel(tasks)
        missing(t) = exist(resultFileName(cfg,tasks(t)),'file') ~= 2;
    end
    tasks = tasks(missing);

    logFile = fullfile(cfg.resultDir,sprintf('%s_missing_log_worker%d_of_%d.csv',cfg.name,workerIndex,workerCount));
    writeLogHeader(logFile);

    fprintf('Missing config=%s tasks=%d worker=%d/%d\n',cfg.name,numel(tasks),workerIndex,workerCount);
    newTasks = 0;
    for t = workerIndex : workerCount : numel(tasks)
        task = tasks(t);
        resultFile = resultFileName(cfg,task);
        if exist(resultFile,'file') == 2 && ~cfg.overwrite
            appendLog(logFile,task,'skipped','existing result file',resultFile);
            continue;
        end
        try
            rng(task.seed,'twister');
            Problem = feval(str2func(task.problem),'N',cfg.N,'maxFE',cfg.maxFE);
            algArgs = {'save',0,'run',task.run,'metName',cfg.metrics};
            if ~isempty(task.parameter)
                algArgs = [algArgs,{'parameter'},{task.parameter}];
            end
            Algorithm = feval(str2func(task.algorithmClass),algArgs{:});
            fprintf('[%d/%d missing] %s on %s run=%d seed=%d\n',t,numel(tasks),task.algorithmLabel,task.problem,task.run,task.seed);
            Algorithm.Solve(Problem);

            metadata = task;
            metadata.configName = cfg.name;
            metadata.N          = cfg.N;
            metadata.maxFE      = cfg.maxFE;
            metadata.finishedFE = Problem.FE;
            metadata.runtime    = Algorithm.CalMetric('runtime');
            metadata.timestamp  = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
            result = Algorithm.result;
            metric = Algorithm.metric;
            for i = 1 : numel(cfg.metrics)
                metric.(cfg.metrics{i}) = Algorithm.CalMetric(cfg.metrics{i});
            end
            if isprop(Algorithm,'policyTrace')
                policyTrace = Algorithm.policyTrace;
            else
                policyTrace = [];
            end
            save(resultFile,'result','metric','metadata','policyTrace');
            appendLog(logFile,task,'ok','',resultFile);
            newTasks = newTasks + 1;
        catch err
            appendLog(logFile,task,'error',err.message,resultFile);
            warning('MissingRun:RunFailed','%s on %s run %d failed: %s',task.algorithmLabel,task.problem,task.run,err.message);
            newTasks = newTasks + 1;
        end
        if newTasks >= maxNewTasks
            fprintf('Reached maxNewTasks=%d for missing worker=%d/%d\n',maxNewTasks,workerIndex,workerCount);
            break;
        end
    end
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

function tasks = buildTasks(cfg)
    tasks = struct('algorithmLabel',{},'algorithmClass',{},'parameter',{},'problem',{},'suite',{},'run',{},'seed',{});
    k = 0;
    for a = 1 : numel(cfg.algorithms)
        for p = 1 : numel(cfg.problems)
            for r = 1 : cfg.runs
                k = k + 1;
                tasks(k).algorithmLabel = cfg.algorithms(a).label;
                tasks(k).algorithmClass = cfg.algorithms(a).className;
                tasks(k).parameter      = cfg.algorithms(a).parameter;
                tasks(k).problem        = cfg.problems(p).name;
                tasks(k).suite          = cfg.problems(p).suite;
                tasks(k).run            = r;
                tasks(k).seed           = cfg.seedBase + 10000*a + 100*p + r;
            end
        end
    end
end

function file = resultFileName(cfg,task)
    safeAlg = regexprep(task.algorithmLabel,'[^A-Za-z0-9]+','_');
    file = fullfile(cfg.resultDir,sprintf('%s_%s_N%d_FE%d_run%d_seed%d.mat',safeAlg,task.problem,cfg.N,cfg.maxFE,task.run,task.seed));
end

function writeLogHeader(logFile)
    if exist(logFile,'file') ~= 2
        fid = fopen(logFile,'w');
        fprintf(fid,'algorithm,problem,run,seed,status,message,file\n');
        fclose(fid);
    end
end

function appendLog(logFile,task,status,message,file)
    fid = fopen(logFile,'a');
    fprintf(fid,'%s,%s,%d,%d,%s,%s,%s\n',csv(task.algorithmLabel),csv(task.problem),task.run,task.seed,csv(status),csv(message),csv(file));
    fclose(fid);
end

function s = csv(x)
    if isnumeric(x)
        x = num2str(x);
    end
    x = char(string(x));
    x = strrep(x,'"','""');
    s = ['"',x,'"'];
end
