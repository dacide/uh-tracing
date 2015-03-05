function [] = WriteCoordsToFile( allCoords, pictureNumberDigit, startPictureIndex, endPictureIndex, writingFilePathName )
    
    flagCharacter = '#';
    pictureExtension = 'jpg';
    
    fileName = writingFilePathName;
    %flagCharPlaces = strfind(pictureDirPath, flagCharacter);
   % pictureNumberDigit = length(flagCharPlaces);
   
   pictureNumberDigit = 4; % ####
   
    coordsMatrixDimension = size(allCoords);
    numberOfPoints = coordsMatrixDimension(2);
    numberOfPictures = coordsMatrixDimension(3);
    
    [fileHeader] = GenerateFileHeader();

    fileId = fopen(fileName,'w');
    for fileRow = 0 : numberOfPictures
        if fileRow == 0
            WriteRowToFile(fileId, fileHeader);
             %disp(fileHeader);
        else
            pictureCoords = allCoords(:,:,fileRow);
            [imageNumber] = GenerateImageDigitNumber(pictureNumberDigit, fileRow, startPictureIndex);
            [imageNumberPlusExtension] = AddExtensionToNumber(imageNumber, pictureExtension);
            [pictureRow] = GeneratePictureRow(imageNumberPlusExtension, pictureCoords);
            %disp(pictureRow);
            WriteRowToFile(fileId, pictureRow);
        end   
    end
    fclose(fileId);   
end

% IF startPictureIndex == 1, just gives us the row number in all coords
% matrix
function [imageNumber] = GenerateImageDigitNumber(pictureNumberDigit, fileRow, startPictureIndex)
     specification = strcat('%0',num2str(pictureNumberDigit),'d');
     index = fileRow + startPictureIndex - 1;
     imageNumber = cellstr(num2str(index,specification));
end

function [imageNumberPlusExtension] = AddExtensionToNumber(imageNumber, extension)
    ext = strcat('.', extension);
    imageNumberPlusExtension = cellstr(strcat(imageNumber, ext));
end

function [fileHeader] = GenerateFileHeader()
    fileHeader = 'Filename';
    maxRawIndex = 32;
    maxAuxIndex = 10;
    for index = 1 : maxRawIndex
        for coord = 1:2
            if coord == 1
                coordPart = 'x';
            else
                coordPart = 'y';
            end
            rawR = GetRawR(index, coordPart);
            fileHeader = [fileHeader, rawR];
        end
    end
    for index = 1 : maxAuxIndex
        for coord = 1:2
            if coord == 1
                coordPart = 'x';
            else
                coordPart = 'y';
            end
            [aux] = GetAux(index, coordPart);
            fileHeader = [fileHeader, aux];
        end
    end
end

function [rawR] = GetRawR(index, coordPart)
    raw = 'Raw.';
    R = strcat('R',num2str(index),'.');
    rawR = cellstr(strcat(raw,R,upper(coordPart)));
end

function [aux] = GetAux(index, coordPart)
    au = 'Aux';
    aux = cellstr(strcat(au, num2str(index), '.', lower(coordPart)));
end

function [pictureRow] = GeneratePictureRow(pictureNumberPlusExtension, pictureCoords)
    maxRawIndex = 32;
    maxAuxIndex = 10;
    defaultAux = -1;
    pictureRow = [cellstr(pictureNumberPlusExtension)];
    for point = 1 : maxRawIndex
        for coord = 1 : 2
              pictureRow = [pictureRow, cellstr(num2str(pictureCoords(coord,point)))];
        end
    end
    for point = 1 : maxAuxIndex
        for coord = 1 : 2
             pictureRow = [pictureRow, cellstr(num2str(defaultAux))];
        end
    end
end

function [] = WriteRowToFile(fileId, fileRowData)
    itemsNum = length(fileRowData);
    for i = 1 : itemsNum
        fprintf(fileId,['%s','\t'],fileRowData{1,i});
    end
    fprintf(fileId, '\n');
end

