package core {
import events.GameEvent;

import flash.display.BitmapData;
import flash.display.BlendMode;

import flash.display.DisplayObject;


import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.system.ApplicationDomain;

[Event(name=GameEvent.BALL_LOST, type="events.GameEvent")]
[Event(name=GameEvent.GAME_LOADED, type="events.GameEvent")]
public class Level extends EventDispatcher {

    private var _isStarted:Boolean = false;
    private var _width:int = 500;
    private var _height:int = 700;
    private var _ball:Ball;
    private var _bat:Bat;
    private var _blocks:Array;
    private var _field:Field;
    private var _ui:Sprite;

    private static function randomToMax(max:Number):uint {
        return Math.ceil(Math.random() * max);
    }

    private var _top:int = 30;

    public function Level(xml:XML, appDomain:ApplicationDomain) {
        var fieldStageClass:Class = appDomain.getDefinition("FieldStage") as Class;
        var ballSkin1Class:Class = appDomain.getDefinition("BallSkin1") as Class;
        var batSkin1Class:Class = appDomain.getDefinition("BatSkin1") as Class;
        var blockSkin1Class:Class = appDomain.getDefinition("BlockSkin1") as Class;
        var blockSkin2Class:Class = appDomain.getDefinition("BlockSkin2") as Class;
        var blockSkin3Class:Class = appDomain.getDefinition("BlockSkin3") as Class;
        var blockSkin4Class:Class = appDomain.getDefinition("BlockSkin4") as Class;
        var blockSkin5Class:Class = appDomain.getDefinition("BlockSkin5") as Class;
        var blockSkins:Array = [blockSkin1Class, blockSkin2Class, blockSkin3Class, blockSkin4Class, blockSkin5Class];
        _blocks = [];
        for each (var block:XML in xml.child("blocks")) {
            var x:uint = 0;
            var y:uint = _top;
            for each(var row:XML in block.child("row")) {
                for each(var cell:XML in row.children()) {
                    if (cell.child("block").length() > 0) {
                        var b:Block = new Block(blockSkins[randomToMax(blockSkins.length - 1)]);
                        b.x = x;
                        b.y = y;
                        _blocks.push(b);
                    }
                    x += 51;
                }
                y += 16;
                x = 0;
            }
        }
        _bat = new Bat(batSkin1Class);
        _bat.y = _height - _bat.height - 5;
        _bat.x = _width / 2 - _bat.width / 2;

        _ball = new Ball(ballSkin1Class);
        _ball.x = _bat.x + _bat.width / 2 - _ball.radius;
        _ball.y = _bat.y - _ball.height - 1;

        _field = new Field(fieldStageClass);
    }

    public function get field():Field {
        return _field;
    }

    public function get ball():Ball {
        return _ball;
    }

    public function get bat():Bat {
        return _bat;
    }

    public function get blocks():Array {
        return _blocks;
    }

    public function set blocks(val:Array):void {
        _blocks = val;
    }

    public function get isStarted():Boolean {
        return _isStarted;
    }

    public function start():void {
        _isStarted = true;
        ball.bounceInit();
    }

    public function tick():void {
        if (!isStarted) {
            return;
        }
        if (ballHitsRightBorder()) {
            ball.bounceFromRightBorder();
            dispatchEvent(new GameEvent(GameEvent.WALL_HIT));
        } else if (ballHitsLeftBorder()) {
            ball.bounceFromLeftBorder();
            dispatchEvent(new GameEvent(GameEvent.WALL_HIT));
        } else if (ballHitsBottomBorder()) {
            dispatchEvent(new GameEvent(GameEvent.BALL_LOST));
        } else if (ballHitsTopBorder()) {
            ball.bounceFromTopBorder();
            dispatchEvent(new GameEvent(GameEvent.WALL_HIT));
        } else if (ballHitsBat()) {
            dispatchEvent(new GameEvent(GameEvent.BAT_HIT));
            if (bat.testIfRightSide(ball.x - bat.x)) {
                ball.bounceFromBat(1);
            } else {
                ball.bounceFromBat(-1);
            }
        } else if (ballHitsBlock() != null) {
            var hitBlock:Block = ballHitsBlock();
            ball.bounceFromBlock(hitBlock);
            hitBlock.collapse();
            dispatchEvent(new GameEvent(GameEvent.BLOCK_CRASHED, hitBlock));
            if (!activeBlocksExist()) {
                dispatchEvent(new GameEvent(GameEvent.LEVEL_WON, hitBlock));
            }
        }
        ball.move();
    }

    private function activeBlocksExist():Boolean {
        for each(var block:Block in blocks) {
            if (block.hited == false) {
                return true;
            }
        }
        return false;
    }

    private function ballHitsBlock():Block {
        for each(var block:Block in _blocks) {
            if (block.hited) {
                continue;
            }
            if (areaOfCollision(ball, block, 1) != null) {
                return block;
            }
        }
        return null;
    }

    private function ballHitsBat():Boolean {
        return areaOfCollision(ball, bat, 1) != null;
    }

    private function ballHitsTopBorder():Boolean {
        return ball.y - ball.radius - 5 <= _top;
    }

    private function ballHitsBottomBorder():Boolean {
        return ball.y + ball.radius >= _height;
    }

    private function ballHitsLeftBorder():Boolean {
        return ball.x - ball.radius + 5 <= 0;
    }

    private function ballHitsRightBorder():Boolean {
        return ball.x + ball.radius + 10 >= _width;
    }

    public function moveBatLeft():void {
        var batCanMove:Boolean = bat.x - 10 >= 0;
        if (batCanMove) {
            bat.stepLeft();
        }
        if (!isStarted) {
            if (batCanMove) {
                ball.stepLeft(bat.stepIncrement);
            }
        }
    }

    public function moveBatRight():void {
        var batCanMove:Boolean = bat.x + bat.width + 10 <= _width;
        if (batCanMove) {
            bat.stepRight();
        }
        if (!isStarted) {
            if (batCanMove) {
                ball.stepRight(bat.stepIncrement);
            }
        }
    }

    public function initBatAndBall():void {
        _bat.y = _height - _bat.height - 5;
        _bat.x = _width / 2 - _bat.width / 2;
        _ball.x = _bat.x + _bat.width / 2 - _ball.radius;
        _ball.y = _bat.y - _ball.height - 1;
        _ball.stop();
    }

    public function stop():void {
        _isStarted = false;
    }

    public function ui():Sprite {
        if (_ui == null) {
            var playStage:Sprite = new Sprite();
            playStage.addChild(field);
            playStage.addChild(ball);
            playStage.addChild(bat);
            for each(var block:Block in blocks) {
                playStage.addChild(block);
            }
            _ui = playStage;
        }
        return _ui;
    }

    private static function areaOfCollision(object1:DisplayObject, object2:DisplayObject, tolerance:int = 255):Rectangle {
        if (object1.hitTestObject(object2)) {
            var limits1:Rectangle = object1.getBounds(object1.parent);
            var limits2:Rectangle = object2.getBounds(object2.parent);
            var limits:Rectangle = limits1.intersection(limits2);
            limits.x = Math.floor(limits.x);
            limits.y = Math.floor(limits.y);
            limits.width = Math.ceil(limits.width);
            limits.height = Math.ceil(limits.height);
            if (limits.width < 1 || limits.height < 1) return null;

            var image:BitmapData = new BitmapData(limits.width, limits.height, false);
            var matrix:Matrix = object1.transform.concatenatedMatrix;
            matrix.translate(-limits.left, -limits.top);
            image.draw(object1, matrix, new ColorTransform(1, 1, 1, 1, 255, -255, -255, tolerance));
            matrix = object2.transform.concatenatedMatrix;
            matrix.translate(-limits.left, -limits.top);
            image.draw(object2, matrix, new ColorTransform(1, 1, 1, 1, 255, 255, 255, tolerance), BlendMode.DIFFERENCE);

            var intersection:Rectangle = image.getColorBoundsRect(0xFFFFFFFF, 0xFF00FFFF);
            if (intersection.width == 0) return null;
            intersection.offset(limits.left, limits.top);
            return intersection;
        }
        return null;
    }

}
}
