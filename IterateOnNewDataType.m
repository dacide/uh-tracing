function [] = IterateOnNewDataType(SystemFolder)
    %numberOfSession = 8;
    numberOfSession = 9;
    %startSubjectFolderNumber = 1;%start from 1 different beszélõkhöz tartozó mondatok
   startSubjectFolderNumber = 28 ;
  csvFilePath = 'C:\ubuntueswin\NEWDATA\4\FonetikaUS_CSTG\FonetikaUS_CSTG_0001_0009.csv'; % speaker0020
    %csvFilePath ='C:\ubuntueswin\NEWDATA\3\CMU-US-ARCTIC_SML\cmu_us_arctic_sml_0001_0008.csv'; %speaker0014
    speaker = 'speaker0020';
    %speaker = 'speaker0014';

    for i = 0:numberOfSession-1
        subjectFolderNumber = startSubjectFolderNumber+i;
        [us] = MA_load_tracking(csvFilePath, 'liza', speaker, ['session000' num2str(i+1)]);
        writingCsvFilePath = strcat(SystemFolder.GetTsSubjectCSVFolderPath(subjectFolderNumber),'\ts_1.csv');
        ROIFilepath = strcat(SystemFolder.GetTsSubjectROIFolderPath(subjectFolderNumber),'\ROIconfig1.txt');
        StartNewDataConversation(writingCsvFilePath, ROIFilepath, us);
    end

end

