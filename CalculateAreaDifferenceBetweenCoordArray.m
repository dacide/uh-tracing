function [ areaDifference ] = CalculateAreaDifferenceBetweenCoordArray( manualCoords, trainedCoords, imagePath )
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
    sumArea = 0;
    area = 0;
    correction = 0;
    
    for i = 1 : numberOfGrid-1
        if manualcartesienGridCoords(1,i) ~= -1 && trainedcartesienGridCoords(1,i) ~= -1
            if manualcartesienGridCoords(1,i+1) ~= -1 && trainedcartesienGridCoords(1,i+1) ~= -1
                ACoord = manualcartesienGridCoords(:,i);
                XCoord = trainedcartesienGridCoords(:,i);
                BCoord = manualcartesienGridCoords(:,i+1);
                YCoord = trainedcartesienGridCoords(:,i+1);

                ACoordPolar = manualPolarGridCoords(:,i);
                XCoordPolar = trainedPolarGridCoords(:,i);
                BCoordPolar = manualPolarGridCoords(:,i+1);
                YCoordPolar = trainedPolarGridCoords(:,i+1);
                
                isCrossing = MathUtil.HaveCrossPointCartesien(ACoord, BCoord, XCoord, YCoord);
                area = 0;
                if isCrossing == 1
                    %Nem lép be ha bal oldalon vagy/és jobbon azonos a két
                    %pont
                    difficult = MathUtil.GetDifficultyForAreaCalcCartesien(ACoord, BCoord, XCoord, YCoord);
                    if difficult == 1
                        area = MathUtil.GetCrossPointPolarCoordsFromCartesien(ACoordPolar, BCoordPolar, XCoordPolar, YCoordPolar, 3);
                    else
                        area = MathUtil.GetCrossingPointsSumArea(ACoord, BCoord, XCoord, YCoord);
                    end
                else
                    boolean = MathUtil.IsAreaNull(ACoord, BCoord, XCoord, YCoord);
                    if boolean == 1
                        area = 0;
                    else
                        area = MathUtil.GetNotCrossingPointsSumAreaPolar(ACoordPolar, BCoordPolar, XCoordPolar, YCoordPolar, 3);
                    end
                end
            else
                %TODO
                correction = correction + 1;
            end 
        else
            %TODO
            correction = correction + 1;
        end
        sumArea = sumArea + area;
    end
    areaDifference = sumArea/(numberOfGrid-1-correction);
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