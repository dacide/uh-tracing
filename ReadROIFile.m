function [ ROICoords ] = ReadROIFile( ROIFilePath )   
    [fileId] = OpenFile(ROIFilePath);
    readedLineNumber = 0;
    readedLine = fgetl(fileId);
    ROICoords = [0, 0, 0, 0];
    while ischar(readedLine)
        if readedLineNumber ~= 0
            splitLine = strsplit(readedLine, '\t');
            switch readedLineNumber
                case 1
                    ROICoords(1) = str2num(splitLine{1,2});
                case 2
                    ROICoords(2) = str2num(splitLine{1,2});
                case 3
                    ROICoords(3) = str2num(splitLine{1,2});
                case 4
                    ROICoords(4) = str2num(splitLine{1,2});
            end
        end
        readedLineNumber = readedLineNumber + 1;
        readedLine = fgetl(fileId);
    end
    fclose(fileId);
end

function [fileId] = OpenFile(filePath)
    fileId = fopen(filePath);
    if fileId <= 0
        disp('Error while read ROI file');
    end
end

