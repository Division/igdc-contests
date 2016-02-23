using UnityEngine;
using System.Collections;

public class IncreaseSoundPlayer : MonoBehaviour {

	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	public float resetDuration { get; set; }
	public string soundName { get; set; }
	public int startIndex { get; set; }
	public int endIndex { get; set; }
	public float volume { get; set; }
	
	public void Awake()
	{
		resetDuration = 0.444f;
		volume = 1.0f;
	}
	
	//--------------------------------------------------------------------------
	
	public void Play()
	{
		if (Time.time - lastPlayTime > resetDuration)
		{
			currentIndex = startIndex;
		}
		
		currentIndex = Mathf.Max(Mathf.Min(endIndex, currentIndex), startIndex);
		
		string soundToPlay = System.String.Format("{1}{0:00}", currentIndex, soundName); 
		SoundPlaybackController sound = SoundPlayer.Instance.PlaySound(soundToPlay);
		sound.Volume = volume;
		
		currentIndex++;
		lastPlayTime = Time.time;
	}
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	private float lastPlayTime;
	private int currentIndex;
	
}
