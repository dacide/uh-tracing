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
    
    %--------INIT----------%
    numberOfSubjects = 17;     
    baseFolderPath = 'C:\ubuntueswin\FolderSystem'; 
    numberOfSpeakers = 2;
    speakerSubjectMatrix = [1 8; 9 17];     % egy sor tartalmazza az n. speaker kezdõ és vég subject számát       
    SystemFolder = FolderSystem(baseFolderPath, numberOfSubjects, numberOfSpeakers, speakerSubjectMatrix);   
    selectedSpeakerNumber = 1;  % Kiválasztott beszélõ száma. Egyszerre több is szerepelhet a rendszerben, de a kiválasztás után a többivel nem foglalkozunk.    
    ColdStartTrainingData = [1 2]; % Elsõ ciklusban tanításhoz felhasznált subjectek számai
    SubjectsPercentageForTraining = 80;
    
    
    %------------ITERATION----------------%
    TestData = DetermineTrainingOrTestVector(SystemFolder, selectedSpeakerNumber, ColdStartTrainingData);
    TrainData = ColdStartTrainingData;
    
    %Megadja az iterációk számát x% mellett
    iterationNumber = GetIterationNumberForSpeaker(SystemFolder, SubjectsPercentageForTraining, selectedSpeakerNumber, ColdStartTrainingData);
    
    for iteration = 0 : iterationNumber
        %Elkészül a modell, megtörténik a tracing
        PreparationForErrorEval( SystemFolder, TrainData, TestData, iteration);
        % ErrorEvaluation for modell
        [RMSE_MODEL_AVERAGE, rmseArrayModel] = RunErrorEvaluation( SystemFolder, 2, SelectedSubject);
        [AREA_MODEL_AVERAGE, areaArrayModel] = RunErrorEvaluation( SystemFolder, 4, SelectedSubject);
        [TER_MODEL_AVERAGE, terArrayModel] = RunErrorEvaluation( SystemFolder, 6, SelectedSubject);
        
        %TODO: SAVE TO FILE THE AVERAGE ERROR VALUES WITH THE ITERATION FLAG
        
        %Kiválasztjuk azt a subjectet amit hozzárakunk a trainer vektorhoz
        plusTrainerSubject = SelectPlusOneTrainerSubject(SystemFolder, TestData);
        
        %TrainerDatához hozzáadni, TestDatából kivenni... TODO
        
    end
    
end

% Legroszabbul teljesítõ subjectet kell hozzáadni a trainhez
function plusTrainerSubject = SelectPlusOneTrainerSubject(SystemFolder, TestData)
    RMSE_MAX = 0;
    AREA_MAX = 0;
    RMSE_MAX_SUBJECT = 0;
    AREA_MAX_SUBJECT = 0;
    % TER-nél mit nézzek ? kisebb nagyobb ? SUBS-nál minél kisebb annál
    % jobb. insertion - kisebb jobb ; deletion - kisebb jobb
    
    %Subjectek közül melyiket adjuk hozzá a trainhez???
    for subjectNumber = 1 : size(TestData,2)
        SelectedSubject = TestData(subjectNumber);
        disp('Subject hibáinak vizsgálata: ',SelectedSubject); % hiba
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
       ... % TODO : TER-re is hasonlóan megcsinálni
    end
    
    %valami alapján ki kéne választani, megvan a legrosszabb RMSE;AREA;TER
    %subjectek, lehet hogy nem egyeznek, lehet hogy minde különbözõ.. mi
    %alapján válasszunk ?
    %TODO Tamás válasza alapján
    if RMSE_MAX_SUBJECT == 0
        plusTrainerSubject = TestData(1);
    else
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
        disp('Nem elég nagy a speakerSubjectMatrix');
        SpeakerSubjectNumber = 0;
    end
end

function vector = GenerateSubjectNumberList(SpeakerSubjectNumber)
    vector = SpeakerSubjectNumber(1) : SpeakerSubjectNumber(2);
end

