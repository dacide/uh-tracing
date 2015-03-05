function [ RMSE ] = CalculateRMSEBetweenCoordArray( manualCoords, trainedCoords, imagePath )
    manualPolarArray = IterateOnCoordsToGetPolar(manualCoords);
    trainedPolarArray = IterateOnCoordsToGetPolar(trainedCoords);
    manualPolarGridCoords = GetPolarGridCoords(manualPolarArray);
    trainedPolarGridCoords = GetPolarGridCoords(trainedPolarArray);
    
    manualcartesienGridCoords = GetCartesienGridCoords(manualPolarGridCoords);
    trainedcartesienGridCoords = GetCartesienGridCoords(trainedPolarGridCoords);
    
    PrintTwoPointArray( manualcartesienGridCoords, trainedcartesienGridCoords, imagePath );
    
    dimensions = size(manualPolarGridCoords);
    numberOfGrid = dimensions(2);
    sumNumerator = 0;
    correction = 0;
    for i = 1 : numberOfGrid
        if trainedPolarGridCoords(1,i) ~= 0 && manualPolarGridCoords(1,i) ~= 0
            distanceDifference = trainedPolarGridCoords(1,i) - manualPolarGridCoords(1,i);
            sumNumerator = sumNumerator + distanceDifference^2;
        else
            correction = correction + 1;
        end     
    end  
    RMSE = sqrt(sumNumerator/(numberOfGrid-correction));
end

function [polarGridCoords] = GetPolarGridCoords(polarArray)
    polarGridRate = 3;
    polarGridNumber = 32;
    polarGridLines = 138:(-polarGridRate):45;    
    polarGridCoords = zeros(2,polarGridNumber);
    
    for gridElement = 1 : polarGridNumber
        gridAngle = polarGridLines(gridElement);
        gridLineCoord = GetGridPolarForGridLine( gridAngle, polarArray );
        polarGridCoords(1,gridElement) = gridLineCoord(1);
        polarGridCoords(2,gridElement) = gridAngle;
    end
end

function [polarCoordArray] = IterateOnCoordsToGetPolar(coordArray)
    polarOrigoX = 391;
    polarOrigoY = 426;   
    polarOrigo = [polarOrigoX, polarOrigoY];
    origoBaseY = [0, polarOrigoY];
    
    coordNumber = length(coordArray);
    polarCoordArray = zeros(2,coordNumber);
    
    for i = 1 : coordNumber
        coord = coordArray(:,i);
        if coord(1) ~= -1 && coord(2) ~= -1
             [ polarDistance, phiDegree ] = ConvertOneCoordCartToPolar( polarOrigo, origoBaseY, coord );
             polarCoordArray(1,i) = polarDistance;
             polarCoordArray(2,i) = phiDegree;  
        end
    end
end

function [cartesienGridCoords] = GetCartesienGridCoords(polarGridArray)
    polarOrigoX = 391;
    polarOrigoY = 426;
    
    polarOrigo = [polarOrigoX, polarOrigoY];
    origoBaseY = [0, polarOrigoY];
    polarGridNumber = 32;

    cartesienGridCoords = zeros(2,polarGridNumber);
    
    dimension = size(polarGridArray);
    numberOfPoints = dimension(2);
    for i = 1 : numberOfPoints 
        oneCoord = polarGridArray(:,i);
        cartesienCoord  = OnePolarCoordinateToCartesien( polarOrigo, oneCoord );
        cartesienGridCoords(1,i) = cartesienCoord(1);
        cartesienGridCoords(2,i) = cartesienCoord(2);
    end
end