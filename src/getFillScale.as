package
{
	import flash.display.DisplayObject;

	public function getFillScale(targetWidth:Number, targetHeight:Number, containerWidth:Number, containerHeight:Number, fillToMax:Boolean = false):Number
	{
		if ((containerHeight/containerWidth) > (targetHeight/targetWidth))
		{
			return (fillToMax) ? (containerHeight/targetHeight) : (containerWidth/targetWidth);
		}
		else
		{
			return (fillToMax) ? (containerWidth/targetWidth) : (containerHeight/targetHeight);
		}
	}
}