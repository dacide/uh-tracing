function [] = FusionCSVFilesForAllSubject(FolderSystemObject, nFoldCrossVal, srategyNum, percent, selectSubj)
    % FUSION CSV FILES IN CASE OF TS DATA

    subjectsFolderPath = FolderSystemObject.GetTsFilesFolderPath();
    %subjectsFolderPath = 'C:\ubuntueswin\networkSystem\tsfiles\';
    folderName = GetAllFolderName(subjectsFolderPath);
    subjects = length(folderName);
    selectedSubjectName = 'default';
    if nFoldCrossVal ~= 1
        [strategyNumber, percentage, selectedSubjectNumber]= ChooseTestDatasetGetterStrategy(subjects);
    else
        strategyNumber = srategyNum;
        percentage = percent;
        selectedSubjectNumber = selectSubj;   
    end
    if selectedSubjectNumber ~= 0
        selectedSubjectName = strcat('Subject', num2str(selectedSubjectNumber)); %folderName{1,selectedSubjectNumber};
    end
    if strategyNumber ~= 0
        for subjectNumber = 1 : subjects
            oneSubjectName = strcat('Subject', num2str(subjectNumber));%folderName{1,subjectNumber};
            FusionCSVFilesForOneSubject(FolderSystemObject, subjectNumber, percentage, strategyNumber, selectedSubjectName, oneSubjectName)
        end
    else
        disp('Strategy Number error!');
    end    
end


function [] = FusionCSVFilesForOneSubject(FolderSystemObject, subjectNumber, percentage, strategyNumber, selectedSubjectName, oneSubjectName)
    csvFolder = FolderSystemObject.GetTsSubjectCSVFolderPath(subjectNumber);
    csvPartFileNames = GetAllFileName(csvFolder);
    sumCSVFileId = CreateSumCSVFile(FolderSystemObject, subjectNumber, strategyNumber);
    csvPartFileNumbers = length(csvPartFileNames);
    isfirstCSVFile = 1;
    for csvNumbers = 1 : csvPartFileNumbers
        csvFileName = csvPartFileNames{1, csvNumbers};
        HandleOnePartCSVFile(FolderSystemObject, subjectNumber, percentage, csvFileName, sumCSVFileId, isfirstCSVFile, strategyNumber, selectedSubjectName, oneSubjectName);
        isfirstCSVFile = 0;
    end
    fclose(sumCSVFileId);
end

