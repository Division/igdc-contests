package game.entities.common.follow {
	import math.Vector2;
	
	/**
	 * Декораторы, за которыми может осуществляться следование, должны реализовывать этот интерфейс
	 * @author Division
	 */
	public interface IFollowable {
		function getFollowPositionX() : Number;
		function getFollowPositionY() : Number;		
		function getFollowAngle()	 : Number;
		function updateFollow() : void;
	}
	
}