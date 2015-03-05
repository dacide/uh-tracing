function [ cartesienGridCoordinates ] = PolarCoordinateToCartesien( polarGridCoordinates )
    
    polarOrigoX = 391;
    polarOrigoY = 426;
    
    polarOrigo = [polarOrigoX, polarOrigoY];
    origoBaseY = [0, polarOrigoY];
    
    polarGridRate = 3;
    polarGridNumber = 32;
    polarGridLines = 138:(-polarGridRate):45;    
    
    allCoordsDimensions = size(polarGridCoordinates);
    cartesienGridCoordinates = zeros(allCoordsDimensions);
    pictureNumber = allCoordsDimensions(3);
    picturePoints = allCoordsDimensions(2);
    
    for picture = 1: pictureNumber
        for point = 1 : picturePoints
            picturePointCoord = polarGridCoordinates(:,point,picture);
            if picturePointCoord(1) ~= 0
                cartesienCoord  = OnePolarCoordinateToCartesien( polarOrigo, picturePointCoord );
                newXCoords = cartesienCoord(1);
                newYCoords = cartesienCoord(2);
            else
                newXCoords = -1;
                newYCoords = -1;
            end
            cartesienGridCoordinates(1,point,picture) = newXCoords;
            cartesienGridCoordinates(2,point,picture) = newYCoords;
        end
    end
    
end



