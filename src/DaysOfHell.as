package {
	import com.bit101.components.FPSMeter;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;

	import org.bytearray.JPEGEncoder;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	[SWF(backgroundColor="#FFFFFF", frameRate="30", width="550", height="400")]
	public class DaysOfHell extends Sprite {
		private const FOLDER : String = "DaysOfHell/";
		private var _textField : TextField;
		private var _textFormat : TextFormat;
		private var _image : BitmapData;
		private var _drawMatrix : Matrix;
		private var _jpegEncoder : JPEGEncoder;
		private var _phrases : Array;
		private var _timer : Timer;
		private var _maxCount : int = 11;
		private var _count : int = 1;
		private var _labelOutput : Label;
		private var _inputDaysFrom : InputText;
		private var _inputDaysTo : InputText;
		private var _inputWidth : InputText;
		private var _inputHeight : InputText;
		private var _inputFontSize : InputText;
		private var _inputLetterSpacing : InputText;
		private var _buttonGo : PushButton;

		public function DaysOfHell() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			new Label(this, 10, 10, "Days of Hell image generator. Images will be saved on desktop in a folder named 'DaysOfHell'.");
			new Label(this, 10, 40, "DAY FROM:");
			_inputDaysFrom = new InputText(this, 120, 40, "1", onInputChange);
			new Label(this, 10, 60, "DAY TO:");
			_inputDaysTo = new InputText(this, 120, 60, "10", onInputChange);
			new Label(this, 10, 80, "PAGE WIDTH:");
			_inputWidth = new InputText(this, 120, 80, "900");
			new Label(this, 10, 100, "PAGE HEIGHT:");
			_inputHeight = new InputText(this, 120, 100, "1200");
			new Label(this, 10, 120, "FONT SIZE:");
			_inputFontSize = new InputText(this, 120, 120, "40");
			new Label(this, 10, 140, "LETTER SPACING:");
			_inputLetterSpacing = new InputText(this, 120, 140, "8");
			new PushButton(this, 10, 170, "LOAD PHRASES", onLoadFileClick);
			_buttonGo = new PushButton(this, 120, 170, "GO", onGO);
			_labelOutput = new Label(this, 10, 190);
			new FPSMeter(this, 500, 10);

			_timer = new Timer(1000);
			onInputChange(null);
			
			Font.registerFont(FontClass_125c88f958dfc368_dTLFleischmannD); // libs/font.swc
			_textFormat = new TextFormat("dTLFleischmannD", 40, 0x000000);
			_textFormat.letterSpacing = 8;
			_textFormat.align = TextFormatAlign.CENTER;

			_textField = new TextField();
			_textField.embedFonts = true;
			_textField.antiAliasType = AntiAliasType.ADVANCED;
			_textField.defaultTextFormat = _textFormat;
			_textField.autoSize = TextFieldAutoSize.LEFT;
			
			_drawMatrix = new Matrix();
			
			_phrases = [' DAYS IN HELL', ' DAYS TRYING', ' DAYS I LOVED YOU', ' SURRENDERS', ' FORGOTTEN DAYS', ' WONDERS', ' DAYS WANDERING', ' PROPHECIES', ' DAYS ALONE', ' DAYS MISSING YOU', ' DEGREES HIGHER', ' NEW BEGINNINGS', ' LOST DAYS ', ' DAYS BELOW', ' DAYS WITHOUT YOU', ' DAYS BEING LUCKY', ' TIMES I SAID I WONT', ' DAYS GETTING CLOSER', ' CALLS TO END THIS', ' TIMES DEEPER', ' GOODBYES', ' NO TOMORROWS', ' WAKE UPS', ' RESPONSES TO NOTHING', ' LEARNT LESSONS', ' HEART BEATS', ' UNFULFILLED PROMISES', ' INSANITIES', ' DAYS HOPING', ' DAYS DISMAYED', ' DESTROYERS', ' EMBRACES', ' LITTLE DEATHS', ' DAYS GETTING OLDER', ' VIOLENCES', ' BRUISED TENACITIES', ' PLEASURABLE REFINEMENTS', ' ADDED SUBSTANCES', ' HAZARDOUS CHOICES', ' RISKS TAKEN', ' AMBITIONS', ' SMALL FAILURES', ' TIMES CLOSER TO DEATH', ' TIMES PULLING THE PLUG', ' TIMES MORE FRAGILE', ' TIMES STRONGER'];
		}

		private function onInputChange(event : Event) : void {
			_count = int(_inputDaysFrom.text);
			_maxCount = int(_inputDaysTo.text) + 1;
			var days : int = _maxCount - _count;

			_labelOutput.text = String(days) + " images will take around " + Number(days / 60).toFixed(1) + " minutes";
		}

		private function onGO(event : Event) : void {
			_textFormat.size = Number(_inputFontSize.text);
			_textFormat.letterSpacing = Number(_inputLetterSpacing.text);
			
			_image = new BitmapData(int(_inputWidth.text), int(_inputHeight.text), false, 0xFFFFFFFF);
			
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
			_buttonGo.enabled = false;
		}

		private function onTimer(event : Event) : void {
			if (_count < _maxCount) {
				createImage(String(_count));
				_count++;
			} else {
				removeEventListener(TimerEvent.TIMER, onTimer);
				_timer.stop();
				_labelOutput.text = _labelOutput.text + " ...DONE!";
				_buttonGo.enabled = true;
				_count = int(_inputDaysFrom.text);
			}
		}

		private function createImage(days : String) : void {
			var phrase : String = _phrases[ ( Math.floor(_phrases.length * Math.random()) ) ];
			_textField.text = days + " " + trim(phrase).toUpperCase();
			_textField.setTextFormat(_textFormat);

			_drawMatrix.identity(); 
			_drawMatrix.translate((_image.width - _textField.width) * 0.5, (_image.height - _textField.height) * 0.5);

			_image.fillRect(_image.rect, 0xFFFFFFFF);
			_image.draw(_textField, _drawMatrix, null, null, null, true);

			_jpegEncoder = new JPEGEncoder(100);
			var bytes : ByteArray = _jpegEncoder.encode(_image);
			var fileName : String = FOLDER + days + ".jpg";
			saveFile(bytes, fileName);

			_labelOutput.text = "Processed: " + days;
		}

		private function saveFile(bytes : ByteArray, fileName : String) : void {
			var file : File = File.desktopDirectory.resolvePath(fileName);
			var stream : FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(bytes);
			stream.close();
		}
		
		private var _fileRef: FileReference;
		
		private function onLoadFileClick(event : Event) : void {
			_fileRef = new FileReference();
			_fileRef.addEventListener(Event.SELECT, onFileSelect);
			_fileRef.browse([new FileFilter("Text File", "*.txt;*.text;*")]);
//			_fileRef.browse();
		}

		private function onFileSelect(event : Event) : void {
			_fileRef.addEventListener(Event.COMPLETE, onLoadComplete);
			_fileRef.load();
		}

		private function onLoadComplete(event : Event) : void {
			var data : ByteArray = _fileRef.data;
			var phrases: String = data.readUTFBytes(data.bytesAvailable);
			_phrases = phrases.split(",");
			_labelOutput.text = String( _phrases.length ) + " phrases loaded";	
		}
		
		private function trim(s: String): String {
			return s.replace(/^\s+|\s+$/gs, '');
		}
	}
}
