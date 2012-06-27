package 
{
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.text.*;
	import flash.utils.ByteArray;
	import com.adobe.crypto.MD5;
	import com.adobe.images.PNGEncoder;
	
	
	/**
	 * ...
	 * @author peko
	 */
	public class Main extends Sprite 
	{
		
		var X:uint; 
		var Y:uint; 
		var H:Array = [];
		
		var file:FileReference = new FileReference();

		var colors  :Array = [
			//0xED1C24,
			//0xF68B1F,
			//0x00A651,
			//0x00ABBD,
			
			0x3BAAF5, 
			0x7AC93F, 
			0xFF8F19, 
			0xFF1825, 
			0xFF76AB, 
		];
		
		var canvas:Sprite = new Sprite;
		var backgr:Sprite = new Sprite;
		
		static var PI:Number = Math.PI;
		static var P:Number  = 1.6180339887498948482;
		
		var input:TextField;
		var hash :TextField;
		
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			
			X = stage.stageWidth  >> 1;
			Y = stage.stageHeight >> 1;
			
			backgr.x = X;
			backgr.y = Y;
			addChild(backgr);
			
			canvas.x = X;
			canvas.y = Y+24;
			canvas.filters = [
				new ColorMatrixFilter([
				   -1.0, 0.0, 0.0, 0.0, 255.0,
				    0.0,-1.0, 0.0, 0.0, 255.0,
				    0.0, 0.0,-1.0, 0.0, 255.0,
				   -1.0,-1.0,-1.0, 1.0,   0.0,
				])
			];
			addChild(canvas);

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
			
			drawRabbit();
			
			canvas.addEventListener(MouseEvent.CLICK, onMouseClick);
			backgr.addEventListener(MouseEvent.CLICK, onMouseClick);
			
		}
		
		
		function onText(e:Event = null):void {
			
			H = [];
			hash.text = MD5.hash(input.text);
			hash.appendText(MD5.hash(hash.text));
			hash.appendText(MD5.hash(hash.text));
			
			for (var i:int = 0; i < hash.text.length / 2; i++) {
				var h:String = "0x" + hash.text.substr(i * 2, 2);
				H.push(parseInt(h));
			}
			
			drawBg();
			drawRabbit();
			

		}
		
		
		private function onMouseClick(e:MouseEvent=null):void {
			//var M:Matrix = new Matrix;
			//M.tx = 1110;
			//M.ty =   24;
			//var bd:BitmapData = logo.clone();
			//bd.draw(stage, M);
			//file.save(PNGEncoder.encode(bd), input.text+".png");
			var bd:BitmapData = new BitmapData(512,512,false,0xFFFFFF);
			bd.draw(stage);
			file.save(PNGEncoder.encode(bd), input.text+".png");
			
		}

		
		private function drawBg():void {
			
			var g:Graphics = backgr.graphics;
			g.clear();

			g.beginFill(colors[H[0] % colors.length]);
			g.drawCircle(0, 0 , 150);
			
		}
		
		private function drawRabbit():void {

			
			var g:Graphics = canvas.graphics;
			g.clear()
			
			var max_av:Number = 0.10;
			                    
			var dx:Number;
			var dy:Number;
			var h:uint = 0;
			var top:Object = { sc: 8, av: (H[h++]-128) / 128.0 * max_av, r:30, rv: -1.0, d: - PI / 2.0, v : 3 };
			var bot:Object = { sc: 8, av: (H[h++]-128) / 128.0 * max_av, r:30, rv:  1.0, d: + PI / 2.0, v : 3 };
			
			drawArc(g, top);	
			drawArc(g, bot);	
			
			var lLeg:Object   = clone(bot);
			var rLeg:Object   = clone(bot);
			lLeg.sc = 10;
			rLeg.sc = 10;
			lLeg.r /=  4;
			rLeg.r /=  4;
			
			dx = bot.t.x / bot.t.length;
			dy = bot.t.y / bot.t.length;

			lLeg.p.x += ( +dy ) * bot.r / 2.0;
			lLeg.p.y += ( -dx ) * bot.r / 2.0;
			rLeg.p.x += ( -dy ) * bot.r / 2.0;
			rLeg.p.y += ( +dx ) * bot.r / 2.0;
			lLeg.rv = 0.5;
			rLeg.rv = 0.5;
			lLeg.av = Math.abs((H[h++]-128) / 128.0 * 0.1) * (top.av > 0 ? 1 : -1);
			rLeg.av = Math.abs((H[h++]-128) / 128.0 * 0.1) * (top.av > 0 ? 1 : -1);
			lLeg.d -= H[h++] / 255.0 * PI / 4.0;
			rLeg.d += H[h++] / 255.0 * PI / 4.0;
		
			drawArc(g, lLeg);
			drawArc(g, rLeg);
			
			lLeg.av = Math.abs((H[h++]-128) / 128.0 * 0.2) * (top.av > 0 ? -1 : 1)
			rLeg.av = Math.abs((H[h++]-128) / 128.0 * 0.2) * (top.av > 0 ? -1 : 1)
		
			drawArc(g, lLeg);
			drawArc(g, rLeg);
			
			var gx:Number = lLeg.p.x + rLeg.p.x;
			var gy:Number = lLeg.p.y + rLeg.p.y;
			var ga:Number = Math.atan2(lLeg.p.y - rLeg.p.y, lLeg.p.x - rLeg.p.x);
			canvas.rotation = -ga*180/PI;
			trace (ga);
			//canvas.x +=gx;
			//canvas.y +=gy;
			
			
			var tail:Object = clone(bot);
			var tb:Number = 1.0-(max_av - Math.abs(bot.av)) / max_av;  
			tail.p.x +=+dy*(bot.r*1.2)*tb*(bot.av > 0 ? 1 : -1)
			tail.p.y +=-dx*(bot.r*1.2)*tb*(bot.av > 0 ? 1 : -1)
			tail.sc   = 1;
			tail.r    = bot.r / 3.0;
			drawArc(g, tail)
			
			var rHand:Object = clone(top);
			var lHand:Object = clone(top);
			lHand.sc =   8;
			rHand.sc =   8;
			lHand.r /=   3;
			rHand.r /=   3;
			lHand.rv = 0.5;
			rHand.rv = 0.5;
			lHand.av = (H[h++]-128) / 128.0 * 0.2;
			rHand.av = (H[h++]-128) / 128.0 * 0.2;
			
			dx = top.t.x / top.t.length;
			dy = top.t.y / top.t.length;
			
			lHand.p.x += ( dy*2-dx/2.0) * top.r / 2.0;
			lHand.p.y += (-dx*2-dy/2.0) * top.r / 2.0;
			rHand.p.x += (-dy*2-dx/2.0) * top.r / 2.0;
			rHand.p.y += ( dx*2-dy/2.0) * top.r / 2.0;
			lHand.d -= PI / 2.0 + PI/6.0;
			rHand.d += PI / 2.0 + PI/6.0;
			lHand.av = (H[h++]-128) / 128.0 * 0.2;
			rHand.av = (H[h++]-128) / 128.0 * 0.2;
			
			var lHandC:Object = clone(lHand);
			var rHandC:Object = clone(rHand);
			lHandC.cl  = 0x404040;
			rHandC.cl  = 0x404040;
			lHandC.r  *= 0.8;
			rHandC.r  *= 0.8;
			lHandC.rv *= 1.5;
			rHandC.rv *= 1.5;
			
			drawArc(g, lHandC);
			drawArc(g, rHandC);
			                
			drawArc(g, lHandC);
			drawArc(g, rHandC);
			
			drawArc(g, lHand);
			drawArc(g, rHand);
			
			drawArc(g, lHand);
			drawArc(g, rHand);
			

			var head:Object = clone(top);
			head.sc   = 3;
			head.r   *= 2;
			head.v    = 2;
			head.rv   =-4;
			head.p.x += dx * top.r * 2.0;
			head.p.y += dy * top.r * 2.0;
			drawArc(g, head);
			
			dx = head.t.x / head.t.length;
			dy = head.t.y / head.t.length;
			
			var lEye:Object = clone(head);
			var rEye:Object = clone(head);
			
			lEye.sc =   1;
			rEye.sc =   1;
			lEye.v  =   1;
			rEye.v  =   1;
			lEye.rv =   0;
			rEye.rv =   0;
			lEye.r  = top.r / P / P;
			rEye.r  = top.r / P / P;
		    lEye.d -= H[h++] / 255.0 * PI / 10.0;
			rEye.d += H[h++] / 255.0 * PI / 10.0;
			
			var ed:Number = 1.0-(max_av - Math.abs(head.av)) / max_av;  
			var edx:Number = dy * ed * (head.av > 0 ? 1 : -1);
			var edy:Number =-dx * ed * (head.av > 0 ? 1 : -1);
			
			lEye.p.x +=( dy/1.5 - dx + edx)* head.r / P ;
			lEye.p.y +=(-dx/1.5 - dy + edy)* head.r / P ;
			rEye.p.x +=(-dy/1.5 - dx + edx)* head.r / P ;
			rEye.p.y +=( dx/1.5 - dy + edy)* head.r / P ;
			lEye.cl = 0x404040;
			rEye.cl = 0x404040;
			
			drawArc(g, lEye);
			drawArc(g, rEye);
			
			lEye.cl = 0;
			rEye.cl = 0;
			
			lEye.p.x -= edx * lEye.r;
			lEye.p.y -= edy * lEye.r;
			rEye.p.x -= edx * rEye.r;
			rEye.p.y -= edy * rEye.r;
			
			lEye.r /= P*P;
			rEye.r /= P*P;
			
			drawArc(g, lEye);
			drawArc(g, rEye);
		
			var lEar:Object = clone(head);
			var rEar:Object = clone(head);
			lEar.sc =   5;
			rEar.sc =   5;
			lEar.v  =   5;
			rEar.v  =   5;
			lEar.rv = 0.5;
			rEar.rv = 0.5;
			lEar.r  = top.r / 2.0;
			rEar.r  = top.r / 2.0;
			lEar.d -= H[h++] / 255.0 * PI / 10.0;
			rEar.d += H[h++] / 255.0 * PI / 10.0;
			
			lEar.p.x +=( dy + dx )* head.r / P ;
			lEar.p.y +=(-dx + dy )* head.r / P ;
			rEar.p.x +=(-dy + dx )* head.r / P ;
			rEar.p.y +=( dx + dy )* head.r / P ;
			
			drawArc(g, lEar);
			drawArc(g, rEar);
			
			drawArc(g, lEar);
			drawArc(g, rEar);
			
			
		}
		
		// Object param
		// p  - start point
		// v  - velocity vector
		// a  - acceleration vector
		// d  - start direction
		// av - angular veloctiy
		// aa - angular acceleartion
		// r  - start radius
		// rv - radius velocity
		// ra - radius acceleration
		// sc - steps counter
		// cl - color
		private function drawArc(g:Graphics, o:Object ):Object { 
			
			if (!o.p ) o.p  = new Point;
			if (!o.v ) o.v  = 10;
			if (!o.a ) o.a  =  0;
			if (!o.d ) o.d  =  0;
			if (!o.av) o.av =  0;
			if (!o.aa) o.aa =  0;
			if (!o.r ) o.r  = 20;
			if (!o.rv) o.rv =  0;
			if (!o.ra) o.ra =  0;
			if (!o.sc) o.sc = 10;
			if (!o.cl) o.cl =  0;
			
			for (var i:uint = 0; i < o.sc; i++ ) {

				g.beginFill(o.cl);
				g.drawCircle(o.p.x, o.p.y, o.r);
				g.endFill();
				
				var M:Matrix = new Matrix;
				M.rotate(o.d);
				o.t = new Point(o.v, 0);
				o.t = M.transformPoint(o.t);
				o.p = o.p.add(o.t);
				
				o.v  += o.a;
				o.av += o.aa;
				o.d  += o.av;
				o.rv += o.ra;
				o.r  += o.rv;
			}
			
			return o;
		}
		
		private function clone(o:Object):Object {
			var c:Object = { };
			for (var k:String in o)
				if (o[k] is Point) c[k] = new Point(o[k].x, o[k].y); else c[k] = o[k];
			return c
		}
		
	}
	
}