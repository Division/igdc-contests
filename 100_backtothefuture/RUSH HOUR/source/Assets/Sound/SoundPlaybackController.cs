using UnityEngine;
using System.Collections;

public class SoundPlaybackController : MonoBehaviour
{
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	public const float DEFAULT_VOLUME = 0.93f;
	
	//-------------------
	// properties
	
	public float Volume 
	{
		get
		{
			return volume;
		}
		
		set
		{
			volume = Mathf.Clamp01(value);
			UpdateVolume();
		}
	}
	
	//**************************************************************************
	// Getting/setting data
	
	public float Length
	{
		get {
			AudioSource source = this.AudioSource;
			return source.clip.length;
		}
	}
	
	//--------------------------------------------------------------------------
	
	public AudioSource AudioSource
	{
		get {
			if (!audioSource)
			{
				audioSource = GetComponent<AudioSource>();
			}
			
			return audioSource;
		}
	}
	
	//**************************************************************************
	// Playback methods
	
	// Cancels die after time. If you want loop for some time call setDieTime()
	public void Loop()
	{
		needDieAfterTime = false;
		AudioSource source = this.AudioSource;
		source.loop = true;
	}
	
	//--------------------------------------------------------------------------
	
	// If called sound will be played after play method called
	public void DelayPlayback()
	{
		AudioSource source = this.AudioSource;
		source.playOnAwake = false;
	}
	
	//--------------------------------------------------------------------------
	
	public void Play()
	{
		AudioSource source = this.AudioSource;
		source.Play();
	}
	
	//--------------------------------------------------------------------------
	
	public void Pause()
	{
		AudioSource source = this.AudioSource;
		source.Pause();
	}
	
	//**************************************************************************
	// Initialization
	
	public void DieAfterTime(float time)
	{
		dieTime = time;
		needDieAfterTime = true;
	}
	
	//**************************************************************************
	// Animation
	
	public void AnimateFade(float duration, bool dieAfterFade)
	{
		SoundAnimationFade fade = gameObject.AddComponent<SoundAnimationFade>();
		fade.initialize(Time.realtimeSinceStartup, duration);
		
		if (dieAfterFade)
		{
			Die(duration);
		}
	}
	
	//--------------------------------------------------------------------------
	
	public void AnimateGrow()
	{
		
	}
	
	//**************************************************************************
	// Death
	
	public void Die()
	{
		Die(0);
	}
	
	//--------------------------------------------------------------------------
	
	public void Die(float afterTime)
	{
		dieTime = Time.realtimeSinceStartup + afterTime;
		needDieAfterTime = true;
	}
	
	//**************************************************************************
	//
	// MonoBehaviour
	//
	//**************************************************************************
	
	// Use this for initialization
	void Awake ()
	{
		needDieAfterTime = true;
		Volume = DEFAULT_VOLUME;
	}
	
	//--------------------------------------------------------------------------
	
	void Update ()
	{
		bool needDieNow = false;
		if (needDieAfterTime &&  (Time.realtimeSinceStartup > dieTime) ) needDieNow = true;
		
		if (needDieNow)
		{
			Destroy(gameObject);
			return;
		}
	}
	
	//--------------------------------------------------------------------------
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	//-------------------
	// Death params
	private float dieTime;
	private bool needDieAfterTime;
	private float interruptTime;
	
	//-------------------
	// Playback params
	private float volume = 1; // [0..1] This volume is multiplied by current volume settings to get real volume
	
	//-------------------
	// AudioSource
	private AudioSource audioSource = null; // Use getAudioSource() method instead of this ivar
	
	//**************************************************************************
	// Volume configuration
	
	private void UpdateVolume()
	{
		float cfgVolume = getVolumeCfgValue();
		float realVolume =  cfgVolume * volume;
		this.AudioSource.volume = realVolume;
	}
	
	//--------------------------------------------------------------------------
	
	private float getVolumeCfgValue()
	{
		float cfgVolume = 1;
		
		return cfgVolume;
	}
}

