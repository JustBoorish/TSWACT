import com.Utils.Signal;
import GUI.TradePost.Views.PostalServiceView;
import org.aswing.ASFont;
import org.aswing.AttachIcon;
import org.aswing.Icon;
import org.aswing.JTextArea;
import org.aswing.JScrollPane;
import org.aswing.JFrame;
import mx.utils.Delegate;

/**
 * ...
 * @author ...
 */
class com.tswact.DebugWindow
{
	public static var Trace:Number = 1;
	public static var Debug:Number = 2;
	public static var Info:Number = 3;
	public static var Warning:Number = 4;
	public static var Error:Number = 5;
	
	public static function Log(level:Object, str:String):Void
	{
		if (_global["boodebug2"] != undefined && _global.boodebug["logsignal"] != undefined)
		{
			if (typeof(level) == "number")
			{
				_global.boodebug2.logsignal.Emit(level, str);
			}
			else
			{
				_global.boodebug2.logsignal.Emit(Debug, level);
			}
		}
	}
}