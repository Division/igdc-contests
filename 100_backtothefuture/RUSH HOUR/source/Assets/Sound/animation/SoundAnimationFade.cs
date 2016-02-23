using UnityEngine;
using System.Collections;

public class SoundAnimationFade : SoundAnimation
{

	//**************************************************************************
	//
	// Protected
	//
	//**************************************************************************
	
	override protected void doAnimation(float koef)
	{
		float volume = 1 - koef;
		audioController.Volume = volume;
	}
	
}

