classdef CMOEA_AOP_DDPG_Trace < ALGORITHM
% <2026> <multi> <real/integer/label/binary/permutation> <constrained>
% Behavior-equivalent CMOEA-AOP copy with diagnostic policy tracing.

    properties
        policyTrace;
    end
    methods
        function main(Algorithm,Problem)
            Population{1}  = Problem.Initialization();
            Population{2}  = Problem.Initialization();
            Fitness{1}     = TraceCalFitness(Population{1}.objs,Population{1}.cons);
            Fitness{2}     = TraceCalFitness(Population{2}.objs);
            transfer_state = 0;
            cnt            = 0;

            state_dim    = Problem.M*2 + 2;
            action_dim   = 3;
            action_bound = 5;
            minnumber    = 1e-5;

            state1 = GenerateSample(Problem,rand(1,action_dim),Population{1},Population{1});
            agent  = DDPG(state_dim,action_dim,action_bound);
            Algorithm.policyTrace = struct('FE',{},'progress',{},'policy',{},'rates',{},'ratesByPop',{}, ...
                'generated',{},'survived',{},'generatedByPop',{},'survivedByPop',{}, ...
                'creditCount',{},'feasibleByPop',{},'cvScoreByPop',{},'objScoreByPop',{});

            %% Optimization
            while Algorithm.NotTerminated(Population{1})
                action = agent.selectAction(state1,true);
                action = (action+action_bound) / sum(action+action_bound+minnumber);
                cnt    = cnt + 1;
                LastPopulation1 = Population{1};
                generated       = zeros(1,3);
                survived        = zeros(1,3);
                generatedByPop  = zeros(2,3);
                survivedByPop   = zeros(2,3);
                creditObs       = TraceInitCreditObservation();

                if transfer_state == 0
                    for i = 1 : 2
                        [valOffspring{i},source{i},counts{i}] = TraceOperatorConstrainedAOP(Problem,Population,randperm(Problem.N,Problem.N),action,i);
                        generated = generated + counts{i};
                        generatedByPop(i,:) = generatedByPop(i,:) + counts{i};
                        creditObs = TraceObserveOffspring(creditObs,i,source{i},valOffspring{i});
                    end
                    for i = 1 : 2
                        if i == 1
                            combined = [Population{1},valOffspring{1},valOffspring{2}];
                        else
                            combined = [Population{2},valOffspring{2},valOffspring{1}];
                        end
                        ownStart = Problem.N + 1;
                        ownEnd   = Problem.N + length(source{i});
                        [Population{i},Fitness{i},Next] = TraceEnvironmentalSelection(combined,Problem.N,i);
                        ownSurvived = TraceSurvivalBySource(source{i},Next(ownStart:ownEnd));
                        survived = survived + ownSurvived;
                        survivedByPop(i,:) = survivedByPop(i,:) + ownSurvived;
                    end
                    if Problem.FE/Problem.maxFE >= 0.2
                        transfer_state = 1;
                    end
                else
                    for i = 1 : 2
                        MatingPool = TournamentSelection(2,Problem.N,Fitness{i});
                        [valOffspring{i},source{i},counts{i}] = TraceOperatorConstrainedAOP(Problem,Population,MatingPool,action,i);
                        generated = generated + counts{i};
                        generatedByPop(i,:) = generatedByPop(i,:) + counts{i};
                        creditObs = TraceObserveOffspring(creditObs,i,source{i},valOffspring{i});
                    end
                    [~,~,Next]       = TraceEnvironmentalSelection([Population{2},valOffspring{2}],Problem.N,1);
                    succ_rate(1,cnt) = (sum(Next(1:Problem.N))/100) - (sum(Next(Problem.N+1:end))/50);

                    [~,~,Next]       = TraceEnvironmentalSelection([Population{1},valOffspring{1}],Problem.N,2);
                    succ_rate(2,cnt) = (sum(Next(1:Problem.N))/100) - (sum(Next(Problem.N+1:end))/50);

                    for i = 1 : 2
                        if succ_rate(i,cnt) > 0
                            rand_number = randperm(Problem.N);
                            combined = [Population{i},valOffspring{i},Population{2/i}(rand_number(1:Problem.N/2))];
                        else
                            combined = [Population{i},valOffspring{i},valOffspring{2/i}];
                        end
                        ownStart = Problem.N + 1;
                        ownEnd   = Problem.N + length(source{i});
                        [Population{i},Fitness{i},Next] = TraceEnvironmentalSelection(combined,Problem.N,i);
                        ownSurvived = TraceSurvivalBySource(source{i},Next(ownStart:ownEnd));
                        survived = survived + ownSurvived;
                        survivedByPop(i,:) = survivedByPop(i,:) + ownSurvived;
                    end
                end

                Algorithm.policyTrace(cnt).FE        = Problem.FE;
                Algorithm.policyTrace(cnt).progress  = Problem.FE/Problem.maxFE;
                Algorithm.policyTrace(cnt).policy    = 'ddpg_aop_trace';
                Algorithm.policyTrace(cnt).rates     = TraceNormalizeRates(action);
                Algorithm.policyTrace(cnt).ratesByPop = repmat(TraceNormalizeRates(action),2,1);
                Algorithm.policyTrace(cnt).generated = generated;
                Algorithm.policyTrace(cnt).survived  = survived;
                Algorithm.policyTrace(cnt).generatedByPop = generatedByPop;
                Algorithm.policyTrace(cnt).survivedByPop  = survivedByPop;
                Algorithm.policyTrace(cnt).creditCount    = creditObs.count;
                Algorithm.policyTrace(cnt).feasibleByPop  = creditObs.feasible;
                Algorithm.policyTrace(cnt).cvScoreByPop   = creditObs.cvScore;
                Algorithm.policyTrace(cnt).objScoreByPop  = creditObs.objScore;

                [state1,action1,nextstate1,ter,reward1] = GenerateSample(Problem,action,LastPopulation1,Population{1});
                agent.store(state1,action1,reward1,nextstate1,ter);
                agent.train();
            end
        end
    end
