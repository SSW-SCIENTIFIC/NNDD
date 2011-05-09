package org.mineap.util.font
{
	import flash.text.Font;
	
	import mx.core.FlexGlobals;
	
	/**
	 * アプリケーションで使用するフォントの一覧を管理するクラスです。
	 * @author shiraminekeisuke
	 * 
	 */
	public class FontUtil
	{
		/**
		 * 
		 * 
		 */
		public function FontUtil()
		{
		}
		
		/**
		 * アプリケーションで使用可能なフォントの一覧を返します。
		 * @return 使用可能なフォントの一覧
		 */
		public static function fontList():Vector.<Font>{
			var fonts:Vector.<Font> = new Vector.<Font>();
			
			var array:Array = Font.enumerateFonts(true);
			for each(var font:Font in array){
				fonts.push(font);
			}
			
			return fonts;
			
		}
		
		/**
		 * アプリケーションで使用するフォントを設定します。
		 * @param fontName 設定するフォントの名前
		 * @return 設定後、実際にアプリケーションに登録されたフォントの名前
		 */
		public static function setFont(fontName:String):String{
			if(fontName != null){
				FlexGlobals.topLevelApplication.setStyle("fontFamily", fontName);
				FlexGlobals.topLevelApplication.setPlayerFont(fontName);
			}
			return FlexGlobals.topLevelApplication.getStyle("fontFamily");
		}
		
		/**
		 * 
		 * @param fontSize
		 * @return 
		 * 
		 */
		public static function setSize(fontSize:int):String{
			FlexGlobals.topLevelApplication.setStyle("fontSize", fontSize);
			FlexGlobals.topLevelApplication.setPlayerFontSize(fontSize);
			return FlexGlobals.topLevelApplication.getStyle("fontSize");
		}
		
		/**
		 * 現在のアプリケーションに設定されているフォントの名前を返します。
		 * @return 
		 * 
		 */
		public static function get applicationFont():String{
			return FlexGlobals.topLevelApplication.getStyle("fontFamily");
		}
		
		/**
		 * 指定された文字列をFont.fontNameプロパティに持つFontを探して返します。
		 * 存在しない場合はnullを返します。
		 * @param fontName
		 * @return 
		 * 
		 */
		public static function getFontByName(fontName:String):Font{
			
			var vector:Vector.<Font> = FontUtil.fontList();
			for each(var font:Font in vector){
				if(font.fontName == fontName){
					return font;
				}
			}
			
			return null;
		}
		
	}
}