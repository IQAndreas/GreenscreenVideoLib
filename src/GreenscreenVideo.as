package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Loader;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.sampler.Sample;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	
	//To extend ScaledVideo or contain it? That is the question...
	public class GreenscreenVideo extends Sprite
	{
		
		private static var videoInstance:ScaledVideo;
		private static function getVideoInstance():ScaledVideo
		{
			return videoInstance || makeVideo();
		}
		
		private static function makeVideo():ScaledVideo
		{
			var camera:Camera = Camera.getCamera();
			if (camera)
			{
				const W:Number = 800;
				const H:Number = 600;
				const cameraFPS:Number = 15;
				
				camera.setQuality(0, 100);
				camera.setMode(W, H, cameraFPS, true);
							
				videoInstance = new ScaledVideo(camera.width, camera.height);
				videoInstance.attachCamera(camera);
			}
			else
			{
				return null;
			}
			
			return videoInstance;
		}
		
		private static var stage:Stage;
		private static var adjustGSV:GreenscreenVideo;
		public static function startAdjustMode(targetStage:Stage):void
		{
			GreenscreenVideo.endAdjustMode();

			if (!targetStage) { trace("STAGE IS NULL!"); }
			stage = targetStage;
			
			adjustGSV = new GreenscreenVideo(true, true);
			stage.addChild(adjustGSV);
			adjustGSV.showControls(stage);
			
			stage.addEventListener(Event.RESIZE, resizeAdjuster);
			resizeAdjuster(null);
		}
		
		private static function resizeAdjuster(e:Event):void
		{
			if (adjustGSV && stage)
			{
				adjustGSV.fitToSize(stage.stageWidth, stage.stageHeight, true);
			}
			else
			{
				trace("Error! Adjust GSV not available!");
			}
		}
		
		public static function endAdjustMode():void
		{
			if (adjustGSV) 
			{
				keyColor = adjustGSV.keyColor;
				tolerance = adjustGSV.tolerance;
				ramp = adjustGSV.ramp;
				gamma = adjustGSV.gamma;
				
				//trace("SETTING 0x" + keyColor.toString(16), tolerance, ramp, gamma);
				
				adjustGSV.hideControls();
				adjustGSV.stop();
				
				if (adjustGSV.parent) { adjustGSV.parent.removeChild(adjustGSV); }
				adjustGSV = null;
			}
			
			if (stage)
			{
				stage.removeEventListener(Event.RESIZE, resizeAdjuster);
				stage = null;
			}
		}
		
		public static var keyColor:uint;
		public static var tolerance:Number = 0.10;
		public static var ramp:Number = 0.005;
		public static var gamma:Number = 1.0;

		
		//[Embed(source="GrayScale.pbj",mimeType="application/octet-stream")]
		[Embed(source="DifferenceKey.pbj",mimeType="application/octet-stream")]
		private var DifferenceKeyShader : Class;
		
		//[Embed(source="test.png",mimeType="application/octet-stream")]
		//private var SampleImage : Class;
		
		//private var img:Loader;
		private var textField:TextField;
		private var container:Sprite;
		
		public function GreenscreenVideo(useGlobalSettings:Boolean = true, startInAdjustMode:Boolean = false)
		{
			super();
			
			if (GreenscreenVideo.adjustGSV)
			{
				trace("Warning! GreenscreenVideo is still in adjust mode! The instance will still work, but the camera may be busy.");
			}
			
			//import flash.utils.describeType;
			//trace(describeType(SampleVideo));
			
			textField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.selectable = false;
			textField.mouseEnabled = false;
			
			textField.textColor = 0xFFFFFF;
			textField.backgroundColor = 0x000000;	
			
			container = new Sprite();
			
			_video = GreenscreenVideo.getVideoInstance();
			if (!_video) 
			{
				write("Camera not found! Attach the camera and restart the SWF.");
				return; 
			}
			
			container.addChild(_video);
			//target = _video;
			target = container;
			
			
			if (useGlobalSettings)
			{
				_keyColor = GreenscreenVideo.keyColor;
				_tolerance = GreenscreenVideo.tolerance;
				_ramp = GreenscreenVideo.ramp;
				_gamma = GreenscreenVideo.gamma;
				
				//trace("Getting global settings 0x" + _keyColor.toString(16), _tolerance, _ramp, _gamma);
			}
			
			if (startInAdjustMode)
			{
				this.startAdjustMode();
			}
			else
			{
				this.startFilter();	
			}
			
			this.addChild(container);
			this.addChild(textField);
			
		}
		
		private var target:DisplayObject;
		
		private function write(string:String, append:Boolean = false):void
		{
			if (append)
				{ string = textField.text + "\n" + string; }
			
			if (string)
			{
				textField.text = string;
				textField.background = true;
			}
			else
			{
				textField.text = "";
				textField.background = false;
			}
			
		}
		
		/*private function onMetaData(infoObject:Object):void 
		{ 
			trace("META", infoObject.width, infoObject.height);
			this.fitToSize(infoObject.width, infoObject.height, video.fillToMax);
		}*/
		
		
		private const flipX:Boolean = true;
		public function fitToSize(targetWidth:Number, targetHeight:Number, fillToMax:Boolean = false):void
		{
			//Resize the camera dimensions as well?
			//_camera.setMode(targetWidth, targetHeight, cameraFPS, true);
			
			video.fitToSize(targetWidth, targetHeight, fillToMax);
			if (flipX)
			{
				container.scaleX = -1;
				//container.x = (targetWidth / 2) + (container.width / 2);
				container.x = (targetWidth)// + (container.width / 2);
			}
		}
		
		public function rescale():void
		{
			//Resize the camera dimensions as well?
			//_camera.setQuality(0, 100);
			//_camera.setMode(video.targetWidth, video.targetHeight, cameraFPS, true);
			
			video.rescale();
			if (flipX)
			{
				container.scaleX = -1;
				//container.x = (targetWidth / 2) + (container.width / 2);
				container.x = (video.targetWidth)// + (container.width / 2);
			}
		}		
		
		
		//private var _camera:Camera;
		//public function get camera():Camera
		//{ return _camera; }
		
		private var _video:ScaledVideo;
		public function get video():ScaledVideo
		{ return _video; }
		
		private var shader:Shader;
		private var filter:ShaderFilter;
		
		
		private var _keyColor:uint;
		public function get keyColor():uint
		{ return _keyColor; }
		public function set keyColor(value:uint):void
		{
			_keyColor = value;
			//this.startFilter();
		}
		
		
		//private var _tolerance:Number = 0.02;
		private var _tolerance:Number = 0.10;
		public function get tolerance():Number
		{ return _tolerance; }
		public function set tolerance(value:Number):void
		{
			_tolerance = value;
		}
		
		private var _ramp:Number = 0.005;
		public function get ramp():Number
		{ return _ramp; }
		public function set ramp(value:Number):void
		{
			_ramp = value;
		}
		
		private var _gamma:Number = 1.0;
		public function get gamma():Number
		{ return _gamma; }
		public function set gamma(value:Number):void
		{
			_gamma = value;
		}
		
		
		private var adjustMode:Boolean = false;
		public function startAdjustMode():void
		{
			if (!adjustMode)
			{
				adjustMode = true;
				write("Click the video to choose the greenscreen color", false);
				target.filters = [];
				this.addEventListener(MouseEvent.CLICK, endAdjustMode);
			}
		}
		
		private function endAdjustMode(mouseEvent:MouseEvent = null):void
		{
			adjustMode = false;
			write("");
			
			this.removeEventListener(MouseEvent.CLICK, endAdjustMode);
			
			if (mouseEvent)
			{
				var targetBMD:BitmapData = new BitmapData(target.width, target.height, false);
				targetBMD.draw(target);
				
				_keyColor = targetBMD.getPixel(target.mouseX, target.mouseY);
				trace("Setting key color from click: 0x" + _keyColor.toString(16));
				this.startFilter();
			}
		}
		
		private var controls:GreenscreenControls;
		public function showControls(stage:Stage):void
		{
			this.hideControls();
			controls = new GreenscreenControls(this, 40, 40);
			stage.addChild(controls);
		}
		
		public function hideControls():void
		{
			if (controls && controls.parent) { controls.parent.removeChild(controls); }
		}
		
		private function startFilter():void
		{
			if (adjustMode) { this.endAdjustMode(); }
			//if (this.contains(target)) { this.removeChild(target); }
			
			shader = new Shader();
			shader.byteCode = new DifferenceKeyShader();
			
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		}
		
		
		private function onEnterFrame(e:Event):void
		{
			if (!adjustMode)
			{
				this.applyFilter(target);
			}
		}
		
		private function applyFilter(targetObject:IBitmapDrawable):void
		{
			//var source:BitmapData = new BitmapData(destBMD.width, destBMD.height, false, 0x000000);
			//source.draw(targetObject);
			
			//shader = new Shader();
			//shader.byteCode = new DifferenceKeyShader();
			shader.data.keyColor.value = hex2RGB(_keyColor);
			shader.data.tolerance.value = [_tolerance];
			shader.data.ramp.value = [_ramp];
			shader.data.gamma.value = [_gamma];
			//shader.data.src.input = source;
			
			filter = new ShaderFilter(shader);
			target.filters = [filter];
			
			//destBMD.applyFilter(source, source.rect, new Point(), filter);
		}
		
		private function hex2RGB ( hex:uint ):Array
		{
			var r:uint = (hex & 0xff0000) >> 16;
			var g:uint = (hex & 0x00ff00) >> 8;
			var b:uint = (hex & 0x0000ff);
			return [r/255, g/255, b/255];
		}
		
		
		private var _paused:Boolean = false;
		
		
		private var _stopped:Boolean = false;
		public function get stopped():Boolean
		{ return _stopped; }
		
		public function stop():void
		{
			if (!_stopped)
			{
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				this.removeChild(textField);
				
				if (_video) 
				{ 
					trace("Removing camera from video");
					//_video.attachCamera(null);
					if (container.contains(_video)) { container.removeChild(_video); }
					_video = null;
					//_camera = null;
				}
			}
			
			_stopped = true;
		}
		
		
		
	}
}