end

function [Offspring,source,counts] = TraceOperatorConstrainedAOP(Problem, Population, MatingPool, action, i)
    counts = floor(action.*Problem.N);
    for item = 1 : length(action)
        if counts(item) < 4
            counts(item) = 4;
        end
    end
    MatingPool = repmat(MatingPool,1,20);
    Offspring1 = OperatorGAhalf(Problem,Population{i}(MatingPool(1:counts(1)*2)));
    Offspring2 = OperatorDE(Problem,Population{i}(randi(ceil(Problem.N),1,counts(2))),Population{i}(randi(ceil(Problem.N),1,counts(2))),Population{i}(randi(ceil(Problem.N),1,counts(2))));
    p3         = Population{i};
    Offspring3 = TraceDEBest(Problem,p3(randi(ceil(Problem.N),1,counts(3))),counts(3));
    Offspring  = [Offspring1 Offspring2 Offspring3];
    source     = [ones(1,length(Offspring1)),2*ones(1,length(Offspring2)),3*ones(1,length(Offspring3))];
end

function obs = TraceInitCreditObservation()
    obs.count     = zeros(2,3);
    obs.feasible  = zeros(2,3);
    obs.cvScore   = zeros(2,3);
    obs.objScore  = zeros(2,3);
end

function Fitness = TraceCalFitness(PopObj,PopCon)
    N = size(PopObj,1);
    if nargin == 1
        CV = zeros(N,1);
    else
        CV = sum(max(0,PopCon),2);
    end
    Dominate = false(N);
    for i = 1 : N-1
        for j = i+1 : N
            if CV(i) < CV(j)
                Dominate(i,j) = true;
            elseif CV(i) > CV(j)
                Dominate(j,i) = true;
            else
                k = any(PopObj(i,:)<PopObj(j,:)) - any(PopObj(i,:)>PopObj(j,:));
                if k == 1
                    Dominate(i,j) = true;
                elseif k == -1
                    Dominate(j,i) = true;
                end
            end
        end
    end
    S = sum(Dominate,2);
    R = zeros(1,N);
    for i = 1 : N
        R(i) = sum(S(Dominate(:,i)));
    end
    Distance = pdist2(PopObj,PopObj);
    Distance(logical(eye(length(Distance)))) = inf;
    Distance = sort(Distance,2);
    D = 1./(Distance(:,floor(sqrt(N)))+2);
    Fitness = R + D';
end

