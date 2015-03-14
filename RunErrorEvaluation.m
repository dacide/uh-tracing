function [strategyAverageError, errorArray] = RunErrorEvaluation( varargin )
    % varargin : SystemFolder,TestSubjectIds, SelectedStrategy, SelectedSubjectNumber
    % 1- RMSE SUBJ; 2- RMSE MOD; 3- AREA SUBJ; 4- AREA MOD; 5- TER SUBJ;
    % 6- TER MOD;
    if nargin == 1  % Call function (1 argument) to run only ONESubject evaluation; interaction mode
        SystemFolder = varargin{1};
        [selectedStrategy, selectedSubjectNumber] = SelectStrategy(SystemFolder);
    elseif nargin == 2 % Call function (2 arguments) to run ONESubject OR Model evaluation; interaction mode
        SystemFolder = varargin{1};
        testSubjectIds = varargin{2};
        [selectedStrategy, selectedSubjectNumber] = SelectStrategy(SystemFolder);
    elseif nargin == 4  % Call function (4 arguments) to run ONESubject OR Model evaluation; non-interaction mode
        SystemFolder = varargin{1};
        testSubjectIds = varargin{2};
        selectedStrategy = varargin{3};
        selectedSubjectNumber = varargin{4};
    end
    
    strategyAverageError = 0;
    
    if selectedStrategy==1
      % Calculate RMSE for one subject with all folds
        [strategyAverageError, errorArray] = GetErrorValueForOneSubject(SystemFolder, selectedSubjectNumber, selectedStrategy);
        disp(strcat('Average RMSE on full fold One Subject: ',num2str(strategyAverageError)));
    elseif selectedStrategy == 2        
        % Calculate RMSE for a modell with all folds
        [strategyAverageError, errorArray] = GetErrorValueForModel(SystemFolder, selectedStrategy,testSubjectIds);
        disp(strcat('Average RMSE on full fold on model: ',num2str(strategyAverageError)));
    elseif selectedStrategy == 3
        % Calculate AREA between train and manual lines (point connected
        % with line) ONE SUBJECT
         [strategyAverageError, errorArray] = GetErrorValueForOneSubject(SystemFolder, selectedSubjectNumber, selectedStrategy);
         disp(strcat('Average AREA between manual and train lines ONESUBJECT: ', num2str(strategyAverageError)));
    elseif selectedStrategy == 4
        % Calculate AREA between train and manual lines (point connected
        % with line) MODEL
         [strategyAverageError, errorArray] = GetErrorValueForModel(SystemFolder, selectedStrategy, testSubjectIds);
        disp(strcat('Average Area on full fold on model: ',num2str(strategyAverageError)));
    elseif selectedStrategy == 5
        % Calculate TER (Insertion, Deletion, Substitution) for ONE SUBJECT
        [averageTER, TER] = GetTERValueForOneSubject(SystemFolder, selectedSubjectNumber, selectedStrategy);
        errorArray = TER;
        strategyAverageError = averageTER;
        disp(strcat('Average TER on full fold on One Subject: ',num2str(strategyAverageError)));
    elseif selectedStrategy == 6
        % Calculate TER (Insertion, Deletion, Substitution) for MODEL
        [averageTER, TER] = GetTERValueForModel(SystemFolder, selectedStrategy,testSubjectIds);
        errorArray = TER;
        strategyAverageError = averageTER;
        disp(strcat('Average TER on full fold on model: ',num2str(strategyAverageError)));
    end
end


function [strategyAverageError, errorArray] = GetErrorValueForModel(SystemFolder, selectedStrategy, testSubjectIds)
     sumError = 0;
     for i = 1 : length(testSubjectIds);
        selectedSubjectId = testSubjectIds(i);
        [foldAverageError, errorArray] = GetErrorValueForOneSubject(SystemFolder, selectedSubjectId, selectedStrategy);
        disp(strcat('Average RMSE on full fold: ',num2str(foldAverageError)));
        sumError = sumError + foldAverageError;
     end
     strategyAverageError = sumError/length(testSubjectIds);
end

