package org.mineap.nInterpreter.operation.getMarker
{
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.ResultType;

	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class GetMarkerResult implements IAnalyzeResult
	{
		
		/**
		 * マーカの名前
		 */
		public var name:String;
		
		public function GetMarkerResult()
		{
		}
		
		public function get resultType():ResultType
		{
			return ResultType.GET_MARKER;
		}
		
	}
}