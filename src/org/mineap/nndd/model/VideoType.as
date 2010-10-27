package org.mineap.nndd.model
{
	/**
	 * 
	 * 動画の拡張子を保持するクラスです。<br>
	 * 
	 * @author shiraminekeisuke (MineAP)
	 * 
	 */
	public class VideoType
	{
		
		public static const SWF_S:String = "swf";
		public static const SWF_L:String = "SWF";
		public static const FLV_S:String = "flv";
		public static const FLV_L:String = "FLV";
		public static const MP4_S:String = "mp4";
		public static const MP4_L:String = "MP4";
		public static const HTML_S:String = "html";
		public static const HTML_L:String = "HTML";
		public static const XML_S:String = "xml";
		public static const XML_L:String = "XML";
		public static const JPEG_S:String = "jpeg";
		public static const JPEG_L:String = "JPEG";
		
		/**
		 * ニコ割かどうか
		 */
		public static const NICOWARI:String = "[Nicowari]";
		
		public function VideoType()
		{
		}
	}
}