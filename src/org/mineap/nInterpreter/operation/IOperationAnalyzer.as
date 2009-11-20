package org.mineap.nInterpreter.operation
{
	import org.mineap.nInterpreter.IAnalyzeResult;

	public interface IOperationAnalyzer
	{
		
		function analyze(source:String):IAnalyzeResult;
		
	}
}