function [] = JOBFUNCTION()
    
     %--------INIT FILE SYSTEM----------%
    numberOfSubjects = 57;                                      %REWRITE
    baseFolderPath = 'C:\ubuntueswin\FolderSystem2';              %REWRITE
    numberOfSpeakers = 2;                                         %REWRITE
    speakerSubjectMatrix = [1 27; 28 57];     % egy sor tartalmazza az n. speaker kezdõ és vég subject számát                  %REWRITE    
    SystemFolder = FolderSystem(baseFolderPath, numberOfSubjects, numberOfSpeakers, speakerSubjectMatrix);   
    
    %---------INIT ErrorLog File----------%
    fileHeader = GenerateErrorLogHeader();
    errorValueLogName = sprintf('ErrorValue_%s.txt',datestr(now,'mm_dd_yyyy_HH_MM_SS'));
    errorValueFilePath = strcat(SystemFolder.GetErrorValueLogPath(),'\',errorValueLogName);
    errorValueFileId = fopen(errorValueFilePath,'w');
    WriteRowToFile(errorValueFileId, fileHeader);
    fclose(errorValueFileId);
    
    
    %run SML
    for i = [1:3:14]
        trainsml = [1:i];
        testsml = [15:27];
        [RMSE_MODEL_AVERAGE, AREA_MODEL_AVERAGE, TER_MODEL_AVERAGE] = RunNFoldCrossValidation(SystemFolder, trainsml, testsml, i);
        
        %Create and write to file the error row
        errorValueRow = GenerateErrorValueRow(RMSE_MODEL_AVERAGE, AREA_MODEL_AVERAGE, TER_MODEL_AVERAGE, trainsml, i);
        errorValueFileId = fopen(errorValueFilePath,'a');
        WriteRowToFile(errorValueFileId, errorValueRow);
        fclose(errorValueFileId);
    end
    
    
    %---------INIT ErrorLog File----------%
    fileHeader = GenerateErrorLogHeader();
    errorValueLogName = sprintf('ErrorValue_%s.txt',datestr(now,'mm_dd_yyyy_HH_MM_SS'));
    errorValueFilePath = strcat(SystemFolder.GetErrorValueLogPath(),'\',errorValueLogName);
    errorValueFileId = fopen(errorValueFilePath,'w');
    WriteRowToFile(errorValueFileId, fileHeader);
    fclose(errorValueFileId);
    
    %run CSTG
    for i = [1 :3: 14]
        trainCSTG = [28:i+27];
        testCSTG = [45:57];
        [RMSE_MODEL_AVERAGE, AREA_MODEL_AVERAGE, TER_MODEL_AVERAGE] = RunNFoldCrossValidation(SystemFolder, trainCSTG, testCSTG,(i+8));
        
        %Create and write to file the error row
        errorValueRow = GenerateErrorValueRow(RMSE_MODEL_AVERAGE, AREA_MODEL_AVERAGE, TER_MODEL_AVERAGE, trainCSTG, i+12);
        errorValueFileId = fopen(errorValueFilePath,'a');
        WriteRowToFile(errorValueFileId, errorValueRow);
        fclose(errorValueFileId);
    end
    
    
end

function row = GenerateErrorValueRow(RMSE, AREA, TER, BaseOrSelectedSubject, iterationNumber)
    row = [cellstr(num2str(iterationNumber)), cellstr(num2str(RMSE)),...
        cellstr(num2str(AREA)),cellstr(num2str(TER(1))), ...
        cellstr(num2str(TER(2))), cellstr(num2str(TER(3))),...
        cellstr(num2str(BaseOrSelectedSubject))];
end

function WriteRowToFile(fileId, fileRowData)
    itemsNum = length(fileRowData);
    for i = 1 : itemsNum
        fprintf(fileId,['%s','\t'],fileRowData{1,i});
    end
    fprintf(fileId, '\n');
end

function fileHeader = GenerateErrorLogHeader()
    fileHeader = {'Iteration(Model)', 'RMSE', 'AREA', 'INS', 'DEL', 'SUBS', 'PlusSubjId'};
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