function [Population,Fitness,Next] = TraceEnvironmentalSelection(Population,N,isOrigin)
    if isOrigin == 1
        Fitness = TraceCalFitness(Population.objs,Population.cons);
    else
        Fitness = TraceCalFitness(Population.objs);
    end
    Next = Fitness < 1;
    if sum(Next) < N
        [~,Rank] = sort(Fitness);
        Next(Rank(1:N)) = true;
    elseif sum(Next) > N
        Del  = TraceTruncation(Population(Next).objs,sum(Next)-N);
        Temp = find(Next);
        Next(Temp(Del)) = false;
    end
    Population = Population(Next);
    Fitness    = Fitness(Next);
    [Fitness,rank] = sort(Fitness);
    Population = Population(rank);
end

function Del = TraceTruncation(PopObj,K)
    Distance = pdist2(PopObj,PopObj);
    Distance(logical(eye(length(Distance)))) = inf;
    Del = false(1,size(PopObj,1));
    while sum(Del) < K
        Remain   = find(~Del);
        Temp     = sort(Distance(Remain,Remain),2);
        [~,Rank] = sortrows(Temp);
        Del(Remain(Rank(1))) = true;
    end
end

function Offspring = TraceDEBest(Problem,Population,ProblemN)
    FrontNo = NDSort(Population.objs,Population.cons,1);
    index1  = find(FrontNo == 1);
    best    = index1(floor(rand*length(index1))+1);

    [N,D] = size(Population(1).decs);
    trial = zeros(ProblemN,D);
    for i = 1 : ProblemN
        l = rand;
        if l <= 1/3
            F = 0.6;
        elseif l <= 2/3
            F = 0.8;
        else
            F = 1.0;
        end
        l = rand;
        if l <= 1/3
            CR = 0.1;
        elseif l <= 2/3
            CR = 0.2;
        else
            CR = 1.0;
        end
        indexset    = 1 : ProblemN;
        indexset(i) = [];
        r1  = floor(rand*(ProblemN-1))+1;
        xr1 = indexset(r1);
        indexset(r1) = [];
        r2  = floor(rand*(ProblemN-2))+1;
        xr2 = indexset(r2);
        r3  = floor(rand*(ProblemN-3))+1;
        xr3 = indexset(r3);
        Best_index = Population(best).decs;
        v = Population(xr1).decs + rand*(Best_index-Population(xr1).decs) + F*(Population(xr2).decs-Population(xr3).decs);
        Lower = repmat(Problem.lower,N,1);
        Upper = repmat(Problem.upper,N,1);
        v     = min(max(v,Lower),Upper);
        Site  = rand(N,D) < CR;
        Site(1,floor(rand*D)+1) = 1;
        trial(i,:) = Site.*v + (1-Site).*Population(i).decs;
    end
    Offspring = Problem.Evaluation(trial);
end

function obs = TraceObserveOffspring(obs,popIndex,source,Offspring)
    if isempty(source) || isempty(Offspring)
        return;
    end
    CV = sum(max(0,Offspring.cons),2)';
    feasible = CV <= 0;
    Obj = Offspring.objs;
    span = max(Obj,[],1) - min(Obj,[],1);
    span(span == 0) = 1;
    NormObj = (Obj - min(Obj,[],1))./span;
    objScore = 1./(1 + sum(NormObj,2))';
    cvScore  = 1./(1 + CV);
    for k = 1 : 3
        idx = source == k;
        obs.count(popIndex,k)    = obs.count(popIndex,k) + sum(idx);
        obs.feasible(popIndex,k) = obs.feasible(popIndex,k) + sum(feasible(idx));
        obs.cvScore(popIndex,k)  = obs.cvScore(popIndex,k) + sum(cvScore(idx));
        obs.objScore(popIndex,k) = obs.objScore(popIndex,k) + sum(objScore(idx));
    end
end

function survived = TraceSurvivalBySource(source,ownNext)
    survived = zeros(1,3);
    for k = 1 : 3
        survived(k) = sum(ownNext(source == k));
    end
end

function rates = TraceNormalizeRates(rates)
    rates = reshape(rates,1,[]);
    rates(~isfinite(rates) | rates < 0) = 0;
    if sum(rates) <= 0
        rates = [1,1,1];
    end
    rates = rates./sum(rates);
end
