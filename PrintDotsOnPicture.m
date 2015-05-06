function [] = PrintDotsOnPicture(pictureCoords3D, imagePath)
    
    pictureCoords = pictureCoords3D(:,:,10);

    [A, map] = imread(imagePath);
   % newimg = rgb2gray(map);
    imshow(A);
   %colormap('RGB');
    hold on;
    
    
    
    pictureDimension = size(pictureCoords);
    numberOfDots = pictureDimension(2);
    xCoords = pictureCoords(1,:);
    yCoords = pictureCoords(2,:);
    plot(xCoords,yCoords,'r.','MarkerSize',15);  
   % for i=1:numberOfDots
    %    plot(pictureCoords(1,i),pictureCoords(2,i),'r.','MarkerSize',10);     
    %end   
    hold off; 
end

