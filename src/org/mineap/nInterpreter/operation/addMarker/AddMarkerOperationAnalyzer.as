package org.mineap.nInterpreter.operation.addMarker
{
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.ScriptLine;
	import org.mineap.nInterpreter.operation.IOperationAnalyzer;
	
	public class AddMarkerOperationAnalyzer implements IOperationAnalyzer
	{
		
		public static const ADD_MARKER_OPERATION_PATTERN_1:RegExp = new RegExp("addMarker\\(name:['\"]([^,]+)['\"],vpos:['\"]([^\\)]+)['\"]\\)");
		
		public function AddMarkerOperationAnalyzer()
		{
		}
		
		/**
		 * 
		 * @param source
		 * @return 
		 * 
		 */
		public function analyze(source:ScriptLine):IAnalyzeResult
		{
			
			//addMarker(name:名前,vpos:時刻)
			
			var result:AddMarkerResult = null;
			var resultArray:Array = null;
			var line:String = source.line;
			
			resultArray = ADD_MARKER_OPERATION_PATTERN_1.exec(line);
			if (resultArray != null && resultArray.length > 0)
			{
				result = new AddMarkerResult();
				result.name = String(resultArray[1]);
				result.vpos = Number(resultArray[2]);
			}
			
			return result;
		}
	}
}