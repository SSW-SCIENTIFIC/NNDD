package org.mineap.nndd.util
{
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	
	import org.mineap.util.config.ConfigManager;

	public class DataGridColumnWidthUtil
	{
		public function DataGridColumnWidthUtil()
		{
		}
		
		/**
		 * 指定されたDataGridが持つDataGridColumnの横幅(width)を設定ファイルから読み込んで設定します。
		 * @param dataGrid
		 * 
		 */
		public static function loadAndSet(dataGrid:DataGrid, ignoreColumnNameList:Vector.<String>):void
		{
			var id:String = dataGrid.id;
			if (id == null)
			{
				id = "";
			}
			
			var columns:Array = dataGrid.columns;
			
			for each(var dataGridColumn:DataGridColumn in columns)
			{
				if (dataGridColumn.visible)
				{
					var fieldName:String = dataGridColumn.dataField;
					if (fieldName == null)
					{
						fieldName = "";
					}
					
					if (ignoreColumnNameList.indexOf(fieldName) > -1)
					{
						// 対象外なら次へ
						continue;
					}
					
					var confValueName:String = id + "_" + fieldName + "_width";
					
					var value:String = ConfigManager.getInstance().getItem(confValueName);
					
					if (value != null)
					{
						dataGridColumn.width = int(value);
//						trace(confValueName + ":" + value + "(," + dataGridColumn.width + ")");
					}
				}
			}
			
			for each(var dataGridColumn2:DataGridColumn in dataGrid.columns) {
				var fieldName2:String = dataGridColumn2.dataField;
//				trace(id + "_" + fieldName2 + "_width" + "(current):" + dataGridColumn2.width);
			}
			
			
		}
		
		/**
		 * 指定されたDataGridが持つDataGridColumnの横幅(width)を設定ファイルに保存します。
		 * @param dataGrid
		 * 
		 */
		public static function save(dataGrid:DataGrid, ignoreColumnNameList:Vector.<String>):void
		{
			
			var id:String = dataGrid.id;
			if (id == null)
			{
				id = "";
			}
			
			for each(var dataGridColumn:DataGridColumn in dataGrid.columns)
			{
				if (dataGridColumn.visible)
				{
					var fieldName:String = dataGridColumn.dataField;
					if (fieldName == null)
					{
						fieldName = "";
					}
					
					if (ignoreColumnNameList.indexOf(fieldName) > -1)
					{
						// 対象外なら次へ
						continue;
					}
					
					var width:int = dataGridColumn.width;
					
					var confValueName:String = id + "_" + fieldName + "_width";
					
//					trace(confValueName + ":" + width);
					
					ConfigManager.getInstance().setItem(confValueName, int(dataGridColumn.width));
				}
			}
			
		}
		
	}
}