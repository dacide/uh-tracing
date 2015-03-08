function [] = PrintTwoPointArray( manualCoord, trainedCoord, imagePath )
    img = imread(imagePath);
    image(img);
    colormap('gray');
    hold on;
    
    dimension = size(manualCoord);
    numberOfPoints = dimension(2);
    
    manXCoords = manualCoord(1,:);
    manYCoords = manualCoord(2,:);
    
    trainXCoords = trainedCoord(1,:);
    trainYCoords = trainedCoord(2,:);
    
    plot(manXCoords,manYCoords,'g.','MarkerSize',20);
    plot(trainXCoords,trainYCoords,'r.','MarkerSize',20);
    
    hold off;
  %  pause(0.0001);
    
end

