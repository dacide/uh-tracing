function [ averageROICoords ] = GetAverageROIDimensions( SystemFolder )
    numberOfROIFiles = SystemFolder.GetNumberOfSubject();
    sumROI = [0,0,0,0];
    for i = 1 : numberOfROIFiles
       trainerSubjectFolderPath  = SystemFolder.GetTrainerSubjectFolderPath(i);
       ROIFilePath = strcat(trainerSubjectFolderPath, '\', 'ROI_config.txt');
       tempROICoords = ReadROIFile( ROIFilePath );
       sumROI = sumROI + tempROICoords;
    end
    averageROICoords = round(sumROI/numberOfROIFiles);
end

