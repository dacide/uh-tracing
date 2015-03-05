function [] = DeleteTrainAndTestFiles(SystemFolderObject)
    fclose('all');
    DeleteTainFiles(SystemFolderObject);
    DeleteTestImages(SystemFolderObject);
end

function [] = DeleteTainFiles(SystemFolderObject)
    subjectsNumber = SystemFolderObject.numberOfSubjects;
    for i = 1 : subjectsNumber
        DeleteTrainImages(SystemFolderObject, i);
        DeleteCSVAndROIFiles(SystemFolderObject, i);
    end
end

function [] = DeleteTrainImages(SystemFolderObject, subjectNumber)
    imagesFilePath = SystemFolderObject.GetTrainerSubjectImagesFolderPath(subjectNumber);
    delete(strcat(imagesFilePath, '\', '*.jpg'));
end

function [] = DeleteCSVAndROIFiles(SystemFolderObject, subjectNumber)
    subjectFolderPath = SystemFolderObject.GetTrainerSubjectFolderPath(subjectNumber);
    delete(strcat(subjectFolderPath, '\', 'ROI_config.txt'));
    delete(strcat(subjectFolderPath, '\', 'TongueContours.csv'));
end

function [] = DeleteTestImages(SystemFolderObject)
    testImagesPath = SystemFolderObject.GetTestDataFolderPath();
    delete(strcat(testImagesPath, '\', '*.jpg'));
end