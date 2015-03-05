function PreparationForErrorEval( SystemFolder, trainArray, testArray, cycleNumber)
    
    DeleteTrainAndTestFiles(SystemFolder);
    %DeleteCrossValidationTestImages( SystemFolder ); % Nem töröljük õket
    %mert oda mentõdik le a tracing eredménye!!!
    FusionCSVFilesV2( SystemFolder, trainArray, testArray);
    FusionROIFilesForAllSubject(SystemFolder);
    
    [train_ultrasound, train_contours, test_ultrasound, test_contours, practice_run, ...
        max_num_images, use_crossval, Nfolds, network_sizes, network_types, data_dir, subject_nums, roi] = ...
        GetTrainNetworkVariables(SystemFolder);
    
    TrainNetwork(train_ultrasound, train_contours, test_ultrasound, test_contours, practice_run, ...
           max_num_images, use_crossval, Nfolds, network_sizes, network_types, data_dir, subject_nums, roi);
       
    fclose('all');
    
    ReplaceTestImages(SystemFolder, cycleNumber);
        
    ReplaceNeuralModel(SystemFolder, cycleNumber, NeuralModelFolderPath);
    
    %----Get data for AutoTrace.m----
    neuralModelNthFolderPath = SystemFolder.GetNeuralModelNthFolderPath(foldNumber);
    networkFileName = StringPlusNumber('network', '.mat', cycleNumber);
    networkFile = strcat(neuralModelNthFolderPath, '\', networkFileName);
    
    directory = SystemFolder.GetCrossValNthFolderPath(cycleNumber);
    
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
    network_sizes = '[size(trainX,2), floor(size(XC,2)),  floor(size(XC,2)), size(XC,2)*5]'; % *(1/2) node 3 rejtett réteg
    network_types = {'gaussian', 'sigmoid', 'sigmoid','sigmoid'};
    data_dir = SystemFolder.GetTrainDataFolderPath();
    subject_nums = [1:1:SystemFolder.numberOfSubjects];
    maxROICoords = GetHighestROIDimensions(SystemFolder);   %needed beacause of the different region of interest coords
    %averageROICoords = GetAverageROIDimensions(SystemFolder);
    roi = maxROICoords;
end

function [] = ReplaceTestImages(SystemFolder, nFoldIteration)
    [sourcePath, destinationPath] = GetSourceAndDestFolderForTestImages(SystemFolder, nFoldIteration);
    copyfile(strcat(sourcePath, '\', '*.jpg'), strcat(destinationPath, '\'));
end

function [sourcePath, destinationPath] = GetSourceAndDestFolderForTestImages(SystemFolder, nFoldIteration)
    sourcePath = SystemFolder.GetTestDataFolderPath();
    crossValFolderPath = SystemFolder.GetCrossValFolderPath();
    mkdir(crossValFolderPath, num2str(nFoldIteration));
    destinationPath = strcat(crossValFolderPath, '\', num2str(nFoldIteration));
end

function [] = ReplaceNeuralModel(SystemFolder, numberOfModelFolder, sourceNeuralModelFolderPath)
    neuralModelFolderPath = SystemFolder.GetNeuralModelFolderPath();
    mkdir(neuralModelFolderPath, num2str(numberOfModelFolder));
    destination = SystemFolder.GetNeuralModelNthFolderPath(numberOfModelFolder);
    networkFileName = StringPlusNumber('network', '.mat', numberOfModelFolder);
    meancdistFileName = StringPlusNumber('meancdist', '.mat', numberOfModelFolder);
    movefile(strcat(sourceNeuralModelFolderPath, '\network.mat'), strcat(destination, '\' , networkFileName));
    movefile(strcat(sourceNeuralModelFolderPath, '\meancdist.mat'), strcat(destination, '\', meancdistFileName));
end

function [fileName] = StringPlusNumber(firstString, secondString, number)
    fileName = strcat(firstString, '_', num2str(number), secondString);
end
