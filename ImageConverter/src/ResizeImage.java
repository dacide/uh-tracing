import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Iterator;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.FileImageOutputStream;

import net.coobird.thumbnailator.Thumbnails;


public class ResizeImage {

	private BufferedImage baseImage;
	private BufferedImage resizedImage;
	
	public BufferedImage ReadImage(String filePath){
		BufferedImage image = null;
		try{
	      // the line that reads the image file
	      image = ImageIO.read(new File(filePath));
	    } 
	    catch (IOException e){
	    	e.printStackTrace();
	    }
		return image;
	}
	
	public void SetBaseImage(BufferedImage image){
		this.baseImage = image;
	}
	
	public void SetResizedImage(BufferedImage image){
		this.resizedImage = image;
	}
	
	public BufferedImage GetBaseImage(){
		return this.baseImage;
	}
	
	public BufferedImage GetResizedImage(){
		return this.resizedImage;
	}
	
	public void DownscaleBaseImage(int newWidth, int newHeight){
		BufferedImage resizedImage = null;
		try {
			resizedImage =  Thumbnails.of(this.baseImage).size(newWidth, newHeight).asBufferedImage();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		this.resizedImage = resizedImage;
	}
	
	public void SaveImageInFile(String fileName, String extension, BufferedImage bufferImage){
		Iterator iter = ImageIO.getImageWritersByFormatName(extension);
		ImageWriter writer = (ImageWriter)iter.next();
		// instantiate an ImageWriteParam object with default compression options
		ImageWriteParam iwp = writer.getDefaultWriteParam();
		
		iwp.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
		iwp.setCompressionQuality(1);   // an integer between 0 and 1
		// 1 specifies minimum compression and maximum quality
		
		
		File file = new File(fileName);
		FileImageOutputStream output = null;
		try {
			output = new FileImageOutputStream(file);
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		writer.setOutput(output);
		IIOImage image = new IIOImage(bufferImage, null, null);
		try {
			writer.write(null, image, iwp);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		writer.dispose();
	}

	public BufferedImage InsertResizedPicToBlank(BufferedImage overlayImage, int xOffset, int yOffset, String blankFilePath){
		BufferedImage blankImage = null;		
		File blankimagePath = new File(blankFilePath);
		try {
			blankImage = ImageIO.read(blankimagePath);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	
		Graphics2D g2Source = blankImage.createGraphics();
		g2Source.drawImage(overlayImage, xOffset, yOffset, null);		
		g2Source.dispose();
		return blankImage;
	}


}
