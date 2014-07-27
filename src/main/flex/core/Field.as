package core {
import flash.display.Sprite;

public class Field extends Sprite {
    public function Field(FieldStageClassSkin:Class) {
        addChild(new FieldStageClassSkin());
    }
}
}
