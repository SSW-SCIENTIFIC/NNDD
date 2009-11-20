package org.mineap.a2n4as
{
	
	public class RankingPatterns
	{
		
		private var _pattern_thumbImg:RegExp;
		private var _pattern_video:RegExp;
		
		public function RankingPatterns(pattern_video:RegExp, pattern_thumbImg:RegExp)
		{
			this._pattern_thumbImg = pattern_thumbImg;
			this._pattern_video = pattern_video;
		}
		
		public function get pattern_thumbImg():RegExp{
			return this._pattern_thumbImg;
		}
		
		public function get pattern_video():RegExp{
			return this._pattern_video;
		}

	}
}