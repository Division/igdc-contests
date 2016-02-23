using UnityEngine;
using System.Collections.Generic;

public class GamePlayController : MonoBehaviour {
	
	//**************************************************************************
	//
	// WaveProps
	//
	//**************************************************************************
	
	private class WaveProps
	{
		public float timeBeforeRush;
		public float rushDuration;
		public int bombsOnStart;
		public int waveIndex;
		public float fallInterval;
		
		public WaveProps(float inTimeBeforeRush, float inRushDuration, float inFallInterval, int inBombsOnStart, int inWaveIndex)
		{
			timeBeforeRush = inTimeBeforeRush;
			rushDuration = inRushDuration;
			bombsOnStart = inBombsOnStart;
			waveIndex = inWaveIndex;
			fallInterval = inFallInterval;
		}
	}
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	//-------------------
	// Const
	public const string HANDLE_ROWS_CLEARED = "HandleRowsCleared";
	public const float MIN_FALL_INTERVAL = 0.015f;
	public const float MAX_FALL_INTERVAL = 0.5f;
	
	//-------------------
	// Editor connections
	public BlockController blockController;
	public InGameUI gameUI;
	
	//-------------------
	// Properties
	public bool isRushing { get; set; }
	public int currentWaveIndex { get; set; }
	public int figuresSpawned { get; set; }
	public int score { get; set; }
	public System.Type nextFigureType { get; set; }
	
	public void Reset()
	{
		blockController.Reset();
		isRushing = false;
		figuresSpawned = 0;
		score = 0;
		currentWave = waveProps[0];
		waveStartTime = Time.time;
		PrepareNextFigure();
		currentWaveIndex = 0-1;
		//currentWaveIndex = 12;
		ApplyNextWave();
	}
	
	//--------------------------------------------------------------------------
	
	public void PrepareNextFigure()
	{
		nextFigureType = GetNextFigure();
		gameUI.UpdateNextFigure(nextFigureType);
	}
	
	//**************************************************************************
	//
	// MonoBehaviour
	//
	//**************************************************************************
	
	void Awake()
	{
		InitWaveProps();
		InitFigures();
	}
	
	//--------------------------------------------------------------------------
	
	void Update()
	{
		if (!blockController.enabled)
		{
			return;
		}
		
		UpdateState();
		UpdateUI();
	}
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	private int bonusBombsSpawned;
	private List<WaveProps> waveProps;
	private WaveProps currentWave;
	private System.Type[] allFigures;
	private System.Type[] basicFigures;
	private System.Type[] basicAndPointFigures;
	private System.Type[] basicAndPointAndShooterFigures;
	private System.Type[] pointOnlyFigures;
	private System.Type[] shooterOnlyFigures;
	private System.Type[] zigZagOnlyFigures;
	private System.Type[] gOnlyFigures;
	private System.Type[] quadOnlyFigures;
	private System.Type[] bombsOnlyFigures;
	private float waveStartTime;
	
	//**************************************************************************
	// Init
	
