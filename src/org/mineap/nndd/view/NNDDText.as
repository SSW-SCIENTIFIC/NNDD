package org.mineap.nndd.view
{
	import flash.events.MouseEvent;
	
	import mx.controls.Text;
	import mx.core.FlexGlobals;
	
	import org.mineap.nndd.player.comment.Command;
	
	import spark.components.Application;


	/**
	 * NNDDText.as
	 * 
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */	
	public class NNDDText extends Text
	{
		
		/**
		 * このNNDDTextを表示するタイミングを決定するVposです。
		 */
		public var vpos:Number = -1;
		
		/**
		 * このNNDDTextを表示する際にフォントの大きさを決定するコマンドです。
		 */
		public var size:int = Command.MEDIUM;
		
		/**
		 * このNNDDTextを表示する際に表示位置を決定するコマンド(NAKA,UE,SHITA)です。
		 */
		public var pos:int = Command.NAKA;
		
		/**
		 * このNNDDTextに対応するコメントを投稿したユーザーのIDです
		 */
		public var user_id:String = "";
		
		/**
		 * このNNDDTextに対応するコメントを識別するための番号です。これはひとつの動画内では一意です。
		 */
		public var no:Number = 0;
		
		/**
		 * このNNDDTextに対応する修飾命令です
		 */
		public var mail:String = "";
		
		/**
		 * このNNDDTextの表示位置を決定する際に必要になるNNDDTextへの参照です。
		 */
		public var nnddText:NNDDText = null;
		
		/**
		 * 
		 * 
		 */
		public function NNDDText()
		{
			super();
			this.focusEnabled = true;
			this.selectable = false;
			
//			addEventListener(MouseEvent.CLICK, mouseClickEventHandler);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverEventHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutEventHandler);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function mouseOverEventHandler(event:MouseEvent):void{
			if(!FlexGlobals.topLevelApplication.isMouseHide){
				(event.currentTarget as NNDDText).drawFocus(true);
			}
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function mouseOutEventHandler(event:MouseEvent):void{
			(event.currentTarget as NNDDText).drawFocus(false);
		}
		
//		/**
//		 * 
//		 * @param event
//		 * 
//		 */
//		private function mouseClickEventHandler(event:MouseEvent):void{
//			this.setFocus();
//		}
		
		
	}
}