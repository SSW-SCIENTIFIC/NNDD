package org.mineap.util.config
{
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	/**
	 * 設定ファイルのI/Oを担当します。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class ConfigIO
	{
		
		/**
		 * 設定ファイル
		 */
		private var _confFile:File = File.applicationStorageDirectory.resolvePath("config.xml");
		
		/**
		 * 設定ファイルの中身
		 */
		private var _confXML:XML = <config/>;
		
		/**
		 * 唯一の ConfigUtil オブジェクト
		 */
		private static const _configUtil:ConfigIO = new ConfigIO();
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function getInstance():ConfigIO{
			return _configUtil;
		}
		
		public function ConfigIO()
		{
		}
		
		/**
		 * 設定ファイルに name をキーとして value を書き込みます。
		 * nameに対応する値が既に設定されている場合は、valueで上書きします。
		 * 存在しない場合は name と value のペアを新たに追加します。
		 * 
		 * @param name
		 * @param value
		 * 
		 */
		public function setValue(name:String, value:String):void{
			
			var item:String = new String("<" + name + ">" + value + "</" + name + ">");
			
			var xmlList:XMLList = this._confXML.child(name);
			if(xmlList != null && xmlList.length() > 0){
				if(xmlList[0] != null && xmlList[0] != undefined){
					this._confXML.replace(name, XML(item));
					return;
				}
			}
			
			this._confXML.appendChild(XML(item));
		}
		
		/**
		 * 設定ファイルから name に対応する値を探し、返します。
		 * nameに対応する値が存在しない場合はnullを返します。
		 * 
		 * @param name
		 * @return 
		 * 
		 */
		public function getByName(name:String):String{
			var xmlList:XMLList = _confXML.child(name);
			
			if(xmlList != null && xmlList.length() > 0){
				if(xmlList[0] != null && xmlList[0] != undefined){
					return String(xmlList[0]);
				}
			}
			
			return null;
		}
		
		/**
		 * 設定ファイル内の要素名の一覧を返します。
		 * @return 
		 * 
		 */
		public function getNames():Vector.<String>{
			var keys:Vector.<String> = new Vector.<String>();
			
			var xmlList:XMLList = _confXML.children();
			
			if(xmlList != null && xmlList.length() > 0){
				var index:int = 0;
				for each(var xml:XML in xmlList){
					keys[index] = xml.name();
					index++;
				}
			}
			
			return keys;
		}
		
		/**
		 * 設定ファイルを読み込みます。
		 * 
		 * @return 
		 */
		public function load():Boolean{
			
			trace("load");
			
			XML.ignoreWhitespace = true;
			
			var fileStream:FileStream = new FileStream();
			fileStream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			
			if(this._confFile.exists){
				
				try{
				
					fileStream.open(this._confFile, FileMode.READ);
					var string:String = fileStream.readUTFBytes(_confFile.size);
					try{
						_confXML = new XML(string);
					}catch(error:Error){
						trace(error.getStackTrace());
						_confXML = <config/>;
					}
					
					fileStream.close();
					fileStream.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					
					return true;
				
				}catch(error:Error){
					trace(error.getStackTrace());
					return false;
				}
				
			}
			
			return false;
			
		}
		
		/**
		 * 設定ファイルを保存します。
		 * 
		 */
		public function save():void{
			
			var fileStream:FileStream = new FileStream();
			fileStream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			
			try{
				if(_confFile.exists){
					var newFile:File = new File(_confFile.nativePath + ".back");
					_confFile.copyTo(newFile, true);
					_confFile.deleteFile();
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			
			fileStream.open(_confFile, FileMode.WRITE);
			fileStream.writeUTFBytes(_confXML);
			fileStream.close();
			fileStream.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		public function errorHandler(event:ErrorEvent):void{
			trace(event);
			(event.currentTarget as FileStream).removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			try{
				(event.currentTarget as FileStream).close();
			}catch(error:Error){
				trace(error.getStackTrace());
			}
		}
	
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get confFileNativePath():String{
			if(this._confFile != null){
				return this._confFile.nativePath;
			}else{
				return "not found.";
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get confFile():File{
			if(this._confFile != null){
				return new File(this._confFile.url);
			}else{
				return null;
			}
		}
		
	}
}