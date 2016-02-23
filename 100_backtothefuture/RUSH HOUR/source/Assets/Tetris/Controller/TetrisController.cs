using UnityEngine;
using System.Collections;

public class TetrisController : MonoBehaviour {
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	//-------------------
	// const
	public const string PLAY_SOUND_MOVE_LEFT = "PlaySoundMoveLeft";
	public const string PLAY_SOUND_MOVE_RIGHT = "PlaySoundMoveRight";
	public const string PLAY_SOUND_ROTATE = "PlaySoundRotate";
	public const string HANDLE_GAME_OVER = "HandleHameOver";
	public const string HANDLE_RUSH_STARTED = "HandleRushStarted";
	public const string HANDLE_RUSH_ENDED = "HandleRushEnded";
	public const string READY_SPAWN_FIGURE = "ReadyToSpawnFigure";
	
	//-------------------
	// Editor connections
	public GameObject brickObject;
	public BlockController brickController;
	public GamePlayController gamePlayController;
	
	public void Restart()
	{
		gamePlayController.enabled = true;
		brickController.enabled = true;
		
		if (backgroundMusicSlow)
		{
			Destroy(backgroundMusicSlow.gameObject);
			backgroundMusicSlow = null;
		}
		
		if (backgroundMusicFast)
		{
			Destroy(backgroundMusicFast.gameObject);
			backgroundMusicFast = null;
		}
		
		gamePlayController.Reset();
		SpawnFigure();
	}
	
	//**************************************************************************
	//
	// MonoBehaviour
	//
	//**************************************************************************
	
	void Awake() 
	{
		gamePlayController = GetComponent<GamePlayController>();
		InitSound();
	}
	
	//--------------------------------------------------------------------------
	
	void Update() 
	{
		if (resetTimeScaleTime != 0 && Time.realtimeSinceStartup > resetTimeScaleTime && Time.timeScale < 1)
		{
			Time.timeScale = 1;
			resetTimeScaleTime = 0;
		} else if (Time.timeScale < 1)
		{
			return;
		}
		
		ProcessInput();
	}
	
	//--------------------------------------------------------------------------
	
	void OnDisable()
	{
		if (backgroundMusicSlow)
		{
			backgroundMusicSlow.Pause();
		}
		
		if (backgroundMusicFast)
		{
			backgroundMusicFast.Pause();
		}
	}
	
	//--------------------------------------------------------------------------
	
	void OnEnable()
	{
		if (backgroundMusicSlow)
		{
			backgroundMusicSlow.Play();
		}
		
		if (backgroundMusicFast)
		{
			backgroundMusicFast.Play();
		}
	}
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	private SoundPlaybackController backgroundMusicSlow;
	private SoundPlaybackController backgroundMusicFast;
	private SoundPlaybackController speedingSound;
	private float resetTimeScaleTime;
	private float lastMoveTime;
	private float lastFallDownTime;
	
