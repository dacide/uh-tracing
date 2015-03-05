function [] = RunNFoldCrossValidation(SystemFolder, trainArray, testArray,numberOfModelFolder)
% megadni hogy hány fold cross validation
% ez lesz a ciklusszám

    %minden ciklusban törölni a train és a teszt adatokat    
    % elindítani teszt és train adat készítést 
    %ROI számítás módosítása. ROI fájlok számítása 
    %TrainNetwork.m módosítása. futtatása
    %lementeni máshová a tanított modellt jelezve a ciklusszámot  
    % de elõtte a tesztet átmásolni egy mappába ami jelzi a crossval.
    % ciklusát   
    %futtatni a kiértékelést és lementeni a végeredményt valahova.
    
   
    
   % SystemFolder = FolderSystem('C:\ubuntueswin\FolderSystem', 4);
    NeuralModelFolderPath = 'C:\ubuntueswin\Autotrace-master\old\savefiles';
   % [strategyNumber, percentage, selectedSubjectNumber]= ChooseTestDatasetGetterStrategy(SystemFolder.numberOfSubjects);
    nFoldCrossVal = 1;
 %   nFoldNumber = GetNFoldNumber(); %nFoldNumber = 1;
 nFoldNumber = 1;
    for foldNumber = 1 : nFoldNumber
        
        DeleteTrainAndTestFiles(SystemFolder);
        DeleteCrossValidationTestImages( SystemFolder );
       % FusionCSVFilesForAllSubject(SystemFolder, nFoldCrossVal, strategyNumber, percentage, selectedSubjectNumber);
        
        %kell hozzá az összes sumcsv file;
        %hatékonyság növelés: teszt adatot ha állandó nem újramásolni
        FusionCSVFilesV2( SystemFolder, trainArray, testArray);
        
        FusionROIFilesForAllSubject(SystemFolder);
        
        [train_ultrasound, train_contours, test_ultrasound, test_contours, practice_run, ...
        max_num_images, use_crossval, Nfolds, network_sizes, network_types, data_dir, subject_nums, roi] = ...
        GetTrainNetworkVariables(SystemFolder);
        
        TrainNetwork(train_ultrasound, train_contours, test_ultrasound, test_contours, practice_run, ...
           max_num_images, use_crossval, Nfolds, network_sizes, network_types, data_dir, subject_nums, roi);

        fclose('all');
        
        ReplaceTestImages(SystemFolder, foldNumber);
        
        ReplaceNeuralModel(SystemFolder, numberOfModelFolder, NeuralModelFolderPath);
        
        %----Get data for AutoTrace.m----
        neuralModelNthFolderPath = SystemFolder.GetNeuralModelNthFolderPath(foldNumber);
        networkFileName = StringPlusNumber('network', '.mat', foldNumber);
        networkFile = strcat(neuralModelNthFolderPath, '\', networkFileName);
        
        directory = SystemFolder.GetCrossValNthFolderPath(foldNumber);
        
        [xs, ys] = AutoTracer(directory, roi, networkFile);
        %somehow save these two cucc

    end
    
end

function nFoldNumber = GetNFoldNumber()
    nFoldNumber = 10;
    prompt = 'How many folds do you want to calculate?  ';
    nFoldNumber = input(prompt);
end

function [strategyNumber, percentage, selectedSubject]= ChooseTestDatasetGetterStrategy(subjectNumber)
   % console input for a number
   disp('1. From all subject get X% to be the test data');
   disp('2. From one subject get X% to be the test data');
   prompt = 'Choose test getter strategy!  ';
   result = input(prompt);
   switch result
       case 1
           strategyNumber = 1;  % from all user get X %
           [percentage] = GetPercentageForStrategy();
           selectedSubject = 0;
       case 2
           strategyNumber = 2;  % from one user get X %
           [percentage] = GetPercentageForStrategy();
           [selectedSubject] = SelectSubjectTest(subjectNumber);
       otherwise
            disp('_________Wrong input number!________');
            strategyNumber = 0;
   end 
end

function[percentage] = GetPercentageForStrategy()
    prompt= 'What should be the TEST persentage (default 10%)? 1-100:  ';
    result = input(prompt);
    if result > 0 && result <= 100
        percentage = result;
    else
        percentage = 10;
    end
end

function [selectedSubject] = SelectSubjectTest(subjectNumber)
    prompt = strcat('Which subject should be test data (default = 1)? Write in 1-', num2str(subjectNumber), ':   ');
    result = input(prompt);
    if result >= 1 && result <= subjectNumber
        selectedSubject = result;
    else
        selectedSubject = 1;
    end
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
