package events {
import flash.events.Event;

public class SplashScreenEvent extends Event{
    public static const START_GAME : String = "start_game";
    public static const RESTART_GAME : String  = "restart_game";
    public static const ANIMATION_ENDED : String  = "animation_ended";
    public function SplashScreenEvent(type : String) {
        super(type);
    }
    public override function clone():Event{
        return new SplashScreenEvent(type);
    }
}
}
