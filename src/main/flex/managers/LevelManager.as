package managers {
import core.Block;
import core.Level;

import events.GameEvent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import flash.events.Event;

import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.text.TextField;

import mx.effects.effectClasses.FadeInstance;

[Event(name=GameEvent.BALL_LOST, type="events.GameEvent")]
[Event(name=GameEvent.GAME_LOADED, type="events.GameEvent")]
[Event(name=GameEvent.BLOCK_CRASHED, type="events.GameEvent")]
[Event(name=GameEvent.BAT_HIT, type="events.GameEvent")]
[Event(name=GameEvent.WALL_HIT, type="events.GameEvent")]
public class LevelManager extends EventDispatcher{
    private var levelUrls : Array = [];
    private var levels : Array = [];
    private var levelCounter : int = 0;
    private var appDomain : ApplicationDomain;
    public function LevelManager (appDomain : ApplicationDomain) : void {
        this.appDomain = appDomain;
    }
    public function get currentLevelNumber () : uint {
        return levelCounter;
    }
    public function get currentLevel () : Level {
        return levels[levelCounter];
    }
    public function loadLevels() : void {
        var levelsLoader : URLLoader = new URLLoader(new URLRequest("levels/levels.xml"));
        levelsLoader.addEventListener(Event.COMPLETE, function (e : Event) : void {
            levelsLoader.removeEventListener(Event.COMPLETE, arguments.callee);
            var levelsXML : XML = XML(levelsLoader.data);
            for each (var property : XML in levelsXML){
                if(property.name() == "levels"){
                    for each(var exactLevel : XML in property.children()){
                        if(exactLevel.name() == "level"){
                            var url : String = "levels/" + exactLevel.attribute("file");
                            levelUrls.push(url);
                        }
                    }
                }
            }
            loadLevelsRecursive(0);
        });
        levelsLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event) : void {
            Game.STAGE.dispatchEvent(new GameEvent(GameEvent.ERROR, "an error occured during 'levels.xml' loading"));
        });
    }

    private function loadLevelsRecursive (i : uint) : void {
        var exactLevelLoader : URLLoader = new URLLoader();
        exactLevelLoader.load(new URLRequest(levelUrls[i]));
        exactLevelLoader.addEventListener(Event.COMPLETE, function (e : Event) : void {
            exactLevelLoader.removeEventListener(Event.COMPLETE, arguments.callee);
            var level : XML = XML(exactLevelLoader.data)
            var l : Level = new Level(level, appDomain);
            levels.push(l);
            if(i < levelUrls.length - 1){
                i++;
                loadLevelsRecursive(i);
            } else {
                dispatchEvent(new GameEvent(GameEvent.GAME_LOADED));
                currentLevel.addEventListener(GameEvent.BALL_LOST, throwUp);
                currentLevel.addEventListener(GameEvent.BLOCK_CRASHED, throwUp);
                currentLevel.addEventListener(GameEvent.LEVEL_WON, onLevelWon);
                currentLevel.addEventListener(GameEvent.WALL_HIT, throwUp);
                currentLevel.addEventListener(GameEvent.BAT_HIT, throwUp);
            }
        })
        exactLevelLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event) : void {
            Game.STAGE.dispatchEvent(new GameEvent(GameEvent.ERROR, "an IO error occured during file loading"));
        });
    }

    public function nextLevel () : Level {
        if(currentLevel != null){
            currentLevel.removeEventListener(GameEvent.BALL_LOST, throwUp);
            currentLevel.removeEventListener(GameEvent.BLOCK_CRASHED, throwUp);
            currentLevel.removeEventListener(GameEvent.LEVEL_WON, throwUp);
            currentLevel.removeEventListener(GameEvent.BAT_HIT, throwUp);
            currentLevel.removeEventListener(GameEvent.WALL_HIT, throwUp);
        }
        levelCounter ++;
        currentLevel.addEventListener(GameEvent.BALL_LOST, throwUp);
        currentLevel.addEventListener(GameEvent.BLOCK_CRASHED, throwUp);
        currentLevel.addEventListener(GameEvent.LEVEL_WON, onLevelWon);
        currentLevel.addEventListener(GameEvent.BAT_HIT, throwUp);
        currentLevel.addEventListener(GameEvent.WALL_HIT, throwUp);
        return levels[levelCounter];
    }

    private function onLevelWon(e : GameEvent) : void {
        dispatchEvent(e);
    }

    private function throwUp(e : Event):void {
        dispatchEvent(e);
    }

    public function set currentLevelNumber(level : uint):void {
        levelCounter = level;
    }

    public function refreshLevels():void {
        for each(var level : Level in levels){
            for each (var block : Block in level.blocks){
                block.hited = false;
            }
        }
    }
}
}