	private void ProcessInput()
	{
		if (Input.GetKeyDown(KeyCode.Escape))
		{
			MenuHandler.Instance.ShowPause();
			return;
		}
		
		bool shouldMoveLeft = Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.A);
		bool shouldMoveRight = Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.D);
		float movePeriod = gamePlayController.isRushing ? 0.1f : 0.15f;
		bool timePassed = Time.time - lastMoveTime > movePeriod;
		
		if (timePassed && (Input.GetKey(KeyCode.LeftArrow) || Input.GetKey(KeyCode.A)))
		{
			shouldMoveLeft = true;
		}
		
		if (timePassed && (Input.GetKey(KeyCode.RightArrow) || Input.GetKey(KeyCode.D)))
		{
			shouldMoveRight = true;
		}
		
		if (shouldMoveLeft) 
		{
			lastMoveTime = Time.time;
			brickController.MoveToSide(-1);
		} else 
		if (shouldMoveRight) 
		{
			lastMoveTime = Time.time;
			brickController.MoveToSide(1);
		}
		
		bool fallDownTimeReached = Time.time - lastFallDownTime > 0.03f;
		if (fallDownTimeReached && (Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.DownArrow)))
		{
			brickController.FallDown();
			lastFallDownTime = Time.time;
			if (Input.GetKeyDown(KeyCode.S)) 
			{
				PlaySpeeding();
			}
		} else 
		{
			StopSpeeding();
		}
		
		if (Input.GetKeyDown(KeyCode.Space) || Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.W))
		{
			brickController.PerformAction();
		}
	}
	
	// Sent from BlockController
	private void ReadyToSpawnFigure()
	{
		SpawnFigure();
	}
	
	//--------------------------------------------------------------------------
	
	private void HandleRushStarted()
	{
		Time.timeScale = 0;
		resetTimeScaleTime = Time.realtimeSinceStartup + 2.0f;
		PlayFastMusic();
	}
	
	//--------------------------------------------------------------------------
	
	private void ResetTimeScale()
	{
		Time.timeScale = 1.0f;
	}
	
	//--------------------------------------------------------------------------
	
	private void HandleRushEnded()
	{
		PlaySlowMusic();
	}
	
	//--------------------------------------------------------------------------
	
	private void SpawnFigure()
	{
		brickController.SpawnFigure(gamePlayController.nextFigureType);
		gamePlayController.PrepareNextFigure();
	}
	
	//**************************************************************************
	// GameOver
	
	private void HandleHameOver()
	{
		if (PlayerPrefs.HasKey(TetrisConst.CONFIG_BEST_SCORE))
		{
			if (PlayerPrefs.GetInt(TetrisConst.CONFIG_BEST_SCORE) < gamePlayController.score)
			{
				PlayerPrefs.SetInt(TetrisConst.CONFIG_BEST_SCORE, gamePlayController.score);
			}
		} else {
			PlayerPrefs.SetInt(TetrisConst.CONFIG_BEST_SCORE, gamePlayController.score);
		}
		
		gamePlayController.enabled = false;
		brickController.enabled = false;
		Invoke("ShowGameOver", 1.0f);
	}
	
	//--------------------------------------------------------------------------
	
	private void ShowGameOver()
	{
		MenuHandler.Instance.ShowGameOverController(gamePlayController.score);
	}
	
	//**************************************************************************
	// Sound
	
	private void InitSound()
	{

	}
	
	//--------------------------------------------------------------------------
	
	private void PlaySlowMusic()
	{
		if (!backgroundMusicSlow)
		{
			backgroundMusicSlow = SoundPlayer.Instance.PlaySound(SoundConst.BACKGROUND_MUSIC_SLOW);
			backgroundMusicSlow.Volume = 1.0f;
			backgroundMusicSlow.Loop();
		} else 
		{
			if (backgroundMusicFast)
			{
				backgroundMusicFast.AnimateFade(0.3f, true);
				backgroundMusicFast = null;
			}
			backgroundMusicSlow.Play();
		}
	}
	
	//--------------------------------------------------------------------------
	
	private void PlayFastMusic()
	{
		if (backgroundMusicSlow)
		{
			backgroundMusicSlow.Pause();
		}
		
		backgroundMusicFast = SoundPlayer.Instance.PlaySound(SoundConst.BACKGROUND_MUSIC_RUSH);
		backgroundMusicFast.Volume = 1.0f;
		backgroundMusicFast.Loop();
	}
	
	//--------------------------------------------------------------------------
	
	private void PlaySoundMoveLeft()
	{
		SoundPlaybackController sound = SoundPlayer.Instance.PlaySound(SoundConst.MOVE_LEFT);
		sound.Volume = 0.55f;
	}
	
	//--------------------------------------------------------------------------
	
	private void PlaySoundMoveRight()
	{
		SoundPlaybackController sound = SoundPlayer.Instance.PlaySound(SoundConst.MOVE_RIGHT);
		sound.Volume = 0.55f;
	}
	
	//--------------------------------------------------------------------------
	
	private int currentRotationIndex = 0;
	private void PlaySoundRotate()
	{
		string soundName = currentRotationIndex == 0 ? SoundConst.ROTATE1 : SoundConst.ROTATE2;
		SoundPlaybackController sound = SoundPlayer.Instance.PlaySound(soundName);
		sound.Volume = 0.80f;
		currentRotationIndex = (currentRotationIndex + 1) % 2;
	}
	
	//--------------------------------------------------------------------------
	
	private void PlaySpeeding()
	{
		StopSpeeding();
		speedingSound = SoundPlayer.Instance.PlaySound(SoundConst.SPEEDING);
		speedingSound.Volume = 0.70f;
	}
	
	//--------------------------------------------------------------------------
	
	private void StopSpeeding()
	{
		if (speedingSound)
		{
			speedingSound.AnimateFade(0.5f, true);
			speedingSound = null;
		}
	}
	
}
