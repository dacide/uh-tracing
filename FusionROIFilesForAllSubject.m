function [] = FusionROIFilesForAllSubject(FolderSystemObject)
    subjectsFolderPath = FolderSystemObject.GetTsFilesFolderPath();
    %subjectsFolderPath = 'C:\ubuntueswin\networkSystem\tsfiles\';
    folderName = GetAllFolderName(subjectsFolderPath);
    subjects = length(folderName);
    for subjectNumber = 1 : subjects
        %oneSubjectName = folderName{1,subjectNumber};
        FusionROIFilesForOneSubject(FolderSystemObject, subjectNumber);
    end
    
end

function [] = FusionROIFilesForOneSubject(FolderSystemObject, subjectNumber)
    roiFolder = FolderSystemObject.GetTsSubjectROIFolderPath(subjectNumber);
    %roiFolder = strcat(subjectsFolderPath, oneSubjectName, '\roi\');
    [fileNames] = GetAllFileName(roiFolder);
    fileNumber = length(fileNames);
    extremeROI = [1000,0,1000,0];
    for roiFileNumber = 1 : fileNumber
        roiFileName = fileNames{1,roiFileNumber};
        ROIFilePath = strcat(roiFolder, '\', roiFileName);
        tempROI = ReadROIFile( ROIFilePath );
        extremeROI = GetExtremeArray(tempROI, extremeROI);
    end
    roiFilePath = GetExtremeRoiFilePath(FolderSystemObject, subjectNumber);
    CreateROIFile( extremeROI, roiFilePath );
end

function [roiFilePath] = GetExtremeRoiFilePath(FolderSystemObject, subjectNumber)
    basePath = FolderSystemObject.GetTrainerSubjectFolderPath(subjectNumber);
    roiFilePath = strcat(basePath, '\ROI_config.txt');
end

function [extremeArray] = GetExtremeArray(tempArray, oldExtremeArray)
    extremeArray = oldExtremeArray;
    if tempArray(1)<oldExtremeArray(1)
        extremeArray(1) = tempArray(1);
    end
    if tempArray(2)>oldExtremeArray(2)
        extremeArray(2) = tempArray(2);
    end
    if tempArray(3)<oldExtremeArray(3)
        extremeArray(3) = tempArray(3);
    end
    if tempArray(4)>oldExtremeArray(4)
        extremeArray(4) = tempArray(4);
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

