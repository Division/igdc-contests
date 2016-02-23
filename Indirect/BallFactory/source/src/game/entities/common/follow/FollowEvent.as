package game.entities.common.follow {
	import decorator.DecorEvent;
	
	/**
	 * Поиск объектов, за которым происходит следование
	 * И регистрания внутри найденного объекта
	 * @author Division
	 */
	public class FollowEvent extends DecorEvent{

		public static const REGISTER_FOLLOW : String = "RegisterFollow";
		public static const UPDATE_FOLLOW : String = "UpdateFollow";
		
		private var _follow : Follow;
		
		public function FollowEvent(type : String, follow : Follow = null) {
			super(type);
			_follow = follow;
		}
		
		public function getFollow() : Follow {
			return _follow;
		}
		
	}

}