package core {
import events.GameEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Keyboard;

[Event(name=GameEvent.SCORES_SAVED, type="events.GameEvent")]
public class SaveScoresField extends Sprite{
    public function SaveScoresField(scores : uint) {
        addEventListener(Event.ADDED_TO_STAGE, function (e:Event) : void {
            var textFormat : TextFormat = new TextFormat("ArcadeClassic", 20, 0xFFFFFF);
            var enterYourNameTf : TextField = new TextField();
            enterYourNameTf.defaultTextFormat = textFormat;
            enterYourNameTf.embedFonts = true;
            enterYourNameTf.width = 200;
            enterYourNameTf.text = "your name";
            enterYourNameTf.x = 100;
            enterYourNameTf.y = 300;

            var yourNameTf : TextField  = new TextField();
            yourNameTf.defaultTextFormat = textFormat;
            yourNameTf.embedFonts = true;
            yourNameTf.type = "input";
            yourNameTf.width = 200;
            yourNameTf.x = 200;
            yourNameTf.y = 300;
            stage.focus = yourNameTf;
            yourNameTf.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent):void {
                if(e.keyCode == Keyboard.ENTER){
                    stage.focus = stage;
                    yourNameTf.removeEventListener(KeyboardEvent.KEY_DOWN, arguments.callee);
                    if(yourNameTf.text != ""){
                        var url : String = Game.POST_SCORES_URL + "?name=" + yourNameTf.text + "&scores=" + scores;
                        var loader : URLLoader = new URLLoader(new URLRequest(url));
                        loader.addEventListener(Event.COMPLETE, function (e:Event):void {
                            dispatchEvent(new GameEvent(GameEvent.SCORES_SAVED));
                        });
                        loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event) : void {trace("io error");})
                    }
                }
            })
            addChild(yourNameTf);
            addChild(enterYourNameTf);
        });
    }
}
}
