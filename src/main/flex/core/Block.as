package core {
import flash.display.DisplayObject;
import flash.display.Sprite;

public class Block extends Sprite {
    private var _hited : Boolean = false;
    public function get hited () : Boolean {
        return _hited;
    }
    public function set hited (value : Boolean) : void {
        _hited = value;
    }
    public function Block(BlockSkinClass : Class) {
        var skin : DisplayObject = new BlockSkinClass();
        addChild(skin);
    }
    public override function toString () : String {
        return "x: " + x + ", y: " + y + ", w: " + width + ", h: " + height;
    }
    public function collapse():void {
        _hited = true;
        if(parent != null){
            parent.removeChild(this);
        }
    }
}
}
