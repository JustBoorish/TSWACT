import com.tswact.Controller;
import com.tswact.Checkbox;
import com.tswact.Graphics;
import com.Utils.Archive;
import com.Utils.Text;
import com.GameInterface.DistributedValue;
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
class com.tswact.ConfigWindow
{
	private var m_parent:MovieClip;
	private var m_frame:MovieClip;
	private var m_name:String;
	private var m_closedCallback:Function;
	private var m_textFormat:TextFormat;
	private var m_maxWidth:Number;
	private var m_titleHeight:Number;
	private var m_maxHeight:Number;
	private var m_margin:Number;
	private var m_helpIcon:MovieClip;
	private var m_showConfigCheck:Checkbox;
	private var m_folder:TextField;
	private var m_archive:Archive;
	
	public function ConfigWindow(parent:MovieClip, title:String, x:Number, y:Number, width:Number, closedCallback:Function, helpIcon:String, archive:Archive)
	{
		m_name = title;
		m_parent = parent;
		m_closedCallback = closedCallback;
		m_archive = archive;
		m_frame = m_parent.createEmptyMovieClip(title + "ConfigWindow", m_parent.getNextHighestDepth());
		m_frame._visible = false;
		m_frame._x = x;
		m_frame._y = y;
		m_maxWidth = width;
		m_margin = 6;
		m_titleHeight = 60;
		m_maxHeight = (210 - m_titleHeight);
		
		m_textFormat = Graphics.GetTextFormat();
		
		DrawFrame(helpIcon);
	}
	
	public function Unload():Void
	{
		m_frame._visible = false;
		m_frame.removeMovieClip();
	}
	
	public function ToggleVisible():Void
	{
		SetVisible(!GetVisible());
	}
	
	public function SetVisible(visible:Boolean):Void
	{
		if (visible == true)
		{
			m_showConfigCheck.SetChecked(Controller.GetShowConfig(m_archive));
			m_folder.text = String(Controller.GetGameFolder(m_archive));
		}
		
		m_frame._visible = visible;
		
		if (visible != true)
		{
			Controller.SetShowConfig(m_archive, m_showConfigCheck.IsChecked());
			Controller.SetGameFolder(m_archive, m_folder.text);
			
			if (m_closedCallback != null)
			{
				m_closedCallback();
			}
		}
	}
	
	public function GetVisible():Boolean
	{
		return m_frame._visible;
	}
	
	public function GetCoords():Object
	{
		var pt:Object = new Object();
		pt.x = m_frame._x;
		pt.y = m_frame._y;
		return pt;
	}
	
