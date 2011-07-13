package org.mineap.nInterpreter.operation.addMarker
{
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.ResultType;
	
	/**
	 * addMarker命令の解析結果を格納するクラスです
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class AddMarkerResult implements IAnalyzeResult
	{
		/**
		 * マーカの名前
		 */
		public var name:String;
		
		/**
		 * マーカに指定された時刻(vpos)
		 */
		public var vpos:Number;
		
		/**
		 * 
		 * 
		 */
		public function AddMarkerResult()
		{
			// addMaker(name:名前,vpos:マーカー時刻)
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get resultType():ResultType
		{
			return ResultType.ADD_MARKER;
		}

	}
}