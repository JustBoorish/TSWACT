import com.GameInterface.DistributedValue;
import com.GameInterface.Log;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;
import com.tswact.DebugWindow;
import com.tswact.IntervalCounter;
import mx.utils.Delegate;

/**
 * ...
 * @author ...
 * This code is based on the icon handling from TSWACT by Aedani, original code by Viper.  Thanks to Aedani and Viper.
 */
class com.tswact.BIcon
{
	public static var ICON_X:String = "ICON_X";
	public static var ICON_Y:String = "ICON_Y";
	private var m_parent:MovieClip;
	private var m_icon:MovieClip;
	private var m_highlight:MovieClip;
	private var m_tooltip:TooltipInterface;
	private var m_toggleVisibleFunc:Function;
	private var m_rightToggleVisibleFunc:Function;
	private var m_ctrlToggleVisibleFunc:Function;
	private var m_version:String;
	private var m_showConfig:Boolean;
	private var m_duration:String;
	private var m_dragging:Boolean;
	private var m_x:Number;
	private var m_y:Number;
	
	/* VTIO */

	// The two distributed values used for monitoring when VTIO is loaded and the open/close state of your option window.
	private var m_VTIOIsLoadedMonitor:DistributedValue;

	// Variables for checking if the compass is there
	private var m_CompassCheckTimer:IntervalCounter;

	// The add-on information string, separated into 5 segments.
	// First is the add-on name as it will appear in the Add-on Manager list.
	// Second is the developer name (your name).
	// Third is the current version number, choose any format you like.
	// Fourth is the distributed value used to open/close your option window. Can be undefined if you have no options.
	// Fifth is the path to your icon as seen in-game using Ctrl + Shift + F2 (the debug window). Can be undefined if you have no icon (this also means your add-on won't be slotable).
	private var VTIOAddonInfo_s:String;
	
	public function BIcon(parent:MovieClip, icon:MovieClip, version:String, toggleVisibleFunc:Function, rightToggleVisibleFunc:Function, ctrlToggleVisibleFunc:Function, x:Number, y:Number) 
	{
		if (icon == null)
		{
			DebugWindow.Log(DebugWindow.Error, "Icon null");
		}
		m_parent = parent;
		m_icon = icon;
		m_version = version;
		m_toggleVisibleFunc = toggleVisibleFunc;
		m_rightToggleVisibleFunc = rightToggleVisibleFunc;
		m_ctrlToggleVisibleFunc = ctrlToggleVisibleFunc;
		VTIOAddonInfo_s = "TSWACT|Boorish|" + m_version + "|VTIO_TSWACT|_root.tswact\\tswact.ACTIcon";
		m_showConfig = true;
		m_duration = "";
		m_dragging = false;

		if (x < 0 || x > Stage.width - 18)
		{
			m_x = -1;
		}
		else
		{
			m_x = x;
		}
		
		if (y < 0 || y > Stage.height - 18)
		{
			m_y = -1;
		}
		else
		{
			m_y = y;
		}
		
		onLoad();
	}
	
	private function onLoad():Void
	{
		// Setting up the VTIO loaded monitor.
		m_VTIOIsLoadedMonitor = DistributedValue.Create("VTIO_IsLoaded");
		m_VTIOIsLoadedMonitor.SignalChanged.Connect(SlotCheckVTIOIsLoaded, this);

		// Setting up your icon.
		m_icon._width = 18;
		m_icon._height = 18;
		m_icon.onRelease = Delegate.create(this, onRelease);
		m_icon.onRollOver = Delegate.create(this, onRollover);
		m_icon.onRollOut = Delegate.create(this, onRollout);
		m_icon.onMousePress = Delegate.create(this, onMousePress);
		
		if (m_x == -1 || m_y == -1)
		{
			m_CompassCheckTimer = new IntervalCounter("IconPosition", IntervalCounter.WAIT_MILLIS, IntervalCounter.MAX_ITERATIONS, Delegate.create(this, PositionIcon), Delegate.create(this, PositionOnCompassMissing), null, IntervalCounter.COMPLETE_ON_ERROR);
		}
		else
		{
			m_icon._x = m_x;
			m_icon._y = m_y;
		}

		// Check if VTIO is loaded (if it loaded before this add-on was).
		SlotCheckVTIOIsLoaded();
	}
	
	public function GetCoords():Object
	{
		var pt:Object = new Object();
		if (!m_VTIOIsLoadedMonitor.GetValue())
		{
			pt.x = m_icon._x;
			pt.y = m_icon._y;
		}
		else
		{
			pt.x = -1;
			pt.y = -1;
		}
		
		return pt;
	}
	
