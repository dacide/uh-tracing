function [] = PrintDotsOnPicture(pictureCoords, imagePath)
    img = imread(imagePath);
    image(img);
    colormap('gray');
    hold on;
    
    pictureDimension = size(pictureCoords);
    numberOfDots = pictureDimension(2);
    xCoords = pictureCoords(1,:);
    yCoords = pictureCoords(2,:);
    plot(xCoords,yCoords,'r.','MarkerSize',10);  
   % for i=1:numberOfDots
    %    plot(pictureCoords(1,i),pictureCoords(2,i),'r.','MarkerSize',10);     
    %end   
    hold off; 
end

