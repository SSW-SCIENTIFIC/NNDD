package org.mineap.nInterpreter.operation
{
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.ScriptLine;

	public interface IOperationAnalyzer
	{
		
		function analyze(source:ScriptLine):IAnalyzeResult;
		
	}
}