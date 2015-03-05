classdef FolderSystem
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        baseFolderPath = '';
        numberOfSubjects = 0; % SUBJECT is the SENTENCE or the RECORDED UNIT NOT THE SPEAKER
        numberOfSpeakers =  0; % SHOWS how many speaker has subjects in the system
        speakerSubjectMatrix = []; % Stores each speaker start and end subject number
        trainDataFolderName = 'trainData';
        basicImagesFolderName = 'basicImages';
        convertedImagesFolderName = 'convertedImages'
        testDataFolderName = 'testData';
        tsFilesFolderName = 'tsFiles';
        crossValidationFolderName = 'crossValidationTestImages';
        neuralModelFolderName = 'neuralModels'
        sumCSVFolderName = 'sumCSV'
        
        subjectFolderBaseName = 'Subject';
        subjectTrainImagesFolderName = 'IMAGES'
        roiFolderName = 'roi';
        csvFolderName = 'csv';
    end
    
    methods
        
        %baseFolderPath, numberOfSubject, numberOfSpeakers, speakerSubjectMatrix
        function obj = FolderSystem(varargin)
            if nargin>2
                numberOfSpeakersLoc = varargin{3};
                speakerSubjectMatrixLoc = varargin{4};
                numberOfSubjectsLoc = varargin{2};
                if size(speakerSubjectMatrixLoc,1) >= numberOfSpeakersLoc && numberOfSubjectsLoc == speakerSubjectMatrixLoc(numberOfSpeakersLoc,2)
                    obj.numberOfSpeakers = numberOfSpeakersLoc;
                    obj.speakerSubjectMatrix = speakerSubjectMatrixLoc;
                else
                    disp('FolderSystem speakers number conflict!');
                end
            end
            obj.baseFolderPath = varargin{1};
            obj.numberOfSubjects = varargin{2};
        end
        
        function AddSpeakersInformation(obj, numberOfSpeakers, speakerSubjectMatrix)
            if size(speakerSubjectMatrix,1) >= numberOfSpeakers && obj.numberOfSubjects == speakerSubjectMatrix(numberOfSpeakers,2)
                obj.numberOfSpeakers = numberOfSpeakers;
                obj.speakerSubjectMatrix = speakerSubjectMatrix;
            else
                disp('FolderSystem speakers number conflict!');
            end
        end
        
        function numberOfSpeakers = GetNumberOfSpeakers(obj)
            numberOfSpeakers = obj.numberOfSpeakers;
        end
        
        function speakerSubjectMatrix = GetSpeakerSubjectMatrix(obj)
            speakerSubjectMatrix = obj.speakerSubjectMatrix;
        end
        
        function sumCSVFolderPath = GetSumCSVFolderPath(obj)
            baseFolderPathf = GetBaseFolderPath(obj);
            sumCSVFolderPath = strcat(baseFolderPathf, '\', obj.sumCSVFolderName);
        end
        
        function numberOfSubject = GetNumberOfSubject(obj)
            numberOfSubject = obj.numberOfSubjects;
        end
        
        function baseFolderPath = GetBaseFolderPath(obj)
            baseFolderPath = obj.baseFolderPath;
        end
        
        function trainDataFolderPath = GetTrainDataFolderPath(obj)
            baseFolderPathf = GetBaseFolderPath(obj);
            trainDataFolderPath = strcat(baseFolderPathf, '\', obj.trainDataFolderName);
        end
        
        function crossValFolderPath = GetCrossValFolderPath(obj)
            baseFolderPathf = GetBaseFolderPath(obj);
            crossValFolderPath = strcat(baseFolderPathf, '\', obj.crossValidationFolderName);
        end
        
        function crossValNthFolderPath = GetCrossValNthFolderPath(obj, nthFold)
            crossValFolderPath = GetCrossValFolderPath(obj);
            crossValNthFolderPath = strcat(crossValFolderPath, '\', num2str(nthFold));
        end
        
        function neuralModelFolderPath = GetNeuralModelFolderPath(obj)
            baseFolderPathf = GetBaseFolderPath(obj);
            neuralModelFolderPath = strcat(baseFolderPathf, '\', obj.neuralModelFolderName);
        end
        
        function neuralModelNthFolderPath = GetNeuralModelNthFolderPath(obj, folderNumber)
            neuralModelFolderPath = GetNeuralModelFolderPath(obj);
            neuralModelNthFolderPath = strcat(neuralModelFolderPath, '\', num2str(folderNumber));
        end
        
        function basicImagesFolderPath = GetBasicImagesFolderPath(obj)
            baseFolderPathf = GetBaseFolderPath(obj);
            basicImagesFolderPath = strcat(baseFolderPathf, '\', obj.basicImagesFolderName);
        end
        
        function convertedImagesFolderPath = GetConvertedImagesFolderPath(obj)
            baseFolderPathf = GetBaseFolderPath(obj);
            convertedImagesFolderPath = strcat(baseFolderPathf, '\', obj.convertedImagesFolderName);
        end
        
        function subjectConvertedetImageFolderPath = GetSubjectConvertedetImageFolderPath(obj, subjectNumber)
            convertedImagesFolderPath = GetConvertedImagesFolderPath(obj);
            subjectFolderName = SubjectFolderPlusNumber(obj, subjectNumber);
            subjectConvertedetImageFolderPath = strcat(convertedImagesFolderPath, '\', subjectFolderName);
        end
        
        function testDataFolderPath = GetTestDataFolderPath(obj)
            baseFolderPathf = GetBaseFolderPath(obj);
            testDataFolderPath = strcat(baseFolderPathf, '\', obj.testDataFolderName);
        end
        
        function tsFilesFolderPath = GetTsFilesFolderPath(obj)
            baseFolderPathf = GetBaseFolderPath(obj);
            tsFilesFolderPath = strcat(baseFolderPathf, '\', obj.tsFilesFolderName);
        end
        
        function specificTrainerSubjectFolderPath = GetTrainerSubjectFolderPath(obj, subjectNumber)
            subjectFolderName = SubjectFolderPlusNumber(obj, subjectNumber);
            trainDataFolderPath = GetTrainDataFolderPath(obj);
            specificTrainerSubjectFolderPath = strcat(trainDataFolderPath, '\', subjectFolderName);
        end
        
        function specificTrainerSubjectImagesFolderPath = GetTrainerSubjectImagesFolderPath(obj, subjectNumber)
            specificTrainerSubjectFolderPath = GetTrainerSubjectFolderPath(obj, subjectNumber);
            specificTrainerSubjectImagesFolderPath = strcat(specificTrainerSubjectFolderPath, '\', obj.subjectTrainImagesFolderName);
        end
        
        function specificTsSubjectFolderPath = GetTsSubjectFolderPath(obj, subjectNumber)
            tsFilesFolderPath = GetTsFilesFolderPath(obj);
            subjectFolderName = SubjectFolderPlusNumber(obj, subjectNumber);
            specificTsSubjectFolderPath = strcat(tsFilesFolderPath, '\', subjectFolderName);
        end
        
        function specificTsSubjectROIFolderPath = GetTsSubjectROIFolderPath(obj, subjectNumber)
            specificTsSubjectFolderPath = GetTsSubjectFolderPath(obj, subjectNumber);
            specificTsSubjectROIFolderPath = strcat(specificTsSubjectFolderPath, '\', obj.roiFolderName);
        end
        
        function specificTsSubjectCSVFolderPath = GetTsSubjectCSVFolderPath(obj, subjectNumber)
            specificTsSubjectFolderPath = GetTsSubjectFolderPath(obj, subjectNumber);
            specificTsSubjectCSVFolderPath = strcat(specificTsSubjectFolderPath, '\', obj.csvFolderName);
        end
        
        function InitializeFolderSystem(obj)
            mkdir(obj.baseFolderPath, obj.trainDataFolderName);
            mkdir(obj.baseFolderPath, obj.basicImagesFolderName);
            mkdir(obj.baseFolderPath, obj.convertedImagesFolderName);
            mkdir(obj.baseFolderPath, obj.testDataFolderName);
            mkdir(obj.baseFolderPath, obj.tsFilesFolderName);
            mkdir(obj.baseFolderPath, obj.crossValidationFolderName);
            mkdir(obj.baseFolderPath, obj.neuralModelFolderName);
            mkdir(obj.baseFolderPath, obj.sumCSVFolderName);
            
            CreateTsFileDirectory(obj);
            CreateTrainFileDirectory(obj);
            CreateBasicImageFileDirectory(obj);
            CreateConvertedImageFileDirectory(obj)
        end
        
    end
    
    methods (Access = private)
                  
        function subjectFolderName = SubjectFolderPlusNumber(obj, subjectNumber)
            subjectFolderName = strcat(obj.subjectFolderBaseName, num2str(subjectNumber));
        end
        
        function [] = CreateImagesFolder(obj, parentPath)
            mkdir(parentPath, obj.subjectTrainImagesFolderName);
        end
        
        function [] = CreateCSVandROIFolders(obj, parentPath)
            mkdir(parentPath, obj.roiFolderName);
            mkdir(parentPath, obj.csvFolderName);
        end
        
        function [] = CreateTrainFileDirectory(obj)
            subjectNumber = obj.numberOfSubjects;
            trainDataFolderPath = GetTrainDataFolderPath(obj);
            for i = 1 : subjectNumber
                subjectFolderName = SubjectFolderPlusNumber(obj, i);
                specificTrainerSubjectFolderPath = GetTrainerSubjectFolderPath(obj, i);
                mkdir(trainDataFolderPath, subjectFolderName);
                CreateImagesFolder(obj, specificTrainerSubjectFolderPath);
            end
        end
        
        function [] = CreateTsFileDirectory(obj)
            subjectNumber = obj.numberOfSubjects;
            tsFilesFolderPath = GetTsFilesFolderPath(obj);
            for i = 1 : subjectNumber
                subjectFolderName = SubjectFolderPlusNumber(obj, i);
                specificTsSubjectFolderPath = GetTsSubjectFolderPath(obj, i);
                mkdir(tsFilesFolderPath, subjectFolderName);               
                CreateCSVandROIFolders(obj, specificTsSubjectFolderPath);
            end
        end
        
        function [] = CreateBasicImageFileDirectory(obj)
            subjectNumber = obj.numberOfSubjects;
            basicImagesFolderPath = GetBasicImagesFolderPath(obj);
            for i = 1 : subjectNumber
                subjectFolderName = SubjectFolderPlusNumber(obj, i);
                mkdir(basicImagesFolderPath, subjectFolderName); 
            end  
        end
        
        function [] = CreateConvertedImageFileDirectory(obj)
            subjectNumber = obj.numberOfSubjects;
            convertedImagesFolderPath = GetConvertedImagesFolderPath(obj);
            for i = 1 : subjectNumber
                subjectFolderName = SubjectFolderPlusNumber(obj, i);
                mkdir(convertedImagesFolderPath, subjectFolderName); 
            end  
        end
        
    end
    
end

