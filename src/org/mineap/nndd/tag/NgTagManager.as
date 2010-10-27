package org.mineap.nndd.tag
{
	import flash.filesystem.File;
	
	import mx.controls.TileList;
	
	import org.mineap.nndd.FileIO;
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	
	/**
	 * タグフィルタを管理するクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class NgTagManager
	{
		
		private var _ngTagProvider:Array;
		private var _ngTagMap:Object = new Object();
		private var _tempNgTagArray:Array;
		private var _libraryManager:ILibraryManager;
		private var _logManager:LogManager = LogManager.instance;
		
		private static const _ngTagManager:NgTagManager = new NgTagManager();
		
		/**
		 * シングルトンパターン
		 */
		public function NgTagManager()
		{
			if(_ngTagManager != null){
				throw new ArgumentError("NgTagManagerはインスタンス化できません。");
			}
		}
		
		/**
		 * 唯一のNgTagManagerのインスタンスを返します。
		 * @return 
		 * 
		 */
		public static function get instance():NgTagManager{
			return _ngTagManager;
		}
		
		/**
		 * イニシャライザです。
		 * 
		 * @param dataProvider NgTagのリストを保持するdataProvider
		 * @return 
		 * 
		 */
		public function initialize(dataProvider:Array):void{
			this._libraryManager = LibraryManagerBuilder.instance.libraryManager;
			this._ngTagProvider = dataProvider;
		}
		
		/**
		 * タグをフィルタに追加します
		 * @param tag
		 * 
		 */
		private function addTag(tag:String):void{
			if(!isExist(tag)){
				this._ngTagProvider.push(tag);
			}
			this._ngTagMap[tag] = tag;
		}
		
		/**
		 * 
		 * @param tags
		 * 
		 */
		public function addTags(tags:Array):void{
			for each(var tag:String in tags){
				addTag(tag);
			}
			saveNgTags();
			this._ngTagProvider.sort();
		}
		
		/**
		 * タグをフィルタから取り除きます
		 * @param tag
		 * 
		 */
		private function removeTag(tag:String):void{
			delete this._ngTagMap[tag];
		}
		
		/**
		 * 
		 * @param tags
		 * 
		 */
		public function removeTags(tags:Array):void{
			for each(var tag:String in tags){
				removeTag(tag);
			}
			saveNgTags();
			tagRefresh();
		}
		
		/**
		 * タグがフィルタ対象かどうか調べます。
		 * @param tag
		 * @return 
		 * 
		 */
		public function isExist(tag:String):Boolean{
			if(this._ngTagMap[tag] != null){
				return true;
			}
			return false;
		}
		
		/**
		 * NgTagManagerが保持するMapをdataProviderに反映します。
		 * 
		 */
		private function tagRefresh():void{
			
			this._ngTagProvider.splice(0, this._ngTagProvider.length);
			
			for each(var tag:String in this._ngTagMap){
				
				this._ngTagMap[tag] = tag;
				this._ngTagProvider.push(tag);
			}
			
			this._ngTagProvider.sort();
		}
		
		/**
		 * 
		 * @param tileList
		 * 
		 */
		public function tagRenew(tileList:TileList):void{
			if(tileList != null){
				tileList.dataProvider = this._ngTagProvider;
			}
		}
		
		/**
		 * NGタグ情報を読み込みます。
		 * 
		 */
		public function loadNgTags():void{
			
			try{
				
				var file:File = this.ngTagsFile;
				
				if(!file.exists){
					return;
				}
				
				var fileIO:FileIO = new FileIO(_logManager);
				var xml:XML = fileIO.loadXMLSync(decodeURIComponent(file.url), false);
				
				var xmlList:XMLList = xml.child("tag");
				
				for each(var tagXML:XML in xmlList){
					
					var tag:String = decodeURIComponent(tagXML.text().toString());
					
					this._ngTagMap[tag] = tag;
					this._ngTagProvider.push(tag);
					
				}
				
				this._ngTagProvider.sort();
				
			}catch(error:Error){
				_logManager.addLog("NGタグ読み込みに失敗:" + error);
				trace(error.getStackTrace());
			}
			
		}
		
		
		/**
		 * NgTagManagerが保持するNGタグ情報をxmlに書き出します。
		 * 
		 */
		public function saveNgTags():void{
			
			try{
				
				var file:File = this.ngTagsFile;
				
				var xml:XML = new XML("<ngTags />");
				for each(var tag:String in this._ngTagProvider){
					var tagXML:XML = new XML("<tag />");
					tagXML.appendChild(encodeURIComponent(tag));
					xml.appendChild(tagXML);
				}
				
				var fileIO:FileIO = new FileIO(this._logManager);
				fileIO.saveXMLSync(file, xml);
				
			}catch(error:Error){
				this._logManager.addLog("NGタグ保存に失敗:" + error);
				trace(error.getStackTrace());
			}
			
		}
		
		
		/**
		 * NgTag情報を保存したxmlファイルの場所を返します。
		 * @return 
		 * 
		 */
		public function get ngTagsFile():File{
			var file:File = this._libraryManager.systemFileDir;
			return new File(file.url + "/ngTags.xml");
		}
		
	}
}