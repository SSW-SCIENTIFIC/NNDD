package org.mineap.nndd
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.mineap.nndd.model.SearchSortString;
	import org.mineap.nicovideo4as.Login;
	import org.mineap.nicovideo4as.loader.SearchPageLoader;
	import org.mineap.nicovideo4as.model.SearchSortType;
	import org.mineap.nicovideo4as.analyzer.SearchResultAnalyzer;

	public class NNDDSearchListRenewer extends EventDispatcher
	{
		
		public static const RENEW_SUCCESS:String = "RenewSuccess";
		public static const RENEW_FAIL:String = "RenewFail";
		
		
		private var _login:Login = new Login();
		
		private var _searchLoader:SearchPageLoader = new SearchPageLoader();
		
		private var _user:String;
		
		private var _password:String;
		
		private var _word:String;
		
		private var _sort:int = 0;
		
		private var _order:int = 0;
		
		private var _page:int = 1;
		
		public function NNDDSearchListRenewer()
		{
		}
		
		
		public function renew(user:String, password:String, word:String, sort:int, order:int, page:int):void{
			
			this._user = user;
			this._password = password;
			this._word = word;
			this._sort = sort;
			this._order = order;
			this._page = page;
			
			login();
		}
		
		private function login():void{
			
			this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccessEventHandler);
			this._login.addEventListener(Login.LOGIN_FAIL, failEventHandler);
			
			this._login.login(this._user, this._password);
			
		}
		
		private function loginSuccessEventHandler(event:Event):void{
			
			this._searchLoader.addEventListener(Event.COMPLETE, loadCompleteEventHandler);
			
			var sort:String = SearchSortType.convertSortTypeNumToString(this._sort);
			var order:String = SearchSortType.convertSortOrderTypeNumToString(this._order);
			
			this._searchLoader.getSearchPage(this._word, sort, order, this._page);
		}
		
		private function loadCompleteEventHandler(event:Event):void{
			
			var serachResutlAnalyzer:SearchResultAnalyzer = new SearchResultAnalyzer();
			
			serachResutlAnalyzer.analyzer(this._searchLoader.data);
			
			close();
			dispatchEvent(new Event(RENEW_SUCCESS));
			
		}
		
		private function failEventHandler(event:Event):void{
			close();
			dispatchEvent(new Event(RENEW_FAIL));
		}
		
		public function close():void{
			try{
				this._login.close();
			}catch(error:Error){
				error.getStackTrace();
			}
			
			try{
				this._searchLoader.close();
			}catch(error:Error){
				error.getStackTrace();
			}
		}
		
		
	}
}