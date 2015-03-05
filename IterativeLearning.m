function [ output_args ] = IterativeLearning()
    
    % F�cs�r�k:
        % - Kiv�laszthat� melyik userre fusson az iterat�v tan�t�s, ha t�bb
        % speaker van egyszerre jelen a libraryben (�s csakis egy userre lehet iterat�v tan�tani)



    % TODO: iterat�v tan�t�adat n�vel�s:
        %- 1 kiindul�si �llapot 'R0': megadott mondatokkal kezdeni a tan�t�st (sz�mvektorral megadni)
        %- Erre k�sz�teni egy DNN modelt
        %- Modelt letesztelni az �sszes t�bbi marad�k mondatra
        %- RMSE; AREA; ... adatok alapj�n legrosszabbul teljes�t� mondatot hozz�adni (TODO: CSAK EGY MONDATOT HOZZ�ADNI EGYSZERRE) 'R0'-hoz. 'R0'+egy mondat = 'R1'
        %- Lementeni a hiba �rt�keket elemz�sre

        %-'R1'-el k�sz�teni egy �j modellt
        %- ...

        %- ez menjen a mondatok 50-70-X % -ig.
    
    %--------INIT----------%
    numberOfSubjects = 17;     
    baseFolderPath = 'C:\ubuntueswin\FolderSystem'; 
    numberOfSpeakers = 2;
    speakerSubjectMatrix = [1 8; 9 17];     % egy sor tartalmazza az n. speaker kezd� �s v�g subject sz�m�t       
    SystemFolder = FolderSystem(baseFolderPath, numberOfSubjects, numberOfSpeakers, speakerSubjectMatrix);   
    selectedSpeakerNumber = 1;  % Kiv�lasztott besz�l� sz�ma. Egyszerre t�bb is szerepelhet a rendszerben, de a kiv�laszt�s ut�n a t�bbivel nem foglalkozunk.    
    ColdStartTrainingData = [1 2]; % Els� ciklusban tan�t�shoz felhaszn�lt subjectek sz�mai
    SubjectsPercentageForTraining = 80;
    
    
    %------------ITERATION----------------%
    TestData = DetermineTrainingOrTestVector(SystemFolder, selectedSpeakerNumber, ColdStartTrainingData);
    TrainData = ColdStartTrainingData;
    
    %Megadja az iter�ci�k sz�m�t x% mellett
    iterationNumber = GetIterationNumberForSpeaker(SystemFolder, SubjectsPercentageForTraining, selectedSpeakerNumber, ColdStartTrainingData);
    
    for iteration = 0 : iterationNumber
        %Elk�sz�l a modell, megt�rt�nik a tracing
        PreparationForErrorEval( SystemFolder, TrainData, TestData, iteration);
        % ErrorEvaluation for modell
        [RMSE_MODEL_AVERAGE, rmseArrayModel] = RunErrorEvaluation( SystemFolder, 2, SelectedSubject);
        [AREA_MODEL_AVERAGE, areaArrayModel] = RunErrorEvaluation( SystemFolder, 4, SelectedSubject);
        [TER_MODEL_AVERAGE, terArrayModel] = RunErrorEvaluation( SystemFolder, 6, SelectedSubject);
        
        %TODO: SAVE TO FILE THE AVERAGE ERROR VALUES WITH THE ITERATION FLAG
        
        %Select the plus one subject ID for the next iteration's train array
        plusTrainerSubject = SelectPlusOneTrainerSubject(SystemFolder, TestData);
        
        %TrainerDat�hoz hozz�adni, TestDat�b�l kivenni... TODO
        newTrainData = PutInSelectedSubjectToTrain(TrainData, selectedSubjectId);
        newTestData = TakeOffSelectedSubjectFromTest(TestData, selectedSubjectId);
        
        TrainData = newTrainData;
        TestData = newTestData;
        
    end
    
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
        plusTrainerSubject = RMSE_MAX_SUBJECT;
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
        disp('Nem el�g nagy a speakerSubjectMatrix');
        SpeakerSubjectNumber = 0;
    end
end

function vector = GenerateSubjectNumberList(SpeakerSubjectNumber)
    vector = SpeakerSubjectNumber(1) : SpeakerSubjectNumber(2);
end

