package org.mineap.nInterpreter.nico2niwa.operation.jumpmarker
{
	public class JumpMarker
	{
		private var _marker:String = null;
		
		private var _vpos:Number = 0;
		
		public function JumpMarker(marker:String, vpos:Number)
		{
			this._marker = marker;
			this._vpos = vpos;
		}

		public function get marker():String
		{
			return _marker;
		}

		public function get vpos():Number
		{
			return _vpos;
		}


	}
}