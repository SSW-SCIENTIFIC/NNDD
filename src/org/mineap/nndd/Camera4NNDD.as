package org.mineap.nndd
{
	
	import flash.events.ActivityEvent;
	import flash.media.Camera;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.controls.VideoDisplay;
	
	public class Camera4NNDD
	{
		
		private var camera:Camera;
		
		/**
		 * カメラを初期化します。
		 * @param width カメラから取得する画像の横幅です
		 * @param height カメラから取得する画像の高さです
		 * @param fps カメラでキャプチャするFPSです
		 * 
		 */
		public function Camera4NNDD(width:int, height:int, fps:int)
		{
			//カメラソースを取得
			camera = Camera.getCamera();
			//表示処理
			if ( camera != null ) {
				//カメラのモードを変更
				camera.setMode(width,height,fps);
				
			} else {
				//カメラが接続されていないとき
				trace("カメラ無し");
			}
		
		}
		
		/**
		 * 引数として与えられたVideoDisplayにCameraオブジェクトを
		 * セットし、その結果を返します。
		 * @param videoDisplay CameraオブジェクトをセットしたいVideoDisplayオブジェクト
		 * @return Cameraオブジェクトのセットに成功したかどうか(trueかfalse)
		 * 
		 */
		public function makeCameraForVideoDisplay(videoDisplay:VideoDisplay):Boolean
		{
			if(camera != null){
				videoDisplay.attachCamera(camera);
				return true;
			}else{
				return false;
			}
		}
		
		
		/**
		 * 引数として与えられたNetStreamにCameraオブジェクトをセットし、
		 * その結果を返します。 
		 * @param netStream
		 * @return 
		 * 
		 */
		public function makeCameraForNetStream(netStream:NetStream):Boolean
		{
			netStream = new NetStream(new NetConnection());
			if(camera != null){
				netStream.attachCamera(camera);
				return true;
			}else{
				return false;
			}
		}
		
		
		/**
		 * 引数で与えられたVideoDisplayオブジェクトからCameraを取り除きます。
		 * @param videoDisplay Cameraを取り除きたいVideoDisplayオブジェクト
		 * @return Cameraオブジェクトの取り除きに成功したかどうか
		 * 
		 */
		public function removeCamera(videoDisplay:VideoDisplay):Boolean
		{
			if(camera != null){
				videoDisplay.attachCamera(null);
				return true;
			}
			return false;
		}
		
		
		/**
		 * 引数で与えられたFunctionオブジェクトをCameraのアクティブリスナーとして
		 * 登録します。
		 * @param listener
		 * @return 
		 * 
		 */
		public function addActivityEventListener(listener:Function):Boolean
		{
			if(camera != null){
				camera.addEventListener( ActivityEvent.ACTIVITY , listener );
				return true;
			}else{
				return false;
			}
		}
		

	}
}