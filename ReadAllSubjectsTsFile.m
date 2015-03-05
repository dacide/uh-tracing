function [] = ReadAllSubjectsTsFile(FolderSystemObject)
    subjectsFolderPath = FolderSystemObject.GetTsFilesFolderPath();
    %subjectsFolderPath = 'C:\ubuntueswin\networkSystem\tsfiles\';
    folderName = GetAllFolderName(subjectsFolderPath);
    
    numberOfSubjects = length(folderName);
    
    for folderNumber = 1 : numberOfSubjects
        %subjectFolderPath = strcat(subjectsFolderPath, folderName(folderNumber));
        %subjectFolderPath = strcat(subjectFolderPath,'\');
        ReadAllTsFileInSubjectFolder(FolderSystemObject, folderNumber);
    end
    
end

function[folderName] = GetAllFolderName(subjectsFolderPath)
    directories = dir(subjectsFolderPath);
    isFolder = [directories(:).isdir];
    folderName = {directories(isFolder).name}';
    folderName(ismember(folderName,{'.','..'})) = [];
    folderName = folderName';
end

function[] = ReadAllTsFileInSubjectFolder(FolderSystemObject, folderNumber)
    subjectFolderPath = FolderSystemObject.GetTsSubjectFolderPath(folderNumber);    
   % f = dir(subjectFolderPath{1,1});
    f = dir(subjectFolderPath);
    isfile = [f(:).isdir];
    nameFiles = {f(~isfile).name}'; % just files not folders
    nameFiles = nameFiles';
    
    numberOfTsFiles = length(nameFiles);
    
    for fileNumber = 1 : numberOfTsFiles
        fileNameArray = strsplit(nameFiles{1,fileNumber},'.');
        csvFilePath = GetCsvPath(fileNameArray, FolderSystemObject, folderNumber);
        ROIFilePath = GetROIFilePath(fileNumber,FolderSystemObject, folderNumber);
        [tsFilePath] = GetTSFilePath(nameFiles, FolderSystemObject, folderNumber , fileNumber);       
        StartConversation(tsFilePath, csvFilePath, ROIFilePath);
    end
end

function[csvFilePath] = GetCsvPath(fileNameArray, FolderSystemObject, folderNumber)
    csvFolderPath = FolderSystemObject.GetTsSubjectCSVFolderPath(folderNumber);
    fileName = strcat(fileNameArray(1), '.csv');
    csvFilePath = strcat(csvFolderPath, '\', fileName{1,1});
end

function [ROIFilePath] = GetROIFilePath(fileNumber,FolderSystemObject, folderNumber)
    roiFolderPath = FolderSystemObject.GetTsSubjectROIFolderPath(folderNumber);
    ROINum = strcat('ROIconfig', num2str(fileNumber));
    ROIwithExtension = strcat(ROINum, '.txt');
    ROIFilePath = strcat(roiFolderPath, '\', ROIwithExtension);
end

function [tsFilePath] = GetTSFilePath(nameFiles,  FolderSystemObject, folderNumber, fileNumber)
    subjectTsFolderPath = FolderSystemObject.GetTsSubjectFolderPath(folderNumber);
    tsFilePath = strcat(subjectTsFolderPath, '\', nameFiles{1, fileNumber});
end

