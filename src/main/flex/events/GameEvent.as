package events {
import core.Block;

import flash.events.Event;

public class GameEvent extends Event {
    public static const GAME_LOADED : String = "game_loaded";
    public static const LEVEL_WON : String = "level_won";
    public static const BALL_LOST : String = "ball_lost";
    public static const BLOCK_CRASHED : String = "block_crashed";
    public static const BAT_HIT : String = "bat_hit";
    public static const WALL_HIT : String = "wall_hit";
    public static const ERROR : String = "error";
    public static const SCORES_SAVED : String = "scores_saved";
    private var _block : Block;
    private var _errorMessage : String;
    public function get block () : Block {
        return _block;
    }
    public function GameEvent(type : String, ...args) {
        super(type);
        if(args.length > 0 && args[0] is Block){
            _block = args[0];
        } else if (args.length > 0 && args[0] is String){
            _errorMessage = args[0];
        }
    }
    public override function clone() : Event{
        return new GameEvent(type, _block, _errorMessage);
    }

    public function get errorMessage():String {
        return _errorMessage;
    }
}
}
