package org.mineap.a2n4as
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * 市場情報を取得するクラスです。
	 * 取得結果は、addEventListener()で登録したリスナから取得します。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class IchibaInfoLoader
	{
		
		private var _ichibaLoader:URLLoader;
		
		public function IchibaInfoLoader()
		{
			this._ichibaLoader = new URLLoader();
			
		}
		
		/**
		 * 市場情報を取得します。
		 * 
		 * @param videoId
		 * 
		 */
		public function getIchibaInfo(videoId:String):void{
			
			//市場情報サーバーの負荷分散
			var balance:int = (Math.random()*100)%5;
			if(balance == 0){
				balance++;
			}
			var url:String = "http://ichiba" +balance+ ".nicovideo.jp/embed/?action=showMain&v="+ videoId +"&rev=20090122";
			this._ichibaLoader.load(new URLRequest(url));
			
		}
		
		/**
		 * 市場情報取得用のURLLoaderにリスナを追加します。
		 * 
		 * @param event
		 * @param listener
		 * 
		 */
		public function addEventListener(event:String, listener:Function):void{
			this._ichibaLoader.addEventListener(event, listener);
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._ichibaLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._ichibaLoader = null;
		}

	}
}