	private void InitWaveProps()
	{
 		waveProps = new List<WaveProps>();
		WaveProps prop;
		
		prop = new WaveProps(20, 10, 0.11f, 0, 0);
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 15, 0.09f, 0, 1); // Points
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 15, 0.12f, 0, 2);
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 10, 0.08f, 0, 3); // Shooter
		waveProps.Add(prop);
		
		prop = new WaveProps(5, 15, 0.08f, 0, 4);
		waveProps.Add(prop);
		
		prop = new WaveProps(10, 8, 0.10f, 0, 5); // Bombs
		waveProps.Add(prop);
		
		prop = new WaveProps(30, 10, 0.07f, 0, 6);
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 15, 0.12f, 1, 7); // Quad Figure
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 15, 0.10f, 1, 8); // Bombs
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 15, 0.1f, 0, 9); // L figure
		waveProps.Add(prop);
		
		prop = new WaveProps(25, 4, 0.045f, 0, 10); // FAST
		waveProps.Add(prop);
		
		prop = new WaveProps(35, 15, 0.09f, 0, 11); // Z figure
		waveProps.Add(prop);
		
		prop = new WaveProps(30, 13, 0.07f, 0, 12); // BOMBS
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 35, 0.09f, 0, 13); // Long
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 15, 0.07f, 0, 14);
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 20, 0.1f, 0, 16); // Points
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 15, 0.07f, 2, 17); 
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 20, 0.07f, 0, 20); // Bombs
		waveProps.Add(prop);
		
		prop = new WaveProps(20, 10, 0.06f, 1, 21);
		waveProps.Add(prop);

		prop = new WaveProps(5, 5, 0.06f, 0, 23); // Z figure
		waveProps.Add(prop);

		prop = new WaveProps(5, 5, 0.06f, 0, 24); // L figure
		waveProps.Add(prop);
		
		prop = new WaveProps(5, 5, 0.06f, 0, 25); // Quad figure
		waveProps.Add(prop);
		
		prop = new WaveProps(5, 17, 0.09f, 0, 26); // Bombs
		waveProps.Add(prop);
		
		prop = new WaveProps(50, 20, 0.08f, 0, 27);
		waveProps.Add(prop);
		
		prop = new WaveProps(50, 15, 0.08f, 3, 28);
		waveProps.Add(prop);
	}
	
	//--------------------------------------------------------------------------
	
	private void InitFigures()
	{
		allFigures = new System.Type[]
		{
			typeof(PlankFigure),typeof(PlankFigure), typeof(PlankFigure), typeof(PlankFigure), 
			typeof(QuadFigure),typeof(QuadFigure),typeof(QuadFigure),typeof(QuadFigure),
			typeof(PiercingPointFigure),typeof(PiercingPointFigure),
			typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),
			typeof(VerticalBombFigure),
			typeof(BlockShooter),typeof(BlockShooter),
			typeof(ZigZagLeftFigure),typeof(ZigZagLeftFigure),
			typeof(ZigZagRightFigure),typeof(ZigZagRightFigure),
			typeof(FigureGLeft),typeof(FigureGLeft),
			typeof(FigureGRight),typeof(FigureGRight),
		};
		
		basicFigures = new System.Type[]
		{
			typeof(PlankFigure),typeof(PlankFigure), typeof(PlankFigure), typeof(PlankFigure), 
			typeof(QuadFigure),typeof(QuadFigure),typeof(QuadFigure),typeof(QuadFigure),
			typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),
			typeof(ZigZagLeftFigure),typeof(ZigZagLeftFigure),
			typeof(ZigZagRightFigure),typeof(ZigZagRightFigure),
			typeof(FigureGLeft),typeof(FigureGLeft),
			typeof(FigureGRight),typeof(FigureGRight),
		};
		
		basicAndPointFigures = new System.Type[]
		{
			typeof(PlankFigure),typeof(PlankFigure), typeof(PlankFigure), typeof(PlankFigure), 
			typeof(QuadFigure),typeof(QuadFigure),typeof(QuadFigure),typeof(QuadFigure),
			typeof(PiercingPointFigure),typeof(PiercingPointFigure),
			typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),
			typeof(ZigZagLeftFigure),typeof(ZigZagLeftFigure),
			typeof(ZigZagRightFigure),typeof(ZigZagRightFigure),
			typeof(FigureGLeft),typeof(FigureGLeft),
			typeof(FigureGRight),typeof(FigureGRight),
		};
		
		basicAndPointAndShooterFigures = new System.Type[]
		{
			typeof(PlankFigure),typeof(PlankFigure), typeof(PlankFigure), typeof(PlankFigure), 
			typeof(QuadFigure),typeof(QuadFigure),typeof(QuadFigure),typeof(QuadFigure),
			typeof(PiercingPointFigure),typeof(PiercingPointFigure),
			typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),typeof(DoubleAngleFigure),
			typeof(BlockShooter),typeof(BlockShooter),
			typeof(ZigZagLeftFigure),typeof(ZigZagLeftFigure),
			typeof(ZigZagRightFigure),typeof(ZigZagRightFigure),
			typeof(FigureGLeft),typeof(FigureGLeft),
			typeof(FigureGRight),typeof(FigureGRight),
		};
		
		
		pointOnlyFigures = new System.Type[] { typeof(PiercingPointFigure) };
		shooterOnlyFigures = new System.Type[] { typeof(BlockShooter) };
		zigZagOnlyFigures = new System.Type[] { typeof(ZigZagLeftFigure), typeof(ZigZagRightFigure) };
		gOnlyFigures = new System.Type[] { typeof(FigureGLeft), typeof(FigureGRight) };
		quadOnlyFigures = new System.Type[] { typeof(QuadFigure) };
		bombsOnlyFigures = new System.Type[] { typeof(VerticalBombFigure) };
	}
	
	//**************************************************************************
	// State
	
	private void UpdateState()
	{
		if (isRushing)
		{
			int timeRemaining = GetRushRemainingTime();
			if (timeRemaining <= 0)
			{
				ApplyNextWave();
			}
		} 
		else {
			int timeRemaining = GetTimeBeforeRush();
			if (timeRemaining <= 0)
			{
				ApplyRushState();
			}
		}
	}
	
	//--------------------------------------------------------------------------
	
	private void ApplyRushState()
	{
		isRushing = true;
		blockController.fallInterval = GetFallInterval();
		BroadcastMessage(TetrisController.HANDLE_RUSH_STARTED);
	}
	
	//--------------------------------------------------------------------------
	
	private void ApplyNextWave()
	{
		bonusBombsSpawned = 0;
		waveStartTime = Time.time;
		isRushing = false;
		currentWaveIndex++;
		
		currentWave = waveProps[0];
		
		foreach (WaveProps wave in waveProps)
		{
			if (wave.waveIndex <= currentWaveIndex && wave.waveIndex > currentWave.waveIndex)
			{
				currentWave = wave;
			}
		}
		
		blockController.fallInterval = GetFallInterval();
		
		BroadcastMessage(TetrisController.HANDLE_RUSH_ENDED);
	}
	
	//**************************************************************************
	// Callbacks
	
	private void HandleRowsCleared(int rowsCount)
	{
		int scoreIncrease = GetScoreIncrease(rowsCount);
		score += scoreIncrease;
		gameUI.ShowScoreIncrease(scoreIncrease);
	}
	
	//**************************************************************************
	// Spawning
	
	private System.Type GetNextFigure()
	{
		System.Type result;
		
		int ind = 0;
		
		System.Type[] figureTypes = GetFigureTypes();
		
		do {
			int index = Random.Range(0, figureTypes.Length);
			result = figureTypes[index];
			ind ++;
		} while (result == nextFigureType && ind < 10);
		
		return result;
	}
	
	//**************************************************************************
	// UI
	
	private void UpdateUI()
	{
		int rushTime = isRushing ? GetRushRemainingTime() : GetTimeBeforeRush();
		gameUI.UpdateTexts(score, currentWaveIndex + 1, GetCurrentSpeed(), rushTime, isRushing);
	}
	
	//**************************************************************************
	// Utils
	
	private int GetScoreIncrease(int numberRows)
	{
		float initialValue = 20;
		float rushBonus = isRushing ? 10 : 1;
		return (int)(initialValue * (currentWaveIndex + 1) * rushBonus * numberRows * numberRows);
	}
	
	//--------------------------------------------------------------------------
	
	private int GetTimeBeforeRush()
	{
		if (isRushing)
		{
			return 0;
		}
		
		return (int)(currentWave.timeBeforeRush - (Time.time - waveStartTime));
	}
	
	//--------------------------------------------------------------------------
	
	private int GetRushRemainingTime()
	{
		if (!isRushing)
		{
			return 0;
		}
		
		return (int)(currentWave.timeBeforeRush + currentWave.rushDuration - (Time.time - waveStartTime));
	}
	
	//--------------------------------------------------------------------------
	
	private float GetFallInterval()
	{
		float result;
		
		if (isRushing)
		{
			result = currentWave.fallInterval - 0.0025f * GetWaveDelta();
		} else {
			result = MAX_FALL_INTERVAL - 0.01f * currentWaveIndex;
		}
		
		if (result < MIN_FALL_INTERVAL)
		{
			result = MIN_FALL_INTERVAL;
		}
		
		return result;
	}
	
	//--------------------------------------------------------------------------
	
	private int GetWaveDelta()
	{
		return currentWaveIndex - currentWave.waveIndex;
	}
	
	//--------------------------------------------------------------------------
	
	private int GetCurrentSpeed()
	{
		return (int)(10 / GetFallInterval());
	}
	
	//--------------------------------------------------------------------------
	
	private System.Type[] GetFigureTypes()
	{
		
		if (bonusBombsSpawned < currentWave.bombsOnStart)
		{
			bonusBombsSpawned++;
			return bombsOnlyFigures;
		}
		
		if (isRushing)
		{
			switch (currentWaveIndex)
			{
				case 1: return pointOnlyFigures;
				case 3: return shooterOnlyFigures;
				case 5: return allFigures;
				case 7: return quadOnlyFigures;
				case 8: return bombsOnlyFigures;
				case 9: return gOnlyFigures;
				case 11: return zigZagOnlyFigures;
				case 12: return bombsOnlyFigures;
				case 16: return pointOnlyFigures;
				case 20: return bombsOnlyFigures;
				case 23: return zigZagOnlyFigures;
				case 24: return gOnlyFigures;
				case 25: return quadOnlyFigures;
				case 26: return bombsOnlyFigures;
			}
		}
	
		if (currentWaveIndex <= 1)
		{
			return basicFigures;
		} else 
		if (currentWaveIndex <= 3)
		{
			return basicAndPointFigures;
		} else
		if (currentWaveIndex <= 4)
		{
			return basicAndPointAndShooterFigures;
		} else 
		if (currentWaveIndex == 5)
		{
			return bombsOnlyFigures;
		}
		
		return allFigures;
	}
}
