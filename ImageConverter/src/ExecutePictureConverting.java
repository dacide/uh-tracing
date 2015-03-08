import java.awt.image.BufferedImage;
import java.io.File;


public class ExecutePictureConverting {

	public static void main(String[] args) {
		
		System.out.println("Start");
		
		String blankFilePath = "C:/ubuntueswin/blank.jpg";
		int numberOfSubjects = 17;
		
		for(int j=1;j<=numberOfSubjects;j++){
			String subjectFolderName = "Subject"+j;
			String folderPath = "C:/ubuntueswin/FolderSystem/basicImages/"+subjectFolderName+"/";
			String saveFolder = "C:/ubuntueswin/FolderSystem/convertedImages/"+subjectFolderName+"/";
			
			String extension = "jpg";
			
			int newHeigth = 413;
			int newWidth = 550;
			
			int offsetX = 140;
			int offsetY = 30;
			
			File folder = new File(folderPath);
			File[] listOfFiles = folder.listFiles();
			
			for(int i=0; i< listOfFiles.length; i++){
				if(listOfFiles[i].isFile()){
					String pictureFile = listOfFiles[i].getName();
					
					String pictureFileName = pictureFile.replaceAll("\\D+","");
					
					ResizeImage newImage = new ResizeImage();
					newImage.SetBaseImage(newImage.ReadImage(folderPath+pictureFile));
					newImage.DownscaleBaseImage(newWidth, newHeigth);
					BufferedImage resizedImage = newImage.GetResizedImage();
					BufferedImage finalPicture = newImage.InsertResizedPicToBlank(resizedImage, offsetX, offsetY, blankFilePath);
					newImage.SaveImageInFile(saveFolder+pictureFileName+"."+extension, extension, finalPicture);
				}
			}
			
		}
		System.out.println("End");
	}
	
	

}
