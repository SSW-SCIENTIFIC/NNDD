package org.mineap.a2n4as.util
{
	/**
	 * getThreadKeyにアクセスした際の応答を解析します。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class GetThreadKeyResultAnalyzer
	{
		
		private var _keys:Vector.<String> = new Vector.<String>();
		
		private var _map:Object = new Object();
		
		public function GetThreadKeyResultAnalyzer()
		{
		}
		
		/**
		 * 渡された文字列をgetThreadkeyの戻り値であると仮定して解析します。
		 * 
		 * @param result
		 * @return 
		 * 
		 */
		public function analyze(result:String):Boolean{
			try{
				
				// "&"　で分割する
				for each(var results:String in decodeURIComponent(result).split("&")){
					// "=" で分割する
					var words:Array = results.split("=");
					
					this._keys.push(words[0]);
					this._map[words[0]] = words[1];
				}
				
				return true;
			
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			return false;
			
		}

		/**
		 * キーの一覧を返します。
		 * @return 
		 * 
		 */
		public function getKeys():Vector.<String>{
			return this._keys;
		}

		/**
		 * keyに対応する値を返します。存在しない場合はnullを返します。
		 * @param key
		 * @return 
		 * 
		 */
		public function getValue(key:String):String{
			return this._map[key];
		}
		
	}
}