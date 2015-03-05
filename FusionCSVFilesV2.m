function FusionCSVFilesV2( SystemFolder, trainSubjectData, testSubjectData)
    % konstans teszt adatsor, egy subject;
    % bemeneten megadni [] vektorként, hogy melyik subjectek legyenek a
    % tanító adatok
    % trainSubjectData = [1,2,3,4,11,...];
    % testSubjectData = [5,6];
    
    % külön megcsinálni mindegyiknek a teljes csv fájlt.
    % ha benne van a train cuccban akkor mehet a trainbe
    
    HandleTrainData(SystemFolder, trainSubjectData);
    HandleTestData(SystemFolder, testSubjectData);
end

function HandleTestData(SystemFolder, testSubjectData)
    testNumber = length(testSubjectData);
    for i = 1 : testNumber
        testSubjectNumber = testSubjectData(i);
        CopyImagesToTestFolder(SystemFolder, testSubjectNumber);
    end
end

function HandleTrainData(SystemFolder, trainSubjectData)
    numberOfSubject = SystemFolder.GetNumberOfSubject();
    for i = 1 : numberOfSubject
        insideArray = ElementInArray(trainSubjectData, i);
        if insideArray == 1
            CopySumCSVFileToTrainFolder(SystemFolder, i);
            CopyImagesToTrainFolder(SystemFolder, i); 
        else
            CreateEmptyCSVFile(SystemFolder, i);
        end         
    end
end

function CreateEmptyCSVFile(SystemFolder, subjectNumber)
    fileHeader = GenerateFileHeader();
    trainSubjectFolderPath = strcat(SystemFolder.GetTrainerSubjectFolderPath(subjectNumber),'\TongueContours.csv');
    fileId = fopen(trainSubjectFolderPath,'w');
    WriteRowToFile(fileId, fileHeader);
    fclose(fileId);
end

function [] = WriteRowToFile(fileId, fileRowData)
    itemsNum = length(fileRowData);
    for i = 1 : itemsNum
        fprintf(fileId,['%s','\t'],fileRowData{1,i});
    end
    fprintf(fileId, '\n');
end

function [fileHeader] = GenerateFileHeader()
    fileHeader = 'Filename';
    maxRawIndex = 32;
    maxAuxIndex = 10;
    for index = 1 : maxRawIndex
        for coord = 1:2
            if coord == 1
                coordPart = 'x';
            else
                coordPart = 'y';
            end
            rawR = GetRawR(index, coordPart);
            fileHeader = [fileHeader, rawR];
        end
    end
    for index = 1 : maxAuxIndex
        for coord = 1:2
            if coord == 1
                coordPart = 'x';
            else
                coordPart = 'y';
            end
            [aux] = GetAux(index, coordPart);
            fileHeader = [fileHeader, aux];
        end
    end
end

function [rawR] = GetRawR(index, coordPart)
    raw = 'Raw.';
    R = strcat('R',num2str(index),'.');
    rawR = cellstr(strcat(raw,R,upper(coordPart)));
end

function [aux] = GetAux(index, coordPart)
    au = 'Aux';
    aux = cellstr(strcat(au, num2str(index), '.', lower(coordPart)));
end

function boolean = ElementInArray(array, element)
    member = ismember(array, element);
    boolean = 0;
    for i = 1 : length(member)
        if member(i) == 1
            boolean = 1;
            break;
        end
    end
end


function CopyImagesToTestFolder(SystemFolder, testSubjectNumber)
    imageOrigin = SystemFolder.GetSubjectConvertedetImageFolderPath(testSubjectNumber);
    allFiles = dir( imageOrigin );
    allNames = {allFiles(~[allFiles.isdir]).name};
    imageNumber = length(allNames);
    for i = 1 : imageNumber
        cellName = allNames(i);
        name = cellName{1};
        imageOriginPath = strcat(imageOrigin,'\', name);
        splitName = strsplit(name, '.');
        numberNameCell = splitName(1);
        numberName = numberNameCell{1};
        destinationImageName = strcat('Subject_', num2str(testSubjectNumber),'_',numberName,'.jpg');
        imageDestination = strcat(SystemFolder.GetTestDataFolderPath(),'\', destinationImageName);
        copyfile(imageOriginPath, imageDestination);
    end
end

function CopyImagesToTrainFolder(SystemFolder, trainSubjectNumber)
    imageOrigin = strcat(SystemFolder.GetSubjectConvertedetImageFolderPath(trainSubjectNumber), '\*.jpg');
    imageDestination = SystemFolder.GetTrainerSubjectImagesFolderPath(trainSubjectNumber);
    copyfile(imageOrigin,imageDestination);
end

function CopySumCSVFileToTrainFolder(SystemFolder, trainSubjectNumber)
    trainSubjectNameOrigin = strcat('Subject_', num2str(trainSubjectNumber));
    csvOrigin = strcat(SystemFolder.GetSumCSVFolderPath(),'\', trainSubjectNameOrigin, '.csv');
    csvDestination = strcat(SystemFolder.GetTrainerSubjectFolderPath(trainSubjectNumber), '\TongueContours.csv');
    copyfile(csvOrigin, csvDestination);
end
