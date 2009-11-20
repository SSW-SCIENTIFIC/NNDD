package org.mineap.nInterpreter
{
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
		
	}
}