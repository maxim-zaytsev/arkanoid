package core {
import flash.display.DisplayObject;
import flash.display.Sprite;

public class Bat extends  Sprite{

    private var _stepIncrement : int = 20;

    public function Bat(SkinClass : Class) {
        var skin : DisplayObject = new SkinClass();
        addChild(skin);
    }
    public override function toString() : String{
        return "x:" + x + ", y:" + y + ", w:" + width + ", h:" + height;
    }
    public function stepLeft() :void {
        x -= _stepIncrement;
    }
    public function stepRight () : void {
        x += _stepIncrement;
    }

    public function get stepIncrement () : uint {
        return _stepIncrement;
    }

    public function testIfRightSide(batHitPoint:Number):Boolean {
        return batHitPoint > width / 2;
    }
}
}
