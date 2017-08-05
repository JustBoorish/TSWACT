import com.tswact.DebugWindow;
import com.GameInterface.Game.Character;
import com.Utils.ID32;
import com.Utils.Signal;
import mx.utils.Delegate;
/**
 * ...
 * @author Boorish
 */
class com.tswact.CharacterWrapper
{
	public var SignalToggleCombat:Signal;
	private var m_character:Character;
	private var m_inCombat:Boolean;
	private var m_timeout:Number;
	
	public function CharacterWrapper(character:Character) 
	{
		m_character = character;
		m_inCombat = m_character.IsThreatened();
		m_timeout = -1;
		SignalToggleCombat = new Signal();
	}
	
	public function GetName():String
	{
		var name:String = m_character.GetName();
		if (name == null || name.length < 2)
		{
			name = "";
			m_inCombat = false;
		}
		
		return name;
	}
	
	public function GetCharacter():Character
	{
		return m_character;
	}
	
	public function GetID():ID32
	{
		return m_character.GetID();
	}
	
	public function IsThreatened():Boolean
	{
		var old:Boolean = m_inCombat;
		m_inCombat = m_inCombat && m_character.IsThreatened() && (m_character.IsDead() != true) && (m_character.IsGhosting() != true);
		var name:String = GetName();
		if (old != m_inCombat)
		{
			DebugWindow.Log("m_inCombat wrong for " + name + ". m_inCombat=" + old.toString() + " IsInCombat=" + m_character.IsInCombat().toString() + " IsDead=" + m_character.IsDead().toString() + " IsGhosting=" + m_character.IsGhosting().toString());
		}
		
		return m_inCombat;
	}
	
	public function Connect():Void
	{
		m_character.SignalToggleCombat.Connect(ToggleCombat, this);
		m_character.SignalCharacterAlive.Connect(AliveStopCombat, this);
		m_character.SignalCharacterDestructed.Connect(DestructedStopCombat, this);
		m_character.SignalCharacterTeleported.Connect(TeleportedStopCombat, this);
		m_character.SignalCharacterDied.Connect(DiedStopCombat, this);
		m_character.SignalCharacterRevived.Connect(RevivedStopCombat, this);
	}
	
	public function Disconnect():Void
	{
		m_character.SignalToggleCombat.Disconnect(ToggleCombat, this);
		m_character.SignalCharacterAlive.Disconnect(AliveStopCombat, this);
		m_character.SignalCharacterDestructed.Disconnect(DestructedStopCombat, this);
		m_character.SignalCharacterTeleported.Disconnect(TeleportedStopCombat, this);
		m_character.SignalCharacterDied.Disconnect(DiedStopCombat, this);
		m_character.SignalCharacterRevived.Disconnect(RevivedStopCombat, this);
	}
	
	private function AliveStopCombat():Void
	{
		StopCombat("Alive");
	}
	
	private function DestructedStopCombat():Void
	{
		StopCombat("Destructed");
	}
	
	private function TeleportedStopCombat():Void
	{
		StopCombat("Teleported");
	}
	
	private function DiedStopCombat():Void
	{
		StopCombat("Died");
	}
	
	private function RevivedStopCombat():Void
	{
		StopCombat("Revived");
	}
	
	private function ToggleCombat(inCombat:Boolean):Void
	{
		if (inCombat == true)
		{
			ClearTimeout();
			
			if (m_inCombat != true)
			{
				m_inCombat = true;
				SignalToggleCombat.Emit(true, GetName());
			}
		}
		else
		{
			StopCombat("ToggleCombat");
		}
	}
	
	private function StopCombat(reason:String):Void
	{
		if (m_inCombat)
		{
			ClearTimeout();
			m_timeout = setTimeout(Delegate.create(this, DelayedStopCombat), 1100, reason);
		}
	}
	
	private function DelayedStopCombat(reason:String):Void
	{
		if (m_inCombat)
		{
			m_inCombat = false;
			DebugWindow.Log("Stop combat for " + GetName() + " reason " + reason);
			SignalToggleCombat.Emit(false, GetName());
		}
	}
	
	private function ClearTimeout():Void
	{
		if (m_timeout != -1)
		{
			clearTimeout(m_timeout);
			m_timeout = -1;
		}
	}
}