function [] = CreateROIFile( ROICoords, writingFilePathName )
    
    %TS file roi indexes
    upCoordIndex = 1;
    downCoordIndex = 2;    
    leftCoordIndex = 3;
    rightCoordIndex = 4;
    
    
    if ~ROICoords
        disp('Error while reading Region of interest');
    else
        [header] = generateROIHeader();
        fileName = writingFilePathName;
        fileId = fopen(fileName,'w');
        for fileRow = 0 : 4
            if fileRow == 0
                WriteToFile(fileId, header);
            else
                [row] = generateROIRow(fileRow, ROICoords, upCoordIndex, downCoordIndex, leftCoordIndex, rightCoordIndex);
                WriteToFile(fileId, row);
            end
        end
    end
    fclose(fileId);
end

function [header] = generateROIHeader()
    header1 = 'machine';
    header2 = 'UNKNOWN';
    header = cellstr([cellstr(header1), cellstr(header2)]);
end

function [row] = generateROIRow(rowNumber, ROICoords, upCoordIndex, downCoordIndex, leftCoordIndex, rightCoordIndex)
    switch rowNumber
        case 1
            row = cellstr(['top', cellstr(num2str(ROICoords(upCoordIndex)))]);
        case 2
            row = cellstr(['bottom', cellstr(num2str(ROICoords(downCoordIndex)))]);
        case 3
            row = cellstr(['left', cellstr(num2str(ROICoords(leftCoordIndex)))]);
        case 4
            row = cellstr(['right', cellstr(num2str(ROICoords(rightCoordIndex)))]);
    end
end

function [] = WriteToFile(fileId, fileRowData)
    itemsNum = length(fileRowData);
    for i = 1 : itemsNum
        fprintf(fileId,['%s','\t'],fileRowData{1,i});
    end
    fprintf(fileId, '\n');
end
