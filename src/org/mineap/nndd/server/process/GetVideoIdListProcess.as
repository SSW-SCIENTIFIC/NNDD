package org.mineap.nndd.server.process
{
	import com.tilfin.airthttpd.server.HttpResponse;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.server.IRequestProcess;
	import org.mineap.nndd.util.LibraryUtil;
	import org.mineap.nndd.util.PathMaker;
	
	/**
	 * 動画の一覧取得APIが呼ばれたときの処理
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class GetVideoIdListProcess implements IRequestProcess
	{
		public function GetVideoIdListProcess()
		{
		}
		
		public function process(requestXml:XML, httpResponse:HttpResponse):void
		{
			var libraryManager:ILibraryManager = LibraryManagerBuilder.instance.libraryManager;
			
			var videoList:Vector.<NNDDVideo> = libraryManager.getNNDDVideoArray(libraryManager.libraryDir, true);
			
			var nnddResponse:XML = <nnddResponse />;
			
			for each(var nnddVideo:NNDDVideo in videoList)
			{
				
				var videoId:String = null;
				
				videoId = PathMaker.getVideoID(nnddVideo.getVideoNameWithVideoID());
				
				if (videoId == null) 
				{
					continue;
				}
				
				var videoXML:XML = <video />;
				videoXML.@id = videoId;
				videoXML.@isEconomy = nnddVideo.isEconomy;
				videoXML.appendChild(nnddVideo.videoName);
				
				nnddResponse.appendChild(videoXML);
				
			}
			
			httpResponse.body = nnddResponse.toXMLString();
			httpResponse.statusCode = 200;
			
			LogManager.instance.addLog("動画リスト取得要求:list.len=" + videoList.length + ", resCode=" + httpResponse.statusCode);
		}
	}
}