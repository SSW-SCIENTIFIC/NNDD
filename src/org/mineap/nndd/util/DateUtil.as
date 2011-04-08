package org.mineap.nndd.util
{
	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class DateUtil
	{
		
		import mx.formatters.DateFormatter;
		
		public function DateUtil()
		{
		}
		
		/**
		 * 日本で一般的な日付の文字列表現を返します。
		 * 
		 * @param date
		 * @return yyyy/mm/dd hh:mm:ss
		 * 
		 */
		public static function getDateString(date:Date):String{
			
			if(date == null){
				date = new Date();
			}
			
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "YYYY/MM/DD JJ:NN:SS";
			
			var dateString:String = dateFormatter.format(date);
			
			return dateString;
			
		}
		
		/**
		 * 日本で一般的な日付の文字列表現を返します。<br />
		 * このメソッドはファイル名につかう文字列表現用です。("/" および ":" を使わないようにしています。)
		 * 
		 * @param date
		 * @return yyyy-mm-dd hh-mm-ss
		 * 
		 */
		public static function getDateStringForFileName(date:Date):String{
			
			if(date == null){
				date = new Date();
			}
			
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "YYYY-MM-DD JJ-NN-SS";
			
			var dateString:String = dateFormatter.format(date);
			
			return dateString;
			
		}
		
		/**
		 * 
		 * @param dateString 2010/11/12 12:36:12
		 * @return 
		 * 
		 */
		public static function getDate(dateString:String):Date{
			var pattern:RegExp = new RegExp("(\\d\\d\\d\\d)/(\\d\\d)/(\\d\\d) (\\d\\d):(\\d\\d):(\\d\\d)");
			
			var newDate:Date = new Date();
			
			try{
				
				var array:Array = dateString.match(pattern);
				
				var year:String = array[1];
				var month:String = array[2];
				var date:String = array[3];
				var h:String = array[4];
				var m:String = array[5];
				var s:String = array[6];
				
				newDate = new Date(year, Number(month) - 1, date, h, m, s);
				
			}catch(e:Error){
				trace(e + "\n" + e.getStackTrace());
			}
			
			return newDate;
			
		}
		
		/**
		 * 
		 * @param dateString 2007-12-11T00:48:55+09:00
		 * @return 
		 * 
		 */
		public static function getDateForThumbXML(dateString:String):Date{
			var pattern:RegExp = new RegExp("(\\d\\d\\d\\d)-(\\d\\d)-(\\d\\d)T(\\d\\d):(\\d\\d):(\\d\\d)+.*");
			
			var newDate:Date = null;
			
			try{
				
				var array:Array = dateString.match(pattern);
				
				var year:String = array[1];
				var month:String = array[2];
				var date:String = array[3];
				var h:String = array[4];
				var m:String = array[5];
				var s:String = array[6];
				
				newDate = new Date(year, Number(month) - 1, date, h, m, s);
				
			}catch(e:Error){
				trace(e + "\n" + e.getStackTrace());
			}
			
			return newDate;
		}
		
		/**
		 * "5:03"のような形式の文字列から秒数を計算し、Numberで返します。
		 * @param lengthString 5:03
		 * @return 
		 * 
		 */
		public static function getTimeForThumbXML(lengthString:String):Number
		{
			var len:Number = 0;
			
//			var pattern:RegExp = new RegExp("(\\d+):(\\d\\d)");
			
			try{
//				var array:Array = lengthString.match(pattern);
				
				var index:int = lengthString.indexOf(":");
				if(index == -1){
					return len;
				}
				
				// 分
				var mStr:String = lengthString.substr(0,index);
				if(mStr.length < 1){
					mStr = "0";
				}
				// 秒
				var sStr:String = lengthString.substr(index+1);
				if(sStr.length < 1){
					sStr = "0";
				}
				var m:int = int(mStr) * 60;
				var s:int = int(sStr);
				
				len = m + s;
				
			}catch(e:Error){
				trace(e.getStackTrace());
			}
			
			return len;
		}
		
	}
}