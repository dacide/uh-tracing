function [ averageError ] = DifferenceBetweenManualContours(  )
    % beolvasni a saját csv-t
    % beolvasni másik kontúrt
    
    firstManualContourPath = 'C:\ubuntueswin\NEWDATA\TSFILES\SML\1\ts_1.csv';
    secondManualContourPath = 'C:\ubuntueswin\FolderSystem\sumCSV\Subject_1.csv';
    
    imageBasePath = 'C:\ubuntueswin\FolderSystem\convertedImages\Subject1';
    
    [allFirstSentenceCoords] = ReadOneCSV(firstManualContourPath);
    [allSecondSentenceCoords] = ReadOneCSV(secondManualContourPath);
    
    sumError = 0;
    
    if size(allFirstSentenceCoords,3) ~= size(allSecondSentenceCoords,3)
        disp('FUUUUU');
    end
    
    for i = 1 : size(allFirstSentenceCoords,3)
        [imageNumber] = GenerateImageDigitNumber(4, i, 1);
        imagePath = strcat(imageBasePath,'\',imageNumber,'.jpg');
        firstSentenceCoords = allFirstSentenceCoords(:,:,i);
        secondSentenceCoords = allSecondSentenceCoords(:,:,i);
        %error = CalculateRMSEBetweenCoordArray( firstSentenceCoords, secondSentenceCoords, imagePath );
       %error = CalculateAreaDifferenceBetweenCoordArray( firstSentenceCoords, secondSentenceCoords, imagePath );
        [ error] = CalculateTERBetweenCoordArray( firstSentenceCoords, secondSentenceCoords, imagePath );
       sumError = sumError + error;
        pause(0.2);
    end
    
    averageError = sumError/size(allFirstSentenceCoords,3);
    
    
end

function [imageNumber] = GenerateImageDigitNumber(pictureNumberDigit, fileRow, startPictureIndex)
     specification = strcat('%0',num2str(pictureNumberDigit),'d');
     index = fileRow + startPictureIndex - 1;
     imageNumber = num2str(index,specification);
end

function [allPictureCoords] = ReadOneCSV(csvFilePath)
    csvFileID = OpenFile(csvFilePath);
    readedLine = fgetl(csvFileID); % read header !!!
    readedLine = fgetl(csvFileID);
    allPictureCoords = zeros(2,32,500);
    pictureNumber = 0;
    while ischar(readedLine)
        splitLine = strsplit(readedLine, '\t');
        pictureNameCell = splitLine(1);
        pictureName = pictureNameCell{1,1};
        [lineCoords] = ConvertReadLineToCoords(readedLine);
        pictureNumber = pictureNumber + 1;
        allPictureCoords(:,:,pictureNumber) = lineCoords;
        readedLine = fgetl(csvFileID);
    end
    fclose(csvFileID);
    allPictureCoords(:,:,pictureNumber+1:end) = [];
    
end

function [coords] = ConvertReadLineToCoords(readLine)
    coords = zeros(2,32);
    split = strsplit(readLine, '\t');
    for i = 2 : 65 % 64 = number of coords x + y
        cell = split(i);
        modul = mod(i,2);
        if modul == 0
            coords(1,i/2) = str2num(cell{1,1});
        else
            coords(2,(i-1)/2) = str2num(cell{1,1});
        end
    end
end

function [fileId] = OpenFile(filePath)
    fileId = fopen(filePath, 'r');
    if fileId <= 0 
        disp('____ERROR WHILE READ FILE____');
    end
end
