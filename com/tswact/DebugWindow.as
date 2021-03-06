import com.tswact.DebugWindow;
import com.tswact.Graphics;
import com.Utils.Text;
import caurina.transitions.Tweener;
import mx.utils.Delegate;
/**
 * There is no copyright on this code
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 * LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
 * NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * Author: Boorish
 */
class com.tswact.DebugWindow
{
	private static var m_instance:DebugWindow = null;
	
	private var m_debug:MovieClip;
	private var m_textArea:TextField;
	private var m_textFormat:TextFormat;
	private var m_logLevel:Number;
	private var m_text:String;
	
	public static var Trace:Number = 1;
	public static var Debug:Number = 2;
	public static var Info:Number = 3;
	public static var Warning:Number = 4;
	public static var Error:Number = 5;
	
	private function DebugWindow(parent:MovieClip, logLevel:Number, inName:String) 
	{
		var name:String = inName;
		if (name == null)
		{
			name = "BooDebug3";
		}
		
		m_logLevel = logLevel;
		
		m_debug = parent.createEmptyMovieClip(name, parent.getNextHighestDepth());
		m_debug._visible = false;
		m_debug._x = 0;
		m_debug._y = 25;
		m_debug._alpha = 60;
		
		m_text = "";
		m_textFormat = Graphics.GetTextFormat();
		var w:Number = 625;
		var h:Number = 320;			
		DrawFrame(name, w, h);		
	}

	public static function GetInstance(parent:MovieClip, logLevel:Number, inName:String):DebugWindow
	{
		if (m_instance == null)
		{
			m_instance = new DebugWindow(parent, logLevel, inName);
		}
		
		return m_instance;
	}
	
	public static function Log(level:Object, str:String):Void
	{
		if (m_instance != null)
		{
			if (typeof(level) == "number")
			{
				m_instance.LogMsg(Number(level), str);
			}
			else
			{
				m_instance.LogMsg(Debug, String(level));
			}
		}
	}
	
	public static function SetVisible(visible:Boolean):Void
	{
		if (m_instance != null)
		{
			m_instance.SetDebugVisible(visible);
		}
	}
	
	public static function ToggleVisible():Void
	{
		if (m_instance != null)
		{
			m_instance.SetDebugVisible(!m_instance.GetDebugVisible());
		}
	}
	
	private function LogMsg(logLevel:Number, str:String):Void
	{
		if (logLevel >= m_logLevel)
		{
			m_text = GetDate() + "  " + str + "\n" + m_text.substring(0, 10000);
			if (m_debug._visible == true)
			{
				m_textArea.text = m_text;
			}
		}
	}
	
	private function SetDebugVisible(visible:Boolean):Void
	{
		if (visible == true)
		{
			m_textArea.text = m_text;
		}
		
		m_debug._visible = visible;
	}
	
	private function GetDebugVisible():Boolean
	{
		return m_debug._visible;
	}
	
	private function GetDate():String
	{
		var d:Date = new Date();
		return AddZero(d.getHours()) + ":" + AddZero(d.getMinutes()) + ":" + AddZero(d.getSeconds());
	}
	
	private function AddZero(inVal:Number):String
	{
		if (inVal < 10)
		{
			return "0" + inVal.toString();
		}
		else
		{
			return inVal.toString();
		}
	}
	
