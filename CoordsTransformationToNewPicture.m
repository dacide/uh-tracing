%Gets 3D matrix; (2 X NUMBER_OF_POINT_IN_ONE_PICTURE X NUMBER_OF_PICTURE)
%All picture is 600*800; else change pictureHeigth & pictureWidth
function [ transformatedCoords ] = CoordsTransformationToNewPicture( allCoords, pictureHeigth, pictureWidth, newPictureHeigth, newPictureWidth, yCoordsPictureOffset, xCoordPictureOffset)
        
    % Downscale or upscale, depends on the previous constans
    yCoordScale = newPictureHeigth / pictureHeigth;
    xCoordScale = newPictureWidth / pictureWidth;
    
    allCoordsDimensions = size(allCoords);
    transformatedCoords = zeros(allCoordsDimensions);
    pictureNumber = allCoordsDimensions(3);
    picturePoints = allCoordsDimensions(2);
    for picture = 1 : pictureNumber
        for point = 1 : picturePoints
            if allCoords(1,point,picture) ~= 0 && allCoords(2,point,picture) ~= 0
                newXCoord = round((allCoords(1,point,picture) * xCoordScale ) + xCoordPictureOffset);
                newYCoord = round((allCoords(2,point,picture) * yCoordScale ) + yCoordsPictureOffset);
            else
                newXCoord = 0;
                newYCoord = 0;
            end
            transformatedCoords(1,point,picture) = newXCoord;
            transformatedCoords(2,point,picture) = newYCoord;
        end
    end
end

