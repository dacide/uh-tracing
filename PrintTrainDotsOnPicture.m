function [] = PrintTrainDotsOnPicture( xs, ys )
    dirPath = 'C:\ujkepek\0131.jpg';
    img = imread(dirPath);
    image(img);
    colormap('gray');
    hold on;
    
    
    dimens =size(xs{1,80});
    
    for i=1:dimens(2)
        %disp(allDotCoordsMatrix(1,i,1));
        %disp(allDotCoordsMatrix(2,i,1));
        plot(xs{1,80}(i), ys{1,80}(i),'r.','MarkerSize',10);
        
    end
    
    hold off;
end

