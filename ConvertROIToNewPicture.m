function [ newROICoords ] = ConvertROIToNewPicture( ROICoords, pictureHeigth, pictureWidth, newPictureHeigth, newPictureWidth, yCoordPictureOffset, xCoordPictureOffset )
    
    hightRatio = newPictureHeigth / pictureHeigth;
    widthRatio = newPictureWidth / pictureWidth;
    
    up = round((ROICoords(1) * hightRatio) + yCoordPictureOffset);
    down = round((ROICoords(2) * hightRatio) + yCoordPictureOffset);
    left = round((ROICoords(3) * widthRatio) + xCoordPictureOffset);
    right = round((ROICoords(4) * widthRatio) + xCoordPictureOffset);
    
    newROICoords = [up, down, left, right];
    
end