	private function DrawFrame(helpIcon:String):Void
	{
		var radius:Number = 8;		
		var extents:Object = Text.GetTextExtent(m_name, m_textFormat, m_frame);
		
		var configWindow:MovieClip = m_frame;
		configWindow.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
		configWindow.beginFill(0x000000, 60);
		configWindow.moveTo(radius, 0);
		configWindow.lineTo((m_maxWidth-radius), 0);
		configWindow.curveTo(m_maxWidth, 0, m_maxWidth, radius);
		configWindow.lineTo(m_maxWidth, (m_maxHeight-radius));
		configWindow.curveTo(m_maxWidth, m_maxHeight, (m_maxWidth-radius), m_maxHeight);
		configWindow.lineTo(radius, m_maxHeight);
		configWindow.curveTo(0, m_maxHeight, 0, (m_maxHeight-radius));
		configWindow.lineTo(0, radius);
		configWindow.curveTo(0, 0, radius, 0);
		configWindow.endFill();
		
		var titleHeight:Number = extents.height + 8;
		configWindow.beginFill(0x000000, 100);
		configWindow.moveTo(radius, 0);
		configWindow.lineTo((m_maxWidth-radius), 0);
		configWindow.curveTo(m_maxWidth, 0, m_maxWidth, radius);
		configWindow.lineTo(m_maxWidth, titleHeight);
		configWindow.lineTo(0, titleHeight);
		configWindow.lineTo(0, radius);
		configWindow.curveTo(0, 0, radius, 0);
		configWindow.endFill();
		
		var tabText:TextField = configWindow.createTextField(m_name + "Text", configWindow.getNextHighestDepth(), 20, (titleHeight - extents.height) / 2, extents.width, extents.height);
		tabText.embedFonts = true;
		tabText.selectable = false;
		tabText.antiAliasType = "advanced";
		tabText.autoSize = true;
		tabText.border = false;
		tabText.background = false;
		tabText.setNewTextFormat(m_textFormat);
		tabText.text = m_name;
		
		var dragWindow:MovieClip = configWindow.createEmptyMovieClip(m_name + "DragWindow", configWindow.getNextHighestDepth());
		dragWindow.lineStyle(0, 0x000000, 0, true, "none", "square", "round");
		dragWindow.beginFill(0x000000, 0);
		dragWindow.moveTo(radius, 0);
		dragWindow.lineTo((m_maxWidth-radius), 0);
		dragWindow.curveTo(m_maxWidth, 0, m_maxWidth, radius);
		dragWindow.lineTo(m_maxWidth, (m_maxHeight-radius));
		dragWindow.curveTo(m_maxWidth, m_maxHeight, (m_maxWidth-radius), m_maxHeight);
		dragWindow.lineTo(radius, m_maxHeight);
		dragWindow.curveTo(0, m_maxHeight, 0, (m_maxHeight-radius));
		dragWindow.lineTo(0, radius);
		dragWindow.curveTo(0, 0, radius, 0);
		dragWindow.endFill();
		dragWindow.onPress = Delegate.create(this, function() { configWindow.startDrag(); } );
		dragWindow.onRelease = Delegate.create(this, function() { configWindow.stopDrag(); } );
		
		var buttonRadius:Number = 6.5;
		var buttonBack:MovieClip = configWindow.createEmptyMovieClip(m_name + "ButtonBack", configWindow.getNextHighestDepth());
		Graphics.DrawFilledCircle(buttonBack, buttonRadius, 0, 0, 0x848484, 100);
		buttonBack._x = m_maxWidth - buttonRadius * 2 - 15;
		buttonBack._y = titleHeight / 2 - buttonRadius;
		
		var buttonHover:MovieClip = buttonBack.createEmptyMovieClip(m_name + "ButtonHover", buttonBack.getNextHighestDepth());
		Graphics.DrawFilledCircle(buttonHover, buttonRadius, 0, 0, 0xFE2E2E, 80);
		buttonHover._alpha = 0;
		
		buttonBack.onRollOver = Delegate.create(this, function() { buttonHover._alpha = 0; Tweener.addTween(buttonHover, { _alpha:60, time:0.5, transition:"linear" } ); } );
		buttonBack.onRollOut = Delegate.create(this, function() { Tweener.removeTweens(buttonHover); buttonHover._alpha = 0; } );
		buttonBack.onPress = Delegate.create(this, function() { Tweener.removeTweens(buttonHover); buttonHover._alpha = 0; this.SetVisible(false); } );
		
		var crossRadius:Number = 3.5;
		var cross:MovieClip = buttonBack.createEmptyMovieClip(m_name + "ButtonCross", buttonBack.getNextHighestDepth());
		cross.lineStyle(2, 0xFFFFFF, 100, true, "none", "square", "round");
		cross.moveTo(buttonRadius - crossRadius, buttonRadius - crossRadius);
		cross.lineTo(buttonRadius + crossRadius, buttonRadius + crossRadius);
		cross.moveTo(buttonRadius + crossRadius, buttonRadius - crossRadius);
		cross.lineTo(buttonRadius - crossRadius, buttonRadius + crossRadius);
		
		if (helpIcon != null)
		{
			m_helpIcon = configWindow.attachMovie(helpIcon, "HelpIcon", configWindow.getNextHighestDepth());
			m_helpIcon._width = 14;
			m_helpIcon._height = 14;
			m_helpIcon._y = titleHeight / 2 - m_helpIcon._height / 2;
			m_helpIcon._x = buttonBack._x - m_helpIcon._width - 10;

			var helpHover:MovieClip = m_helpIcon.createEmptyMovieClip(m_name + "HelpHover", m_helpIcon.getNextHighestDepth());
			Graphics.DrawFilledCircle(helpHover, 6 / m_helpIcon._xscale * 100, 0, 0, 0x6bcdf0, 80);
			helpHover._alpha = 0;
		
			m_helpIcon.onRollOver = Delegate.create(this, function() { helpHover._alpha = 0; Tweener.addTween(helpHover, { _alpha:60, time:0.5, transition:"linear" } ); } );
			m_helpIcon.onRollOut = Delegate.create(this, function() { Tweener.removeTweens(helpHover); helpHover._alpha = 0; } );
			m_helpIcon.onPress = Delegate.create(this, function() { Tweener.removeTweens(helpHover); helpHover._alpha = 0; this.onHelpPress(); } );
		}
		
		var checkSize:Number = 10;
		var enabledText:String = "Show instructions on icon tooltip";
		var enabledExtents:Object = Text.GetTextExtent(enabledText, m_textFormat, configWindow);
		m_showConfigCheck = new Checkbox("EnabledCheck", configWindow, 20, titleHeight + 20 + enabledExtents.height / 2 - checkSize / 2, checkSize, null, true);
		Graphics.DrawText("EnabledLabel", configWindow, enabledText, m_textFormat, 30 + checkSize, titleHeight + 20, enabledExtents.width, enabledExtents.height);
		
		var intervalText:String = "SWL Game folder";
		var intervalExtents:Object = Text.GetTextExtent(intervalText, m_textFormat, configWindow);
		Graphics.DrawText("IntervalLabel", configWindow, intervalText, m_textFormat, 20, titleHeight + 30 + enabledExtents.height, intervalExtents.width, intervalExtents.height);

		m_folder = configWindow.createTextField("IntervalText", configWindow.getNextHighestDepth(), 30 + intervalExtents.width, titleHeight + 30 + enabledExtents.height, m_maxWidth - intervalExtents.width - 60, intervalExtents.height);
		m_folder.type = "input";
		m_folder.setNewTextFormat(m_textFormat);
		m_folder.setTextFormat(m_textFormat);
		m_folder.embedFonts = true;
		m_folder.selectable = true;
		m_folder.antiAliasType = "advanced";
		m_folder.autoSize = false;
		m_folder.border = true;
		m_folder.background = true;
		m_folder.textColor = 0xFFFFFF;
		m_folder.backgroundColor = 0x2E2E2E;
	}
	
	private function onHelpPress():Void
	{
		var newURL:String = "https://tswact.wordpress.com/installation/";
		DistributedValue.SetDValue("WebBrowserStartURL", newURL);
		DistributedValue.SetDValue("web_browser", true);
	}
}