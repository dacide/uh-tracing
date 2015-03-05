% Returned matrix will contain [ [R, Phi] X NUMBER_OF_POINTS_IN_PICUTRE X NUMBER_OF_PICTURE]
% Needed to measure the origo of the polar grid. If changes, change
% variables!
% Everything is calculated in DEGREE.
function [ allTransformedPointsCoords] = CartesienToPolarCoordinate( allPointsCoords )
    
    polarOrigoX = 391;
    polarOrigoY = 426;
    
    polarOrigo = [polarOrigoX, polarOrigoY];
    origoBaseY = [0, polarOrigoY];
    origoBaseX = [polarOrigoX, 0];
    
    allCoordsDimensions = size(allPointsCoords);
    allTransformedPointsCoords = zeros(allCoordsDimensions);
    pictureNumber = allCoordsDimensions(3);
    picturePoints = allCoordsDimensions(2);
    for picture = 1: pictureNumber
        for point = 1 : picturePoints
            picturePointCoord = allPointsCoords(:,point,picture);
            if picturePointCoord(1) ~= 0 && picturePointCoord(2) ~= 0 
                [ newRCoords, newPhiCoords ] = ConvertOneCoordCartToPolar( polarOrigo, origoBaseY, picturePointCoord );
            else
                newRCoords = 0;
                newPhiCoords = 0;
            end
            allTransformedPointsCoords(1,point,picture) = newRCoords;
            allTransformedPointsCoords(2,point,picture) = newPhiCoords;
        end
    end
end