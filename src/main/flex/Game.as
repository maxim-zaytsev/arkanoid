package {

import core.ErrorMessage;
import core.SaveScoresField;
import core.StatusPanel;

import events.GameEvent;
import events.SplashScreenEvent;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.ui.Keyboard;

import managers.LevelManager;
import managers.SoundManager;
import managers.SplashScreenManager;

import mx.core.UIComponent;

public class Game extends UIComponent {

    [Embed(source="../resources/arkanoid.swf", mimeType="application/octet-stream")]
    private var Swf : Class;

    [Embed(source="../resources/arcadeclassic.ttf", fontName = "ArcadeClassic", mimeType = "application/x-font")]
    private var arcadeFont:Class;

    public static const MAX_SCORES_URL : String = "http://192.241.221.76:9000/top/max";
    public static const POST_SCORES_URL : String = "http://192.241.221.76:9000/top/post";
    public static const TOP_URL : String = "http://192.241.221.76:9000/top/list";

    private var splashManager : SplashScreenManager;
    private var levelManager : LevelManager;
    private var soundManager : SoundManager;
    private var statusPanel : StatusPanel;
    private var appDomain : ApplicationDomain;
    private var errorMessage : ErrorMessage;
    public static var STAGE : EventDispatcher;

    public function Game() {
        var loader : Loader = new Loader();
        loader.loadBytes(new Swf());
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e : Event) : void {
            appDomain = loader.contentLoaderInfo.applicationDomain;
            soundManager = new SoundManager(appDomain);
            splashManager = new SplashScreenManager(appDomain);
            splashManager.addEventListener(SplashScreenEvent.START_GAME, onGameStarted);
            soundManager.playIntroMusic();
            show(splashManager.firstScreen());
        });
        addEventListener(Event.ADDED_TO_STAGE, function (e:Event):void {
            STAGE = stage;
            STAGE.addEventListener(GameEvent.ERROR, onGameError);
        });
    }

    private function onGameError(event:GameEvent):void {
        if(errorMessage && contains(errorMessage)){
            errorMessage.text = event.errorMessage;
        }
        show(new ErrorMessage(event.errorMessage));
    }

    private function show(target:DisplayObject):void {
        if (contains(target) && target.parent == this) {
            var childIndex:int = getChildIndex(target);
            getChildAt(childIndex).visible = true;
            setChildIndex(getChildAt(childIndex), numChildren-1);
        } else {
            addChild(target);
        }
    }

    private function hide(target:DisplayObject):void {
        if (contains(target)) {
            var childIndex:int = getChildIndex(target);
            getChildAt(childIndex).visible = false;
        }
    }

    private function onGameStarted(e:Event):void {
        splashManager.removeEventListener(SplashScreenEvent.START_GAME, onGameStarted);
        hide(splashManager.firstScreen());
        levelManager = new LevelManager(appDomain);
        levelManager.addEventListener(GameEvent.GAME_LOADED, onLevelsLoaded);
        levelManager.loadLevels();
    }

    private function onLevelsLoaded(e:Event):void {
        levelManager.removeEventListener(GameEvent.GAME_LOADED, onLevelsLoaded);
        var ui : Sprite = levelManager.currentLevel.ui();
        show(ui);
        statusPanel = new StatusPanel();
        show(statusPanel);
        soundManager.stopPlaying();
        soundManager.playLevelMusic();
        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
        levelManager.addEventListener(GameEvent.BALL_LOST, onBallLost);
        levelManager.addEventListener(GameEvent.BLOCK_CRASHED, onBlockCrashed);
        levelManager.addEventListener(GameEvent.LEVEL_WON, onLevelWon);
        levelManager.addEventListener(GameEvent.BAT_HIT, onBatHit);
        levelManager.addEventListener(GameEvent.WALL_HIT, onWallHit);
    }

    private function onWallHit(event:GameEvent):void {
        soundManager.wallHit();
    }

    private function onBatHit(event:GameEvent):void {
        soundManager.batHit();
    }

    private function onBallLost(e:Event):void{
        soundManager.batHit();
        levelManager.currentLevel.stop();
        levelManager.currentLevel.initBatAndBall();
        statusPanel.lives--;
        if(statusPanel.lives == 0) {
            gameOver();
        }
    }

    private function onRestartGame(e:Event) : void {
        stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);

        splashManager.addEventListener(SplashScreenEvent.START_GAME, onGameStarted);
        splashManager.removeEventListener(SplashScreenEvent.RESTART_GAME, arguments.callee);

        levelManager.removeEventListener(GameEvent.BALL_LOST, onBallLost);
        levelManager.removeEventListener(GameEvent.BLOCK_CRASHED, onBlockCrashed);
        levelManager.removeEventListener(GameEvent.LEVEL_WON, onLevelWon);
        levelManager.removeEventListener(GameEvent.BAT_HIT, onBatHit);
        levelManager.removeEventListener(GameEvent.WALL_HIT, onWallHit);

        levelManager.currentLevelNumber = 0;
        levelManager.currentLevel.stop();
        levelManager.currentLevel.initBatAndBall();
        levelManager.refreshLevels();

        soundManager.stopPlaying();
        soundManager.playIntroMusic();

        hide(splashManager.finalScreen());
        show(splashManager.firstScreen());
        hide(statusPanel);

        statusPanel.initialize();
    }

    private function gameOver():void{
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
        hide(levelManager.currentLevel.ui());
        var finalScreen : Sprite = splashManager.finalScreen();
        show(finalScreen);

        var loader : URLLoader = new URLLoader(new URLRequest(Game.MAX_SCORES_URL));
        loader.addEventListener(Event.COMPLETE, function(e:Event):void {
            loader.removeEventListener(Event.COMPLETE, arguments.callee);
            var maxScores : uint = parseInt(loader.data);
            if(statusPanel.scores > maxScores){
                var saveScoresField : SaveScoresField = new SaveScoresField(statusPanel.scores);
                saveScoresField.addEventListener(GameEvent.SCORES_SAVED, function (e:GameEvent):void {
                    splashManager.addEventListener(SplashScreenEvent.RESTART_GAME, onRestartGame);
                    splashManager.dispatchEvent(new SplashScreenEvent(SplashScreenEvent.RESTART_GAME));
                    finalScreen.removeChild(saveScoresField);
                });
                finalScreen.addChild(saveScoresField);
            } else {
                splashManager.addEventListener(SplashScreenEvent.RESTART_GAME, onRestartGame);
            }
        });
        loader.addEventListener(IOErrorEvent.IO_ERROR, function (e:Event):void {
            splashManager.addEventListener(SplashScreenEvent.RESTART_GAME, onRestartGame);
        });
    }

    private function onBlockCrashed(e:GameEvent):void{
        if(e.block != null){
            soundManager.blockCrash();
            statusPanel.scores += 100;
        }
    }

    private function onLevelWon(e:Event):void{
        hide(levelManager.currentLevel.ui());
        show(levelManager.nextLevel().ui());
        show(statusPanel);
        statusPanel.level ++;
        levelManager.currentLevel.stop();
        levelManager.currentLevel.initBatAndBall();
    }


    private function onEnterFrame(e:Event):void {
        if (levelManager.currentLevel != null) {
            levelManager.currentLevel.tick();
        }
    }

    private function onKeyPressed(e:KeyboardEvent):void {
        if (e.keyCode == Keyboard.LEFT) {
            levelManager.currentLevel.moveBatLeft();
        }
        if (e.keyCode == Keyboard.RIGHT) {
            levelManager.currentLevel.moveBatRight();
        }
        if (e.keyCode == Keyboard.SPACE && !levelManager.currentLevel.isStarted) {
            levelManager.currentLevel.start();
        }
    }
}
}
