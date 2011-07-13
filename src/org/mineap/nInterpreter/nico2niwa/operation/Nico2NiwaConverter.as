package org.mineap.nInterpreter.nico2niwa.operation
{
	import org.mineap.nInterpreter.ScriptLine;

	public interface Nico2NiwaConverter
	{
		function convert(source:ScriptLine):ScriptLine;
	}
}