	private function onMousePress(buttonIndex:Number, clickCount:Number) : Void
	{
		if (m_tooltip != undefined)	m_tooltip.Close();
		DistributedValue.SetDValue("VTIO_TSWACT", !DistributedValue.GetDValue("VTIO_TSWACT"));
		if (buttonIndex == 1)
		{
			if (m_dragging != true)
			{
				m_toggleVisibleFunc();
			}
		}
		else if (buttonIndex == 2)
		{
			if (Key.isDown(Key.CONTROL))
			{
				m_ctrlToggleVisibleFunc();
			}
			else
			{
				if (Key.isDown(Key.SHIFT) && !m_VTIOIsLoadedMonitor.GetValue())
				{
					m_dragging = true;
					m_icon.startDrag();
				}
				else
				{
					m_rightToggleVisibleFunc();
				}
			}
		}
	}
	
	private function onRelease():Void
	{
		if (m_tooltip != undefined)	m_tooltip.Close();
		if (m_dragging == true)
		{
			m_dragging = false;
			m_icon.stopDrag();
			
		}
	}
	
	public function SetShowConfig(showConfig:Boolean):Void
	{
		m_showConfig = showConfig;
	}

	public function SetDuration(duration:String):Void
	{
		m_duration = duration;
	}
	
	public function SetHighlightVisible(visible:Boolean):Void
	{
		if (m_highlight == null)
		{
			CreateHighlight();
		}
		
		if (m_highlight != null)
		{
			m_highlight._visible = visible;
		}
	}
	
	private function CreateHighlight():Void
	{
		var parent:MovieClip;
		if (_root["tswact\\tswact"]["Icon"] != null)
		{
			parent = _root["tswact\\tswact"]["Icon"];
		}
		else if (_root["tswact\\tswact"]["ACTIcon"] != null)
		{
			parent = _root["tswact\\tswact"]["ACTIcon"];
		}
		if (parent == null)
		{
			return;
		}
		
		m_highlight = parent.createEmptyMovieClip("Highlight", parent.getNextHighestDepth());
		m_highlight.lineStyle(1, 0xFF0000, 100, true, "none", "square", "round");
		m_highlight.moveTo(0, 0);
		m_highlight.lineTo(32, 0);
		m_highlight.lineTo(32, 32);
		m_highlight.lineTo(0, 32);
		m_highlight.lineTo(0, 0);
	}

	private function onRollover():Void
	{
		if (m_dragging != true)
		{
			if (m_tooltip != undefined) m_tooltip.Close();
			var tooltipData:TooltipData = new TooltipData();
			tooltipData.AddAttribute("", "<font face='_StandardFont' size='13' color='#FF8000'><b>TSWACT v" + m_version + " by Boorish</b></font>");
			tooltipData.AddAttributeSplitter();
			
			tooltipData.AddAttribute("", "");
			tooltipData.AddAttribute("", "<font face='_StandardFont' size='12' color='#FFFFFF'>Last Fight Duration: " + m_duration + "</font>");
			
			if (m_showConfig)
			{
				tooltipData.AddAttribute("", "");
				tooltipData.AddAttribute("", "<font face='_StandardFont' size='12' color='#FFFFFF'>Left click:  Open/Close ACT results</font>");
				tooltipData.AddAttribute("", "<font face='_StandardFont' size='12' color='#FFFFFF'>Right click: Open/Close Config</font>");
			}
			
			tooltipData.m_Padding = 4;
			tooltipData.m_MaxWidth = 210;
			m_tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, 0, tooltipData);
		}
	}
	
	private function onRollout():Void
	{
		if (m_tooltip != undefined)	m_tooltip.Close();
	}

	// The compass check function.
	// The compass check function.
	private function PositionIcon():Boolean
	{
		var finish:Boolean = false;
		if (m_dragging == true)
		{
			finish = true;
		}
		else
		{
			if (_root.compass != undefined && _root.compass._x != undefined && _root.compass._x > 0) {
				var myPoint:Object = new Object();
				myPoint.x = _root.compass._x - 270;
				myPoint.y = _root.compass._y + 0;
				_root.localToGlobal(myPoint);
				_root.boobuilds.globalToLocal(myPoint);
				m_icon._x = myPoint.x;
				m_icon._y = myPoint.y;
				finish = true;
			}
		}
		
		return finish;
	}
	
	private function PositionOnCompassMissing(isError:Boolean):Void
	{
		if (isError == true)
		{
			m_icon._x = Stage.width / 4 + 30;
			m_icon._y = 2;
		}
	}


	// The function that checks if VTIO is actually loaded and if it is sends the add-on information defined earlier.
	// This function will also get called if VTIO loads after your add-on. Make sure not to remove the check for seeing if the value is actually true.
	private function SlotCheckVTIOIsLoaded():Void
	{
		if (m_VTIOIsLoadedMonitor.GetValue())
			DistributedValue.SetDValue("VTIO_RegisterAddon", VTIOAddonInfo_s);
	}
	
}
