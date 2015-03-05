function [polarGridCoords ] = GetPolarGridCoords( polarCoordinates )
     
    polarGridRate = 3;
    polarGridNumber = 32;
    polarGridLines = 138:(-polarGridRate):45;
    
    polarCoordsDimension = size(polarCoordinates);
    pictureNumber = polarCoordsDimension(3);
    polarGridCoords = zeros(2,polarGridNumber,pictureNumber);
    
    for picture = 1:pictureNumber
        onePicturePolarCoordinates = polarCoordinates(:,:,picture);
        for gridElement = 1:polarGridNumber
            gridAngle = polarGridLines(gridElement);
            gridLineCoord = GetGridPolarForGridLine( gridAngle, onePicturePolarCoordinates );
            polarGridCoords(1,gridElement,picture) = gridLineCoord(1);
            polarGridCoords(2,gridElement,picture) = gridAngle;
        end
    end 
end