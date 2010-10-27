package org.mineap.nndd
{
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import mx.core.Application;

	public class SystemTrayIconManager
	{
		
		public function setTrayIcon():Boolean{
			
			var isSuccess:Boolean = false;
			
			// メニューの設定
//			var playMenuItem:NativeMenuItem = new NativeMenuItem("再生");
//			playMenuItem.addEventListener(Event.SELECT, onPlay);
			var mainWindowMenuItem:NativeMenuItem = new NativeMenuItem("メインウィンドウ");
			mainWindowMenuItem.addEventListener(Event.SELECT, onMainWindowOpen);
			var playerWindowMenuItem:NativeMenuItem = new NativeMenuItem("プレーヤー");
			playerWindowMenuItem.addEventListener(Event.SELECT, onPlayerWindowOpen);
			
			var nativeMenu:NativeMenu = new NativeMenu();
//			nativeMenu.addItem(playMenuItem);
			nativeMenu.addItem(mainWindowMenuItem);
			nativeMenu.addItem(playerWindowMenuItem);
			
			// Icon設定
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadSuccessHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, iconLoadFailHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, iconLoadFailHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.DISK_ERROR, iconLoadFailHandler);
			
			if(NativeApplication.supportsSystemTrayIcon){
				
				loader.load(new URLRequest("icon32.png"));	//Windows用は小さい方がきれいに見える？
				
				var separator:NativeMenuItem = new NativeMenuItem("", true);
				nativeMenu.addItem(separator);
				
				var exitMenuItem:NativeMenuItem = new NativeMenuItem("終了");
				exitMenuItem.addEventListener(Event.SELECT, onExitMenuItem);
				nativeMenu.addItem(exitMenuItem);
				
				var systemTrayIcon:SystemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
				systemTrayIcon.menu = nativeMenu;
				systemTrayIcon.tooltip = "NNDD";
				
				trace("SystemTrayIcon Supported");
				isSuccess = true;
				
			}else if(NativeApplication.supportsDockIcon){
				
				loader.load(new URLRequest("icon128.png"));	//Mac用はでかいのを使えば良いよ
				
				var dockIcon:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
				dockIcon.menu = nativeMenu;
				
				trace("DockIcon Supported");
				isSuccess = true;
			}
			
			trace("トレイアイコン設定:" + isSuccess);
			
			return isSuccess;
		}
		
		private function onPlay(event:Event):void{
			Application.application.play();
		}
		
		private function onMainWindowOpen(event:Event):void{
			Application.application.visible = true;
			Application.application.activate();
		}
		
		private function onPlayerWindowOpen(event:Event):void{
			Application.application.playerOpen();
		}
		
		private function iconLoadSuccessHandler(event:Event):void{
			var loader:LoaderInfo = LoaderInfo(event.currentTarget);
			var image:Bitmap = Bitmap(loader.content);
			var bitmapData:BitmapData = image.bitmapData;
			
			trace(event);
			
			NativeApplication.nativeApplication.icon.bitmaps = [bitmapData];
		}
		
		private function iconLoadFailHandler(event:Event):void{
			trace(event);
		}
		
		private function onExitMenuItem(event:Event):void{
			Application.application.exitButtonClicked();
		}
		
		
	}
}