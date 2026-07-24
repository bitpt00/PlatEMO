function Offspring = OperatorConstrainedAOP(Problem, Population, MatingPool, action, i)

%------------------------------- Copyright --------------------------------
% Copyright (c) 2026 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    rates    = action;
    rawNum   = rates.*Problem.N;
    ratesNum = floor(rawNum);
    for item = 1 : length(action)
        if ratesNum(item) < 4
            ratesNum(item) = 4; % Set the minimum value to 4 so that each operator can be called normally
        end
    end
    while sum(ratesNum) < Problem.N
        [~,item] = max(rawNum-ratesNum);
        ratesNum(item) = ratesNum(item) + 1;
    end
    while sum(ratesNum) > Problem.N
        candidates = find(ratesNum > 4);
        [~,idx]    = max(ratesNum(candidates)-rawNum(candidates));
        ratesNum(candidates(idx)) = ratesNum(candidates(idx)) - 1;
    end
    popSize = length(Population{i});
    MatingPool = MatingPool(MatingPool >= 1 & MatingPool <= popSize);
    if isempty(MatingPool)
        MatingPool = randi(popSize,1,Problem.N);
    end
    MatingPool = repmat(MatingPool,1,ceil(2*ratesNum(1)/length(MatingPool))+1);
    Offspring1 = OperatorGAhalf(Problem,Population{i}(MatingPool(1:ratesNum(1)*2)));
    Offspring2 = OperatorDE(Problem,Population{i}(randi(popSize,1,ratesNum(2))),Population{i}(randi(popSize,1,ratesNum(2))),Population{i}(randi(popSize,1,ratesNum(2))));
    p3         = Population{i};
    Offspring3 = DEBest(Problem, p3(randi(popSize,1,ratesNum(3))),ratesNum(3));
    Offspring  = [Offspring1 Offspring2 Offspring3];
end
