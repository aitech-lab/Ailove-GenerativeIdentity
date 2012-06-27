package 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.*;
	import flash.utils.ByteArray;
	import com.adobe.crypto.MD5;
	
	/**
	 * ...
	 * @author peko
	 */
	public class Main extends Sprite 
	{
		
		var X:uint; 
		var Y:uint; 
		var H:Array = [];
		
		var canvas:Sprite;
		
		static var PI:Number = Math.PI;
		static var P:Number  = 1.6180339887498948482;
		
		var input:TextField;
		var hash :TextField;
		var top   :Sprite = new Sprite();
		var bottom:Sprite = new Sprite();
		var lLeg  :Sprite = new Sprite();
		var rLeg  :Sprite = new Sprite();
		var lHand :Sprite = new Sprite();
        var rHand :Sprite = new Sprite();
		var lEar  :Sprite = new Sprite();
		var rEar  :Sprite = new Sprite();
		var Eyes  :Sprite = new Sprite();
		var Tail  :Sprite = new Sprite();
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			canvas = new Sprite;
			X = stage.stageWidth  >> 1;
			Y = stage.stageHeight >> 1;
			canvas.x = X;
			canvas.y = Y;
			addChild(canvas);
			canvas.addChild(lLeg  );
			canvas.addChild(rLeg  );
			canvas.addChild(bottom);
			canvas.addChild(top   );
			canvas.addChild(lHand );
			canvas.addChild(rHand );
			canvas.addChild(lEar );
			canvas.addChild(rEar );
			
			
			
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
			
			drawRabbit();

		}
		
		private function drawRabbit():void {
			
			var g:Graphics = canvas.graphics;
			g.clear();
			g.lineStyle(0, 0, 0.2);
			
			var dx:Number;
			var dy:Number;
			var h = 0;
			var sa:Number = 0;// H[h++] / 255.0;
			var top:Object    = { sc: H[h++] % 4+6, av: (H[h++]-128) / 128.0 * 0.15, r:30, rv: -1.0, d: sa * PI/4 - PI / 2.0, v : 5 };
			var bottom:Object = { sc: H[h++] % 4+6, av: (H[h++]-128) / 128.0 * 0.15, r:30, rv:  1.0, d: sa * PI/4 + PI / 2.0, v : 5 };
			
			drawArc(g, top );	
			drawArc(g, bottom );	
			
			var lLeg:Object   = clone(bottom);
			var rLeg:Object   = clone(bottom);
			lLeg.sc = 10;
			rLeg.sc = 10;
			lLeg.r /=  4;
			rLeg.r /=  4;
			
			dx = bottom.t.x / bottom.t.length;
			dy = bottom.t.y / bottom.t.length;

			lLeg.p.x += ( +dy ) * bottom.r / 2.0;
			lLeg.p.y += ( -dx ) * bottom.r / 2.0;
			rLeg.p.x += ( -dy ) * bottom.r / 2.0;
			rLeg.p.y += ( +dx ) * bottom.r / 2.0;
			lLeg.rv = 0.5;
			rLeg.rv = 0.5;
			//lLeg.av = (H[h++]-128) / 128.0 * 0.1;
			//rLeg.av = (H[h++]-128) / 128.0 * 0.1;
			lLeg.av *= -1;
			rLeg.av *= -1;
			
			drawArc(g, lLeg);
			drawArc(g, rLeg);
			
			lLeg.av = (H[h++]-128) / 128.0 * 0.1;
			rLeg.av = (H[h++]-128) / 128.0 * 0.1;
			lLeg.av *= -1;
			rLeg.av *= -1;
			drawArc(g, lLeg);
			drawArc(g, rLeg);
			
			var rHand:Object = clone(top);
			var lHand:Object = clone(top);
			lHand.sc =  10;
			rHand.sc =  10;
			lHand.r /=   4;
			rHand.r /=   4;
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
			
			drawArc(g, lHand);
			drawArc(g, rHand);
			
			drawArc(g, lHand);
			drawArc(g, rHand);
			
			var head:Object = clone(top);
			head.sc = 3;
			head.r *= 2;
			head.v  = 2;
			head.rv =-4;
			head.p.x += head.t.x / head.t.length * top.r * 2.0;
			head.p.y += head.t.y / head.t.length * top.r * 2.0;
			drawArc(g, head);
			
			var lEar:Object = clone(head);
			var rEar:Object = clone(head);
			lEar.sc =   7;
			rEar.sc =   7;
			lEar.v  =   5;
			rEar.v  =   5;
			lEar.rv = 0.5;
			rEar.rv = 0.5;
			lEar.r  = top.r / 3.0;
			rEar.r  = top.r / 3.0;
			
			dx = head.t.x / head.t.length;
			dy = head.t.y / head.t.length;

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
			
			for (var i:uint = 0; i < o.sc; i++ ) {
				
				g.beginFill(0);
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