function [ cartesienCoord ] = OnePolarCoordinateToCartesien( polarOrigo, oneCoord )
    phi = oneCoord(2);
    distance = oneCoord(1);
    if distance ~= 0      
        angle = CalculateAngle(phi);
        [coordX1, coordY1] = CalculateCoords(angle, distance);
        [cartesienCoord] = AddToPolarOrigo(polarOrigo, coordX1, coordY1);
    else
        cartesienCoord = [-1,-1];
    end
end

function angle = CalculateAngle(phi)
    angle = 90-phi;
end

function [coordX1, coordY1] = CalculateCoords(angle, distance)
    coordY1 = distance * cosd(angle);
    coordX1 = distance * sind(angle);
end

function [newCoord] = AddToPolarOrigo(polarOrigo, coordX1, coordY1)
    coordX = round(polarOrigo(1) + coordX1);
    coordY = round(polarOrigo(2) - coordY1);
    newCoord = [coordX, coordY];
end

