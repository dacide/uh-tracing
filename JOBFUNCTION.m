function [] = JOBFUNCTION()
    
    SystemFolder = FolderSystem('C:\ubuntueswin\FolderSystem', 17);

    trainsml1 = [1,0,0,0,0,0,0];
    trainsml2 = [1,2,0,0,0,0,0];
    trainsml3 = [1,2,3,0,0,0,0];
    trainsml4 = [1,2,3,4,0,0,0];
    trainsml5 = [1,2,3,4,5,0,0];
    trainsml6 = [1,2,3,4,5,6,0];
    trainsml7 = [1,2,3,4,5,6,7];
    testsml = [8];
    trainsml = [trainsml1;trainsml2;trainsml3;trainsml4;trainsml5;trainsml6;...
        trainsml7];
    
    traincstg1 = [9,0,0,0,0,0,0,0];
    traincstg2 = [9,10,0,0,0,0,0,0];
    traincstg3 = [9,10,11,0,0,0,0,0];
    traincstg4 = [9,10,11,12,0,0,0,0];
    traincstg5 = [9,10,11,12,13,0,0,0];
    traincstg6 = [9,10,11,12,13,14,0,0];
    traincstg7 = [9,10,11,12,13,14,15,0];
    traincstg8 = [9,10,11,12,13,14,15,16];
    testcstg = [17];
    traincstg = [traincstg1;traincstg2;traincstg3;traincstg4;traincstg5;traincstg6;...
        traincstg7;traincstg8];
    
    %run SML
  %  for i = 1 : 7
        trainArray = GetClearArray(trainsml, 4);
        RunNFoldCrossValidation(SystemFolder, 1, testsml,4);
  %  end
    
    %run CSTG
  %  for i = 1 : 8
  %      trainArray = GetClearArray(traincstg, i);
 %       RunNFoldCrossValidation(SystemFolder, trainArray, testcstg,(i+8));
  %  end
    
    
end

function [clearArray] = GetClearArray(train, i)
    dirtyArray = train(i,:);
    l = length(dirtyArray);
    clearArray = [];
    for j = 1 : l
        index = dirtyArray(j);
        if index ~=0
            clearArray = [clearArray, index];
        end
    end
end

