import com.GameInterface.Game.Character;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.Team;
import com.GameInterface.Game.Raid;
import com.GameInterface.Game.TeamInterface;
import com.tswact.CharacterWrapper;
import com.Utils.Signal;
import com.Utils.ID32;
import com.GameInterface.Log;
import com.tswact.DebugWindow;
import mx.utils.Delegate;
/**
 * ...
 * @author ...
 */
class com.tswact.TeamInfo
{
	private var m_character:CharacterWrapper;
	private var m_groupList:Array;
	private var m_inCombat:Boolean;
	private var m_combatCounter:Number;
	private var m_previousCombatants:String;
	private var m_timeout:Number;
	public var SignalToggleCombat:Signal;
	
	public function TeamInfo() 
	{
		m_character = new CharacterWrapper(Character.GetClientCharacter());
		m_inCombat = m_character.IsThreatened();
		m_previousCombatants = "";
		m_timeout = -1;
		SignalToggleCombat = new Signal();
		m_groupList = getEmptyGroupList();
		
		m_character.Connect();
		m_character.SignalToggleCombat.Connect(onClientCombatChanged, this);
		
		TeamInterface.SignalClientJoinedRaid.Connect(onJoinedRaid, this);
		TeamInterface.SignalClientJoinedTeam.Connect(onJoinedTeam, this);
	}

	public function Refresh()
	{
		if (TeamInterface.IsInRaid(m_character.GetID()) || TeamInterface.IsInTeam(m_character.GetID()))
		{
			TeamInterface.RequestTeamInformation();
		}
	}

	public function GetGroupList() : Array
	{
		var nameList:Array = new Array();
		
		for (var i:Number = 0; i < m_groupList.length; i++)
		{
			nameList.push(m_groupList[i].GetName());
		}
		
		return nameList;
	}
	
	private function ClearTimer():Void
	{
		if (m_timeout != -1)
		{
			clearInterval(m_timeout);
			m_timeout = -1;
		}
	}
	
	private function onClientCombatChanged(inCombat:Boolean):Void
	{
		//DebugWindow.Log("onClientCombatChanged m_inCombat=" + m_inCombat.toString() + " inCombat=" + inCombat.toString());
		if (inCombat == true)
		{
			ClearTimer();
			
			if (!m_inCombat)
			{
				if (TeamInterface.IsInRaid(m_character.GetID()) || TeamInterface.IsInTeam(m_character.GetID()))
				{
					Refresh();
				}

				m_inCombat = true;
				SignalToggleCombat.Emit(true);
				//DebugWindow.Log("onClientCombatChanged m_inCombat=" + m_inCombat.toString());
			}
		}
		else
		{
			if (m_inCombat)
			{
				StopCombat(m_character.GetName());
				m_timeout = setInterval(Delegate.create(this, StopCombat), 1000, m_character.GetName());
			}
		}
	}
	
	private function onCombatChanged(inCombat:Boolean, name:String):Void
	{
		//DebugWindow.Log("onCombatChanged " + name + " m_inCombat=" + m_inCombat.toString() + " inCombat=" + inCombat.toString());
		if (m_inCombat == true)
		{
			if (inCombat != true)
			{
				m_combatCounter = 0;
				StopCombat(name);
			}
		}
	}
	
	private function StopCombat(name:String):Void
	{
		if (m_inCombat == true)
		{
			//DebugWindow.Log("StopCombat " + name + " m_inCombat=false");
			m_inCombat = false;
			ClearTimer();
			SignalToggleCombat.Emit(false);
		}
	}

	private function onJoinedRaid(inRaid:Raid)
	{
		var newGroupList:Array = getEmptyGroupList();
        for (var prop in inRaid.m_Teams)
        {
			addTeamToGroupList(newGroupList, inRaid.m_Teams[prop]);
			if (isGroupListDifferent(newGroupList) == true)
			{
				//disconnectGroupList(m_groupList);
				m_groupList = newGroupList;
				//connectGroupList(m_groupList);
			}
		}
	}
	
	private function onJoinedTeam(inTeam:Team)
	{
		if (!TeamInterface.IsInRaid(m_character.GetID()))
		{
			var newGroupList:Array = getEmptyGroupList();
			addTeamToGroupList(newGroupList, inTeam);
			if (isGroupListDifferent(newGroupList) == true)
			{
				//disconnectGroupList(m_groupList);
				m_groupList = newGroupList;
				//connectGroupList(m_groupList);
			}
		}
	}

	private function getGroupInCombatCount():Number
	{
		if (m_groupList == null)
		{
			DebugWindow.Log("getGroupInCombatCount group list null");
		}
		if (m_groupList.length < 1)
		{
			DebugWindow.Log("getGroupInCombatCount group list length zero");
		}

		var ret:Number = 0;
		var combatStr:String = "";
		for (var i:Number = 0; i < m_groupList.length; i++)
		{
			var name:String = m_groupList[i].GetName();
			if (m_groupList[i].IsThreatened() == true && name != null && name.length > 0)
			{
				ret = ret + 1;
				combatStr = combatStr + " " + name;
			}
			else
			{
				if (name == null)
				{
					combatStr = combatStr + " name is null";
				}
				else if (name.length < 1)
				{
					combatStr = combatStr + " name is blank";
				}
				
				if (m_groupList[i] == null)
				{
					combatStr = combatStr + " m_groupList[i] is null " + i;
				}
				
				if (m_groupList[i].IsThreatened() == null)
				{
					combatStr = combatStr + " m_groupList[i].IsThreatened() is null " + i;
				}
				
			}
		}
		
		if (ret > 0)
		{
			DebugWindow.Log("isGroupInCombat " + combatStr);
		}
		else
		{
			DebugWindow.Log("isGroupInCombat out of combat " + combatStr);
		}

		return ret;
	}
	
	private function isGroupListDifferent(groupList:Array):Boolean
	{
		if (groupList.length != m_groupList.length)
		{
			return true;
		}
		
		var nameMap:Object = new Object();
		for (var i:Number = 0; i < m_groupList.length; i++)
		{
			nameMap[m_groupList[i].GetName()] = 1;
		}
		
		for (var i:Number = 0; i < groupList.length; i++)
		{
			if (nameMap[groupList[i].GetName()] != 1)
			{
				return true;
			}
		}
		
		return false;
	}
	
	private function getEmptyGroupList():Array
	{
		var groupList:Array = new Array();
		groupList.push(m_character);
		return groupList;
	}
	
	private function addTeamToGroupList(groupList:Array, inTeam:Team)
	{
		for (var i:Number = 0; i < 5; i++)
		{
			var member:ID32 = inTeam.GetTeamMemberID(i);
			if (!member.IsNull())
			{			
				var memberChar:Character = Character.GetCharacter(member);
				if (memberChar.GetName() != m_character.GetName())
				{
					groupList.push(new CharacterWrapper(memberChar));
				}
			}
		}
	}
	
	private function connectGroupList(groupList:Array):Void
	{
		for (var i:Number = 1; i < groupList.length; i++)
		{
			//groupList[i].SignalToggleCombat.Connect(onCombatChanged, this);
			groupList[i].Connect();
		}
	}

	private function disconnectGroupList(groupList:Array):Void
	{
		for (var i:Number = 1; i < groupList.length; i++)
		{
			//groupList[i].SignalToggleCombat.Disconnect(onCombatChanged, this);
			groupList[i].Disconnect();
		}
	}
}