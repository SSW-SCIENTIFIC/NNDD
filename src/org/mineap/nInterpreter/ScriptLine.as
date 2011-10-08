package org.mineap.nInterpreter
{
	/**
	 * 実行するスクリプト1行を表現するデータモデル
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class ScriptLine
	{
		
		private var _line:String;
		
		private var _mail:String;
		
		private var _vpos:int;
		
		/**
		 * 
		 * @param line
		 * @param mail
		 * @param vpos
		 * 
		 */
		public function ScriptLine(line:String, mail:String, vpos:int)
		{
			this._line = line;
			this._mail = mail;
			this._vpos = vpos;
		}
		
		public function get mail():String
		{
			return _mail;
		}

		public function set mail(value:String):void
		{
			_mail = value;
		}

		/**
		 * 実際のスクリプト文字列
		 */
		public function get line():String
		{
			return _line;
		}

		/**
		 * スクリプトが実行された時刻(vpos)
		 */
		public function get vpos():int
		{
			return _vpos;
		}

		/**
		 * 
		 * @param value
		 * 
		 */
		public function set line(value:String):void
		{
			_line = value;
		}

		/**
		 * 
		 * @param value
		 * 
		 */
		public function set vpos(value:int):void
		{
			_vpos = value;
		}


	}
}