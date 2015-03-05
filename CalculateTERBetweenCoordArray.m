function [ averageTer ] = CalculateTERBetweenCoordArray( manualCoords, trainedCoords, imagePath )
    manualPolarArray = IterateOnCoordsToGetPolar(manualCoords);
    trainedPolarArray = IterateOnCoordsToGetPolar(trainedCoords);   
    
    manualPolarGridCoords = GetPolarGridCoords(manualPolarArray);
    trainedPolarGridCoords = GetPolarGridCoords(trainedPolarArray);
    
    manualcartesienGridCoords = GetCartesienGridCoords(manualPolarGridCoords);
    trainedcartesienGridCoords = GetCartesienGridCoords(trainedPolarGridCoords);
    
    % For debug
    PrintTwoPointArray( manualcartesienGridCoords, trainedcartesienGridCoords, imagePath );
    
    dimensions = size(manualPolarGridCoords);
    numberOfGrid = dimensions(2);
    
    numberOfManualPoints = size(manualCoords,2);
    
    insertion = 0;
    deletion = 0;
    substitution = 0;
    bound = 7;
    for i = 1 : numberOfGrid
        %Calc Insertion error (train data 1 ; manual 0)   
        if manualPolarGridCoords(1,i) == 0 && trainedPolarGridCoords(1,i) ~= 0
            insertion = insertion + 1;
        end
        
        %Calc Deletion error (train data 0 ; manual 1)
        if manualPolarGridCoords(1,i) ~= 0 && trainedPolarGridCoords(1,i) == 0
            deletion = deletion + 1;
        end
        
        %Calc Substitution ( train data 1 ; manual 1; inside bounds)
        if manualPolarGridCoords(1,i) ~= 0 && trainedPolarGridCoords(1,i) ~= 0
            dist1 = abs(manualPolarGridCoords(1,i) - trainedPolarGridCoords(1,i));
            if dist1 > bound
                substitution = substitution + 1;
            end
        end    
    end
    averageI = insertion/numberOfManualPoints;
    averageD = deletion/numberOfManualPoints;
    averageS = substitution/numberOfManualPoints;
    averageTer = [averageI, averageD, averageS];
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