package org.mineap.nInterpreter.operation.comment.color
{
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.ScriptLine;
	import org.mineap.nInterpreter.instance.CommentDefaultOptionManager;
	import org.mineap.nInterpreter.operation.IOperationAnalyzer;

	public class CommentColorOperationAnalyzer implements IOperationAnalyzer
	{
		
		/**
		 * 
		 */
		public static const COMMENT_COLOR_OPERATION_PATTERN:RegExp = new RegExp("commentColor=(0x[A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])");
		
		/**
		 * 
		 * 
		 */
		public function CommentColorOperationAnalyzer()
		{
		}
		
		/**
		 * 渡された文字列を解析します。
		 * この実装は結果を返さず、CommentDefaultOptionManagerに値を設定します。
		 * 
		 * @param source
		 * @return 
		 * 
		 */
		public function analyze(source:ScriptLine):IAnalyzeResult
		{
			
			//commentColor=0xff0000
			
			//デフォルト値は 0xffffff
			
			var line:String = source.line;
			
			var resultArray:Array = null;
			resultArray = COMMENT_COLOR_OPERATION_PATTERN.exec(line);
			
			if (resultArray != null && resultArray.length > 0)
			{
				
				var color:int = int(resultArray[1]);
				
				CommentDefaultOptionManager.instance.commentColor = color;
			}
			
			return null;
		}
		
	}
}