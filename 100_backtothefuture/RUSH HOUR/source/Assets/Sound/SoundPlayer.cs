using UnityEngine;
using System.Collections;

public class SoundPlayer : MonoBehaviour{
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	//-------------------
	// Editor connections
	
	// Put here all sounds that must be played
	public AudioClip[] clips;
	
	//**************************************************************************
	// Singleton
	
	public static SoundPlayer Instance { get { return instance; } }
	
	
	//**************************************************************************
	// Playback
	
	public SoundPlaybackController PlaySound(AudioClip clip)
	{
		GameObject go = new GameObject("Sound [" + clip.name + "]");
		go.transform.parent = transform;
		go.transform.position = Vector3.zero;
		
		AudioSource source = go.AddComponent<AudioSource>();
		source.clip = clip;
		source.Play();
		
		SoundPlaybackController controller = go.AddComponent<SoundPlaybackController>();
		controller.DieAfterTime(Time.realtimeSinceStartup + clip.length);
		
		return controller;
	}
	
	//--------------------------------------------------------------------------
	
	public SoundPlaybackController PlaySound(string name)
	{
		AudioClip clip = GetAudioClip(name);
		return PlaySound(clip);
	}

	//**************************************************************************
	// SoundQueue
	
	public SoundQueuePlayer CreateSoundQueuePlayer()
	{
		GameObject go = new GameObject("SoundQueuePlayer");
		SoundQueuePlayer player = go.AddComponent<SoundQueuePlayer>();
		go.transform.parent = transform;
		
		return player;
	}
	
	//**************************************************************************
	// Getting clips and their data
	
	public AudioClip GetAudioClip(string name)
	{
		if (!nameToClipHash.Contains(name))
		{
			throw new UnityException("Unknown sound key: " + name);
		}
		
		return (AudioClip)nameToClipHash[name];
	}
	
	//--------------------------------------------------------------------------
	
	public float GetClipLength(string name)
	{
		AudioClip clip = GetAudioClip(name);
		return clip.length;
	}
	
	//**************************************************************************
	//
	// MonoBehaviour
	//
	//**************************************************************************
	
	void Awake()
	{
		if (instance) throw new UnityException("SoundUtils already exists");
		instance = this;
		
		InitSounds();
	}
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	private static SoundPlayer instance;
	
	//-------------------
	// Name keys and AudioClip values
	private Hashtable nameToClipHash;
	
	//**************************************************************************
	// Initialization
	
	private void InitSounds()
	{
		nameToClipHash = new Hashtable();
		foreach (AudioClip clip in clips) 
		{
			nameToClipHash[clip.name] = clip;
		}
	}
}
