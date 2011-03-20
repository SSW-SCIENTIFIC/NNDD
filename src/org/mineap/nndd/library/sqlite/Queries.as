package org.mineap.nndd.library.sqlite
{
	public class Queries
	{
		
		public static const CREATE_TABLE_NNDDVIDEO:String = "CREATE TABLE IF NOT EXISTS nnddvideo (" +
			" id INTEGER PRIMARY KEY," +
			" key TEXT," +
			" uri TEXT," +
			" dirpath_id INTEGER," +
			" videoName TEXT," +
			" isEconomy INTEGER," +
			" modificationDate REAL," +
			" creationDate REAL," +
			" thumbUrl TEXT," +
			" playCount REAL," +
			" time REAL," +
			" lastPlayDate REAL," +
			" yetReading INTEGER," +
			" pubDate REAL," +
			" UNIQUE(key));";
		
		public static const CREATE_INDEX_KEY_OF_NNDDVIDEO:String = "CREATE INDEX keyindex ON nnddvideo (key);";
		
		public static const CREATE_TABLE_TAG:String = "CREATE TABLE IF NOT EXISTS tagstring (" +
			" id INTEGER PRIMARY KEY," +
			" tag TEXT," +
			" UNIQUE(tag));";
		
		public static const CREATE_TABLE_NNDDVIDEO_TAG:String = "CREATE TABLE IF NOT EXISTS nnddvideo_tag (" +
			" id INTEGER PRIMARY KEY," +
			" nnddvideo_id INTEGER," +
			" tag_id INTEGER," +
			" UNIQUE(nnddvideo_id, tag_id));";
		
		public static const CREATE_TABLE_FILE:String = "CREATE TABLE IF NOT EXISTS file (" +
			" id INTEGER PRIMARY KEY," +
			" dirpath TEXT," +
			" UNIQUE(dirpath));";
		
		public static const CREATE_TABLE_VERSION:String = "CREATE TABLE IF NOT EXISTS version (" +
			" id INTEGER PRIMARY KEY," +
			" version TEXT);";
		
		public static const INSERT_NNDDVIDEO:String = "INSERT INTO nnddvideo(" +
			" key, uri, dirpath_id, videoName, isEconomy, modificationDate, creationDate, thumbUrl, playCount, time, lastPlayDate, yetReading, pubDate" +
			" ) VALUES(" +
			" :key, :uri, :dirpath_id, :videoName, :isEconomy, :modificationDate, :creationDate, :thumbUrl, :playCount, :time, :lastPlayDate, :yetReading, :pubDate" +
			" );";
		
		public static const INSERT_TAGSTRING:String = "INSERT INTO tagstring(" +
			" tag" +
			" ) VALUES(" +
			" :tag" +
			" );";
		
		public static const INSERT_NNDDVIDEO_TAG:String = "INSERT INTO nnddvideo_tag(" +
			" nnddvideo_id, tag_id" +
			" ) VALUES(" +
			" :nnddvideo_id, :tag_id" +
			" );";
		
		public static const INSERT_FILE:String = "INSERT INTO file(" +
			" dirpath" +
			" ) VALUES(" +
			" :dirpath" +
			" );";
		
		public static const INSERT_VERSION:String = "INSERT INTO version(" +
			" id, version" +
			" ) VALUES(" +
			" :id, :version" +
			" );";
		
		public static const DELETE_NNDDVIDEO:String = "DELETE FROM nnddvideo WHERE id = :id;";
		
		public static const DELETE_TAGSTRING:String = "DELETE FROM tagstring WHERE id = :id;";
		
		public static const DELETE_NNDDVIDEO_TAG:String = "DELETE FROM nnddvideo_tag WHERE id = :id;";
		
		public static const DELETE_FILE:String = "DELETE FROM file WHERE id = :id;";
		
		public static const DELETE_NEEDLESS_FILE:String = "DELETE FROM file WHERE id = " +
			"(SELECT file.id FROM file WHERE file.id NOT IN" +
			"(SELECT file.id FROM file INNER JOIN nnddvideo ON nnddvideo.dirpath_id = file.id)" +
			");";
		
		public static const UPDATE_NNDDVIDEO:String = "UPDATE nnddvideo SET" +
			" uri = :uri," +
			" key = :key," +
			" dirpath_id = :dirpath_id," +
			" videoName = :videoName," +
			" isEconomy = :isEconomy," +
			" modificationDate = :modificationDate," +
			" creationDate = :creationDate," +
			" thumbUrl = :thumbUrl," +
			" playCount = :playCount," +
			" time = :time," +
			" lastPlayDate = :lastPlayDate," +
			" yetReading = :yetReading," +
			" pubDate = :pubDate" +
			" WHERE id = :id;";
		
		public static const UPDATE_TAGSTRING:String = "UPDATE tagstring SET" +
			" tag = :tag" +
			" WHERE id = :id;";
		
		public static const UPDATE_NNDDVIDEO_TAG:String = "UPDATE nnddvideo_tag SET" +
			" nnddvideo_id = :nnddvideo_id," +
			" tag_id = :tag_id" +
			" WHERE id = :id;";
		
		public static const UPDATE_VERSION:String = "UPDATE version SET" +
			" version = :version" +
			" WHERE id = :id;";
		
		public static const SELECT_NNDDVIDEO_ALL:String = "SELECT * FROM nnddVideo;";
		
		public static const SELECT_TAGSTRING_ALL:String = "SELECT * FROM tagstring;";
		
		public static const SELECT_NNDDVIDEO_TAG_ALL:String = "SELECT * FROM nnddvideo_tag;";
		
		public static const SELECT_NNDDVIDEO_BY_ID:String = "SELECT * FROM nnddVideo WHERE id = :id;";
		
		public static const SELECT_NNDDVIDEO_BY_KEY:String = "SELECT * FROM nnddVideo WHERE key = :key;";
		
		public static const SELECT_TAGSTRING_BY_ID:String = "SELECT * FROM tagstring WHERE id = :id;";
		
		public static const SELECT_TAGSTRING_BY_TAG:String = "SELECT * FROM tagstring WHERE tag like :tag;";
		
		public static const SELECT_NNDDVIDEO_TAG_BY_NNDDVIDEO_ID:String = "SELECT * FROM nnddvideo_tag WHERE nnddvideo_id = :nnddvideo_id;";
		
		public static const SELECT_NNDDVIDEO_TAG_BY_TAG_ID:String = "SELECT * FROM nnddvideo_tag WHERE tag_id = :tag_id;";
		
		public static const SELECT_NNDDVIDEO_BY_FILE_ID:String = "SELECT * FROM nnddvideo WHERE dirpath_id = :dirpath_id;";
		
		public static const SELECT_TAGSTRING_RELATED_BY_NNDDVIDEO:String = "SELECT tagstring.* FROM nnddvideo_tag, tagstring WHERE nnddvideo_tag.nnddvideo_id = :videoid AND tagstring.id = nnddvideo_tag.tag_id;";
		
		public static const SELECT_VERSION_BY_ID:String = "SELECT * FROM version WHERE id = :id";
		
		public static const SELECT_FILE_BY_ID:String = "SELECT * FROM file WHERE id = :id;";
		
		public static const SELECT_FILE_ALL:String = "SELECT * FROM file;";
		
		
		public static const DROP_NNDDVIDEO:String = "DROP TABLE nnddvideo;";
		
		public static const DROP_INDEX_KEY_OF_NNDDVIDEO:String = "DROP INDEX keyindex;";
		
		public static const DROP_NNDDVIDEO_TAG:String = "DROP TABLE nnddvideo_tag;";
		
		public static const DROP_TAGSTRING:String = "DROP TABLE tagstring;";
		
		public static const DROP_FILE:String = "DROP TABLE file;";
		
		public function Queries()
		{
		}
	}
}