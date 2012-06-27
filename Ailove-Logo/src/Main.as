package 
{
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientGlowFilter;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import com.adobe.crypto.MD5;
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.utils.ByteArray;
	import flash.utils.SetIntervalTimer;
	import flash.utils.Timer;
	import com.adobe.images.PNGEncoder;
	
	/**
	 * ...
	 * @author 
	 */
	public class Main extends Sprite 
	{
		
		var colors  :Array = [
			0xED1C24,
			0xF68B1F,
			0x00A651,
			0x00ABBD,
			
			//0x3BAAF5, 
			//0x7AC93F, 
			//0xFF8F19, 
			//0xFF1825, 
			//0xFF76AB, 
		];
		
		var blending:Array = [
			//BlendMode.MULTIPLY,
			//BlendMode.HARDLIGHT,
			//BlendMode.NORMAL, 
			//BlendMode.LIGHTEN,
			//BlendMode.DARKEN,
			
			//BlendMode.DIFFERENCE,
			//BlendMode.ADD,
			//BlendMode.MULTIPLY, 
			BlendMode.SCREEN,
			BlendMode.OVERLAY,
			//BlendMode.HARDLIGHT,
			//BlendMode.INVERT,
		];
		
		var P:Number = 1.618;
		var D:int    =    7;
		var N:int    =    5;
		var X, Y, R:Number;
		var H:Array = [];
		var canvas:Sprite = new Sprite();
		var blobs :Sprite = new Sprite();
		var debug :Sprite = new Sprite();
		
		var input:TextField;
		var hash :TextField;
		var timer:uint;
		var file:FileReference = new FileReference();
		
		[Embed(source="../assets/logo-template.png")]
		public var Logo:Class;
		public var logo:BitmapData = Bitmap(new Logo()).bitmapData;
		
		public function Main():void  {
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			X = stage.stageWidth  >> 1;
			Y = stage.stageHeight >> 1;
			R = stage.stageWidth / P / P;
			timer = 2;
			
			input = new TextField();
			input.defaultTextFormat = new TextFormat("Trebuchet MS", 24 ,0x808080,null,null,null,null,null,"center")
			input.text       ="enter your email here";
			input.x          =   0;
			input.y          = stage.stageHeight - 60;
			input.width      = stage.stageWidth;
			input.height     =  36;
			input.maxChars   = 100;
			input.selectable = true;
			input.type       = TextFieldType.INPUT;
			input.addEventListener(TextEvent.TEXT_INPUT, onText);
			input.addEventListener(Event.CHANGE, onText);
			
			addChild(input);
			
			hash = new TextField();
			hash.defaultTextFormat = new TextFormat("Trebuchet MS", 9 ,0xA0A0A0,null,null,null,null,null,"center")
			hash.x          =   0;
			hash.y          = stage.stageHeight - 20;
			hash.width      = stage.stageWidth;
			hash.height     =  36;
			hash.maxChars   = 100;
			addChild(hash);
			
			onText();
			canvas.addEventListener(MouseEvent.CLICK, onMouseClick);
			canvas.useHandCursor = true;
			addChild(canvas);
			canvas.filters = [
				new DropShadowFilter(
					0,90,0xFFFFFF,0.1,4,4,4,3
				),
				new ConvolutionFilter(3, 3,
					[ 0.00,-0.25, 0.0, 
					 -0.25, 2.00,-0.25,
					  0.00,-0.25, 0.0], 
				1)];
			canvas.x = X;
			canvas.y = Y-24;
			canvas.mask = new Sprite;
			canvas.mask.x = X;
			canvas.mask.y = Y-24;
			addChild(canvas.mask);
			
			var g:Graphics = Sprite(canvas.mask).graphics;
			g.beginFill(0);
			g.drawCircle(0, 0, R);
			//drawHeart(g, 11, 128);
			g.endFill();
			
			addChild(blobs)
			blobs.blendMode = BlendMode.SCREEN;
			blobs.x = X;
			blobs.y = Y - 24;
			blobs.filters = [
				//new GlowFilter(0xFFFFFF, 1, 64, 64, 1, 3),
				new GradientGlowFilter(0, 0,
					[0xFFFFFF, 0xFFFFFF], 
					[0.0 ,  1.0], 
					[0xB0, 0xC0],
					8, 8, 3.5, 
					3,"outer",false),
				new GradientGlowFilter(0, 0,
					[0xFFFFFF, 0xFFFFFF], 
					[0.0 ,  1.0], 
					[0x60, 0x63],
					32, 32, 3.0, 
					3, "outer", true),

			]
			generateBlobs();
			
			addChild(debug);
			debug.x = X;
			debug.y = Y-24;
			debug.blendMode = "multiply";
			
			
			var t:Timer = new Timer(250);
			t.addEventListener(TimerEvent.TIMER, everySec);
			t.start();
		}
		
		private function generateBlobs():void {
			for (var i:int = 0; i < N*2; i++ ) {
				var b:Sprite = new Sprite();
				blobs.addChild(b);
				b.x = 0;
				b.y = 0;
				b.scaleX = b.scaleY = 0;
				//TweenLite.to(b, 1, {
				//	scaleX: H[i * 3 + 2] / 255.0 + 0.5,
				//	scaleY: H[i * 3 + 2] / 255.0 + 0.5,
				//	delay :i / 10.0 } );
					
				var g:Graphics = b.graphics;
				g.beginFill(0xFFFFFF);
				g.drawCircle(0, 0, 10);
				//g.drawRect( -10, -10, 20, 20);
				g.endFill();
			}
		}
		
		
		private function moveBlobs():void {
			for (var i:uint = 0; i < blobs.numChildren; i++ ) {
				var b:Sprite = blobs.getChildAt(i) as Sprite;
				TweenLite.to(b, 1, {
					x     : (H[i * 3    ] % 7-3)*X/8, 
					y     : (H[i * 3 + 1] % 7-3)*X/8,
					scaleX: H[i * 3 + 2] % 2 + 1,
					scaleY: H[i * 3 + 2] % 2 + 1,
					delay:i/10.0});
			}
		}
		
		private function everySec(e:Event = null):void {
			if (++timer == 3) {
				canvas.graphics.clear();
				debug.graphics.clear();
				draw();
				moveBlobs();
				//drawDebug();
			}
		}
		
		private function onMouseClick(e:MouseEvent=null):void {
			var M:Matrix = new Matrix;
			M.tx = 1110;
			M.ty =   24;
			var bd:BitmapData = logo.clone();
			bd.draw(stage, M);
			file.save(PNGEncoder.encode(bd), input.text+".png");
			//var bd:BitmapData = new BitmapData(512,512,false,0xFFFFFF);
			//bd.draw(stage);
			//file.save(PNGEncoder.encode(bd), input.text+".png");
			
		}
		
		private function onText(e:Event=null):void {
			
			H = [];
			hash.text = MD5.hash(input.text);
			hash.appendText(MD5.hash(hash.text));
			hash.appendText(MD5.hash(hash.text));
			
			for (var i:int = 0; i < hash.text.length / 2; i++) {
				var h:String = "0x" + hash.text.substr(i * 2, 2);
				H.push(parseInt(h));
			}

			timer = 0;

		}
		
		private function draw():void {
			
			while (canvas.numChildren) canvas.removeChildAt(0);
			
			
			var a:Array = [];
			
			for (var i:int = 0; i < N; i++ ) {
				// var l:int = Math.round(Math.random() * 4-2);
				
				var ac:Number = Math.round((H[i*2+0]/255.0) * D) * Math.PI * 2 / D;
				var ar:Number = Math.round((H[i*2+1]/255.0) * (D / 2 - 2) + 1) * Math.PI * 2 / D;
				
				var xc:Number = Math.pow(P, H[i] % 3 - 1) * R * Math.cos(ac);
				var yc:Number = Math.pow(P, H[i] % 3 - 1) * R * Math.sin(ac);
				var xr1:Number = R * Math.cos(ac + ar);
				var yr1:Number = R * Math.sin(ac + ar);
				var xr2:Number = R * Math.cos(ac - ar);
				var yr2:Number = R * Math.sin(ac - ar);
				var rc:Number = Math.sqrt(Math.pow(xr1 - xc , 2) + Math.pow(yr1 - yc , 2));
				var hr:Number = Math.sqrt(Math.pow(xr1 - xr2, 2) + Math.pow(yr1 - yr2, 2));
			
				a.push( { x:xc, y:yc, x1:xr1, y1:yr1, x2:xr2, y2:yr2, r:rc, h: hr, a:ac} );
				
				//var g:Graphics = debug.graphics;
				//g.moveTo(xc, yc);
				//g.lineStyle(0, 0, 0.2);
				//g.lineTo(xr1, yr1);
				//g.moveTo(xc, yc);
				//g.lineStyle(0, 0, 0.2);
				//g.lineTo(xr2, yr2);
		
			}
			
			a = a.sortOn("r", Array.NUMERIC | Array.DESCENDING);
			
			var c1:int = H[0] % colors.length;
			var c2:int = H[1] % colors.length;
			
			var g:Graphics = canvas.graphics;
			
			var M:Matrix = new Matrix;
			M.createGradientBox(X*2, Y*2, (H[1]/255.0)*Math.PI*2, -X , -Y);
			g.beginGradientFill(
				GradientType.RADIAL,
				[colors[c1], colors[c2]],
				[1.00 , 1.00 ],
				[0x00 , 0xFF ],
				M
			);
			
			//g.beginFill(colors[int(Math.random() * colors.length)], 1.00);
			g.drawCircle(0, 0, R);
			g.endFill();
			
			for (var i:int = 0; i < N; i++ ) {
								
				var c:Sprite = new Sprite;
				canvas.addChild(c);
				c.x = a[i].x; 
				c.y = a[i].y; 
				c.blendMode =  blending[H[i] % blending.length]
				g = c.graphics;
				c1 = H[i*2+0] % colors.length;
				c2 = H[i*2+1] % colors.length;
				
				var M:Matrix = new Matrix;
				M.createGradientBox(a[i].h, a[i].h, a[i].a + Math.PI / 2, a[i].x-a[i].h/2 , a[i].y-a[i].h/2);
				
				g.beginGradientFill(
					GradientType.LINEAR,
					[colors[c1], colors[c1]],
					[      0.00,       1.0],
					[      0x00,       0xFF],
					M
				);
		
				//g.beginFill(colors[int(Math.random() * colors.length)],0.50);
				g.drawCircle(0, 0, a[i].r);
				g.endFill();
				//if (H[i]%4 == 0 ) c.filters = [new BlurFilter(H[i] % 32+4, H[i] % 32+4, 3)];
				c.scaleX = c.scaleY = 0; 
				TweenLite.to(c, 1, {scaleX:1, scaleY:1, ease:com.greensock.easing.Cubic.easeOut, delay:i/5.0});
			}
			
			//var nl:uint = N;
			//for (var i:int = 0; i < N; i++ ) {
			//	if (i % 3 == 0) {
			//		var c:Sprite = new Sprite;
			//		canvas.addChild(c);
			//		c.alpha = 0;
			//		g = c.graphics;
			//		g.lineStyle(0, 0xFFFFFF, 0.75);
			//		g.drawCircle(a[i].x, a[i].y, a[i].r);
			//		TweenLite.to(c, 2, {alpha:1, delay:++nl/5.0});
			//	}
			//	//g.beginFill(0xFFFFFF, 1);
			//	//g.drawCircle(a[i].x1, a[i].y1, 5);
			//	//g.drawCircle(a[i].x2, a[i].y2, 5);
			//	//g.endFill();
			//}
			
			//var c:Sprite = new Sprite;
			//canvas.addChild(c);
			////c.filters = [new DropShadowFilter(4,90,0,0.1,8,8)]
			//c.scaleX = c.scaleY = 0;
			//TweenLite.to(c, 2, {scaleX:1, scaleY:1, delay: N/20.0});
			//g = c.graphics;
			//g.beginFill(0xFFFFFF);
			//drawHeart(g, 9, 128);
			//g.endFill();
		}
		
		
		private function drawHeart(g:Graphics, sc:int, sp:int):void {
			g.moveTo(0, -5*sc);
			for (var i:int = 0; i <= sp; i++) {
				var b:Number = Math.PI * 2/ sp * i;
				var x:Number = sc*(16 * Math.pow(Math.sin(b), 3));
				var y:Number =-sc*(13 * Math.cos(b) - 5 * Math.cos(2 * b) - 2 * Math.cos(3 * b) - Math.cos(4 * b));
				g.lineTo(x, y);
			}
		}
		
		private function drawDebug():void {
			
			
			var g:Graphics = debug.graphics;
			g.lineStyle(0, 0, 0.2);
			
			for (var i:int = -1; i <= 2; i++) {
				var r:Number = R * Math.pow(P, i);
				g.drawCircle(0, 0, r);
				for (var j:int = 0; j < D; j++) {
					var a:Number = j * Math.PI * 2 / D;
					var x = Math.cos(a);
					var y = Math.sin(a);
					g.moveTo(x * (r - 5), y * (r - 5));
					g.lineTo(x * (r + 6), y * (r + 6));
				}
			}
			
			
		}
		
	}
	
}