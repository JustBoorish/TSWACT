//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.BuffData;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.Log;
import com.GameInterface.WaypointInterface;
import com.Utils.Archive;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.StringUtils;
import com.tswact.BIcon;
import com.tswact.ConfigWindow;
import com.tswact.DebugWindow;
import com.tswact.TeamInfo;
import mx.utils.Delegate;

class com.tswact.Controller extends MovieClip
{
	private static var m_version:String = "3.1";
	private static var Folder:String = "FOLDER";
	private static var Version:String = "VERSION";
	private static var Show_Config:String = "SHOW_CONFIG";
	
	private var m_debug:DebugWindow;
	private var m_clientCharacter:Character;
	private var m_team:TeamInfo;
	private var m_combatChanged:Boolean;
	private var m_mc:MovieClip;
	private var m_evadeCounter:Number;
	private var m_icon:BIcon;
	private var m_archive:Archive;
	private var m_combatStart:Date;
	private var m_combatEnd:Date;
	private var m_abilityPos:Number;
	private var m_abilityId:Number;
	private var m_configWindow:ConfigWindow;
	
	//On Load
	private function onLoad():Void
	{
		m_mc = this;
		m_mc._visible = true;
		
		_root["tswact\\tswact"].OnModuleActivated = Delegate.create(this, OnModuleActivated);
		_root["tswact\\tswact"].OnModuleDeactivated = Delegate.create(this, OnModuleDeactivated);

		m_evadeCounter = 0;
		setTimeout(Delegate.create(this, DelayedStart), 1000);
	}

	function OnModuleActivated(config:Archive):Void
	{
		if (config == null)
		{
			m_archive = new Archive();
		}
		else
		{
			m_archive = config;
		}
		
		if (m_icon == null)
		{
			m_icon = new BIcon(m_mc, _root["tswact\\tswact"].ACTIcon, m_version, Delegate.create(this, ShowBrowser), Delegate.create(this, ShowConfig), Delegate.create(this, ToggleDebug), m_archive.FindEntry(BIcon.ICON_X, -1), m_archive.FindEntry(BIcon.ICON_Y, -1));
		}
		
		//DebugWindow.Log("TSWACT OnModuleActivated: " + m_archive.toString());
		SetIconConfig();
	}
	
	function OnModuleDeactivated():Archive
	{
		var pt:Object = m_icon.GetCoords();
		
		m_archive.DeleteEntry(Version);
		m_archive.AddEntry(Version, m_version);
		m_archive.DeleteEntry(BIcon.ICON_X);
		m_archive.AddEntry(BIcon.ICON_X, pt.x);
		m_archive.DeleteEntry(BIcon.ICON_Y);
		m_archive.AddEntry(BIcon.ICON_Y, pt.y);
		//DebugWindow.Log("TSWACT OnModuleDeactivated: " + m_archive.toString());
		return m_archive;
	}
	
	private function DelayedStart():Void
	{
		m_combatChanged = false;
		m_clientCharacter = Character.GetClientCharacter();

		if (m_debug == null)
		{
			if (m_clientCharacter != null && (m_clientCharacter.GetName() == "Boorish" || m_clientCharacter.GetName() == "Boor" || m_clientCharacter.GetName() == "BoorGirl"))
			{
				m_debug = DebugWindow.GetInstance(m_mc, DebugWindow.Debug, "TSWACTDebug");
			}
		}
		
		Log.Error("TSWACT", "TSWACT Loaded for |" + m_clientCharacter.GetName() + "|");
		DebugWindow.Log("TSWACT Loaded");
		
		m_team = new TeamInfo();
		m_team.SignalToggleCombat.Connect(onCombatChanged, this);	
		
		WaypointInterface.SignalPlayfieldChanged.Connect(WaypointChanged, this);
		m_clientCharacter.SignalCharacterAlive.Connect(WaypointChanged, this);
		m_clientCharacter.SignalCharacterTeleported.Connect(WaypointChanged, this);
		m_clientCharacter.SignalCharacterRevived.Connect(WaypointChanged, this);
		WaypointChanged();
	}
	
	private function SetIconConfig():Void
	{
		m_icon.SetShowConfig(GetShowConfig(m_archive));
	}
	
	private function onCombatChanged(inCombat:Boolean) {
		m_combatChanged = true;
		m_icon.SetHighlightVisible(inCombat);

		if (inCombat)
		{
			m_combatStart = new Date();
			m_combatEnd = null;
			
			var nameList:Array = new Array();
			nameList.push(m_clientCharacter.GetName());
			LogGroupEntry(inCombat, nameList);
		}
		else
		{
			if (TeamInterface.IsInRaid(m_clientCharacter.GetID()) || TeamInterface.IsInTeam(m_clientCharacter.GetID()))
			{
				LogGroupEntry(inCombat, m_team.GetGroupList());
			}
			else
			{
				var nameList:Array = new Array();
				nameList.push(m_clientCharacter.GetName());
				LogGroupEntry(inCombat, nameList);
			}
			
			if (m_combatStart != null)
			{
				m_combatEnd = new Date();
				SetDuration();
			}
		}
	}

