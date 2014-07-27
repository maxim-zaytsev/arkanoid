package managers {
import com.adobe.serialization.json.JSON;
import core.ScoresRecord;
import events.GameEvent;
import events.SplashScreenEvent;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.text.TextField;
import flash.text.TextFormat;

[Event(name=SplashScreenEvent.ANIMATION_ENDED, type="events.SplashScreenEvent")]
[Event(name=SplashScreenEvent.START_GAME, type="events.SplashScreenEvent")]
[Event(name=SplashScreenEvent.RESTART_GAME, type="events.SplashScreenEvent")]
public class SplashScreenManager extends EventDispatcher {

    [Embed(source="../../resources/arcadeclassic.ttf", fontName="ArcadeClassic", mimeType="application/x-font")]
    private var arcadeFont:Class;

    private var splashClass:Class;
    private var scoresClass:Class;
    private var _firstScreen:Sprite;
    private var _finalScreen:Sprite;
    private var _scoresTable:Sprite;

    public function SplashScreenManager(appDomain : ApplicationDomain) {
        splashClass = appDomain.getDefinition("Splash1") as Class;
        scoresClass = appDomain.getDefinition("Scores") as Class;
    }

    private var splashScreen:DisplayObject;
    private var scoresScreen:Sprite;

    public function firstScreen():DisplayObject {
        if (_firstScreen == null) {
            _firstScreen = new Sprite();
            splashScreen = new splashClass();
            scoresScreen = new scoresClass();
            _firstScreen.addChild(splashScreen);
            _firstScreen.addChild(scoresScreen);
            scoresScreen.visible = false;
        }
        splashScreen.visible = true;
        splashScreen.addEventListener("game.to.new.game", toNewGame);
        splashScreen.addEventListener("game.to.scores", toScores);
        _firstScreen.visible = true;
        return _firstScreen;
    }

    private function toScores(e:Event):void {
        splashScreen.removeEventListener("game.to.new.game", toNewGame);
        splashScreen.removeEventListener("game.to.scores", toScores);
        scoresScreen.addEventListener("game.back.from.scores", backFromScores);
        splashScreen.visible = false;
        scoresScreen.visible = true;
        var urlLoader:URLLoader = new URLLoader(new URLRequest(Game.TOP_URL));
        urlLoader.addEventListener(Event.COMPLETE, onScoresLoaded);
        urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function (e:Event):void {
            trace("network error");
        });
    }

    private function onScoresLoaded(e:Event):void {
        if (_scoresTable && scoresScreen.contains(_scoresTable)) {
            scoresScreen.removeChild(_scoresTable);
        }
        _scoresTable = buildScoresTable(e.target.data);
        scoresScreen.addChild(_scoresTable);
    }

    private function onScoresLoaded1(e:Event):void {
        var scoresTable : Sprite = buildScoresTable(e.target.data);
        if (_finalScreen.contains(scoresTable)) {
            _finalScreen.removeChild(scoresTable);
        }
        _finalScreen.addChild(scoresTable);
    }

    private function buildScoresTable(json:String):Sprite {
        var records:Array = [];
        for each(var scoreRecordJson:Object in JSON.decode(json) as Array) {
            var record:ScoresRecord = new ScoresRecord();
            for (var prop:String in scoreRecordJson) {
                record[prop] = scoreRecordJson[prop];
            }
            records.push(record);
        }
        var nextY:uint = 350;
        var scoresTextFieldsContainer:Sprite = new Sprite();
        for each(record in records) {
            var textFormat:TextFormat = new TextFormat("ArcadeClassic", 20, 0xFFFFFF);
            var nameTf:TextField = new TextField();
            nameTf.defaultTextFormat = textFormat;
            nameTf.embedFonts = true;
            nameTf.text = record.name;
            var scoresTf:TextField = new TextField();
            scoresTf.defaultTextFormat = textFormat;
            scoresTf.embedFonts = true;
            scoresTf.text = record.scores.toString();
            nameTf.width = 200;
            scoresTf.width = 100;
            nameTf.x = 100
            scoresTf.x = 375;
            nameTf.y = scoresTf.y = nextY;
            nextY += 20;
            scoresTextFieldsContainer.addChild(nameTf);
            scoresTextFieldsContainer.addChild(scoresTf);
            scoresScreen.addChild(scoresTextFieldsContainer);
        }
        return scoresTextFieldsContainer;
    }

    private function toNewGame(e:Event):void {
        splashScreen.removeEventListener("game.to.new.game", toNewGame);
        splashScreen.removeEventListener("game.to.scores", toScores);
        scoresScreen.removeEventListener("game.back.from.scores", backFromScores);
        splashScreen.visible = false;
        scoresScreen.visible = false;
        dispatchEvent(new GameEvent(SplashScreenEvent.START_GAME));
    }

    private function backFromScores(e:Event):void {
        splashScreen.addEventListener("game.to.new.game", toNewGame);
        splashScreen.addEventListener("game.to.scores", toScores);
        scoresScreen.removeEventListener("game.back.from.scores", backFromScores);
        splashScreen.visible = true;
        scoresScreen.visible = false;
    }

    public function finalScreen():Sprite {
        if (_finalScreen == null) {
            _finalScreen = new scoresClass();
            var urlLoader:URLLoader = new URLLoader(new URLRequest(Game.TOP_URL));
            urlLoader.addEventListener(Event.COMPLETE, onScoresLoaded1);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function (e:Event):void {
                trace("network error");
            });
        }
        _finalScreen.addEventListener("game.back.from.scores", function (e:Event):void {
            _finalScreen.removeEventListener("game.back.from.scores", arguments.callee);
            dispatchEvent(new SplashScreenEvent(SplashScreenEvent.RESTART_GAME));
        })
        return _finalScreen;
    }
}
}
