package org.mineap.nInterpreter.nico2niwa.operation.setdefault {
    import flash.desktop.DockIcon;

    import org.mineap.nInterpreter.ScriptLine;
    import org.mineap.nInterpreter.nico2niwa.operation.Nico2NiwaConverter;
    import org.mineap.nndd.player.comment.Command;

    public class DefaultComverter implements Nico2NiwaConverter {

        /**
         * ＠デフォルト命令を解析する正規表現です。
         */
        public var DEFAULT_PATTERN: RegExp = new RegExp("デフォルト");

        private static const command: Command = new Command();

        public function DefaultComverter() {
        }

        /**
         * デフォルト命令をニワン語に変換します。
         * (現在は色設定のみ対応)
         *
         * @param source
         * @return
         *
         */
        public function convert(source: ScriptLine): ScriptLine {
            var operation: String = "";
            var line: String = source.line;
            var resultArray: Array = DEFAULT_PATTERN.exec(line);

            if (resultArray != null && resultArray.length > 0) {

                var color: int = command.getColorByCommand(source.mail);

                var colorStr: String = color.toString(16);
                while (colorStr.length < 6) {
                    colorStr = "0" + colorStr;
                }

                operation = "commentColor=0x" + colorStr;

            }
            return new ScriptLine(operation, null, source.vpos);
        }
    }
}