	private function SetDuration():Void
	{
		if (m_combatStart != null && m_combatEnd != null)
		{
			var startMillis:Number = m_combatStart.getTime();
			var endMillis:Number = m_combatEnd.getTime();
			var durationStr:String = "";
			var duration:Number = Math.round((endMillis - startMillis) / 1000);
			if (duration > 0)
			{
				var mins:Number = Math.floor(duration / 60);
				var secs:Number = duration % 60;
				
				if (mins < 10)
				{
					durationStr = durationStr + "0";
				}
				
				durationStr = durationStr + mins + ":";
				
				if (secs < 10)
				{
					durationStr = durationStr + "0";
				}
				
				durationStr = durationStr + secs;
			}
			
			m_icon.SetDuration(durationStr);
		}			
	}
	
	private function LogGroupEntry(inCombat:Boolean, groupList:Array)
	{
		if (m_combatChanged)
		{
			m_combatChanged = false;
			
			if (inCombat)
			{
				Log.Error("TSWACT - Enter combat", GetGroupString(groupList) + GetBuffString() + "|");
			}
			else
			{
				Log.Error("TSWACT - Out of combat", GetGroupString(groupList));
			}
		}
	}
	
	private function GetGroupString(groupList:Array) : String
	{
		var ret:String;
		ret = "";
		
		for (var i:Number = 0; i < groupList.length; i++)
		{
			var str:String = String(groupList[i]);
			if (ret != "")
			{
				ret = ret + "|";
			}
			
			ret = ret + str;
		}
		
		return "|" + ret + "|";
	}
	
	private function WaypointChanged():Void
	{
		var playfield:Number = m_clientCharacter.GetPlayfieldID();
		if (playfield == null)
		{
			playfield = 0;
		}
		
		if (playfield > 0)
		{
			var name:String = LDBFormat.LDBGetText("Playfieldnames", playfield);
			Log.Error("TSWACT - Playfield", "|" + name + "|");
			DebugWindow.Log("Playfield " + playfield + " = " + name);
		}
		else
		{
			setTimeout(Delegate.create(this, WaypointChanged), 500);
		}
	}
	
	private function ShowBrowser():Void
	{
		var folder:String = GetFolder();
		if (folder == "")
		{
			ShowConfig();
		}
		else
		{
			if (DistributedValue.GetDValue("web_browser"))
			{
				DistributedValue.SetDValue("web_browser", false);
			}
			else
			{
				var newURL:String = "file:///" + folder + "/Scripts/Z_act.html";
				DistributedValue.SetDValue("WebBrowserStartURL", newURL);
				DistributedValue.SetDValue("web_browser", true);
			}
		}
	}
	
	private function GetFolder():String
	{
		var folder:String = m_archive.FindEntry(Folder, "");
		folder = folder.split(" ").join("%20");
		folder = folder.split("\\").join("/");
		folder = Trim(folder, "/");
		return folder;
	}
	
	public static function Trim(inStr:String, replStr:String):String
	{
		if (inStr == null)
		{
			return "";
		}
		
		var ret:String = inStr;
		while (ret.charAt(ret.length - 1) == replStr)
		{
			ret = ret.substr(0, ret.length - 1);
		}
		
		return ret;
	}
	
	private function ShowConfig():Void
	{
		if (m_configWindow != null)
		{
			m_configWindow.Unload();
		}

		var w:Number = 425;
		var h:Number = 260;
		m_configWindow = new ConfigWindow(this.m_mc, "TSWACT Configuration", Stage.width / 2 - w / 2, Stage.height / 2 - h / 2, w, Delegate.create(this, HideConfig), "ACTHelp", m_archive);
		m_configWindow.SetVisible(true);
	}
	
	private function HideConfig():Void
	{
		SetIconConfig();
		if (m_configWindow != null)
		{
			m_configWindow.Unload();
			m_configWindow = null;
		}
	}
	
	private function ToggleDebug():Void
	{
		DebugWindow.ToggleVisible();
	}
	
	private function GetBuffString():String
	{
		var ret:String = "Buffs";
		for(var prop in m_clientCharacter.m_BuffList)
		{
			var buffData:BuffData = BuffData(m_clientCharacter.m_BuffList[prop]);
			ret = ret + ":" + Trim(buffData.m_Name);
		}

		return ret;
	}
	
	private function GetArrayFromString(inArrayString:String):Array
	{
		if (inArrayString.indexOf("|") == -1)
		{
			var ret:Array = new Array();
			ret.push(inArrayString);
			return ret;
		}
		else
		{
			return inArrayString.split("|");
		}
	}
	
	private function GetArrayString(inArray:Array):String
	{
		var arrayString:String = "";
		for (var i:Number = 0; i < inArray.length; i++)
		{
			if (i > 0)
			{
				arrayString = arrayString + "|";
			}
			
			arrayString = arrayString + inArray[i];
		}
		
		return arrayString;
	}
	
	public static function GetShowConfig(archive:Archive):Boolean
	{
		return archive.FindEntry(Show_Config, true);
	}
	
	public static function SetShowConfig(archive:Archive, newConfig:Boolean):Void
	{
		if (newConfig != null)
		{
			archive.DeleteEntry(Show_Config);
			archive.AddEntry(Show_Config, newConfig);
		}
	}
	
	public static function GetGameFolder(archive:Archive):String
	{
		return archive.FindEntry(Folder, "");
	}
	
	public static function SetGameFolder(archive:Archive, newFolder:String):Void
	{
		if (newFolder != null)
		{
			archive.DeleteEntry(Folder);
			archive.AddEntry(Folder, StringUtils.Strip(newFolder));
		}
	}
}
