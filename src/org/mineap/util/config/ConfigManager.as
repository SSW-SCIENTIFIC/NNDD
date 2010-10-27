package org.mineap.util.config
{
	/**
	 * 設定情報を管理するクラスです
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class ConfigManager
	{
		
		/**
		 * 唯一の ConfigManager インスタンス
		 */
		private static const _configManager:ConfigManager = new ConfigManager();
		
		/**
		 * 設定のIOを担当する ConfigIO のインスタンス
		 */
		private var _configIO:ConfigIO;
		
		/**
		 * 値をキーに結びつけてマッピングして保持するオブジェクト
		 */
		private var _map:Object = new Object();
		
		/**
		 * 唯一の ConfigManager を返します。
		 * @return 
		 * 
		 */
		public static function getInstance():ConfigManager{
			return _configManager;
		}
		
		/**
		 * コンストラクタ
		 * このクラスはシングルトンです。 ConfigManager#getInstance() を使ってインスタンスを取得してください。
		 */
		public function ConfigManager()
		{
			this._configIO = ConfigIO.getInstance();
			this.reload();
		}
		
		/**
		 * 設定を保存します
		 * 
		 */
		public function save():void{
			
			for(var key:String in this._map){
				var value:String = this._map[key];
				if(value != null){
					this._configIO.setValue(key, value);
				}
			}
			
			this._configIO.save();
			
			this.reload();
			
		}
		
		/**
		 * ConfigManagerが保持する設定をリセットし、再度読み込みます。
		 * 設定ファイルが存在しないときは false を返します。
		 * 
		 * @return 
		 */
		public function reload():Boolean{
			
			this._map = new Object();
			
			if(this._configIO.load()){
				
				var names:Vector.<String> = this._configIO.getNames();
				
				for each(var name:String in names){
					this._map[name] = this._configIO.getByName(name);
				}
				
				return true;
				
			}else{
				return false;
			}
		}
		
		/**
		 * 
		 * @param name
		 * @param value
		 * 
		 */
		public function setItem(name:String, value:Object):void{
			if(value == null){
				return;
			}
			
			if(value is String){
				this._map[name] = value;
			}else{
				this._map[name] = value.toString();
			}
		
		}
		
		/**
		 * 
		 * @param name
		 * @return 
		 * 
		 */
		public function getItem(name:String):String{
			
			var value:String = this._map[name];
			
			return value;
			
		}
		
		/**
		 * 
		 * @param name
		 * 
		 */
		public function removeItem(name:String):void{
			
			delete this._map[name];
			
		}
		
		/**
		 * 設定情報が空かどうかを調べます。
		 * @return 設定情報が空の時true、そうでない時falseを返す。
		 * 
		 */
		public function isEmpty():Boolean{
			if(this._configIO.getNames().length == 0){
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get confFileNativePath():String{
			return this._configIO.confFileNativePath;
		}
		
	}
}