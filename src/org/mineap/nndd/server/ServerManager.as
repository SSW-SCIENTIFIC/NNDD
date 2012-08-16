package org.mineap.nndd.server
{
	import com.tilfin.airthttpd.server.HttpConnection;
	import com.tilfin.airthttpd.server.HttpListener;
	
	import flash.errors.IllegalOperationError;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.model.RssType;
	import org.mineap.nndd.myList.MyListManager;
	import org.mineap.nndd.util.MyListUtil;

	/**
	 * NNDDのサーバ機能を管理するクラスです
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class ServerManager
	{
		
		private static const manager:ServerManager = new ServerManager();
		

		private var httpListener:HttpListener = null;
		
		
		/**
		 * 唯一の ServerManager のインスタンスを変えす。
		 * @return 
		 * 
		 */
		public static function get instance():ServerManager
		{
			return manager;
		}
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function ServerManager()
		{
			if (manager != null)
			{
				throw new IllegalOperationError("ServerManagerはインスタンスを生成できません。");
			}
		}
		
		/**
		 * 指定されたポート番号で通信の待ち受けを開始します。
		 * 
		 * @param localPort
		 * 
		 */
		public function startServer(localPort:int):Boolean
		{
			
			stopServer();
			
			try
			{
			
				httpListener = new HttpListener(httpLogCallbackFunction);
				
				httpListener.service = new NNDDHttpService();
				httpListener.listen(localPort);
				
				LogManager.instance.addLog("他のNNDDからの通信待ち受けを開始しました:localPort=" + localPort);
			
				return true;
				
			}
			catch(error:Error)
			{
				LogManager.instance.addLog("他のNNDDからの通信待ち受けの開始に失敗:localPort=" + localPort + ", [" + error + "]");
				trace(error.getStackTrace());
			}
			
			return false;
		}
		
		/**
		 * 
		 * @param msg
		 * @return 
		 * 
		 */
		protected function httpLogCallbackFunction(msg:String):void
		{
			trace(msg);
		}
		
		/**
		 * 通信の待ち受けを終了します。
		 * 
		 */
		public function stopServer():void
		{
			if (httpListener != null)
			{
				// 既にServerSocketが動いていたら一度閉じる
				try 
				{
					httpListener.shutdown();
				}
				catch (error:Error)
				{
					trace(error.getStackTrace());
				}
				
				httpListener = null;
				
			}
			
			LogManager.instance.addLog("他のNNDDからの通信待ち受けを停止");
			
		}
		
	}
}