package org.mineap.nInterpreter
{
	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class ResultType
	{
		public function ResultType()
		{
		}
		
		/**
		 * jump命令の解析結果である事を示す定数です。
		 */
		public static const JUMP:ResultType = new ResultType();
		
		/**
		 * seek命令の解析結果である事を示す定数です。
		 */
		public static const SEEK:ResultType = new ResultType();
		
		/**
		 * addMarker命令の解析結果である事を示す定数です。
		 */
		public static const ADD_MARKER:ResultType = new ResultType();
		
		/**
		 * getMarker命令の解析結果である事を示す定数です。
		 */
		public static const GET_MARKER:ResultType = new ResultType();
		
	}
}