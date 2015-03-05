function [allPictureCoordinates, pictureDirPath, startPictureIndex, endPictureIndex, ROIcoords] = ReadFromEdgeTrack(tsFilePath)
    % n. darab kép ( max indexszám értéke)
    % pontok száma ( 10. érték a TS fájlban)
    % mátrix amiben tároljuk a koordinátákat:
    %   3D mátrix
    %   2*pontok_szám*képek_száma 
    
    % TS File important data row numbers and features
    pictureDirPathPlace = 3;
    startPictureIndexPlace = 4;
    endPictureIndexPlace = 5;
    ROIcoordsPlace = 7;
    numberOfFirstCoordsPlace = 10;
    CharBetweenCoords = ' ';
    
    % Default values
    pictureDirPath = 'none';
    startPictureIndex = -1;
    endPictureIndex = -1;
    numberOfPictures = -1;
    firstNumberOfCoords = -1;
    ROIcoords = -1;
    
    
    %Get all picture coord number in vector
    allPictureCoordsNumber= getCoordsPerPicture(tsFilePath, numberOfFirstCoordsPlace);
    
    maxNumberOfCoords = max(allPictureCoordsNumber);
    fileId = getFileOpened(tsFilePath);
    
    % Store all pictures dot coordinates
    % dimension:
    %   2 X Number_of_coordinates_in_one_picture X Number_of_pictures
    %   2: first -> X      second -> Y
    allPictureCoordinates = zeros(2,maxNumberOfCoords,length(allPictureCoordsNumber));
    
    readedLine = fgetl(fileId);
    readedLineNum = 1;
    [convertedCoordsBorders] = convertCorrdsBorder(numberOfFirstCoordsPlace, allPictureCoordsNumber);
    
    while ischar(readedLine)
        %disp(readedLine);
        switch readedLineNum
            case pictureDirPathPlace
                pictureDirPath = readedLine;
            case startPictureIndexPlace
                startPictureIndex = round(str2double(readedLine));
            case endPictureIndexPlace
                endPictureIndex = round(str2double(readedLine));
                numberOfPictures = endPictureIndex;
            case numberOfFirstCoordsPlace 
                firstNumberOfCoords = round(str2double(readedLine));
            case ROIcoordsPlace
                ROIcoords = str2num(readedLine);
        end
        
        if readedLineNum > numberOfFirstCoordsPlace
            [allPictureCoordinates] = InsertLineToMatrix(allPictureCoordinates, CharBetweenCoords, readedLine, readedLineNum, numberOfFirstCoordsPlace, allPictureCoordsNumber, convertedCoordsBorders);
        end
        
        readedLine = fgetl(fileId);
        readedLineNum = readedLineNum + 1;
    end
    
    fclose(fileId);
    %disp(pictureDirPath);
    %disp(startPictureIndex);
    %disp(allPictureCoordsNumber);
end

function [allCoords] = InsertLineToMatrix(allCoords, CharBetweenCoords, readedLine, readedLineNum, numberOfFirstCoordsPlace, allPictureCoordsNumber, convertedCoordsBorders)
        splittedArray = strsplit(readedLine, CharBetweenCoords);
        splittedArray = SetToRow(splittedArray);
        [coordPlace, picturePlace, isCoords] = convertLineNumberToMatrixIndex(readedLine, readedLineNum, numberOfFirstCoordsPlace, allPictureCoordsNumber, convertedCoordsBorders);
        if isCoords ~= 0
            xCoord = round(str2double(splittedArray(1)));
            yCoord = round(str2double(splittedArray(2)));
            allCoords(1,coordPlace,picturePlace) = xCoord;
            allCoords(2,coordPlace,picturePlace) = yCoord;
        end
        
end

% 0-> its not coords; 1-> it's coords
function [boolean] = IsLineShowsCoords (readedLine)
    boolean = 0;
    numberOfElements = length(strsplit(readedLine));
    if numberOfElements == 2
        boolean = 1;
    end
end

function [rowArray] = SetToRow(array)
    rowArray = array;
    if isrow(array) ~= 1
        rowArray = array';
    end
end
 
function [coordPlace, picturePlace, isCoords] = convertLineNumberToMatrixIndex(readedLine, readedLineNum, numberOfFirstCoordsPlace, allPictureCoordsNumber, convertedCoordsBorders)
    boolean = IsLineShowsCoords(readedLine);
    %disp(boolean);
    %disp(convertedCoordsBorders);
    if boolean == 1
       for i = 1:(length(convertedCoordsBorders)-1)
            if (convertedCoordsBorders(i) < readedLineNum) && (convertedCoordsBorders(i+1) > readedLineNum)
                picturePlace = i;
                isCoords = 1;
                coordPlace = readedLineNum - convertedCoordsBorders(i);
                break
            end
       end
    else
        coordPlace = -1;
        picturePlace = -1;
        isCoords = 0;
    end
end

function [convertedCoordsBorders] = convertCorrdsBorder(numberOfFirstCoordsPlace, allPictureCoordsNumber)
    nextBorder = numberOfFirstCoordsPlace;
    for i = 1:(length(allPictureCoordsNumber)+1)
        if i == 1
            convertedCoordsBorders = [numberOfFirstCoordsPlace];      
        else
            nextBorder = nextBorder + allPictureCoordsNumber(i-1) + 1;
            convertedCoordsBorders = [convertedCoordsBorders, nextBorder];
        end
    end
   % [convertedCoordsBorders] = SetToRow(convertedCoordsBorders);
end

function fileId = getFileOpened(filePath)
    fileId = fopen(filePath);
    if fileId == -1
        disp('Log: Read error, no file found');
    end
end

% To get all picture point coordinates
function [numberOfCoordsPerPicture] = getCoordsPerPicture(filePath, numberOfFirstCoordsPlace)
    fileId = getFileOpened(filePath);    
    readedLine = fgetl(fileId);
    readedLineNum = 1; 
    offsetToNextCoord = numberOfFirstCoordsPlace;
    numberOfCoordsPerPicture=-1;  
    while ischar(readedLine)
        if readedLineNum == offsetToNextCoord
            coordsNum = round(str2double(readedLine));
            if numberOfCoordsPerPicture == -1
                 numberOfCoordsPerPicture = coordsNum;
            else
                numberOfCoordsPerPicture = [numberOfCoordsPerPicture, coordsNum];
            end
           offsetToNextCoord = offsetToNextCoord + coordsNum +1;
        end
        readedLine = fgetl(fileId);
        readedLineNum = readedLineNum + 1;
    end
    fclose(fileId);
end

function [lastReadCoordNum, maxNumberOfCoords, lastReadedLineNum] = checkIfMaxCoordNum(readedLineNum, readedLine, lastReadCoordNum, maxNumberOfCoords, lastReadedLineNum)
     if readedLineNum == (lastReadCoordNum + lastReadedLineNum + 1)
            lastReadCoordNum = round(str2double(readedLine));
            if lastReadCoordNum > maxNumberOfCoords
                maxNumberOfCoords = lastReadCoordNum;
            end
            lastReadedLineNum = readedLineNum;
     end
end
