function IterativeLearning()
        
    %--------INIT FILE SYSTEM----------%
    numberOfSubjects = 57;                                      %REWRITE
    baseFolderPath = 'C:\ubuntueswin\FolderSystem2';              %REWRITE
    numberOfSpeakers = 2;                                         %REWRITE
    speakerSubjectMatrix = [1 27; 28 57];     % egy sor tartalmazza az n. speaker kezdõ és vég subject számát                  %REWRITE    
    SystemFolder = FolderSystem(baseFolderPath, numberOfSubjects, numberOfSpeakers, speakerSubjectMatrix);   
    selectedSpeakerNumber = 1;  % Kiválasztott beszélõ száma. Egyszerre több is szerepelhet a rendszerben, de a kiválasztás után a többivel nem foglalkozunk.     %REWRITE
    ColdStartTrainingData = [1]; % Elsõ ciklusban tanításhoz felhasznált subjectek számai         %REWRITE
    SubjectsPercentageForTraining = 80;              %REWRITE
    
    %---------INIT ErrorLog File----------%
    fileHeader = GenerateErrorLogHeader();
    errorValueLogName = sprintf('ErrorValue_%s.txt',datestr(now,'mm_dd_yyyy_HH_MM_SS'));
    errorValueFilePath = strcat(SystemFolder.GetErrorValueLogPath(),'\',errorValueLogName);
    errorValueFileId = fopen(errorValueFilePath,'w');
    WriteRowToFile(errorValueFileId, fileHeader);
    fclose(errorValueFileId);
    
    %------------ITERATION----------------%
    TestData = DetermineTrainingOrTestVector(SystemFolder, selectedSpeakerNumber, ColdStartTrainingData);
    TrainData = ColdStartTrainingData;
    
    % Gives iteration number from test array percentage (e.g. 80% of the test array should be train data at the end of the iterations)
    % DO NOT give 100% , because there wont be any test data at the end!!
    iterationNumber = GetIterationNumberForSpeaker(SystemFolder, SubjectsPercentageForTraining, selectedSpeakerNumber, ColdStartTrainingData);
    
    plusTrainerSubject = 0;
    
    for iteration = 1 : iterationNumber+1      
        %Create model, do testData trace
        disp(sprintf(strcat('Iteration: ',num2str(iteration),'\n')));
        PreparationForErrorEval( SystemFolder, TrainData, TestData, iteration);
               
        if iteration == 1
            BaseOrSelectedSubject = ColdStartTrainingData;
        else
            BaseOrSelectedSubject = plusTrainerSubject;
        end
                
        %Select the plus one subject ID for the next iteration's train
        %array AND calculate and save model error values from subject
        %error values (just average calculation)
        plusTrainerSubject = IterateOnTestSubjects(SystemFolder, TestData, iteration, errorValueFilePath, BaseOrSelectedSubject);
        
        newTrainData = PutInSelectedSubjectToTrain(TrainData, plusTrainerSubject);
        newTestData = TakeOffSelectedSubjectFromTest(TestData, plusTrainerSubject);
        
        TrainData = newTrainData;
        TestData = newTestData;
        
    end
    
end

function row = GenerateErrorValueRow(RMSE, AREA, TER, BaseOrSelectedSubject, iterationNumber)
    row = [cellstr(num2str(iterationNumber)), cellstr(num2str(RMSE)),...
        cellstr(num2str(AREA)),cellstr(num2str(TER(1))), ...
        cellstr(num2str(TER(2))), cellstr(num2str(TER(3))),...
        cellstr(num2str(BaseOrSelectedSubject))];
end

function WriteRowToFile(fileId, fileRowData)
    itemsNum = length(fileRowData);
    for i = 1 : itemsNum
        fprintf(fileId,['%s','\t'],fileRowData{1,i});
    end
    fprintf(fileId, '\n');
end

function fileHeader = GenerateErrorLogHeader()
    fileHeader = {'Iteration(Model)', 'RMSE', 'AREA', 'INS', 'DEL', 'SUBS', 'PlusSubjId'};
end

function newTrainData = PutInSelectedSubjectToTrain(oldTrainData, selectedSubjectId)
    newTrainData = [oldTrainData, selectedSubjectId];
end

function newTestData = TakeOffSelectedSubjectFromTest(oldTestData, selectedSubjectId)
    % gets rid of all cases where a is exactly equal to selectedSubjectId
    newTestData = oldTestData(oldTestData~=selectedSubjectId);
end

% Select the plus one subject ID for the next iteration's train array
% AND calculate and save model error values
function plusTrainerSubject = IterateOnTestSubjects(SystemFolder, TestData, iteration, errorValueFilePath, BaseOrSelectedSubject)
    RMSE_MAX = 0;
    AREA_MAX = 0;
    TER_MAX = [0,0,0]; % Insertion, Deletion, Substitution
    RMSE_MAX_SUBJECT = 0;
    AREA_MAX_SUBJECT = 0;
    TER_MAX_SUBJECT = 0;
    
    %plusTrainerSubj. default value
    plusTrainerSubject = TestData(1);
    
    %SUM Data for the model evaluation
    RMSE_MODEL_AVERAGE=0;
    AREA_MODEL_AVERAGE=0;
    TER_MODEL_AVERAGE= [0,0,0];
    
    for subjectNumber = 1 : size(TestData,2)
       SelectedSubject = TestData(subjectNumber);
       disp(sprintf(strcat('\n','Examined subject: ',num2str(SelectedSubject))));
       
       %RMSE subj
       [RMSE_AVERAGE, rmseArray] = RunErrorEvaluation( SystemFolder,0, 1, SelectedSubject);
       RMSE_MODEL_AVERAGE = RMSE_MODEL_AVERAGE + RMSE_AVERAGE;
       %AREA subj
       [AREA_AVERAGE, areaArray] = RunErrorEvaluation( SystemFolder,0, 3, SelectedSubject);
       AREA_MODEL_AVERAGE = AREA_MODEL_AVERAGE + AREA_AVERAGE;
       %TER subj
       [TER_AVERAGE, terArray] = RunErrorEvaluation( SystemFolder,0, 5, SelectedSubject);
       TER_MODEL_AVERAGE = TER_MODEL_AVERAGE + TER_AVERAGE;
       
       if RMSE_AVERAGE > RMSE_MAX
           RMSE_MAX_SUBJECT = SelectedSubject;
           RMSE_MAX = RMSE_AVERAGE;
       end
       
       if AREA_AVERAGE > AREA_MAX
           AREA_MAX_SUBJECT = SelectedSubject;
           AREA_MAX = AREA_AVERAGE;
       end
       
       if  all(TER_AVERAGE >= TER_MAX) % only if every value is higher than TER_MAX
           TER_MAX_SUBJECT = SelectedSubject;
           TER_MAX = TER_AVERAGE;
       end  
    end
    
    
    %-----Save new error line to error value log file --------
    RMSE_MODEL_AVERAGE = RMSE_MODEL_AVERAGE/size(TestData,2);
    AREA_MODEL_AVERAGE = AREA_MODEL_AVERAGE/size(TestData,2);
    TER_MODEL_AVERAGE = TER_MODEL_AVERAGE/size(TestData,2);
    
     % File format:
        % ITERATION(Model) ---- RMSE-----AREA----INSERTION----DELETION----SUBSTITUTION------PlusSubject
        % 1-----6.544-------1300-------0.1------0.1----------0.6---------1,2,3
        % 2------6.44--------1200--------0.5------0.6---------0.2----------7
    
    %Create and write to file the error row
    errorValueRow = GenerateErrorValueRow(RMSE_MODEL_AVERAGE, AREA_MODEL_AVERAGE, TER_MODEL_AVERAGE, BaseOrSelectedSubject, iteration);
    errorValueFileId = fopen(errorValueFilePath,'a');
    WriteRowToFile(errorValueFileId, errorValueRow);
    fclose(errorValueFileId);
    
    %----- Select the +1 trainer subject id ------
    if RMSE_MAX_SUBJECT == AREA_MAX_SUBJECT && AREA_MAX_SUBJECT == TER_MAX_SUBJECT
        %all of them ar equal
        plusTrainerSubject = RMSE_MAX_SUBJECT;
    else
        % if not all of the three error_subject equal select the XYZ error_subject
        plusTrainerSubject = AREA_MAX_SUBJECT;
    end    
end



function iterationNumber = GetIterationNumberForSpeaker(SystemFolder, percentageValue, selectedSpeakerNumber, ColdStartTrainingData)
    speakerSubjectNumber = GetSpeakerSubjectNumbers(SystemFolder.GetSpeakerSubjectMatrix(), selectedSpeakerNumber);
    subjectsForSpeaker = GenerateSubjectNumberList(speakerSubjectNumber);
    iterationNumber = floor((size(subjectsForSpeaker,2) - size(ColdStartTrainingData,2))*(percentageValue/100));
end

function vectorB = DetermineTrainingOrTestVector(SystemFolder, selectedSpeakerNumber, vectorA)
    vectorB = [];
    SpeakerSubjectNumber = GetSpeakerSubjectNumbers(SystemFolder.GetSpeakerSubjectMatrix(), selectedSpeakerNumber);
    subjectNumberList = GenerateSubjectNumberList(SpeakerSubjectNumber);
    vectorB = setdiff(subjectNumberList, vectorA);
end

function SpeakerSubjectNumber = GetSpeakerSubjectNumbers(speakerSubjectMatrix, speakerNumber)
    if size(speakerSubjectMatrix,1) >= speakerNumber
        SpeakerSubjectNumber = speakerSubjectMatrix(speakerNumber,:);
    else
        disp('Nem elég nagy a speakerSubjectMatrix');
        SpeakerSubjectNumber = 0;
    end
end

function vector = GenerateSubjectNumberList(SpeakerSubjectNumber)
    vector = SpeakerSubjectNumber(1) : SpeakerSubjectNumber(2);
end

