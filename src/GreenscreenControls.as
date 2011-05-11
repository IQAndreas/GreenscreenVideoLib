package
{
	import com.bit101.components.HSlider;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.Slider;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class GreenscreenControls extends Sprite
	{
		public function GreenscreenControls(greenscreen:GreenscreenVideo, x:Number = 0, y:Number = 0)
		{
			super();
			
			this.greenscreen = greenscreen;
			
			window = new Window(this, x, y, "Greenscreen settings");
			window.hasMinimizeButton = true;
			window.hasCloseButton = false;
			
			const padding:Number = 10;
			vbox = new VBox(null, padding, padding);
			vbox.spacing = 3;
			
			keyColorBtn = new PushButton(vbox, 0, 0, "Change key color", onChangeKeyColor);
			
			new Label(vbox, 0, 0, "Tolerance:");
			toleranceS = new HSlider(vbox, 0, 0, onChange);
			toleranceS.minimum = 0;
			//toleranceS.maximum = 3;
			toleranceS.maximum = 1;
			toleranceS.value = greenscreen.tolerance;
				
			new Label(vbox, 0, 0, "Ramp:");
			rampS = new HSlider(vbox, 0, 0, onChange);
			rampS.minimum = 0;
			rampS.maximum = 1;
			rampS.value = greenscreen.ramp;
				
			new Label(vbox, 0, 0, "Gamma:");
			gammaS = new HSlider(vbox, 0, 0, onChange);
			gammaS.minimum = 0;
			gammaS.maximum = 10;
			gammaS.value = greenscreen.gamma;
			
			window.width = vbox.width + padding*2;
			window.height = window.titleBar.height + vbox.height + padding*2 + padding;
			window.content.addChild(vbox);
			
			//this.x = x;
			//this.y = y;
			
		}
		
		private function onChange(e:Event):void
		{
			greenscreen.tolerance = toleranceS.value;
			greenscreen.ramp = rampS.value;
			greenscreen.gamma = gammaS.value;
		}
		
		private function onChangeKeyColor(e:Event):void
		{
			greenscreen.startAdjustMode();
		}
		
		private var greenscreen:GreenscreenVideo;
		
		private var window:Window;
		
		private var keyColorBtn:PushButton;
		
		private var vbox:VBox;
		private var toleranceS:HSlider;
		private var rampS:HSlider;
		private var gammaS:HSlider;
		
		
		
		
		
		
	}
}