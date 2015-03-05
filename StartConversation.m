function [] = StartConversation(tsFilePath, writingCsvFilePath, ROIFilepath)
    
    pictureHeigth = 600;    % Y coord
    pictureWidth = 800;     % X coord
    
    newPictureHeigth = 413;
    newPictureWidth = 550;

    yCoordsPictureOffset = 30;
    xCoordPictureOffset = 140;

    disp(strcat('START Reading file from_',tsFilePath));
    [elso, pictureDirPath, startPictureIndex, endPictureIndex, ROIcoords] = ReadFromEdgeTrack(tsFilePath);
    
    disp('Start coordinates transformation for new pictures');
    [ masodik ] = CoordsTransformationToNewPicture( elso,  pictureHeigth, pictureWidth, newPictureHeigth, newPictureWidth, yCoordsPictureOffset, xCoordPictureOffset );
    
   % PrintDotsOnPicture(masodik, 'def');
    
    disp('Start conversion from cartesien to polar coordinate');
    [ harmadik] = CartesienToPolarCoordinate( masodik );
    
    disp('Start calculate POLAR GRID coordinates');
    [negyedik ] = GetPolarGridCoords( harmadik );
    
    disp('Start conversion from polar to cartesien');
    [ otodik ] = PolarCoordinateToCartesien( negyedik );
    
  % PrintDotsOnPicture(otodik, 'def');
        
    disp(strcat('Start write to_',writingCsvFilePath));
    WriteCoordsToFile( otodik, pictureDirPath, startPictureIndex, endPictureIndex, writingCsvFilePath);
    
    disp('Start recalc ROI coords');
    [ newROICoords ] = ConvertROIToNewPicture( ROIcoords, pictureHeigth, pictureWidth, newPictureHeigth, newPictureWidth, yCoordsPictureOffset, xCoordPictureOffset );
    
    disp(strcat('Start write ROI to _', ROIFilepath));
    CreateROIFile( newROICoords, ROIFilepath );
    
    disp('_________END_________');
end

