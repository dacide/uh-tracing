function [ gridLineCoord ] = GetGridPolarForGridLine( gridAngle, onePicturePolarCoordinates )
    %[pointA, pointB] = FindNeighborPointsForGridLine(gridAngle, onePicturePolarCoordinates);
    [pointTopMin, foundBoolTopMin] = FindTopMinPointForGridLine(gridAngle, onePicturePolarCoordinates);
    [pointBottomMax, foundBoolBottomMax] = FindBottomMaxPointForGridLine(gridAngle, onePicturePolarCoordinates);
    [gridLineCoord] = CalculateGridLineCoord(pointTopMin, pointBottomMax, gridAngle, foundBoolTopMin, foundBoolBottomMax);
end

function [point, foundBool] = FindTopMinPointForGridLine(gridAngle, onePicturePolarCoordinates)
     matrixDimension = size(onePicturePolarCoordinates);
     pointNumber = matrixDimension(2);
     tempMin = [0,180];
     foundBool = 0;
     for i = 1 : pointNumber
         if onePicturePolarCoordinates(2,i) >= gridAngle && onePicturePolarCoordinates(2,i) < tempMin(2)
             tempMin = onePicturePolarCoordinates(:,i);
             foundBool = 1;
         end
     end
     point = tempMin;
end

function [point, foundBool] = FindBottomMaxPointForGridLine(gridAngle, onePicturePolarCoordinates)
     matrixDimension = size(onePicturePolarCoordinates);
     pointNumber = matrixDimension(2);
     tempMax = [0,10];
     foundBool = 0;
     for i = 1 : pointNumber
         if onePicturePolarCoordinates(2,i) <= gridAngle && onePicturePolarCoordinates(2,i) > tempMax(2)
             tempMax = onePicturePolarCoordinates(:,i);
             foundBool = 1;
         end
     end
     point = tempMax;
end

function [pointA, pointB] = FindNeighborPointsForGridLine(gridAngle, onePicturePolarCoordinates)
    matrixDimension = size(onePicturePolarCoordinates);
    pointNumber = matrixDimension(2);
    pointA = [0,0];
    pointB = [0,0];
    for point = 1:(pointNumber-1)
        %disp(onePicturePolarCoordinates(2,point));
        %disp(onePicturePolarCoordinates(2,(point+1)));
        if ((onePicturePolarCoordinates(2,point) >= gridAngle) && (onePicturePolarCoordinates(2,(point+1)) <= gridAngle))
                pointA = onePicturePolarCoordinates(:,point);
                pointB = onePicturePolarCoordinates(:,(point+1));
            end
        if onePicturePolarCoordinates(1,point) ~= 0 && onePicturePolarCoordinates(1,(point+1)) ~= 0 
            
        end
    end  
end

function [gridLineCoord] = CalculateGridLineCoord(pointTopMin, pointBottomMax, gridAngle, foundBoolTopMin, foundBoolBottomMax)
    gridLineCoord = [0, gridAngle];
    if foundBoolTopMin == 1 && foundBoolBottomMax == 1
        [closerPoint, otherPoint, coordWeigth] = GetCloserCoordToGridAngle(pointTopMin, pointBottomMax, gridAngle);
        distanceCoord = closerPoint(1)*coordWeigth + otherPoint(1)*(1-coordWeigth);
        gridLineCoord = [distanceCoord, gridAngle];
    elseif foundBoolTopMin == 1 && foundBoolBottomMax == 0
        [boolean1] = ShouldUsePointToBeCoord(pointTopMin, gridAngle);
        if boolean1 == 1
            gridLineCoord(1) = pointTopMin(1);
        end
    elseif foundBoolBottomMax == 1 && foundBoolTopMin == 0
        [boolean2] = ShouldUsePointToBeCoord(pointBottomMax, gridAngle);
        if boolean2 == 1
            gridLineCoord(1) = pointBottomMax(1);
        end
    end 
end

function [boolean] = ShouldUsePointToBeCoord(polarCoord, gridAngle)
    boolean = 0;
    diff = abs(polarCoord(2)-gridAngle);
    ratio = diff/3; % 3 = base angle
    if ratio <= (1/3)
        boolean = 1;
    end
end

function [closerPoint, otherPoint, coordWeigth] = GetCloserCoordToGridAngle(pointA, pointB, gridAngle)
    diffA_gridAngle = abs(pointA(2)-gridAngle);
    diffB_gridAngle = abs(pointB(2)-gridAngle);
    if diffB_gridAngle ~= 0
        if diffA_gridAngle ~=0
            ratio = diffA_gridAngle/diffB_gridAngle;
            if ratio > 1
                GaussX = 1/ratio;
            else
                GaussX = ratio;
            end
            coordWeigth = gaussmf(GaussX,[0.85 0]);
            % if coordWeigth < 1 pointA is nearer;  if coordWeight > 1 pointB is
            % nearer
            if ratio <= 1
                closerPoint = pointA;
                otherPoint = pointB;
            elseif ratio > 1
                closerPoint = pointB;
                otherPoint = pointA;
            end 
        else
            closerPoint = pointA;
            otherPoint = pointB;
            coordWeigth = 1;
        end      
    else
        closerPoint = pointB;
        otherPoint = pointA;
        coordWeigth = 1;
    end
    
end