	private function DrawFrame(name:String, maxWidth:Number, maxHeight:Number):Void
	{
		var radius:Number = 8;		
		var extents:Object = Text.GetTextExtent(name, m_textFormat, m_debug);
		
		var configWindow:MovieClip = m_debug;
		configWindow.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
		configWindow.beginFill(0x000000, 60);
		configWindow.moveTo(radius, 0);
		configWindow.lineTo((maxWidth-radius), 0);
		configWindow.curveTo(maxWidth, 0, maxWidth, radius);
		configWindow.lineTo(maxWidth, (maxHeight-radius));
		configWindow.curveTo(maxWidth, maxHeight, (maxWidth-radius), maxHeight);
		configWindow.lineTo(radius, maxHeight);
		configWindow.curveTo(0, maxHeight, 0, (maxHeight-radius));
		configWindow.lineTo(0, radius);
		configWindow.curveTo(0, 0, radius, 0);
		configWindow.endFill();
		
		var titleHeight:Number = extents.height + 8;
		configWindow.beginFill(0x000000, 100);
		configWindow.moveTo(radius, 0);
		configWindow.lineTo((maxWidth-radius), 0);
		configWindow.curveTo(maxWidth, 0, maxWidth, radius);
		configWindow.lineTo(maxWidth, titleHeight);
		configWindow.lineTo(0, titleHeight);
		configWindow.lineTo(0, radius);
		configWindow.curveTo(0, 0, radius, 0);
		configWindow.endFill();
		
		var tabText:TextField = configWindow.createTextField("DebugText", configWindow.getNextHighestDepth(), 20, (titleHeight - extents.height) / 2, extents.width, extents.height);
		tabText.embedFonts = true;
		tabText.selectable = false;
		tabText.antiAliasType = "advanced";
		tabText.autoSize = true;
		tabText.border = false;
		tabText.background = false;
		tabText.setNewTextFormat(m_textFormat);
		tabText.text = name;
		
		m_textArea = configWindow.createTextField("DebugTextArea", configWindow.getNextHighestDepth(), 10, titleHeight + 10, maxWidth - 20, maxHeight - 20 - titleHeight);
		m_textArea.type = "input";
		m_textArea.setNewTextFormat(m_textFormat);
		m_textArea.setTextFormat(m_textFormat);
		m_textArea.wordWrap = true;
		m_textArea.multiline = true;
		m_textArea.embedFonts = true;
		m_textArea.selectable = true;
		m_textArea.antiAliasType = "advanced";
		m_textArea.autoSize = false;
		m_textArea.border = true;
		m_textArea.background = false;
		m_textArea.textColor = 0xFFFFFF;
		
		var buttonRadius:Number = 6.5;
		var buttonBack:MovieClip = configWindow.createEmptyMovieClip("DebugButtonBack", configWindow.getNextHighestDepth());
		Graphics.DrawFilledCircle(buttonBack, buttonRadius, 0, 0, 0x848484, 100);
		buttonBack._x = maxWidth - buttonRadius * 2 - 15;
		buttonBack._y = titleHeight / 2 - buttonRadius;
		
		var buttonHover:MovieClip = buttonBack.createEmptyMovieClip("DebugButtonHover", buttonBack.getNextHighestDepth());
		Graphics.DrawFilledCircle(buttonHover, buttonRadius, 0, 0, 0xFE2E2E, 80);
		buttonHover._alpha = 0;
		
		buttonBack.onRollOver = Delegate.create(this, function() { buttonHover._alpha = 0; Tweener.addTween(buttonHover, { _alpha:60, time:0.5, transition:"linear" } ); } );
		buttonBack.onRollOut = Delegate.create(this, function() { Tweener.removeTweens(buttonHover); buttonHover._alpha = 0; } );
		buttonBack.onPress = Delegate.create(this, function() { Tweener.removeTweens(buttonHover); buttonHover._alpha = 0; configWindow._visible = false; } );
		
		var crossRadius:Number = 3.5;
		var cross:MovieClip = buttonBack.createEmptyMovieClip("DebugButtonCross", buttonBack.getNextHighestDepth());
		cross.lineStyle(2, 0xFFFFFF, 100, true, "none", "square", "round");
		cross.moveTo(buttonRadius - crossRadius, buttonRadius - crossRadius);
		cross.lineTo(buttonRadius + crossRadius, buttonRadius + crossRadius);
		cross.moveTo(buttonRadius + crossRadius, buttonRadius - crossRadius);
		cross.lineTo(buttonRadius - crossRadius, buttonRadius + crossRadius);
	}
}