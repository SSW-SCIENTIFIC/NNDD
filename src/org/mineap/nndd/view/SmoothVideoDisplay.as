package org.mineap.nndd.view
{
	import mx.controls.VideoDisplay;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	/**
	 * Smoothingが適応可能なVideoDisplayです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class SmoothVideoDisplay extends VideoDisplay
	{
		
		private var _smoothing:Boolean = false;
		
		public function SmoothVideoDisplay()
		{
			super();
		}
		
		[Bindable]
		public function set smoothing(val:Boolean):void{
			if (val == _smoothing) return;
			_smoothing = val;
			videoPlayer.smoothing = _smoothing;
		}
		
		public function get smoothing():Boolean{
			return _smoothing;
		}
		
	}
}