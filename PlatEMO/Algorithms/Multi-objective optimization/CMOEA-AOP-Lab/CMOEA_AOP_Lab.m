classdef CMOEA_AOP_Lab < ALGORITHM
% <2026> <multi> <real/integer/label/binary/permutation> <constrained>
% CMOEA-AOP lab with non-DDPG operator portfolio policies
% policy --- equal --- Operator portfolio policy

%------------------------------- Reference --------------------------------
% This lab algorithm is derived from the CMOEA-AOP and EMCMO control flow
% for mechanism-decomposition experiments. The original implementations are
% kept unchanged in their own folders.
%--------------------------------------------------------------------------

    properties
        policyTrace;
    end
    methods
        function main(Algorithm,Problem)
            [policyName,customRates,creditAlpha,creditFloor] = Algorithm.ParameterSet('equal',[1/3,1/3,1/3],0.35,0.05);
            policyName = lower(char(policyName));

            Population{1}  = Problem.Initialization();
            Population{2}  = Problem.Initialization();
            Fitness{1}     = LabCalFitness(Population{1}.objs,Population{1}.cons);
            Fitness{2}     = LabCalFitness(Population{2}.objs);
            transfer_state = 0;
            cnt            = 0;
            creditRates      = [1/3,1/3,1/3];
            creditRatesByPop = repmat(creditRates,2,1);
            Algorithm.policyTrace = struct('FE',{},'progress',{},'policy',{},'rates',{},'ratesByPop',{},'generated',{},'survived',{});

            %% Optimization
            while Algorithm.NotTerminated(Population{1})
                cnt      = cnt + 1;
                progress = Problem.FE/Problem.maxFE;
                ratesByPop = LabSelectRatesByPopulation(policyName,customRates,creditRates,creditRatesByPop,progress);
                rates      = ratesByPop(1,:);
                generated  = zeros(1,3);
                survived   = zeros(1,3);
                generatedByPop = zeros(2,3);
                survivedByPop  = zeros(2,3);
                creditObs      = LabInitCreditObservation();

                if transfer_state == 0
                    for i = 1 : 2
                        matingPool = randperm(Problem.N,Problem.N);
                        [valOffspring{i},source{i},counts{i}] = LabOperatorPortfolio(Problem,Population,matingPool,ratesByPop(i,:),i);
                        generated = generated + counts{i};
                        generatedByPop(i,:) = generatedByPop(i,:) + counts{i};
                        creditObs = LabObserveOffspring(creditObs,i,source{i},valOffspring{i});
                    end
                    for i = 1 : 2
                        if i == 1
                            combined = [Population{1},valOffspring{1},valOffspring{2}];
                        else
                            combined = [Population{2},valOffspring{2},valOffspring{1}];
                        end
                        ownStart = Problem.N + 1;
                        ownEnd   = Problem.N + length(source{i});
                        [Population{i},Fitness{i},Next] = LabEnvironmentalSelection(combined,Problem.N,i);
                        ownSurvived = LabSurvivalBySource(source{i},Next(ownStart:ownEnd));
                        survived = survived + ownSurvived;
                        survivedByPop(i,:) = survivedByPop(i,:) + ownSurvived;
                    end
                    if Problem.FE/Problem.maxFE >= 0.2
                        transfer_state = 1;
                    end
                else
                    for i = 1 : 2
                        matingPool = TournamentSelection(2,Problem.N,Fitness{i});
                        [valOffspring{i},source{i},counts{i}] = LabOperatorPortfolio(Problem,Population,matingPool,ratesByPop(i,:),i);
                        generated = generated + counts{i};
                        generatedByPop(i,:) = generatedByPop(i,:) + counts{i};
                        creditObs = LabObserveOffspring(creditObs,i,source{i},valOffspring{i});
                    end
                    [~,~,Next]       = LabEnvironmentalSelection([Population{2},valOffspring{2}],Problem.N,1);
                    succ_rate(1,cnt) = (sum(Next(1:Problem.N))/100) - (sum(Next(Problem.N+1:end))/50);

                    [~,~,Next]       = LabEnvironmentalSelection([Population{1},valOffspring{1}],Problem.N,2);
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
                        [Population{i},Fitness{i},Next] = LabEnvironmentalSelection(combined,Problem.N,i);
                        ownSurvived = LabSurvivalBySource(source{i},Next(ownStart:ownEnd));
                        survived = survived + ownSurvived;
                        survivedByPop(i,:) = survivedByPop(i,:) + ownSurvived;
                    end
                end

                [creditRates,creditRatesByPop] = LabUpdatePolicyCredit(policyName,creditRates,creditRatesByPop, ...
                    generatedByPop,survivedByPop,creditObs,creditAlpha,creditFloor);

                Algorithm.policyTrace(cnt).FE        = Problem.FE;
                Algorithm.policyTrace(cnt).progress  = Problem.FE/Problem.maxFE;
                Algorithm.policyTrace(cnt).policy    = policyName;
                Algorithm.policyTrace(cnt).rates     = rates;
                Algorithm.policyTrace(cnt).ratesByPop = ratesByPop;
                Algorithm.policyTrace(cnt).generated = generated;
                Algorithm.policyTrace(cnt).survived  = survived;
            end
        end
    end
