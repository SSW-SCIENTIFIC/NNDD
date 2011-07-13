package org.mineap.nInterpreter.instance
{
	import org.mineap.nInterpreter.nico2niwa.operation.jumpmarker.JumpMarker;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class JumpMarkerManager
	{
		
		private static const manager:JumpMarkerManager = new JumpMarkerManager();
		
		private var markerName_vpos_map:Object = new Object();
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():JumpMarkerManager
		{
			return manager;
		}
		
		public function JumpMarkerManager()
		{
			if (manager != null)
			{
				throw new ArgumentError("JumpMarkerMangerはインスタンス化できません");
			}
		}
		
		/**
		 * 
		 * 
		 */
		public function initalize():void
		{
			this.markerName_vpos_map = new Object();
		}
		
		/**
		 * 指定されたマーカにvposを対応づけてマーカを記憶します。
		 * 
		 * @param marker
		 * @param vpos
		 * @return 
		 */
		public function addMarker(marker:String, vpos:int):Boolean
		{
			if (marker == null)
			{
				return false;
			}
			
			var jumpMarker:JumpMarker = new JumpMarker(marker, vpos);
			
			trace("マーカを追加:" + marker + ", " + vpos);
			this.markerName_vpos_map[marker] = jumpMarker;
			
			return true;
		}
		
		/**
		 * マーカに登録されているvposを取得します。vposが登録されていない時は-1を返します。
		 * 
		 * @param marker
		 * @return 
		 * 
		 */
		public function getMarker(marker:String):int
		{
			if (marker == null)
			{
				return -1;
			}
			
			var object:Object = this.markerName_vpos_map[marker];
			if (object == null)
			{
				return -1;
			}
			
			if (object is JumpMarker)
			{
				var vpos:int = (object as JumpMarker).vpos;
				trace("マーカを取得:" + marker + ", " + vpos);
				return vpos;
			}
			else
			{
				return -1;
			}
			
		}
		
		/**
		 * 登録済みのJumpMarkerの一覧を返します
		 * 
		 * @return 
		 * 
		 */
		public function get markers():Vector.<JumpMarker>
		{
			var jumpMarkers:Vector.<JumpMarker> = new Vector.<JumpMarker>();
			
			trace("マーカ一覧を取得");
			
			for each(var object:Object in this.markerName_vpos_map)
			{
				if (object is JumpMarker)
				{
					var name:String = (object as JumpMarker).marker;
					var vpos:int = (object as JumpMarker).vpos;
					trace("マーカ:" + name + ", " + vpos);
					jumpMarkers.push(object);
				}
			}
			
			return jumpMarkers;
			
		}
		
	}
}