function [] = GetRMSEValueForImage( SystemFolder )
    %Beolvasni a valódi adatokat
    %Beolvasni a modell kiadott adatait
    
    %Kell egy hely ahol egy subjectre egy csv fájlban van minden koordináta
    
    [selectedStrategy, selectedSubjectNumber] = SelectRMSEStrategy();
    
    if selectedStrategy==1
        GetRMSEValueForOneSubject(SystemFolder, selectedSubjectNumber);
        % Calculate RMSE for one subject with all folds
    elseif selectedStrategy == 2
        % Calculate RMSE for a modell with all folds
    end
   
    
end

function [] = GetRMSEValueForOneSubject(SystemFolder, selectedSubjectNumber)
    crossValFolderPath = SystemFolder.GetCrossValFolderPath();
    numberOfFolds = length(dir(crossValFolderPath))-2; % -2 because . and .. stuff
    for fold = 1 : numberOfFolds;
        GetSubjectRMSEInOneFold(SystemFolder, selectedSubjectNumber, fold);
    end
end

function [] = GetSubjectRMSEInOneFold(SystemFolder, selectedSubjectNumber, foldNumber)
    nthFoldPath = SystemFolder.GetCrossValNthFolderPath(foldNumber);
    [fileNames] = GetSubjectATfileNames(nthFoldPath, selectedSubjectNumber);
    txtNumber = length(fileNames);
    for i = 1 : txtNumber
        fileName = fileNames(i).name;
        [originalCoords] = GetOriginalCoordsForFile(fileName, SystemFolder);
        [trainedCoords] = GetTrainedCoordsForFile(fileName, nthFoldPath);
        
    end
end

function [originalCoords] = GetOriginalCoordsForFile(fileName, SystemFolder)
    [subjectNumber, imageName] = GetCSVLineInfromation(fileName);
    sumCSVPath = SystemFolder.GetSumCSVFolderPath();
    sumCSVNames = dir(strcat(sumCSVPath, '\', '*.csv'));
    csvFilePath = 'default';
    for i = 1 : length(sumCSVNames)
        oneCSVName = sumCSVNames(i).name;
        splitName = strsplit(oneCSVName, {'_', '.'});
        subjNumCell = splitName(2);
        subjNum = str2num(subjNumCell{1,1});
        if subjNum == subjectNumber
            csvFilePath = strcat(sumCSVPath, '\', oneCSVName{1,1});
            break;
        end
    end
    [originalCoords] = FindRowInCSVFile(csvFilePath, imageName);
end

function [lineCoords] = FindRowInCSVFile(csvFilePath, imageName)
    fileId = OpenFile(csvFilePath);
    readLine = fgetl(fileId);
    while ischar(readLine)
        splitLine = strsplit(readLine, '\t');
        pictureNameCell = splitLine(1);
        pictureName = pictureNameCell{1,1};
        if strcmpi(pictureName, imageName)
            [lineCoords] = ConvertReadLineToCoords(readLine);
            break;
        end
    end
    fclose(fileId);
end

function [coords] = ConvertReadLineToCoords(readLine)
    coords = zeros(2,32);
    split = strsplit(readLine, '\t');
    for i = 2 : 65 % 64 = number of coords
        cell = split(i);
        modul = mod(i,2);
        if modul == 0
            coords(1,i/2) = str2num(cell{1,1});
        else
            coords(2,(i-1)/2) = str2num(cell{1,1});
        end
    end
end

function [fileId] = OpenFile(filePath)
    fileId = fopen(filePath, 'r');
    if fileId <= 0 
        disp('____ERROR WHILE READ FILE____');
    end
end

function [subjectNumber, imageName] = GetCSVLineInfromation(fileName)
    splitArray = strsplit(fileName, '_');
    subjectCell = splitArray(2);
    imageCell = splitArray(3);
    subjectNumber = str2num(subjectCell{1,1});
    imageName = imageCell{1,1};
end

function [trainedCoords] = GetTrainedCoordsForFile(fileName, nthFoldPath)
    filePath = strcat(nthFoldPath, '\', fileName);
    trainedCoords = ReadAutotraceOutputTxt( filePath );
end

function [fileNames] = GetSubjectATfileNames(nthFoldPath, selectedSubjectNumber)
    txtFilePath = strcat(nthFoldPath, '\', 'Subject', selectedSubjectNumber, '*.txt');
    fileNames = dir(txtFilePath);
end

function [selectedStrategy, selectedSubject] = SelectRMSEStrategy()
    disp('1: Get RMSE for one Subject.(all fold)');
    disp('2: Get RMSE for one model (all fold)');
    prompt = 'Select one strategy to calculate RMSE (Default 1. strategy with 1. subject)';
    selectedStrategy = input(prompt);
    switch selectedStrategy
        case 1
            prompt1 = strcat('Select one subject 1-',SystemFolder.GetNumberOfSubject());
            selectedSubject = input(prompt1);
        case 2
            selectedSubject = 0;
        otherwise
            selectedStrategy = 1;
            selectedSubject = 1;
    end
end