end

function ratesByPop = LabSelectRatesByPopulation(policyName,customRates,creditRates,creditRatesByPop,progress)
    switch policyName
        case {'dual_static_split','dual_fixed_split'}
            ratesByPop = [0.2,0.2,0.6; 0.2,0.6,0.2];
        case {'dual_feasibility_explore','dual_feasible_explore'}
            ratesByPop = [0.5,0.0,0.5; 0.2,0.6,0.2];
        case {'dual_survival_credit','dual_credit'}
            ratesByPop = creditRatesByPop;
        case {'dual_mixed_credit'}
            ratesByPop = creditRatesByPop;
        otherwise
            rates = LabSelectRates(policyName,customRates,creditRates,progress);
            ratesByPop = repmat(rates,2,1);
    end
    ratesByPop(1,:) = LabNormalizeRates(ratesByPop(1,:));
    ratesByPop(2,:) = LabNormalizeRates(ratesByPop(2,:));
end

function rates = LabSelectRates(policyName,customRates,creditRates,progress)
    switch policyName
        case {'ga_only','ga'}
            rates = [1,0,0];
        case {'de_rand_only','de_rand'}
            rates = [0,1,0];
        case {'de_best_only','de_best'}
            rates = [0,0,1];
        case {'equal','equal_aop'}
            rates = [1,1,1];
        case {'ga_heavy','fixed_ga_heavy'}
            rates = [0.6,0.2,0.2];
        case {'de_rand_heavy','fixed_de_rand_heavy'}
            rates = [0.2,0.6,0.2];
        case {'de_best_heavy','fixed_de_best_heavy'}
            rates = [0.2,0.2,0.6];
        case {'ga_de_rand','ga+de_rand'}
            rates = [0.5,0.5,0];
        case {'ga_de_best','ga+de_best'}
            rates = [0.5,0,0.5];
        case {'de_rand_de_best','de_rand+de_best'}
            rates = [0,0.5,0.5];
        case {'random','random_aop'}
            rates = rand(1,3);
        case {'stage','stage_aop'}
            if progress < 0.25
                rates = [0.2,0.6,0.2];
            elseif progress < 0.70
                rates = [1,1,1];
            else
                rates = [0.35,0.15,0.5];
            end
        case {'survival_credit','survival_credit_aop'}
            rates = creditRates;
        case {'sliding_survival_credit','sliding_credit'}
            rates = creditRates;
        case {'feasibility_credit','feasible_credit'}
            rates = creditRates;
        case {'cv_credit','constraint_violation_credit'}
            rates = creditRates;
        case {'objective_credit','obj_credit'}
            rates = creditRates;
        case {'mixed_credit','composite_credit'}
            rates = creditRates;
        case {'fixed_custom','custom'}
            rates = customRates;
        otherwise
            error('CMOEA_AOP_Lab:UnknownPolicy','Unknown policy: %s',policyName);
    end
    rates = LabNormalizeRates(rates);
