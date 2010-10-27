package org.mineap.nndd.view
{
	import flash.display.CapsStyle;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;

	public class LoadingPicture extends Sprite
	{
		//図形の数（円周上にいくつ表示するか）
        private var _num:Number;

        //図形１つ分の幅を表す数値
        private var _aWidth:Number;
        //図形１つ分の長さ
        private var _barLength:Number;

        //図形の半径
        private var _radius:Number;

        //フレームごとの回転速度
        private var _rotationPerFrame:Number;

        //線のスタイル
        private var _capsStyle:String;

        //開始色
        private var _startColor:uint;
        //終了色
        private var _endColor:uint;

        public function set num(value:Number):void{
            _num = value;
        }
        public function set aWidth(value:Number):void{
            _aWidth = value;
        }
        public function set barLength(value:Number):void{
            _barLength = value;
        }
        public function set radius(value:Number):void{
            _radius = value;
        }
        public function set capsStyle(value:String):void{
            _capsStyle = value;
        }
        public function set startColor(value:uint):void{
            _startColor = value;
        }
        public function set endColor(value:uint):void{
            _endColor = value;
        }
        public function set rotationPerFrame(value:Number):void{
            _rotationPerFrame = value;
        }

        public function LoadingPicture(
        radius:Number = 70, num:Number = 12, aWidth:Number = 6, length:Number = 20, 
        startColor:uint = 0x444444, endColor:uint = 0xdddddd, capsStyle:String=null){

            _radius = radius;
            _num = num;
            _aWidth = aWidth;
            _barLength = length;
            _capsStyle = capsStyle;
            _startColor = startColor;
            _endColor = endColor;

            redraw();
        }

        /**
         * 描画処理
         */
        public function redraw():void{
            var color:uint = _startColor;
            var differenceBig:Number;
            var differenceMiddle:Number;
            var differenceMin:Number;

            //開始色と終了職のRGBごとの値を取得
            var sb:Number = _startColor % 256;
            var sg:Number = (_startColor >> 8) % 256;
            var sr:Number = (_startColor >> 16) % 256;
            var eb:Number = _endColor % 256;
            var eg:Number = (_endColor >> 8) % 256;
            var er:Number = (_endColor >> 16) % 256;

            //開始色と終了色の差をRGBごとに計算
            differenceBig = int((er - sr) / _num) * 256 * 256;
            differenceMiddle = int((eg - sg) / _num) * 256;
            differenceMin = int((eb - sb) / _num);

            //現在の表示の消去
            graphics.clear();

            //円形にバーを描画する処理
            for(var i:Number = 0; i<=_num; i++){
                var angle:Number = -(i * 360 / _num) - 90;//真上から始めるために90度引く

                var sin:Number = Math.sin(angle * Math.PI / 180);
                var cos:Number = Math.cos(angle * Math.PI / 180);

                //バーの開始点と終了点を計算
                var point1:Point = new Point(cos * _radius, sin * _radius);
                var point2:Point = new Point(cos * (_radius - _barLength), sin * (_radius - _barLength));

                //バーの描画
                graphics.lineStyle(_aWidth, color, 1, false, null, _capsStyle);
                graphics.moveTo(point1.x, point1.y);
                graphics.lineTo(point2.x, point2.y);

                //色を１段階終了色に近づける
                color += differenceBig;
                color += differenceMiddle;
                color += differenceMin;
            }
        }

        public function show(aParent:DisplayObjectContainer, x:Number=0, y:Number=0):void{
            this.x = x;
            this.y = y;
            aParent.addChild(this);
        }

        public function start(rotationPerFrame:Number=10):void{
            this._rotationPerFrame = rotationPerFrame;
            this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        public function stop():void{
            this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        public function remove():void{
            this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            parent.removeChild(this);
        }

        private function onEnterFrame(event:Event):void{
            this.rotation += this._rotationPerFrame;
        }
	}
}