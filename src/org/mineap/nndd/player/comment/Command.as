package org.mineap.nndd.player.comment
{
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.ResultType;
	import org.mineap.nInterpreter.nico2niwa.operation.jump.JumpComverter;
	import org.mineap.nInterpreter.operation.IOperationAnalyzer;
	import org.mineap.nInterpreter.operation.jump.JumpOperationAnalyzer;
	import org.mineap.nInterpreter.operation.seek.SeekOperationAnalyzer;

	/**
	 * Command.as
	 * ニコニコ動画のコメント表示に関するコマンドを処理するクラスです。
	 * 
	 * @author shiraminekeisuke (MineAP)
	 * 
	 */	
	public class Command
	{
		
		public static const NAKA:int = 0;
		public static const UE:int = 1;
		public static const SHITA:int = 2;
		
		public static const NICOWARI_STOP:int = 0;
		public static const NICOWARI_PLAY:int = 1;
		
		public static const POSITION_ARRAY:Array = new Array(
			"naka", "ue", "shita"
		);
		
		/**
		 * 位置を指定するコマンドを表す正規表現です。
		 */
		public static const POSITION_PATTERNS:Array = new Array(
			new RegExp("\\b" + POSITION_ARRAY[0] + "\\b", "ig"), 
			new RegExp("\\b" + POSITION_ARRAY[1] + "\\b", "ig"), 
			new RegExp("\\b" + POSITION_ARRAY[2] + "\\b", "ig")
		);
		
		public static const BIG:int = 0;
		public static const MEDIUM:int = 1;
		public static const SMALL:int = 2;
		
		public static const SIZE_ARRAY:Array = new Array(
			"big", "medium", "small"
		);
		
		/**
		 * サイズを指定するコマンドを表す正規表現です。
		 */
		public static const SIZE_PATTERNS:Array = new Array(
			new RegExp("\\b" + SIZE_ARRAY[0] + "\\b", "ig"), 
			new RegExp("\\b" + SIZE_ARRAY[1] + "\\b", "ig"), 
			new RegExp("\\b" + SIZE_ARRAY[2] + "\\b", "ig")
		);
		
		public static const WHITE:int = 0;
		public static const RED:int = 1;
		public static const PINK:int = 2;
		public static const ORANGE:int = 3;
		public static const YELLOW:int = 4;
		public static const GREEN:int = 5;
		public static const CYAN:int = 6;
		public static const BLUE:int = 7;
		public static const PURPLE:int = 8;
		
		public static const COLLOR_VALUE_ARRAY:Array = new Array(
			new int("0xFFFFFF"), new int("0xFF0000"), new int("0xFF8080"),
			new int("0xFFCC00"), new int("0xFFFF00"), new int("0x00FF00"),
			new int("0x00FFFF"), new int("0x0000FF"), new int("0xC000FF")
		);
		
		public static const COLLOR_COMMAND_ARRAY:Array = new Array(
			"white", "red", "pink", "orange", "yellow", "green", "cyan",
			"blue", "purple"
		);
		
		/**
		 * 色を指定するコマンドを表す正規表現です。
		 */
		public static const COLLOR_COMMAND_PATTERNS:Array = new Array(
			new RegExp("\\b" + COLLOR_COMMAND_ARRAY[0] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_COMMAND_ARRAY[1] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_COMMAND_ARRAY[2] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_COMMAND_ARRAY[3] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_COMMAND_ARRAY[4] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_COMMAND_ARRAY[5] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_COMMAND_ARRAY[6] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_COMMAND_ARRAY[7] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_COMMAND_ARRAY[8] + "\\b", "ig")
		);
		
		public static const NICONICO_WHITE:int = 0,WHITE2:int = 0;
		public static const TRUE_RED:int = 1, RED2:int = 1;
		public static const PASSION_ORANGE:int = 2, ORANGE2:int = 2;
		public static const MADY_YELLOW:int = 3, YELLOW2:int = 3;
		public static const ELEMENTAL_GREEN:int = 4, GREEN2:int = 4;
		public static const MARINE_BLUE:int = 5, BLUE2:int = 5;
		public static const NOBLE_VIOLET:int = 6, PURPLE2:int = 6;
		public static const BLACK:int = 7;
		
		public static const COLLOR_PREMIUM_VALUE_ARRAY:Array = new Array(
			new int("0xCCCC99"), new int("0xCC0033"), new int("0xFF6600"),
			new int("0x999900"), new int("0x00CC66"), new int("0x33FFFC"),
			new int("0x6633CC"), new int("0x000000")
		);
		
		public static const COLLOR_PREMIUM_COMMAND_ARRAY:Array = new Array(
			"niconicowhite", "truered", "passionorange", "madyyellow",
			"elementalgreen", "marineblue", "nobleviolet", "black"
		);
		
		/**
		 * 色を指定するプレミアムコマンドを表す正規表現です。
		 */
		public static const COLLOR_PREMIUM_COMMAND_PATTERNS:Array = new Array(
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND_ARRAY[0] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND_ARRAY[1] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND_ARRAY[2] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND_ARRAY[3] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND_ARRAY[4] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND_ARRAY[5] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND_ARRAY[6] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND_ARRAY[7] + "\\b", "ig")
		);
		
		public static const COLLOR_PREMIUM_COMMAND2_ARRAY:Array = new Array(
			"white2", "red2", "orange2", "yellow2",
			"green2", "blue2", "purple2", "black"
		);
		
		/**
		 * 色を指定するプレミアムコマンド(2)を表す正規表現です。
		 */
		public static const COLLOR_PREMIUM_COMMAND2_PATTERNS:Array = new Array(
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND2_ARRAY[0] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND2_ARRAY[1] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND2_ARRAY[2] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND2_ARRAY[3] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND2_ARRAY[4] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND2_ARRAY[5] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND2_ARRAY[6] + "\\b", "ig"), 
			new RegExp("\\b" + COLLOR_PREMIUM_COMMAND2_ARRAY[7] + "\\b", "ig")
		);
		
		/**
		 * 「セカイの新着動画」で投稿されたコメントである事を表す文字列です。
		 */
		public static const SEKAINO_SHINCHAKU_COMMENT:String = "_live";
		
		public function Command()
		{
		}
		
		/**
		 * ニコニコ動画のコマンドに対応する色（整数値）を返します。
		 * @return 
		 * 
		 */
		public function getColorByCommand(color:String):int{
			var index:int = 0;
			if(color.length > 0){
				for(index = 0; index < Command.COLLOR_COMMAND_ARRAY.length; index++){
					if(color.match(COLLOR_COMMAND_PATTERNS[index]).length >= 1){
						return Command.COLLOR_VALUE_ARRAY[index] as int;
					}
				}
				
				for(index = 0; index < Command.COLLOR_PREMIUM_COMMAND_ARRAY.length; index++){
					if(color.match(Command.COLLOR_PREMIUM_COMMAND_PATTERNS[index]).length >= 1){
						return Command.COLLOR_PREMIUM_VALUE_ARRAY[index] as int;
					}
				}
				
				for(index = 0; index < Command.COLLOR_PREMIUM_COMMAND2_ARRAY.length; index++){
					if(color.match(Command.COLLOR_PREMIUM_COMMAND2_PATTERNS[index]).length >= 1){
						return Command.COLLOR_PREMIUM_VALUE_ARRAY[index] as int;
					}
				}
			}
			
			return int("0xFFFFFF");
		}
		
		/**
		 * ニコニコ動画のコマンドに対応するサイズ（Command定数）を返します。
		 * @param command
		 * @return 
		 * 
		 */
		public function getSize(command:String):int{
			if(command.length > 0){
				for(var index:int = 0; index < Command.SIZE_ARRAY.length; index++){
					if(command.match(Command.SIZE_PATTERNS[index]).length >= 1){
						return index;
					}
				}
			}
			return Command.MEDIUM;
		}
		
		/**
		 * ニコニコ動画のコマンドに対する表示位置（Command定数）返します。
		 * @param command
		 * @return 
		 * 
		 */
		public function getPosition(command:String):int{
			if(command.length > 0){
				for(var index:int = 0; index < Command.POSITION_ARRAY.length; index++){
					if(command.match(Command.POSITION_PATTERNS[index]).length >= 1){
						return index;
					}
				}
			}
			return Command.NAKA;
		}
		
		/**
		 * 渡されたが文字列がコマンドかどうかを判定し、
		 * コマンドであり、かつ@CM命令であれば、指定されているニコ割動画のIDと、
		 * NICOWARI_PLAY or NICOWARI_STOPのいずれかを返します。
		 * 
		 * @param command
		 * @return Array("ニコ割動画ID", NICOWARI_PLAY or NICOWARI_STOP, "再生開始時刻(hhmm形式)")
		 * 	ニコ割動画ID:ニコ割の動画ID。存在しなければ空の文字列。
		 * 	ニコ割再生中の動画の挙動:NICOWARI_PLAYならば動画の再生は続ける。NICOWARI_STOPならば動画は停止。
		 * 	再生開始時刻:ニコ割を時報的に使う場合はhhmm形式で時刻が指定される。指定されていない場合は空文字列。
		 */
		public function getNicowariVideoID(command:String):Array{
			var nicoWariString:String = "";
			var isPlay:int = NICOWARI_PLAY;
			var startTime:String = "";
			
			var op:String = command.substring(0, 3);
			
			if(command.length > 0){
				if(op == "＠ＣＭ" || op == "@CM" ||
						op == "@ＣＭ" || op == "＠CM"){
					var pattern1:RegExp = new RegExp("(nm\\d+)", "ig");
					var pattern2:RegExp = new RegExp("(nm\\d+)[^\\d].*\\s(\\d\\d\\d\\d)", "ig");
					var videoIds:Array = pattern1.exec(command);
					var startTimes:Array = pattern2.exec(command);
					//今のところ、時刻指定のニコ割は再生しない。
					if(videoIds != null && videoIds.length > 0){
						nicoWariString = videoIds[1];
						if(command.indexOf("停止") != -1){
							isPlay = NICOWARI_STOP;
						}else /*if(command.indexOf("再生") != -1)*/{
							isPlay = NICOWARI_PLAY;
						}
						
						if(startTimes != null && startTimes.length > 0){
							startTime = startTimes[2];	
						}
						
					}
				}
			}
			return new Array(nicoWariString, isPlay, startTime);
		}
		
		/**
		 * 渡された文字列がコマンドかどうかを判定し、＠ジャンプ命令であれば、指定されている動画IDとジャンプメッセージを返します。<br>
		 * 
		 * ex. ＠ジャンプ ジャンプ先 [ジャンプメッセージ] [ジャンプ先再生開始位置] [戻り秒数] [戻りメッセージ]
		 * 
		 * @param command
		 * @return Array("動画ID", "ジャンプメッセージ")<br>
		 * 	動画ID:ジャンプ先の動画ID<br>
		 * 	ジャンプメッセージ:ジャンプ時に画面に表示されるメッセージ。存在しない場合は空の文字列。
		 * 
		 */
		public function getAnalyzeResultByNicoScript(command:String):IAnalyzeResult{
			
			var op:String = command.substring(0, 5);
			var result:IAnalyzeResult = null;
			
			if(command.length > 0){
				if(op == "＠ジャンプ" || op == "@ジャンプ" ||
						op == "@ジャンプ" || op == "＠ジャンプ"){
					
					//ニワン語に変換
					var jumpComv:JumpComverter = new JumpComverter();
					command = "/" + jumpComv.converte(command);
					
					op = command.substring(1, 5);
					
				}
				
				result = getAnalyzeResult(command);
				
			}
			return result;
		}
		
		
		/**
		 * ニワン語を解析して結果を返します。
		 * 現状はjump命令とseek命令のみを抽出して実行します。
		 * @param command
		 * @return 
		 * 
		 */
		public function getAnalyzeResult(command:String):IAnalyzeResult{
			
			var iAnalyzeResult:IAnalyzeResult = null;
			var analyzer:IOperationAnalyzer = null;
			if(command.indexOf("jump") != -1){
				command = command.substring(command.indexOf("jump"));
				analyzer = new JumpOperationAnalyzer();
				iAnalyzeResult = analyzer.analyze(command);
			}else if(command.indexOf("seek") != -1){
				command = command.substring(command.indexOf("seek"));
				analyzer = new SeekOperationAnalyzer();
				iAnalyzeResult = analyzer.analyze(command);
			}
			
			return iAnalyzeResult;
		}

	}
}