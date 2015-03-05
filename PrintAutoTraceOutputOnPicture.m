function [] = PrintAutoTraceOutputOnPicture(SystemFolder, nFold)
     testImagesPath = SystemFolder.GetCrossValNthFolderPath(nFold);
     imagesFilePath = strcat(testImagesPath, '\', '*.jpg');
     coordsFilePath = strcat(testImagesPath, '\', '*.txt');
     imagesName = dir(imagesFilePath);
     coordsName = dir(coordsFilePath);
     
     imageNumber = length(imagesName);
     
     IterateOnImages(imageNumber, imagesName, coordsName, testImagesPath);
     
end

function [] = IterateOnImages(imageNumber, imagesName, coordsName, testImagesPath)
    pictureNumberToPlot = 1;
    for i = 1 : imageNumber    
        if pictureNumberToPlot == 0
            pictureNumberToPlot = ShouldPlotMoreImage();
            if pictureNumberToPlot == 0
                break;
            end
        end
        oneImageName = imagesName(i).name;
        oneCoordsName = coordsName(i).name;
        oneImagePath = strcat(testImagesPath, '\', oneImageName);
        oneCoordsPath = strcat(testImagesPath, '\', oneCoordsName);
        
        onePictureCoords = ReadAutotraceOutputTxt( oneCoordsPath );
        PrintDotsOnPicture(onePictureCoords, oneImagePath);
        pictureNumberToPlot = pictureNumberToPlot - 1;
        pause(0.025);
    end
end

function [numberOfImages] = ShouldPlotMoreImage()
    prompt = 'How many pictures do you want to plot? ';
    result = input(prompt);
    numberOfImages = result;
end
