package org.mineap.nInterpreter.nico2niwa.operation.jumpmarker
{
	import org.mineap.nInterpreter.ScriptLine;
	import org.mineap.nInterpreter.nico2niwa.operation.Nico2NiwaConverter;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class JumpMarkerConverter implements Nico2NiwaConverter
	{
		public function JumpMarkerConverter()
		{
		}
		
		/**
		 * 次のニコスクリプトを解析する正規表現です。
		 * "＠ジャンプマーカー；ループ"
		 * このジャンプマーカが実行された時刻が、マーカ"ループ"として登録されます。
		 */
		public static const JUMP_MARKER_OPERATION_PATTERN1:RegExp = new RegExp("ジャンプマーカー[：|:]([\\S]+)");
		
		/**
		 * 
		 * @param source
		 * @return 
		 * 
		 */
		public function convert(source:ScriptLine):ScriptLine
		{
			var line:String = source.line;
			var operation:String = "";
			
			var array:Array = null;
			array = JUMP_MARKER_OPERATION_PATTERN1.exec(line);
			
			if (array != null && array.length > 0)
			{
				var marker:String = array[1];
				
				if (marker != null)
				{
					operation = "addMarker(name:'" + marker + "',vpos:'" + source.vpos + "')";
				}
				
			}
			
			return new ScriptLine(operation, source.vpos);
		}
		
	}
}