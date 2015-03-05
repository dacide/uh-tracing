function [] = TESTING( SystemFolder, modelNumber )
    
    [train_ultrasound, train_contours, test_ultrasound, test_contours, practice_run, ...
    max_num_images, use_crossval, Nfolds, network_sizes, network_types, data_dir, subject_nums, roi] = ...
    GetTrainNetworkVariables(SystemFolder);

    %----Get data for AutoTrace.m----
        neuralModelNthFolderPath = SystemFolder.GetNeuralModelNthFolderPath(modelNumber);
        networkFileName = StringPlusNumber('network', '.mat', modelNumber);
        networkFile = strcat(neuralModelNthFolderPath, '\', networkFileName);
        
        directory = SystemFolder.GetCrossValNthFolderPath(modelNumber);
        
       [xs, ys] = AutoTracer(directory, roi, networkFile);
       
       
    

end

function [train_ultrasound, train_contours, test_ultrasound, test_contours, practice_run, ...
    max_num_images, use_crossval, Nfolds, network_sizes, network_types, data_dir, subject_nums, roi] = ...
    GetTrainNetworkVariables(SystemFolder)
    train_ultrasound = 'true';
    train_contours = 'true';
    test_ultrasound = 'true';
    test_contours = 'false';
    practice_run = 0;%'false';
    max_num_images = Inf;%'Inf';
    use_crossval = 0;'false';
    Nfolds = 5;
    network_sizes = '[size(trainX,2), size(XC,2), size(XC,2), size(XC,2)*5]'; % 5
    network_types = {'gaussian', 'sigmoid', 'sigmoid', 'sigmoid'};
    data_dir = SystemFolder.GetTrainDataFolderPath();
    subject_nums = [1:1:SystemFolder.numberOfSubjects];
    maxROICoords = GetHighestROIDimensions(SystemFolder);   %needed beacause of the different regions of interest coords
    %averageROICoords = GetAverageROIDimensions(SystemFolder);
    roi = maxROICoords;
end

function [fileName] = StringPlusNumber(firstString, secondString, number)
    fileName = strcat(firstString, '_', num2str(number), secondString);
end