function [averageTER, TER] = GetTERValueForModel(SystemFolder, selectedStrategy, testSubjectIds)
    sumTER = 0;
    for i = 1 : length(testSubjectIds)
        selectedSubjectId = testSubjectIds(i);
        [averTER, TER] = GetTERValueForOneSubject(SystemFolder, selectedSubjectId, selectedStrategy);
        sumTER = sumTER + averTER;
    end
    averageTER = sumTER/length(testSubjectIds);
end

function [averageTER, TER] = GetTERValueForOneSubject(SystemFolder, selectedSubjectNumber, selectedStrategy)
     crossValFolderPath = SystemFolder.GetCrossValFolderPath();
     numberOfFolds = length(dir(crossValFolderPath))-2; % -2 because . and .. folder stuff
     sumTER = 0;
     for fold = 1 : numberOfFolds
         [averTER, TER] = GetSubjectTERInOneFold(SystemFolder, selectedSubjectNumber, numberOfFolds, selectedStrategy);
         sumTER = sumTER + averTER;
     end
     averageTER = sumTER/numberOfFolds;
end

function [foldAverageError, errorArray] = GetErrorValueForOneSubject(SystemFolder, selectedSubjectNumber, selectedStrategy)
    crossValFolderPath = SystemFolder.GetCrossValFolderPath();
    numberOfFolds = length(dir(crossValFolderPath))-2; % -2 because . and .. folder stuff
    sumError = 0;
    for fold = 1 : numberOfFolds
        [averageOneFoldError, errorArray] = GetSubjectErrorInOneFold(SystemFolder, selectedSubjectNumber, fold, selectedStrategy);
        sumError = sumError + averageOneFoldError;
    end
    foldAverageError = sumError/numberOfFolds;
end

function [averageTER, TER] = GetSubjectTERInOneFold(SystemFolder, selectedSubjectNumber, foldNumber, selectedStrategy)
    nthFoldPath = SystemFolder.GetCrossValNthFolderPath(foldNumber);
    [fileNames] = GetSubjectATfileNames(nthFoldPath, selectedSubjectNumber);
    txtNumber = length(fileNames);
    switch selectedStrategy
        case 5
            [sumTER, TER] = TERLoop(txtNumber, fileNames, SystemFolder, nthFoldPath);
        case 6
            [sumTER, TER] = TERLoop(txtNumber, fileNames, SystemFolder, nthFoldPath);
    end
    averageTER = sumTER / txtNumber;
end

function [averageError, errorArray] = GetSubjectErrorInOneFold(SystemFolder, selectedSubjectNumber, foldNumber, selectedStrategy)
    nthFoldPath = SystemFolder.GetCrossValNthFolderPath(foldNumber);
    [fileNames] = GetSubjectATfileNames(nthFoldPath, selectedSubjectNumber);
    txtNumber = length(fileNames);
    sumError = 0;
    switch selectedStrategy
        case 1
           [sumError, errorArray] = RMSELoop(txtNumber, fileNames, SystemFolder, nthFoldPath);
        case 2
           [sumError, errorArray] = RMSELoop(txtNumber, fileNames, SystemFolder, nthFoldPath);
        case 3
           [sumError, errorArray] = AreaDifferenceLoop(txtNumber, fileNames, SystemFolder, nthFoldPath);
        case 4
           [sumError, errorArray] = AreaDifferenceLoop(txtNumber, fileNames, SystemFolder, nthFoldPath);
    end
    averageError = sumError/txtNumber;
end

