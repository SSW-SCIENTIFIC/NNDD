package org.mineap.nInterpreter.operation.getMarker
{
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.ScriptLine;
	import org.mineap.nInterpreter.operation.IOperationAnalyzer;
	
	public class GetMarkerOperationAnalyzer implements IOperationAnalyzer
	{
		
		public static const GET_MARKER_OPERATION_PATTERN_1:RegExp = new RegExp("getMarker\\(name:['\"]([\\S]*)['\"]\\)");
		
		public function GetMarkerOperationAnalyzer()
		{
		}
		
		public function analyze(source:ScriptLine):IAnalyzeResult
		{
			
			//getMarker(name:名前)
			
			var result:GetMarkerResult = null;
			var resultArray:Array = null;
			var line:String = source.line;
			
			resultArray = GET_MARKER_OPERATION_PATTERN_1.exec(line);
			if (resultArray != null && resultArray.length > 0)
			{
				result = new GetMarkerResult();
				result.name = String(resultArray[1]);
			}
			
			return result;
		}
	}
}