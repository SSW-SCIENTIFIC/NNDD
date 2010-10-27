package org.mineap.nndd.util
{
	public class CategoryUtil
	{
		public function CategoryUtil()
		{
		}
		
		/**
		 * カテゴリリストを返します。
		 * 
		 * @return 
		 * 
		 */
		public static function getCategoryList():Array{
			
			var catList:Array = new Array();
			
			catList.push(new Array("カテゴリ合算","all"));
			
			catList.push(new Array("エンタ・音楽・スポ","g_ent"));
			catList.push(new Array("  エンターテイメント","ent"));
			catList.push(new Array("  音楽","music"));
			catList.push(new Array("  スポーツ","sport"));
			
			catList.push(new Array("教養・生活","g_life"));
			catList.push(new Array("  動物","animal"));
			catList.push(new Array("  ファッション","fashion"));
			catList.push(new Array("  料理","cooking"));
			catList.push(new Array("  日記","diary"));
			catList.push(new Array("  自然","nature"));
			catList.push(new Array("  科学","science"));
			catList.push(new Array("  歴史","history"));
			catList.push(new Array("  ラジオ","radio"));
			catList.push(new Array("  ニコニコ動画講座","lecture"));
			
			catList.push(new Array("政治","g_politics"));
			
			catList.push(new Array("やってみた","g_try"));
			catList.push(new Array("  歌ってみた","sing"));
			catList.push(new Array("  演奏してみた","play"));
			catList.push(new Array("  踊ってみた","dance"));
			catList.push(new Array("  描いてみた","draw"));
			catList.push(new Array("  ニコニコ技術部","tech"));
			
			catList.push(new Array("アニメ・ゲーム","g_culture"));
			catList.push(new Array("  アニメ","anime"));
			catList.push(new Array("  ゲーム","game"));
			
			catList.push(new Array("アイマス・東方・ボカロ","g_popular"));
			catList.push(new Array("  アイドルマスター","imas"));
			catList.push(new Array("  東方","toho"));
			catList.push(new Array("  VOCALOID","vocaloid"));
			catList.push(new Array("  その他","other"));
			
			return catList;
		}
		
	}
}