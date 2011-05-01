package org.mineap.nndd.nativeProcessPlayer
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import mx.controls.Alert;
	import mx.messaging.Producer;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.Message;
	import org.mineap.util.config.ConfigManager;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class NativeProcessPlayerManager
	{
		private static const manager:NativeProcessPlayerManager = new NativeProcessPlayerManager();
		
		
		private var _executeFile:File = null;
		
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():NativeProcessPlayerManager
		{
			return manager;
		}
		
		/**
		 * 
		 * 
		 */
		public function NativeProcessPlayerManager()
		{
			var filePath:String = ConfigManager.getInstance().getItem("executeFile");
			
			try{
				if(filePath != null){
					_executeFile = new File(filePath);
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			
		}
		
		/**
		 * 
		 * @param path
		 * 
		 */
		public function play(path:String):void{
			
			LogManager.instance.addLog("外部Playerで再生...");
			LogManager.instance.addLog("動画のパス:" + path);
			
			if(!NativeProcess.isSupported){
				LogManager.instance.addLog("このNNDDでは外部Playerがサポートされていません。");
				Alert.show("このNNDDでは外部Playerがサポートされていません。", Message.M_MESSAGE);
				return;
			}
			
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			
			if(executeFile == null){
				LogManager.instance.addLog("外部Playerが指定されていません。");
				Alert.show("外部Playerが指定されていません。", Message.M_MESSAGE);
				return;
			}
			
			if(!executeFile.exists){
				LogManager.instance.addLog("指定されたPlayerが存在しません。\n" + executeFile.nativePath);
				Alert.show("指定されたPlayerが存在しません。\n" + executeFile.nativePath, Message.M_MESSAGE);
				return;
			}

			LogManager.instance.addLog("Playerのパス:" + executeFile.nativePath);
			var args:Vector.<String> = new Vector.<String>;
			if(Capabilities.os.toLowerCase().indexOf("mac") > -1)
			{
				if ("app" == executeFile.extension)
				{
					// macで、appを指定されたときは open コマンドを使う
					nativeProcessStartupInfo.executable = new File("/usr/bin/open");
					
					args.push("-a");
					args.push(executeFile.nativePath);
					args.push(path);
					nativeProcessStartupInfo.arguments = args;
					
				}
				else
				{
					//macだけどappファイルじゃなくて実行ファイルを直接指定されたときはそのまま実行
					nativeProcessStartupInfo.executable = executeFile;
					
					args.push(path);
					nativeProcessStartupInfo.arguments = args;
				}
				
			}
			else
			{
				// win,linuxの時は実行ファイルをそのまま実行
				nativeProcessStartupInfo.executable = executeFile;
				
				args.push(path);
				nativeProcessStartupInfo.arguments = args;
					
			}
			
			var process:NativeProcess = new NativeProcess();
			
			process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, ioErrorEventHanlder);
			process.start(nativeProcessStartupInfo);
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		protected function ioErrorEventHanlder(event:IOErrorEvent):void{
			LogManager.instance.addLog("外部Playerの実行に失敗しました。\n" + event.text);
			Alert.show("外部Playerの実行に失敗しました。\n" + event.text, Message.M_ERROR);
		}
		
		/**
		 * 
		 * @param file
		 * 
		 */
		public function set executeFile(file:File):void{
			this._executeFile = file;
			ConfigManager.getInstance().setItem("executeFile", file.url);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get executeFile():File{
			return this._executeFile;
		}
		
	}
}