package org.mineap.nndd.player
{
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.util.PathMaker;

	/**
	 * Playerの視聴履歴を管理します。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class PlayerHistoryManager
	{
		
		/**
		 * 
		 */
		private var history:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
		
		/**
		 * 
		 * 
		 */
		public function PlayerHistoryManager()
		{
		}
		
		/**
		 * 動画を追加します。
		 * @param url
		 * 
		 */
		public function addVideoUrl(url:String):void{
			if(url != null){
				remove(PathMaker.getVideoID(url));
				history.push(new NNDDVideo(url));
				while(history.length > 100){
					history.shift();
				}
			}
		}
		
		/**
		 * 動画を追加します。
		 * @param video
		 * 
		 */
		public function addVideo(video:NNDDVideo):void{
			if(video != null){
				remove(PathMaker.getVideoID(video.getDecodeUrl()));
				history.push(video);
				while(history.length > 100){
					history.shift();
				}
			}
		}
		
		/**
		 * 指定された動画IDを持つ動画をヒストリーから削除します
		 * @param videoID
		 * 
		 */
		public function remove(videoID:String):void{
			for(var index:int = 0; history.length > index; index++){
				if(PathMaker.getVideoID(history[index].getDecodeUrl()) == videoID){
					history.splice(index, 1);
					return;
				}
			}
			return;
		}
		
		/**
		 * 先頭に追加されている動画を削除し、一つ前の動画を返します。
		 * @return 
		 * 
		 */
		public function back():NNDDVideo{
			// 最後に追加した(=再生中の)項目を削除
			if(history.length > 1){
				history.splice(history.length-1, 1);
			}
			
			// 新しい再生項目
			if(history.length > 0){
				return history[history.length-1];
			}else{
				return null;
			}
		}
		
	}
}