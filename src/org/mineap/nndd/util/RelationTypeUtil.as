package org.mineap.nndd.util
{
	import org.mineap.nicovideo4as.model.RelationOrderType;
	import org.mineap.nicovideo4as.model.RelationSortType;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class RelationTypeUtil
	{
		public function RelationTypeUtil()
		{
		}
		
		public static function convertRelationSortType(index:int):String{
			switch(index){
				case 0:
					return RelationSortType.POPULAR;
				case 1:
					return RelationSortType.RESPONSE_COUNT;
				case 2:
					return RelationSortType.VIEW_COUNT;
				case 3:
					return RelationSortType.F;
				default:
					return RelationSortType.POPULAR;
			}
		}
		
		public static function convertRelationOrderType(index:int):String{
			switch(index){
				case 0:
					return RelationOrderType.DESCENDING;
				case 1:
					return RelationOrderType.ASCENDING;
				default:
					return RelationOrderType.DESCENDING;
			}
		}
	}
}