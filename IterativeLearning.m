function [ output_args ] = IterativeLearning()
    
    % Fícsörök:
        % - Kiválasztható melyik userre fusson az iteratív tanítás, ha több
        % speaker van egyszerre jelen a libraryben (és csakis egy userre lehet iteratív tanítani)



    % TODO: iteratív tanítóadat növelés:
        %- 1 kiindulási állapot 'R0': megadott mondatokkal kezdeni a tanítást (számvektorral megadni)
        %- Erre készíteni egy DNN modelt
        %- Modelt letesztelni az összes többi maradék mondatra
        %- RMSE; AREA; ... adatok alapján legrosszabbul teljesítõ mondatot hozzáadni (TODO: CSAK EGY MONDATOT HOZZÁADNI EGYSZERRE) 'R0'-hoz. 'R0'+egy mondat = 'R1'
        %- Lementeni a hiba értékeket elemzésre

        %-'R1'-el készíteni egy új modellt
        %- ...

        %- ez menjen a mondatok 50-70-X % -ig.
    
    %--------INIT FILE SYSTEM----------%
    numberOfSubjects = 17;     
    baseFolderPath = 'C:\ubuntueswin\FolderSystem'; 
    numberOfSpeakers = 2;
    speakerSubjectMatrix = [1 8; 9 17];     % egy sor tartalmazza az n. speaker kezdõ és vég subject számát       
    SystemFolder = FolderSystem(baseFolderPath, numberOfSubjects, numberOfSpeakers, speakerSubjectMatrix);   
    selectedSpeakerNumber = 1;  % Kiválasztott beszélõ száma. Egyszerre több is szerepelhet a rendszerben, de a kiválasztás után a többivel nem foglalkozunk.    
    ColdStartTrainingData = [1 2]; % Elsõ ciklusban tanításhoz felhasznált subjectek számai
    SubjectsPercentageForTraining = 80;
    
    %---------INIT ErrorLog File----------%
    fileHeader = GenerateErrorLogHeader();
    errorValueLogName = sprintf('ErrorValue_%s.txt',datestr(now));
    errorValueFilePath = strcat(SystemFolder.GetErrorValueLogPath(),'\',errorValueLogName);
    errorValueFileId = fopen(errorValueFilePath,'w');
    WriteRowToFile(errorValueFileId, fileHeader);
    fclose(errorValueFileId);
    
    %------------ITERATION----------------%
    TestData = DetermineTrainingOrTestVector(SystemFolder, selectedSpeakerNumber, ColdStartTrainingData);
    TrainData = ColdStartTrainingData;
    
    % Gives iteration number from test array percentage (e.g. 100% of the test array should be train data at the end of the iteration)
    iterationNumber = GetIterationNumberForSpeaker(SystemFolder, SubjectsPercentageForTraining, selectedSpeakerNumber, ColdStartTrainingData);
    
    plusTrainerSubject = 0;
    
    for iteration = 1 : iterationNumber+1      
        %Elkészül a modell, megtörténik a tracing
        PreparationForErrorEval( SystemFolder, TrainData, TestData, iteration);
        % ErrorEvaluation for model 0 - selected subject - dont care
        [RMSE_MODEL_AVERAGE, rmseArrayModel] = RunErrorEvaluation( SystemFolder, 2, 0);
        [AREA_MODEL_AVERAGE, areaArrayModel] = RunErrorEvaluation( SystemFolder, 4, 0);
        [TER_MODEL_AVERAGE, terArrayModel] = RunErrorEvaluation( SystemFolder, 6, 0);
        
        %TODO: SAVE TO FILE THE AVERAGE ERROR VALUES WITH THE ITERATION FLAG
        
        % File format:
        % ITERATION(Model) ---- RMSE-----AREA----INSERTION----DELETION----SUBSTITUTION------PlusSubject
        % 1-----6.544-------1300-------0.1------0.1----------0.6---------1,2,3
        % 2------6.44--------1200--------0.5------0.6---------0.2----------12
        
        %--------SAVE ERROR VALUE TO TXT FILE IN EVERY ITERATION------------
        if iteration == 1
            BaseOrSelectedSubject = ColdStartTrainingData;
        else
            BaseOrSelectedSubject = plusTrainerSubject;
        end
        
        %Create and write to file the error row
        errorValueRow = GenerateErrorValueRow(RMSE_MODEL_AVERAGE, AREA_MODEL_AVERAGE, TER_MODEL_AVERAGE, BaseOrSelectedSubject, iteration);
        errorValueFileId = fopen(errorValueFilePath,'w');
        WriteRowToFile(errorValueFileId, errorValueRow);
        fclose(errorValueFileId);
        
        %Select the plus one subject ID for the next iteration's train array
        plusTrainerSubject = SelectPlusOneTrainerSubject(SystemFolder, TestData);
        
        newTrainData = PutInSelectedSubjectToTrain(TrainData, selectedSubjectId);
        newTestData = TakeOffSelectedSubjectFromTest(TestData, selectedSubjectId);
        
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
function plusTrainerSubject = SelectPlusOneTrainerSubject(SystemFolder, TestData)
    RMSE_MAX = 0;
    AREA_MAX = 0;
    TER_MAX = [0,0,0]; % Insertion, Deletion, Substitution
    RMSE_MAX_SUBJECT = 0;
    AREA_MAX_SUBJECT = 0;
    TER_MAX_SUBJECT = 0;
    
    %plusTrainerSubj. default value
    plusTrainerSubject = TestData(1);
    
    for subjectNumber = 1 : size(TestData,2)
        SelectedSubject = TestData(subjectNumber);
        disp(strcat('Examined subject: ',SelectedSubject));
        %RMSE subj
       [RMSE_AVERAGE, rmseArray] = RunErrorEvaluation( SystemFolder, 1, SelectedSubject);
       %AREA subj
       [AREA_AVERAGE, areaArray] = RunErrorEvaluation( SystemFolder, 3, SelectedSubject);
       %TER subj
       [TER_AVERAGE, terArray] = RunErrorEvaluation( SystemFolder, 5, SelectedSubject);
       
       if RMSE_AVERAGE > RMSE_MAX
           RMSE_MAX_SUBJECT = SelectedSubject;
       end
       
       if ARREA_AVERAGE > AREA_MAX
           AREA_MAX_SUBJECT = SelectedSubject;
       end
       
       if  all(TER_AVERAGE > TER_MAX) % only if every value is higher than TER_MAX
           TER_MAX_SUBJECT = SelectedSubject;
       end  
    end
    
    if RMSE_MAX_SUBJECT == AREA_MAX_SUBJECT && AREA_MAX_SUBJECT == TER_MAX_SUBJECT
        %all of them ar equal
        plusTrainerSubject = RMSE_MAX_SUBJECT;
    else
        % if not all of the three error_subject equal select the XYZ error_subject        % subject
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
    if size(speakerSubjectMatrix,1) <= speakerNumber
        SpeakerSubjectNumber = speakerSubjectMatrix(speakerNumber,:);
    else
        disp('Nem elég nagy a speakerSubjectMatrix');
        SpeakerSubjectNumber = 0;
    end
end

function vector = GenerateSubjectNumberList(SpeakerSubjectNumber)
    vector = SpeakerSubjectNumber(1) : SpeakerSubjectNumber(2);
end