end

function rates = LabNormalizeRates(rates)
    rates = reshape(rates,1,[]);
    if numel(rates) ~= 3
        error('CMOEA_AOP_Lab:BadRates','Operator portfolio must contain three rates.');
    end
    rates(~isfinite(rates) | rates < 0) = 0;
    if sum(rates) <= 0
        rates = [1,1,1];
    end
    rates = rates./sum(rates);
end

function [Offspring,source,counts] = LabOperatorPortfolio(Problem,Population,MatingPool,rates,i)
    counts    = LabAllocateCounts(rates,Problem.N,4);
    Offspring = [];
    source    = [];

    if counts(1) > 0
        pool = repmat(MatingPool,1,ceil(2*counts(1)/numel(MatingPool))+1);
        offspring = OperatorGAhalf(Problem,Population{i}(pool(1:2*counts(1))));
        Offspring = LabAppendOffspring(Offspring,offspring);
        source    = [source,ones(1,length(offspring))];
    end
    if counts(2) > 0
        n = counts(2);
        offspring = OperatorDE(Problem, ...
            Population{i}(randi(Problem.N,1,n)), ...
            Population{i}(randi(Problem.N,1,n)), ...
            Population{i}(randi(Problem.N,1,n)));
        Offspring = LabAppendOffspring(Offspring,offspring);
        source    = [source,2*ones(1,length(offspring))];
    end
    if counts(3) > 0
        n = counts(3);
        p = Population{i};
        offspring = LabDEBest(Problem,p(randi(Problem.N,1,n)),n);
        Offspring = LabAppendOffspring(Offspring,offspring);
        source    = [source,3*ones(1,length(offspring))];
    end
end

function Offspring = LabAppendOffspring(Offspring,offspring)
    if isempty(Offspring)
        Offspring = offspring;
    else
        Offspring = [Offspring,offspring];
    end
end

function counts = LabAllocateCounts(rates,N,minActive)
    rates  = LabNormalizeRates(rates);
    active = rates > 0;
    counts = floor(rates.*N);
    counts(~active) = 0;
    if sum(active) == 0
        active = true(1,3);
        rates  = [1,1,1]./3;
    end
    if N >= sum(active)*minActive
        low = active & counts < minActive;
        counts(low) = minActive;
    end
    while sum(counts) > N
        candidates = find(active & counts > minActive);
        if isempty(candidates)
            candidates = find(active & counts > 0);
        end
        [~,k] = max(counts(candidates));
        counts(candidates(k)) = counts(candidates(k)) - 1;
    end
    while sum(counts) < N
        deficit = rates - counts./N;
        deficit(~active) = -inf;
        [~,k] = max(deficit);
        counts(k) = counts(k) + 1;
    end
end

function Fitness = LabCalFitness(PopObj,PopCon)
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

function [Population,Fitness,Next] = LabEnvironmentalSelection(Population,N,isOrigin)
    if isOrigin == 1
        Fitness = LabCalFitness(Population.objs,Population.cons);
    else
        Fitness = LabCalFitness(Population.objs);
    end
    Next = Fitness < 1;
    if sum(Next) < N
        [~,Rank] = sort(Fitness);
        Next(Rank(1:N)) = true;
    elseif sum(Next) > N
        Del  = LabTruncation(Population(Next).objs,sum(Next)-N);
        Temp = find(Next);
        Next(Temp(Del)) = false;
    end
    Population = Population(Next);
    Fitness    = Fitness(Next);
    [Fitness,rank] = sort(Fitness);
    Population = Population(rank);
end

function Del = LabTruncation(PopObj,K)
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

