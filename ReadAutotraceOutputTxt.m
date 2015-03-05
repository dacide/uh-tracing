function [ onePictureCoords ] = ReadAutotraceOutputTxt( filePath )
    coordsNumber = GetFileCoordsNumber(filePath);
    fileId = OpenFile(filePath);
    onePictureCoords = zeros(2, coordsNumber);
    for i = 1 : coordsNumber
        readLine = fgetl(fileId);
        splitLine = strsplit(readLine, '\t');
        xCoords = round(str2num(splitLine{1,2}));
        yCoords = round(str2num(splitLine{1,3}));
        onePictureCoords(1,i) = xCoords;
        onePictureCoords(2,i) = yCoords;
    end
    fclose(fileId);
end

function fileId = OpenFile(filePath)
    fileId = fopen(filePath);
    if fileId <=0
        disp('Error while readin AutoTrace generated txt file');
        disp(filePath);
    end
end

function coordsNumber = GetFileCoordsNumber(filePath)
    fileId = OpenFile(filePath);
    readLine = 'default';
    readLineNumber = 0;
    while ischar(readLine)
        readLine = fgetl(fileId);
        readLineNumber = readLineNumber + 1;       
    end
    fclose(fileId);
    coordsNumber = readLineNumber - 1;
end

