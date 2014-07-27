package core {
import flash.display.DisplayObject;
import flash.display.Sprite;

public class Ball extends Sprite{

    private var _radius : uint = 10;
    private var stepIncrement : uint = 10;
    private var x_delta : Number;
    private var y_delta : Number;

    public function get radius () : uint {
        return _radius;
    }
    public function Ball(BallSkin1Class:Class) {
        var skin : DisplayObject = new BallSkin1Class();
        addChild(skin);
    }
    public override function toString() : String{
        return "x:" + x + ", y:" + y + ", r:" + _radius;
    }

    public function stepLeft(stepIncrement:uint):void {
        x -= stepIncrement;
    }

    public function stepRight(stepIncrement:uint):void {
        x += stepIncrement;
    }

    public function move():void {
        x += x_delta;
        y += y_delta;
    }

    public function bounceFromRightBorder():void {
       x_delta = -stepIncrement;
    }

    public function bounceFromLeftBorder():void {
        x_delta = stepIncrement;
    }

    public function bounceFromBottomBorder():void {
        y_delta = -stepIncrement;
    }

    public function bounceFromTopBorder():void {
        y_delta = stepIncrement;
    }

    public function bounceFromBat(batHitPoint:Number):void {
        y_delta = -stepIncrement;
        x_delta = batHitPoint * stepIncrement;
    }

    public function bounceInit():void {
        x_delta = int(Math.random() * 10);
        y_delta = -stepIncrement;
    }

    public function bounceFromBlock(hitBlock:Block):void {
        var bounceDirection : int = (x - hitBlock.x > width / 2)? 1 : -1;
        x_delta = bounceDirection * stepIncrement;
        y_delta = bounceDirection * stepIncrement;
    }

    public function stop () : void {
        x_delta = 0;
        y_delta = 0;
    }
}
}
