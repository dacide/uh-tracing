function [ polarDistance, phiDegree ] = ConvertOneCoordCartToPolar( polarOrigo, basePoint, picturePointCoord )
    [counterStraight, besideStraightA, polarDistance] = CalculateTriangleDistanes(polarOrigo, basePoint, picturePointCoord);
    [phiDegree] = CalculateAngle(counterStraight, besideStraightA, polarDistance);
end

% Points are contains X & Y coordinates
function [distance] = CalculateDistanceBetweenPoints(pointA, pointB)
    distance = sqrt((pointA(1)-pointB(1))^2+(pointA(2)-pointB(2))^2);
end

function [counterStraight, besideStraightA, polarDistance] = CalculateTriangleDistanes(polarOrigo, basePoint, picturePointCoord)
    counterStraight = CalculateDistanceBetweenPoints(basePoint, picturePointCoord);
    besideStraightA = CalculateDistanceBetweenPoints(basePoint, polarOrigo);
    polarDistance = CalculateDistanceBetweenPoints(picturePointCoord, polarOrigo);
end

function [phiDegree] = CalculateAngle(counterStraight, besideStraightA, besideStraightB)
    numerator = (besideStraightA)^2 + (besideStraightB)^2 - (counterStraight)^2;
    denominator = 2 * besideStraightA * besideStraightB;
    cosPhi = numerator/denominator;
    phiDegree = 180 - acosd(cosPhi); 
end