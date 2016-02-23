using UnityEngine;
using System.Collections.Generic;

public class SoundQueuePlayer : MonoBehaviour {
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	//**************************************************************************
	// Adding sounds to play
	
	// Sound will be played after delaySeconds from current moment
	public void AddSound(string name, float delaySeconds)
	{
		if (delaySeconds < 0) delaySeconds = 0;
		
		float length = SoundPlayer.Instance.GetClipLength(name);
		float timeToPlay = Time.time + delaySeconds;
		
		PlaySoundAtTime(name, timeToPlay);
		
		lastClipEndTime = timeToPlay + length;
		lastClipLength = length;
	}
	
	//--------------------------------------------------------------------------
	
	// sound will be played at time of end of previous sound + offsetSeconds
	public void AddSoundOffsetPrevious(string name, float offsetSeconds, bool overwriteEndTime)
	{
		float timeToPlay = lastClipEndTime + offsetSeconds;
		PlaySoundAtTime(name, timeToPlay);
		
		if (overwriteEndTime)
		{
			float length = SoundPlayer.Instance.GetClipLength(name);
			lastClipEndTime = timeToPlay + length;
			lastClipLength = length;
		}
	}
	
	//--------------------------------------------------------------------------
	
	public void AddSoundAfterPrevPartPlayed(string name, float prevPlayedPart, bool overwriteEndTime)
	{
		float lastClipStartTime = lastClipEndTime - lastClipLength;
		float timeToPlay = lastClipStartTime + lastClipLength * prevPlayedPart;
		
		PlaySoundAtTime(name, timeToPlay);
		
		if (overwriteEndTime)
		{
			float length = SoundPlayer.Instance.GetClipLength(name);
			lastClipEndTime = timeToPlay + length;
			lastClipLength = length;
		}
	}
	
	//**************************************************************************
	// Cancel
	
	public void Cancel()
	{
		soundsToPlay.Clear();
	}
	
	//**************************************************************************
	//
	// MonoBehaviour
	//
	//**************************************************************************
	
	void Awake()
	{
		lastClipEndTime = Time.time;
		soundsToPlay = new List<SoundItem>();
	}
	
	//--------------------------------------------------------------------------
	
	void FixedUpdate() 
	{
		for (int i = soundsToPlay.Count - 1; i >= 0; i--)
		{
			bool timeToPlay = soundsToPlay[i].startTime <= Time.time;
			if (timeToPlay)
			{
				SoundPlayer.Instance.PlaySound(soundsToPlay[i].soundName);
				soundsToPlay.RemoveAt(i);
			}
		}
		
		// Destroy when all sounds are played
		if (soundsToPlay.Count == 0)
		{
			Destroy(gameObject);
		}
	}
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	private float lastClipEndTime = 0;
	private float lastClipLength = 0;
	private List<SoundItem> soundsToPlay;
	
	//--------------------------------------------------------------------------
	
	private void PlaySoundAtTime(string sound, float time)
	{
		soundsToPlay.Add(new SoundItem(time, sound));
	}
	
	//**************************************************************************
	//
	// SoundItem
	//
	//**************************************************************************
	
	internal class SoundItem
	{
		public float startTime;
		public string soundName;
		
		public SoundItem(float inStartTime, string inSoundName)
		{
			startTime = inStartTime;
			soundName = inSoundName;
		}
	}
	
}