function [sumTER, TER] = TERLoop(txtNumber, fileNames, SystemFolder, nthFoldPath)
    sumTER = 0;
    TER = zeros(3,txtNumber);
    prevSubjectNumber = 0;
    subjectSumCSVPictureCoords = 0;
    for i = 1: txtNumber
        fileName = fileNames(i).name;
        [nextSubjectNumber, imageName] = GetCSVLineInfromation(fileName);
        imageNumber = GetImageNumber(imageName);
        if nextSubjectNumber ~=  prevSubjectNumber
            sumCSVPath = SystemFolder.GetSumCSVFolderPath();
            csvFilePath = strcat(sumCSVPath, '\', 'Subject_',num2str(nextSubjectNumber),'.csv');
            numberOfLines = GetNumberOfPicturesInCSVFile(csvFilePath);
            %load to memory the sumCSV subject file image coords
            subjectSumCSVPictureCoords = LoadSubjectSumCSV(csvFilePath, numberOfLines); % x,y;coords;image Id
            prevSubjectNumber = nextSubjectNumber;     
        end
        originalCoords = subjectSumCSVPictureCoords(:,:,imageNumber);
        %[originalCoords] = GetOriginalCoordsForFile(fileName, SystemFolder);
        [trainedCoords] = GetTrainedCoordsForFile(fileName, nthFoldPath);
        [imageName] = GetImageName(fileName);
        imagePath = strcat(nthFoldPath, '\', imageName);
        [ averageTer] = CalculateTERBetweenCoordArray( originalCoords, trainedCoords, imagePath );
        sumTER = sumTER + averageTer;
        TER(:,i) = averageTer;
        %disp(averageTer);
    end
end

function [sumError, errorArray] = AreaDifferenceLoop(txtNumber, fileNames, SystemFolder, nthFoldPath)
    sumError = 0;
    errorArray = zeros(1,txtNumber);
    prevSubjectNumber = 0;
    subjectSumCSVPictureCoords = 0;
    for i = 1 : txtNumber
        fileName = fileNames(i).name;
        [nextSubjectNumber, imageName] = GetCSVLineInfromation(fileName);
        imageNumber = GetImageNumber(imageName);
        if nextSubjectNumber ~=  prevSubjectNumber
            sumCSVPath = SystemFolder.GetSumCSVFolderPath();
            csvFilePath = strcat(sumCSVPath, '\', 'Subject_',num2str(nextSubjectNumber),'.csv');
            numberOfLines = GetNumberOfPicturesInCSVFile(csvFilePath);
            %load to memory the sumCSV subject file image coords
            subjectSumCSVPictureCoords = LoadSubjectSumCSV(csvFilePath, numberOfLines); % x,y;coords;image Id
            prevSubjectNumber = nextSubjectNumber;     
        end
        originalCoords = subjectSumCSVPictureCoords(:,:,imageNumber);
       % [originalCoords] = GetOriginalCoordsForFile(fileName, SystemFolder);
        [trainedCoords] = GetTrainedCoordsForFile(fileName, nthFoldPath);
        [imageName] = GetImageName(fileName);
        imagePath = strcat(nthFoldPath, '\', imageName);
        areaError = CalculateAreaDifferenceBetweenCoordArray( originalCoords, trainedCoords, imagePath );
        sumError = sumError + areaError;
        errorArray(i) = areaError;
       % disp(areaError);
    end
end

% fileNames := txt traced data in nfoldCrossVal. folder
function [sumError, errorArray] = RMSELoop(txtNumber, fileNames, SystemFolder, nthFoldPath)
    sumError = 0;
    errorArray = zeros(1,txtNumber);
    prevSubjectNumber = 0;
    subjectSumCSVPictureCoords = 0;
    for i = 1 : txtNumber
        fileName = fileNames(i).name;
        [nextSubjectNumber, imageName] = GetCSVLineInfromation(fileName);
        imageNumber = GetImageNumber(imageName);
        if nextSubjectNumber ~=  prevSubjectNumber
            sumCSVPath = SystemFolder.GetSumCSVFolderPath();
            csvFilePath = strcat(sumCSVPath, '\', 'Subject_',num2str(nextSubjectNumber),'.csv');
            numberOfLines = GetNumberOfPicturesInCSVFile(csvFilePath);
            %load to memory the sumCSV subject file image coords
            subjectSumCSVPictureCoords = LoadSubjectSumCSV(csvFilePath, numberOfLines); % x,y;coords;image Id
            prevSubjectNumber = nextSubjectNumber;     
        end
        originalCoords = subjectSumCSVPictureCoords(:,:,imageNumber);
     %  [originalCoords] = GetOriginalCoordsForFile(fileName, SystemFolder);
        trainedCoords = GetTrainedCoordsForFile(fileName, nthFoldPath);
        [imageName] = GetImageName(fileName);
        imagePath = strcat(nthFoldPath, '\', imageName);   
%        PrintTwoPointArray( originalCoords, trainedCoords, imagePath );
        RMSE = CalculateRMSEBetweenCoordArray( originalCoords, trainedCoords, imagePath );
        sumError = sumError + RMSE;
        errorArray(i) = RMSE;
        %disp(RMSE);
    end
end

function subjectSumCSVPictureCoords = LoadSubjectSumCSV(csvFilePath, numberOfLines)
    subjectSumCSVPictureCoords = zeros(2,32,numberOfLines); % x,y;coords;image Id
    fileId = OpenFile(csvFilePath);
    readLine = fgetl(fileId); % skip header from csv
    readLine = fgetl(fileId);
    while ischar(readLine)
        [lineCoords, imageNumber] = ConvertReadLineToCoords(readLine);
        subjectSumCSVPictureCoords(:,:,imageNumber) = lineCoords;
        readLine = fgetl(fileId);
    end
    fclose(fileId);
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
            csvFilePath = strcat(sumCSVPath, '\', oneCSVName);
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
            [lineCoords, imageNumber] = ConvertReadLineToCoords(readLine);
            break;
        end
        readLine = fgetl(fileId);
    end
    fclose(fileId);
end

function numberOfLines = GetNumberOfPicturesInCSVFile(csvFilePath)
    fid = fopen(csvFilePath, 'rb');
    %# Get file size.
    fseek(fid, 0, 'eof');
    fileSize = ftell(fid);
    frewind(fid);
    %# Read the whole file.
    data = fread(fid, fileSize, 'uint8');
    
    numberOfLines = sum(data == 10) -1; % -1 because of the CSV header  
    fclose(fid);
end

function [coords, imageNumber] = ConvertReadLineToCoords(readLine)
    coords = zeros(2,32);
    split = strsplit(readLine, '\t');
    imageNameCell = split(1);
    imageName = imageNameCell{1,1};
    imageNumber = GetImageNumber(imageName);
    for i = 2 : 65 % 64 = number of coords x & y
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
    splitArray = strsplit(fileName, {'_','.'});
    subjectCell = splitArray(2);
    imageCell = splitArray(3);
    imageName = strcat(imageCell{1,1}, '.jpg');
    subjectNumber = str2num(subjectCell{1,1});
end

function [imageName] = GetImageName(fileName)
    splitArray = strsplit(fileName, '.');
    imageCell = splitArray(1);
    imageName = strcat(imageCell{1,1}, '.jpg');
end

function imageNumber = GetImageNumber(imageName)
    splitArray = strsplit(imageName, '.');
    imageNumberCell = splitArray(1);
    imageNumber = str2num(imageNumberCell{1,1});
end

function [trainedCoords] = GetTrainedCoordsForFile(fileName, nthFoldPath)
    filePath = strcat(nthFoldPath, '\', fileName);
    trainedCoords = ReadAutotraceOutputTxt( filePath );
end

function [fileNames] = GetSubjectATfileNames(nthFoldPath, selectedSubjectNumber)
    txtFilePath = strcat(nthFoldPath, '\', 'Subject_', num2str(selectedSubjectNumber), '*.txt');
    fileNames = dir(txtFilePath);
end

function [selectedStrategy, selectedSubject] = SelectStrategy(SystemFolder)
    disp('1: Get RMSE for ONE SUBJECT (all fold)');
    disp('2: Get RMSE for ONE MODEL (all fold)');
    disp('3: GET Area between train and manual point line ONE SUBJECT (all fold)');
    disp('4: Get Atea between train and manual point line ONE MODEL (all fold)');
    disp('5: Get TER (Tracking Error Rate) for ONE SUBJECT');
    disp('6: Get TER (Tracking Error Rate) for ONE MODEL');
    prompt = 'Select one strategy to calculate RMSE (Default 1. strategy with 1. subject) : ';
    selectedStrategy = input(prompt);
    switch selectedStrategy
        case 1
            prompt1 = strcat('Select one subject 1-',num2str(SystemFolder.GetNumberOfSubject()), ':  ');
            selectedSubject = input(prompt1);
        case 2
            selectedSubject = 0;
        case 3
            prompt1 = strcat('Select one subject 1-',num2str(SystemFolder.GetNumberOfSubject()), ':  ');
            selectedSubject = input(prompt1);
        case 4
            selectedSubject = 0;
        case 5
            prompt1 = strcat('Select one subject 1-',num2str(SystemFolder.GetNumberOfSubject()), ':  ');
            selectedSubject = input(prompt1);
        case 6
            selectedSubject = 0;
        otherwise
            selectedStrategy = 1;
            selectedSubject = 1;
    end
end

