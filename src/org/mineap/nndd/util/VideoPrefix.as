package org.mineap.nndd.util
{
	public class VideoPrefix
	{
		
		/* ユーザー投稿 */
		public static const sm:VideoPrefix = new VideoPrefix("sm");
		
		public static const nm:VideoPrefix = new VideoPrefix("nm");
		
		public static const am:VideoPrefix = new VideoPrefix("am");
		
		public static const fz:VideoPrefix = new VideoPrefix("fz");
		
		public static const ut:VideoPrefix = new VideoPrefix("ut");
		
		
		/* 公式 */
		public static const ax:VideoPrefix = new VideoPrefix("ax");
		
		public static const ca:VideoPrefix = new VideoPrefix("ca");
		
		public static const cd:VideoPrefix = new VideoPrefix("cd");
		
		public static const cw:VideoPrefix = new VideoPrefix("cw");
		
		public static const fx:VideoPrefix = new VideoPrefix("fx");
		
		public static const ig:VideoPrefix = new VideoPrefix("ig");
		
		public static const na:VideoPrefix = new VideoPrefix("na");
		
		public static const nl:VideoPrefix = new VideoPrefix("nl");
		
		public static const om:VideoPrefix = new VideoPrefix("om");
		
		public static const sd:VideoPrefix = new VideoPrefix("sd");
		
		public static const sk:VideoPrefix = new VideoPrefix("sk");
		
		public static const yk:VideoPrefix = new VideoPrefix("yk");
		
		public static const yo:VideoPrefix = new VideoPrefix("yo");
		
		public static const za:VideoPrefix = new VideoPrefix("za");
		
		public static const zb:VideoPrefix = new VideoPrefix("zb");
		
		public static const zc:VideoPrefix = new VideoPrefix("zc");
		
		public static const zd:VideoPrefix = new VideoPrefix("zd");
		
		public static const ze:VideoPrefix = new VideoPrefix("ze");
		
		/* 公式動画全般 */
		public static const so:VideoPrefix = new VideoPrefix("so");
		
		
		public static const PREFIX_ARRAY:Array = new Array(sm, nm, am, fz, ut, ax, ca, cd, cw, fx, ig, na, nl, om, sd, sk, yk, yo, za, zb, zc, zd, ze, so);
		
		
		public var prefix:String = "sm";
		
		public function VideoPrefix(prefix:String)
		{
			this.prefix = prefix;
		}
	}
}