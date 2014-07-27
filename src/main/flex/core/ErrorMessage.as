/**
 * Created with IntelliJ IDEA.
 * User: codein
 * Date: 7/27/14
 * Time: 12:40 PM
 * To change this template use File | Settings | File Templates.
 */
package core {
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

public class ErrorMessage extends Sprite{
    private var errorMessage : String;
    private var tf : TextField;
    public function ErrorMessage(message : String) {
        errorMessage = message;
        tf = new TextField();
        tf.width = 500;
        tf.defaultTextFormat = new TextFormat("arial", 12, 0xFFFF00);
        tf.text = errorMessage;
        addChild(tf);
    }
    public function set text(value : String):void {
        errorMessage = value;
        tf.text = errorMessage;
    }
}
}
