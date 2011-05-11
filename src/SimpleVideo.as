package
{
	import flash.display.DisplayObjectContainer;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.osmf.utils.URL;
	
	public class SimpleVideo extends EventDispatcher
	{
		
		public static const ERROR:String = "SimpleVideo::error";
		public static const END_OF_VIDEO:String = "SimpleVideo::end_of_video";
		
		
		public function SimpleVideo(container:DisplayObjectContainer, url:String, targetWidth:Number = NaN, targetHeight:Number = NaN, fillToMax:Boolean = false)
		{
			trace("SimpleVideo", container, url, targetWidth + "x" + targetHeight);
			
			super(this);
			
			this.container = container;
			this.url = url;
			
			var connection:NetConnection = new NetConnection();
			connection.connect(null);
			
			stream = new NetStream(connection);
			
			stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			// I could set "this" as the client, but I would need to make
			// the two handler functions public. I don't want that.
			var streamClient:Object = new Object();
			streamClient.onMetaData = onMetaData;
			streamClient.onCuePoint = onCuePoint;
			stream.client = streamClient;
			
			//Start with default dimensions and fit target dimensions as
			//soon as the metadata is available
			video = new ScaledVideo(targetWidth, targetHeight, fillToMax);
			video.attachNetStream(stream);
			container.addChild(video);
			
			stream.play(url);			
			//stream.play(null);
			
			/*
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoaderComplete);
			loader.load(new URLRequest(url));
			*/
		}
		/*
		private function onLoaderComplete(event:Event):void
		{
			// http://www.bytearray.org/?p=1689
			var data:ByteArray = loader.data as ByteArray;
			stream.play(null);
			// before appending new bytes, reset the position to the beginning
			stream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
			// append the FLV video bytes
			stream.appendBytes(data);
		}*/
		
		private var loader:URLLoader;
		
		private var container:DisplayObjectContainer;
		private var url:String;
		//private var targetWidth:Number;
		//private var targetHeight:Number;
		//private var fillToMax:Boolean;
		
		private var video:ScaledVideo;
		private var stream:NetStream;

		private var resizer:ScaledVideo;
		
		
		private function onNetStatus(statusEvent:NetStatusEvent):void
		{
			/*trace("STATUS", statusEvent.info);
			var info:Object = statusEvent.info;
			for (var prop:String in info)
			{
				trace(prop + ":", info[prop]);
			}*/
			
			const START:String = "NetStream.Play.Start";
			const STOP:String = "NetStream.Play.Stop";
			
			if (statusEvent.info.code == START)
			{
				_playing = true;
				_finished = false;
			}
			if (statusEvent.info.code == STOP)
			{
				_playing = false;
				_finished = true;
				this.dispatchEvent(new Event(SimpleVideo.END_OF_VIDEO, false, false));
			}
		}
		
		private function onMetaData(meatadata:Object):void
		{
			//Video dimensions should now be available.
			//Will it automatically adjust?
			//this.fitToSize(targetWidth, targetHeight, fillToMax);
			//trace("METADATA");
			this.rescale();
		}
		
		private function onCuePoint(cuePoint:Object):void
		{
			//ignore all
			return;
		}
		
		
		public function stop():void
		{
			//Don't set everything to null just in case (may cause extra errors in this code).
			//This stuff should all be cleared by the garbage collector anyway.
			if (container.contains(video)) { container.removeChild(video); }
			stream.close();
		}
		
		public function fitToSize(targetWidth:Number, targetHeight:Number, fillToMax:Boolean = false):void
		{
			video.fitToSize(targetWidth, targetHeight, fillToMax);
		}
		
		public function rescale():void
		{
			video.rescale();
		}
		
		
		
		/*
		public function fitToSize(targetWidth:Number, targetHeight:Number, fillToMax:Boolean = false):void
		{
			this.targetWidth = targetWidth;
			this.targetHeight = targetHeight;
			this.fillToMax = fillToMax;
			
			this.rescale();
		}
		
		public function rescale():void
		{
			//trace("Rescaling video", video.width, video.videoWidth, video.height, video.videoHeight, video.scaleY);

			if ((video.videoWidth == 0) || (video.videoHeight == 0))
			{
				//Cannot rescale properly until the video is loaded.
				//Otherwise the video's scale will always be 0
				video.width = isNaN(this.targetWidth) ? 320 : this.targetWidth;
				video.height = isNaN(this.targetHeight) ? 240 : this.targetHeight;
			}
			else
			{
				video.width = video.videoWidth;
				video.height = video.videoHeight;
			}
			
			var tWidth:Number = isNaN(this.targetWidth) ? video.videoWidth : this.targetWidth;
			var tHeight:Number = isNaN(this.targetHeight) ? video.videoHeight : this.targetHeight;
			
			
			var scale:Number = getFillScale(video.width, video.height, tWidth, tHeight, fillToMax);
			video.scaleX *= scale;
			video.scaleY *= scale;
			video.x = (tWidth / 2) - (video.width / 2);
			video.y = (tHeight / 2) - (video.height / 2);
		}*/
		
		
		
		private function onIOError(errorEvent:IOErrorEvent):void
		{
			this.triggerError(errorEvent.text);
		}
		
		private function onAsyncError(errorEvent:AsyncErrorEvent):void
		{
			this.triggerError(errorEvent.text);
		}
		
		private function triggerError(errorText:String):void
		{
			if (this.willTrigger(SimpleVideo.ERROR))
			{
				this.dispatchEvent(new ErrorEvent(SimpleVideo.ERROR, false, false, errorText));
			}
			else
			{
				trace("SimpleVideo error: " + errorText);
			}
		}
		
		
		
		private var _playing:Boolean = false;
		public function get playing():Boolean
		{ return _playing; }
		
		//The difference is, a movie play not be playing, 
		//but may still not be finished if property is accessed before video is loaded.
		private var _finished:Boolean = false;
		public function get finished():Boolean
		{ return _finished; }
		
	}
}