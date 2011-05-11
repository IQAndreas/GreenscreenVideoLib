package
{
	import flash.media.Video;

	public class ScaledVideo extends Video
	{
		
		public function ScaledVideo(targetWidth:Number = NaN, targetHeight:Number = NaN, fillToMax:Boolean = false)
		{
			this._targetWidth = targetWidth;
			this._targetHeight = targetHeight;
			this._fillToMax = fillToMax;
			
			var videoWidth:Number = isNaN(targetWidth) ? defaultWidth : targetWidth;
			var videoHeight:Number = isNaN(targetHeight) ? defaultHeight : targetHeight;
			super(videoWidth, videoHeight);
		}
		
		private const defaultWidth:Number = 320;
		private const defaultHeight:Number = 240;
		
		private var _targetWidth:Number;
		public function get targetWidth():Number
		{
			return isNaN(this._targetWidth) ? (this.videoWidth || defaultWidth) : this._targetWidth;
		}
		public function set targetWidth(value:Number):void
		{
			_targetWidth = value;
			this.rescale();
		}
		
		private var _targetHeight:Number;
		public function get targetHeight():Number
		{
			return isNaN(this._targetHeight) ? (this.videoHeight || defaultHeight) : this._targetHeight;
		}
		public function set targetHeight(value:Number):void
		{
			_targetHeight = value;
			this.rescale();
		}
		
		private var _fillToMax:Boolean = false;
		public function get fillToMax():Boolean
		{ return _fillToMax; }
		public function set fillToMax(value:Boolean):void
		{
			_fillToMax = value;
			this.rescale();
		}
		
		public function get boundsWidth():Number
		{
			if ((this.videoWidth == 0) || (this.videoHeight == 0))
			{
				//Cannot rescale properly until the video is loaded.
				//Otherwise the video's scale will always be 0
				return isNaN(this._targetWidth) ? defaultWidth : this._targetWidth;
				//this.height = isNaN(this._targetHeight) ? defaultHeight : this._targetHeight;
			}
			else
			{
				return this.videoWidth;
				//this.height = this.videoHeight;
			}
		}
		
		public function get boundsHeight():Number
		{
			if ((this.videoWidth == 0) || (this.videoHeight == 0))
			{
				//Cannot rescale properly until the video is loaded.
				//Otherwise the video's scale will always be 0
				return isNaN(this._targetHeight) ? defaultHeight : this._targetHeight;
			}
			else
			{
				return this.videoHeight;
			}
		}
		
		
		public function fitToSize(targetWidth:Number, targetHeight:Number, fillToMax:Boolean = false):void
		{
			this._targetWidth = targetWidth;
			this._targetHeight = targetHeight;
			this._fillToMax = fillToMax;
			
			this.rescale();
		}
		
		public function rescale():void
		{
			//trace("Rescaling video", this.width, this.videoWidth, this.height, this.videoHeight, this.scaleY);
			
			//Getters ensure that the sizes will never be 0 or NaN, resulting in 0 scale.
			this.width = this.boundsWidth;
			this.height = this.boundsHeight;
			
			var scale:Number = getFillScale(this.width, this.height, this.targetWidth, this.targetHeight, this.fillToMax);
			this.scaleX *= scale;
			this.scaleY *= scale;
			this.x = (this.targetWidth / 2) - (this.width / 2);
			this.y = (this.targetHeight / 2) - (this.height / 2);
		}
	}
}