function [ allImageCoord, startImageIndex, endImageIndex, ROICoords ] = ReadFromNewFileType( us )
  %  [us] = MA_load_tracking('C:\ubuntueswin\NEWDATA\2\FonetikaUS_CSTG_0001.csv', 'liza', 'speaker0020', 'session0001');
    
    numberOfPicture = us.num_frames;
    [maxNumberOfCoords, ROICoords] = GetMaxNumberOfCoordsAndROI(us);
    ROICoords = round(ROICoords);
    allImageCoord = zeros(2,maxNumberOfCoords,numberOfPicture);
    
    for i = 1 : numberOfPicture
        imagePoints = us.frames(i);        
        xCoord = imagePoints.x;
        yCoord = imagePoints.y;
        [simpleArray] = SimpifyArray(xCoord, yCoord);
        simpleArrayLength = length(simpleArray);
        for j = 1 : simpleArrayLength
            allImageCoord(1,j,i) = simpleArray(1,j);
            allImageCoord(2,j,i) = simpleArray(2,j);
        end
    end
    %pictureDirPath = 'C:\ubuntueswin\FolderSystem\newTypeOfData\1\FonetikaUS_CSTG_0001_jpg\####.jpg';
    startImageIndex = 1;
    endImageIndex = numberOfPicture;
    
    
end

function [simpleArray] = SimpifyArray(xCoord, yCoord)
    sortedX = sort(xCoord);
    unigueX = unique(round(sortedX));
    simplifyLength = length(unigueX);
    originalLength = length(xCoord);
    simpleArray = zeros(2,simplifyLength);
    for i = 1 : simplifyLength
        uniqueXCoord = unigueX(i);
        sumYCoord = 0;
        foundYCoord = 0;
        for j = 1 : originalLength 
            if uniqueXCoord == round(xCoord(j))
                sumYCoord = sumYCoord + yCoord(j);
                foundYCoord = foundYCoord + 1;
            end
        end
        simpleArray(1,i) = round(uniqueXCoord);
        simpleArray(2,i) = round(sumYCoord/foundYCoord);
    end
end

function [maxNumberOfCoords, ROI] = GetMaxNumberOfCoordsAndROI(us)
    numberOfImages = us.num_frames;
    top = 1000;
    bottom = 0;
    left = 1000;
    right = 0;
    maxNumberOfCoords = 0;
    for i = 1 : numberOfImages
        imagePoints = us.frames(i);
        xCoord = imagePoints.x;
        yCoord = imagePoints.y;
        coordsLength = length(xCoord);
        if coordsLength > maxNumberOfCoords
            maxNumberOfCoords = coordsLength;
        end
        for j = 1 : coordsLength
            if xCoord(j) < left
                left = xCoord(j);
            end
            if xCoord(j) > right
                right = xCoord(j);
            end
            if yCoord(j) < top
                top = yCoord(j);
            end
            if yCoord(j) > bottom
                bottom = yCoord(j);
            end
        end
    end
    ROI = [top-10, bottom+10, left-10, right+10];
end

