classdef MathUtil
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        
        function area = GetTriangleAreaFromPolarData(baseAngle, polarCoordA, polarCoordB)
            area = polarCoordA(1) * polarCoordB(1) * cosd(baseAngle) / 2;
        end
        
        function absDifference = GetAbsDifference(valueA, valueB)
            absDifference = abs(valueA - valueB);
        end
        
        function boolean = HaveCrossPointCartesien(Acoord, Bcoord, Xcoord, Ycoord)
            % Look out for the coord system ! (x right + ; y down +)
            boolean = 0;
            if ((Acoord(2) < Xcoord(2)) && (Bcoord(2) > Ycoord(2)))
                boolean = 1;
            elseif (Xcoord(2) < Acoord(2) && (Ycoord(2) > Bcoord(2)))
                boolean = 1;
            end
        end
        
        function crossingPointCoord = GetCrossingPointCartesien(Acoord, Bcoord, Xcoord, YCoord)
            crossingPointCoord = [0,0];
            isCrossing = MathUtil.HaveCrossPointCartesien(Acoord, Bcoord, Xcoord, YCoord);
            if isCrossing == 1
                % Line equation : y = m*x+const
                [m1, const1] = MathUtil.GetLineVariables(Acoord,Bcoord);
                [m2, const2] = MathUtil.GetLineVariables(Xcoord, YCoord);
                %m2 = -m2;
                crossingPointCoord = MathUtil.CalculateCrossPointCoord(m1, const1, m2, const2);
            else
                disp('Not crossing lines from cartesien points!');
            end
        end
        
        function [m, const] = GetLineVariables(aCoord, bCoord)
            const = ( bCoord(2)*aCoord(1) - bCoord(1)*aCoord(2) ) / ( aCoord(1) - bCoord(1) );
            m = (aCoord(2) - const) / aCoord(1);
        end
        
        function [crossPointCoord] = CalculateCrossPointCoord(m1, const1, m2, const2)
            XCoord = (const2-const1) / (m1 - m2);
            YCoord = m1* XCoord + const1;
            crossPointCoord = [XCoord, YCoord];
        end
        
        function distance = GetPointsDistanceCartesien(aCoord, bCoord)
            distance = sqrt( ( aCoord(1)-bCoord(1) )^2 + ( aCoord(2)-bCoord(2) )^2 );
        end
        
        function area = GetTriangleAreaFromCartesienData(aCoord, bCoord, cCoord)
            % Heron
            AB = MathUtil.GetPointsDistanceCartesien(aCoord, bCoord);
            AC = MathUtil.GetPointsDistanceCartesien(aCoord, cCoord);
            BC = MathUtil.GetPointsDistanceCartesien(bCoord, cCoord);
            s = (AB + AC + BC)/2;
            area = sqrt(s*(s-AB)*(s-AC)*(s-BC));
        end
        
        function area = GetCrossingPointsSumArea(Acoord, Bcoord, Xcoord, Ycoord)
            crossingPointCoord = MathUtil.GetCrossingPointCartesien(Acoord, Bcoord, Xcoord, Ycoord);
            area1 = MathUtil.GetTriangleAreaFromCartesienData(Acoord, Xcoord, crossingPointCoord);
            area2 = MathUtil.GetTriangleAreaFromCartesienData(Bcoord, Ycoord, crossingPointCoord);
            area = area1 + area2;
        end
        
        function area = GetNotCrossingPointsSumAreaPolar(Acoord, Bcoord, Xcoord, Ycoord, baseAngle)
            area1 = MathUtil.GetTriangleAreaFromPolarData(baseAngle, Acoord, Bcoord);
            area2 = MathUtil.GetTriangleAreaFromPolarData(baseAngle, Xcoord, Ycoord);
            area = abs(area1 - area2);
        end
        
        function boolean = IsAreaNull(Acoord, Bcoord, Xcoord, Ycoord)
            boolean = 0;
            % ugly...
            if Acoord(1) == Xcoord(1) && Acoord(2) == Xcoord(2) && Bcoord(1) == Ycoord(1) && Bcoord(2) == Ycoord(2)
                boolean = 1;
            end
        end
        
        function phi = CosFunctionToGetAngle(sideA, sideB, opposite)
            cosphi = (sideA^2 + sideB^2 - opposite^2)/(2*sideA*sideB);
            phi = acosd(cosphi);
        end
        
        
        
        % aCoord(2) > xCoord(2) && bCoord(2) < yCoord(2) !!!
        function [area] = SolvePredefinedEquationsFromPolarCoords(aCoord, bCoord, xCoord, yCoord, baseAngle)     
           % X = MathUtil.GetPointsDistanceCartesien(aCoord, bCoord);
           % Y = GetPointsDistanceCartesien(xCoord, yCoord);
            a = xCoord(1);
            b = aCoord(1);
            c = bCoord(1);
            d = yCoord(1);
            
            syms X positive
            [X] = solve(X^2 == a^2 + d^2 - 2*a*d*cosd(baseAngle));
            X = double(X);
            syms Y positive
            [Y] = solve(Y^2 == b^2 + c^2 -2*b*c*cosd(baseAngle));
            Y = double(Y);       
            
            delta = 180 - MathUtil.CosFunctionToGetAngle(a, X, d);
            kszi = 180 - MathUtil.CosFunctionToGetAngle(Y,c,b);
         

            cosDelta = cosd(delta);
            cosKszi = cosd(kszi);
            syms x1 x2 y1 y2 positive
            S = solve(...
                y1^2 == (b-a)^2 + x1^2 - 2*(b-a)*x1*cosDelta,...
                x2^2 == (d-c)^2 + y2^2 - 2*(d-c)*y2*cosKszi,...
                x1+x2 == X, ...
                y1+y2 == Y);
            x1 = double(S.x1);
            x2 = double(S.x2);
            y1 = double(S.y1);
            y2 = double(S.y2);
            
            s1 = (y1 + x1 + (b-a))/2;
            s2 = (y2+x2+(d-c))/2;
            area1 = sqrt(s1*(s1-y1)*(s1-x1)*(s1-(b-a)));
            area2 = sqrt(s2*(s2-y2)*(s2-x2)*(s2-(d-c)));
            area = area1 + area2;
        end
        
        function [area] = GetCrossPointPolarCoordsFromCartesien(aCoord, bCoord, xCoord, yCoord, baseAngle)
            if aCoord(1) > xCoord(1)
                topLeft = aCoord;
                bottomLeft = xCoord;
            else
                topLeft = xCoord;
                bottomLeft = aCoord;
            end
            
            if bCoord(1) < yCoord(1)
                bottomRight = bCoord;
                topRight = yCoord;
            else
                bottomRight = yCoord;
                topRight = bCoord;
            end
            [area] = MathUtil.SolvePredefinedEquationsFromPolarCoords(topLeft, bottomRight, bottomLeft, topRight, baseAngle);
        end
        
        function difficult = GetDifficultyForAreaCalcCartesien(aCoord, bCoord, xCoord, yCoord)
           difficult = 0;
           if aCoord(1) == bCoord(1)
               difficult = 1;
           elseif xCoord(1) == yCoord(1)
                difficult = 1;
           end
        end
        
    end
    
end

