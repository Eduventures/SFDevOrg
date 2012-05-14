public class AjUtil {

	/* resources used in building this class
	http://stackoverflow.com/questions/4246351/creating-random-colour-in-java  (idea for allowing switch specifying light colors only)
	http://www.htmlgoodies.com/JSBook/hextorbg.txt  (basic conversion rountine - since Apex doesn't have java's hex conversion String.valueOf( string, base) )
	*/
	public static String generateHex(Boolean lighterColors)
	{
		return convertRGB(generateRGB(lighterColors));	
	}
	
	public static List<Integer> generateRGB (Boolean lighterColors)
	{
		List<Integer> colorcodes = new List<Integer>();
		for(integer i=0; i<3; i++)
		{
			Double color = Math.Random();
			if(lighterColors)
			{
				if(color < .5)
				{
					color = color + .5;
				}
			}
			color = color*255;
			colorcodes.add(color.intValue());	
		}
		return colorcodes;
	}
	
	
	public static String convertRGB(List<Integer> intList)
	{
		String colorCode = '#';
		
		for(Integer i: intList)
		{   
			String divisor = giveHex( (Math.floor(i/16)).intValue());
   			String remainder = giveHex(Math.mod(i,16));
			
			colorCode = colorCode + divisor + remainder;
		}
		return colorCode;	
	}
	
	public static String giveHex(Integer intVal)
	{
	   if(intVal == 10)
	      return 'A';
	   else if (intVal == 11)
	      return 'B';
	   else if(intVal == 12)
	      return 'C';
	   else if(intVal == 13)
	      return 'D';
	   else if(intVal == 14)
	      return 'E';
	   else if(intVal == 15)
	      return 'F';
	   else
	      return intVal.format();
	}

}