function Offspring = LabDEBest(Problem,Population,ProblemN)
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
        xr1 = indexset(floor(rand*(ProblemN-1))+1);
        indexset(indexset == xr1) = [];
        xr2 = indexset(floor(rand*(ProblemN-2))+1);
        indexset(indexset == xr2) = [];
        xr3 = indexset(floor(rand*(ProblemN-3))+1);
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

function survived = LabSurvivalBySource(source,ownNext)
    survived = zeros(1,3);
    for k = 1 : 3
        survived(k) = sum(ownNext(source == k));
    end
end

function obs = LabInitCreditObservation()
    obs.count     = zeros(2,3);
    obs.feasible  = zeros(2,3);
    obs.cvScore   = zeros(2,3);
    obs.objScore  = zeros(2,3);
end

function obs = LabObserveOffspring(obs,popIndex,source,Offspring)
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

function [creditRates,creditRatesByPop] = LabUpdatePolicyCredit(policyName,creditRates,creditRatesByPop,generatedByPop,survivedByPop,obs,alpha,floorRate)
    generated = sum(generatedByPop,1);
    survived  = sum(survivedByPop,1);
    switch policyName
        case {'survival_credit','survival_credit_aop'}
            creditRates = LabUpdateCreditRates(creditRates,generated,survived,alpha,floorRate);
        case {'sliding_survival_credit','sliding_credit'}
            creditRates = LabUpdateCreditRates(creditRates,generated,survived,min(alpha,0.12),floorRate);
        case {'feasibility_credit','feasible_credit'}
            creditRates = LabUpdateCreditRatesFromScore(creditRates,generated,sum(obs.feasible,1),alpha,floorRate);
        case {'cv_credit','constraint_violation_credit'}
            creditRates = LabUpdateCreditRatesFromScore(creditRates,generated,sum(obs.cvScore,1),alpha,floorRate);
        case {'objective_credit','obj_credit'}
            creditRates = LabUpdateCreditRatesFromScore(creditRates,generated,sum(obs.objScore,1),alpha,floorRate);
        case {'mixed_credit','composite_credit'}
            score = survived + sum(obs.feasible,1) + sum(obs.cvScore,1);
            creditRates = LabUpdateCreditRatesFromScore(creditRates,generated,score,alpha,floorRate);
        case {'dual_survival_credit','dual_credit'}
            for i = 1 : 2
                creditRatesByPop(i,:) = LabUpdateCreditRates(creditRatesByPop(i,:),generatedByPop(i,:),survivedByPop(i,:),alpha,floorRate);
            end
        case {'dual_mixed_credit'}
            score1 = survivedByPop(1,:) + obs.feasible(1,:) + obs.cvScore(1,:);
            score2 = survivedByPop(2,:) + obs.objScore(2,:) + obs.cvScore(2,:);
            creditRatesByPop(1,:) = LabUpdateCreditRatesFromScore(creditRatesByPop(1,:),generatedByPop(1,:),score1,alpha,floorRate);
            creditRatesByPop(2,:) = LabUpdateCreditRatesFromScore(creditRatesByPop(2,:),generatedByPop(2,:),score2,alpha,floorRate);
    end
end

function rates = LabUpdateCreditRates(oldRates,generated,survived,alpha,floorRate)
    rates = LabUpdateCreditRatesFromScore(oldRates,generated,survived,alpha,floorRate);
end

function rates = LabUpdateCreditRatesFromScore(oldRates,generated,score,alpha,floorRate)
    active = generated > 0;
    normalizedScore = zeros(1,3);
    normalizedScore(active) = (score(active) + 0.1)./(generated(active) + 0.3);
    if sum(normalizedScore) <= 0
        target = [1,1,1]./3;
    else
        target = normalizedScore./sum(normalizedScore);
    end
    target = max(target,floorRate);
    target = target./sum(target);
    rates  = (1-alpha).*oldRates + alpha.*target;
    rates  = LabNormalizeRates(rates);
end
