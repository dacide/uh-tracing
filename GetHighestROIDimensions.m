function [ maxROICoords ] = GetHighestROIDimensions( SystemFolder )
    numberOfROIFiles = SystemFolder.GetNumberOfSubject();
    
  %  speakersSubjMatrix = SystemFolder.GetSpeakerSubjectMatrix();
  %  speakerSubjMatrix = speakersSubjMatrix(selectedSpeaker,:);
  %  subjects = [speakerSubjMatrix(1):speakerSubjMatrix(2)];
  %  numberOfROIFiles = length(subjects);
    
    trainerSubjectFolderPath  = SystemFolder.GetTrainerSubjectFolderPath(1);
    ROIFilePath = strcat(trainerSubjectFolderPath, '\', 'ROI_config.txt');
    maxROICoords = ReadROIFile( ROIFilePath );
    
 %   maxROICoords = [1000, 0, 1000, 0];
    for i = 1 : numberOfROIFiles
       trainerSubjectFolderPath  = SystemFolder.GetTrainerSubjectFolderPath(i);
       ROIFilePath = strcat(trainerSubjectFolderPath, '\', 'ROI_config.txt');
       tempROICoords = ReadROIFile( ROIFilePath );
       maxROICoords = ConcatenateROI(maxROICoords, tempROICoords);
    end
end

function [maxRoi] = ConcatenateROI(maxRoi, tempRoi)
    if tempRoi(1) < maxRoi(1)
        maxRoi(1) = tempRoi(1);
    end
    if tempRoi(2) > maxRoi(2)
        maxRoi(2) = tempRoi(2);
    end
    if tempRoi(3) < maxRoi(3)
        maxRoi(3) = tempRoi(3);
    end
    if tempRoi(4) > maxRoi(4)
        maxRoi(4) = tempRoi(4);
    end
end
