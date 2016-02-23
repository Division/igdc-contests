using UnityEngine;
using System.Collections;

public abstract class SoundAnimation : MonoBehaviour
{
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	//**************************************************************************
	// initialization
	
	/**
	 * inStartTime should use real time instead of Time.time
	 */
	public void initialize(float inStartTime, float inDuration)
	{
		startTime = inStartTime;
		duration = inDuration;
	}
	
	//**************************************************************************
	//
	// MonoBehaviour
	//
	//**************************************************************************
	
	void Start()
	{
		audioController = GetComponent<SoundPlaybackController>();
	}
	
	//--------------------------------------------------------------------------
	
	void Update()
	{
		float currentTime = Time.realtimeSinceStartup;
		float animEndTime = startTime + duration;
		bool isInsideAnimationPeriod = (startTime <= currentTime) && ( currentTime <= animEndTime);
		
		if (isInsideAnimationPeriod)
		{
			float koef = Mathf.Clamp01((currentTime - startTime) / duration);
			doAnimation(koef);
		}
		
		if (currentTime > animEndTime)
		{
			Destroy(this);
		}
	}
	
	//**************************************************************************
	//
	// Protected
	//
	//**************************************************************************
	
	//-------------------
	// Animation data
	protected float startTime;
	protected float duration;
	protected bool independentTime;
	
	//-------------------
	// Audio source
	protected SoundPlaybackController audioController;
	
	
	//**************************************************************************
	// Animation process
	
	// Koef is changed between 0 and 1
	abstract protected void doAnimation(float koef);
	
}

