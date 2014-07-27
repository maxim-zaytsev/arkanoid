package core {
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

public class StatusPanel  extends Sprite{
    private var scoresTf:TextField;
    private var livesTf:TextField;
    private var levelTf:TextField;
    private var _scores:uint = 0;
    private var _lives:uint = 3;
    private var _level:uint = 1;


    public function StatusPanel() {
        var textFormat : TextFormat = new TextFormat("ArcadeClassic", 20, 0xFFFFFF);
        scoresTf = new TextField();
        scoresTf.defaultTextFormat = textFormat;
        scoresTf.embedFonts = true;
        scoresTf.text = "SCORE " + _scores;
        scoresTf.width = 200;

        livesTf = new TextField();
        livesTf.defaultTextFormat = textFormat;
        livesTf.embedFonts = true;
        livesTf.text = "LIVES " + _lives;

        levelTf = new TextField();
        levelTf.defaultTextFormat = textFormat;
        levelTf.embedFonts = true;
        levelTf.text = "LEVEL " + _level;

        addChild(scoresTf);
        addChild(livesTf);
        addChild(levelTf);

        scoresTf.x = 10;
        livesTf.x = scoresTf.width;
        levelTf.x = livesTf.width + 300;
    }

    public function set scores(value : uint):void {
        _scores = value;
        scoresTf.text = "SCORE " + _scores;
    }
    public function set lives(value : uint):void {
        _lives = value;
        livesTf.text = "LIVES " + _lives;
    }
    public function set level(value : uint):void {
        _level = value;
        levelTf.text = "LEVEL " + _level;
    }

    public function get scores():uint {
        return _scores;
    }

    public function get lives():uint {
        return _lives;
    }

    public function get level():uint {
        return _level;
    }

    public function initialize():void {
        level = 1;
        lives = 3;
        scores = 0;
    }
}
}
