package org.mineap.nndd.user
{
	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class UserManager
	{
		
		/**
		 * 
		 */
		private var _user:String;
		
		/**
		 * 
		 */
		private var _password:String;
		
		/**
		 * 
		 */
		private static const _userManager:UserManager = new UserManager();
		
		/**
		 * 
		 * 
		 */
		public function UserManager()
		{
			if(_myListRenewScheduler != null){
				throw ArgumentError("MyListRenewSchedulerはインスタンス化できません。");
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():UserManager{
			return _userManager;
		}

		/**
		 * 
		 */
		public function get user():String
		{
			return _user;
		}

		/**
		 * @private
		 */
		public function set user(value:String):void
		{
			_user = value;
		}

		/**
		 * 
		 */
		public function get password():String
		{
			return _password;
		}

		/**
		 * @private
		 */
		public function set password(value:String):void
		{
			_password = value;
		}


	}
}