function [] = HandleOnePartCSVFile(FolderSystemObject, subjectNumber, percentage, csvFileName, sumCSVFileId, isfirstCSVFile, strategyNumber, selectedSubjectName, oneSubjectName)
    csvFolderPath = FolderSystemObject.GetTsSubjectCSVFolderPath(subjectNumber);
    csvPartFilePath = strcat(csvFolderPath, '\', csvFileName);
    csvFileId = OpenFile(csvPartFilePath);
    readedLineNumber = 1;
    readedLine = fgetl(csvFileId);
    switch strategyNumber
        case 1
            while ischar(readedLine)
                HandleOneLineOfCSVStrategyOne(FolderSystemObject, subjectNumber, readedLine, readedLineNumber, sumCSVFileId, percentage, oneSubjectName, isfirstCSVFile);
                readedLineNumber = readedLineNumber + 1;
                readedLine = fgetl(csvFileId);      
            end
        case 2
            while ischar(readedLine)
                HandleOneLineOfCSVStrategyTwo(FolderSystemObject, subjectNumber, readedLine, readedLineNumber, sumCSVFileId, percentage, oneSubjectName, isfirstCSVFile, selectedSubjectName);
                readedLineNumber = readedLineNumber + 1;
                readedLine = fgetl(csvFileId);
            end
        case 3
            while ischar(readedLine)
                HandleOneLineOfCSVStrategyThree(readedLine, readedLineNumber, sumCSVFileId, isfirstCSVFile);
                readedLineNumber = readedLineNumber + 1;
                readedLine = fgetl(csvFileId);
            end
    end 
    fclose(csvFileId);
end

function [] = HandleOneLineOfCSVStrategyOne(FolderSystemObject, subjectNumber, readedLine, readedLineNumber, sumCSVFileId, percentage, oneSubjectName, isfirstCSVFile)
    if isfirstCSVFile == 1 && readedLineNumber == 1
        % Insert header to sum csv file
        WriteLineToFile(sumCSVFileId, readedLine);
    elseif readedLineNumber ~= 1
        booleanTest = IsLineTest(percentage);
        pictureName = GetPictureNameFromLine(readedLine);
        if booleanTest == 1
            MovePictureToTestFolder(FolderSystemObject, subjectNumber, pictureName);
        else
            WriteLineToFile(sumCSVFileId, readedLine);
            MovePictureToTrainFolder(FolderSystemObject, subjectNumber, pictureName);
        end
    end        
end

function [] = HandleOneLineOfCSVStrategyTwo(FolderSystemObject, subjectNumber, readedLine, readedLineNumber, sumCSVFileId, percentage, oneSubjectName, isfirstCSVFile, selectedSubjectName)
    if ~strcmpi(oneSubjectName, selectedSubjectName) % for training
        if isfirstCSVFile == 1 && readedLineNumber == 1
            WriteLineToFile(sumCSVFileId, readedLine);
        elseif readedLineNumber ~= 1
            pictureName = GetPictureNameFromLine(readedLine);
            WriteLineToFile(sumCSVFileId, readedLine);
            MovePictureToTrainFolder(FolderSystemObject, subjectNumber, pictureName);
        end
    else % just for testing
        if isfirstCSVFile == 1 && readedLineNumber == 1
            WriteLineToFile(sumCSVFileId, readedLine);
        elseif readedLineNumber ~= 1
            booleanTest = IsLineTest(percentage);
            pictureName = GetPictureNameFromLine(readedLine);
            if booleanTest == 1
                MovePictureToTestFolder(FolderSystemObject, subjectNumber, pictureName);
            else
                WriteLineToFile(sumCSVFileId, readedLine);
                MovePictureToTrainFolder(FolderSystemObject, subjectNumber, pictureName);
            end
        end
    end
end

function [] = HandleOneLineOfCSVStrategyThree(readedLine, readedLineNumber, sumCSVFileId, isfirstCSVFile)
    if isfirstCSVFile == 1 && readedLineNumber == 1
        % Insert header to sum csv file
        WriteLineToFile(sumCSVFileId, readedLine);
    elseif readedLineNumber ~= 1
        WriteLineToFile(sumCSVFileId, readedLine);
    end        
end

function [] = WriteLineToFile(fileId, lineToWrite)
    fprintf(fileId, lineToWrite);
    fprintf(fileId, '\n');
end

function [] = MovePictureToTrainFolder(FolderSystemObject, subjectNumber, pictureName)
    subjectPictureBasePath = GetSubjectPictureBasePath(FolderSystemObject, subjectNumber);
    pictureSourcePath = strcat(subjectPictureBasePath, '\',  pictureName);
    trainPictureDestination = GetTrainPictureDestination(FolderSystemObject, subjectNumber);
    copyfile(pictureSourcePath, trainPictureDestination);
end

function [] = MovePictureToTestFolder(FolderSystemObject, subjectNumber, pictureName)
    subjectPictureBasePath = GetSubjectPictureBasePath(FolderSystemObject, subjectNumber);
    pictureSourcePath = strcat(subjectPictureBasePath, '\',  pictureName);
    oneSubjectName = strcat('Subject_', num2str(subjectNumber));
    newPictureName = strcat(oneSubjectName, '_', pictureName);
    testPictureDestination = FolderSystemObject.GetTestDataFolderPath();
    pictureDestinationPath = strcat(testPictureDestination, '\', newPictureName);
    copyfile(pictureSourcePath, pictureDestinationPath);
end

function [trainPictureDestination] = GetTrainPictureDestination(FolderSystemObject, subjectNumber)
    trainPictureDestination = FolderSystemObject.GetTrainerSubjectImagesFolderPath(subjectNumber);
end

function [subjectPictureBasePath] = GetSubjectPictureBasePath(FolderSystemObject, subjectNumber)
    subjectPictureBasePath = FolderSystemObject.GetSubjectConvertedetImageFolderPath(subjectNumber);
end

function [pictureName] = GetPictureNameFromLine(readedLine)
    splittedStrings = strsplit(readedLine, '\t');
    pictureNameCell = splittedStrings(1);
    pictureName = pictureNameCell{1,1};
end

function [booleanTest] = IsLineTest(percentage)
    randNumber = randsample(100,1);
    if randNumber <= percentage
        booleanTest = 1;
    else
        booleanTest = 0;
    end
end

function [fileId] = OpenFile(filePath)
    fileId = fopen(filePath, 'r');
    if fileId <=0 
        disp('____ERROR WHILE READ FILE____');
    end
end

function [sumCSVFileId] = CreateSumCSVFile(FolderSystemObject, subjectNumber, strategyNumber)
    switch strategyNumber
        case 3
            folderPath = FolderSystemObject.GetSumCSVFolderPath();
            fileName = strcat('Subject_',num2str(subjectNumber),'.csv');
        otherwise
            fileName = 'TongueContours.csv';
            folderPath = FolderSystemObject.GetTrainerSubjectFolderPath(subjectNumber);           
    end
    %folderPath = strcat('C:\ubuntueswin\networkSystem\finalTrainData\', oneSubjectName);
    csvFilePath = strcat(folderPath, '\', fileName);
    fileId = fopen(csvFilePath, 'w');
    if fileId <= 0
        disp('ERROR WHILE WRITING SUM CSV FILE');
        sumCSVFileId = 0;
    else
        sumCSVFileId = fileId;
    end
end

function [fileNames] = GetAllFileName(folderPath)
    f = dir(folderPath);
    isfile = [f(:).isdir];
    nameFiles = {f(~isfile).name}'; % just files not folders
    fileNames = nameFiles';
end

function [folderName] = GetAllFolderName(subjectsFolderPath)
    directories = dir(subjectsFolderPath);
    isFolder = [directories(:).isdir];
    folderName = {directories(isFolder).name}';
    folderName(ismember(folderName,{'.','..'})) = [];
    folderName = folderName';
end

function [strategyNumber, percentage, selectedSubject]= ChooseTestDatasetGetterStrategy(subjectNumber)
   % console input for a number
   disp('1. From all subject get X% to be the test data');
   disp('2. From one subject get X% to be the test data');
   disp('3. Fusion all csv part file into one per subject');
   prompt = 'Choose test getter strategy!  ';
   result = input(prompt);
   switch result
       case 1
           strategyNumber = 1;  % from all user get X %
           [percentage] = GetPercentageForStrategy();
           selectedSubject = 0;
       case 2
           strategyNumber = 2;  % from one user get X %
           [percentage] = GetPercentageForStrategy();
           [selectedSubject] = SelectSubjectTest(subjectNumber);
       case 3
           strategyNumber = 3;
           percentage = 0;
           selectedSubject = 0;
       otherwise
            disp('_________Wrong input number!________');
            strategyNumber = 0;
   end 
end

function[percentage] = GetPercentageForStrategy()
    prompt= 'What should be the TEST persentage (default 10%)? 1-100:  ';
    result = input(prompt);
    if result > 0 && result <= 100
        percentage = result;
    else
        percentage = 10;
    end
end

function [selectedSubject] = SelectSubjectTest(subjectNumber)
    prompt = strcat('Which subject should be test data (default = 1)? Write in 1-', num2str(subjectNumber), ':   ');
    result = input(prompt);
    if result >= 1 && result <= subjectNumber
        selectedSubject = result;
    else
        selectedSubject = 1;
    end
end