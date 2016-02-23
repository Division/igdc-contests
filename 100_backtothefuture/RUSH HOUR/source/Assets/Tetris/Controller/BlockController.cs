using UnityEngine;
using System.Collections.Generic;

public class BlockController : MonoBehaviour {
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	//-------------------
	// Const
	public readonly Vector2 START_POSITION = new Vector2(5, 0);
	public const string CALLBACK_HANDLE_BOMB = "HandleBomb";
	public const string CALLBACK_HANDLE_SHOT = "HandleShot";
	public const string CALLBACK_HANDLE_SHOT_POSITION_REACHED = "HandleShotPositionReached";
	
	//-------------------
	// Properties
	public float fallInterval { get; set; }
	
	//-------------------
	// Editor connections
	public Transform blockContainer;
	
	public void Reset()
	{
		foreach (BaseBlock block in blocks)
		{
			Destroy(block.gameObject);
		}
		blocks.Clear();
		
		if (currentFigure)
		{
			Destroy(currentFigure.gameObject);
		}
		
		lastFallDownTime = Time.time;
		lastMoveTime = Time.time;
		
		fieldData.Reset();
	}
	
	//**************************************************************************
	// Controls

	public void FallDown()
	{
		if (!enabled)
		{
			return;
		}
		
		if (currentFigure)
		{
			currentFigure.FallDown();
			lastFallDownTime = Time.time;
		}
	}
	
	//--------------------------------------------------------------------------
	
	public void MoveToSide(int direction)
	{
		if (!enabled)
		{
			return;
		}
		
		if (currentFigure)
		{
			currentFigure.Move(direction);
		}
	}
	
	//--------------------------------------------------------------------------
	
	public void PerformAction()
	{
		if (!enabled)
		{
			return;
		}
		
		if (currentFigure)
		{
			currentFigure.PerformAction();
		}
	}
	
	//**************************************************************************
	// Spawning

	public void SpawnFigure(System.Type figureType)
	{
		if (!enabled)
		{
			return;
		}
		
		currentFigure = FigureGenerator.CreateFigure(figureType);
		currentFigure.transform.parent = transform;
		currentFigure.fieldData = fieldData;
		currentFigure.xPosition = (int)START_POSITION.x;
		currentFigure.yPosition = (int)START_POSITION.y;
	}
	
	//**************************************************************************
	//
	// MonoBehaviour
	//
	//**************************************************************************
	
	void Awake() 
	{
		fieldData.Reset();
		fallInterval = 0.5f;
	}
	
	//--------------------------------------------------------------------------
	
	void Update() 
	{
		if (Time.time - lastFallDownTime > fallInterval)
		{
			if (currentFigure)
			{
				FallDown();
			}
		}
	}
	
	//--------------------------------------------------------------------------
#if false
	void OnDrawGizmos()
	{
		if (!Application.isPlaying)
		{
			return;
		}
		
		int [,] data = fieldData.fieldCollisionData;
		for (int i = 0; i < data.GetLength(0); i++)
		{
			for (int j = 0; j < data.GetLength(1); j++)
			{
				if (data[i,j] == 0)
				{
					continue;
				}
				
				Vector3 position = new Vector3(0.5f, -0.5f) + new Vector3(i, -j);
				Gizmos.color = Color.green;
				Gizmos.DrawCube(position, new Vector3(1,1,1));
			}
		}
	}
#endif
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	private float lastFallDownTime;
	private float lastMoveTime;
	private TetrisFieldData fieldData = new TetrisFieldData();
	private BaseFigure currentFigure = null;
	private float currentSideDirection;
	private List<BaseBlock> blocks = new List<BaseBlock>();
	
	//**************************************************************************
	// Callbacks
	
	private void HandleFigureLanded(BaseFigure figure)
	{
		bool hasBlocks = false;
		foreach (BaseBlock block in figure.blocksToAdd) 
		{
			hasBlocks = true;
			block.transform.parent = blockContainer;
			block.HandleLanded();
			blocks.Add(block);
		}
		
		if (hasBlocks)
		{
			CheckFilledLines();
		}
		
		SendMessageUpwards(TetrisController.READY_SPAWN_FIGURE);
	}
	
	//--------------------------------------------------------------------------
	
	private void HandleBomb(BaseBlock block)
	{
		block.transform.parent = blockContainer;
		
		BaseBlock destroyedBlock = GetBlock(block.xPosition, block.yPosition);
		if (destroyedBlock)
		{
			blocks.Remove(destroyedBlock);
			Destroy(destroyedBlock.gameObject);
		}
		
		Destroy(block.gameObject);
	}
	
	//--------------------------------------------------------------------------
	
	private void HandleShot(BaseBlock block)
	{
		blocks.Add(block);
		block.transform.parent = blockContainer;
		block.HandleLanded();
	}
	
	//--------------------------------------------------------------------------
	
	private void HandleShotPositionReached()
	{
		CheckFilledLines();
	}
	
	//**************************************************************************
	// Search
	
	private BaseBlock GetBlock(int x, int y)
	{
		return blocks.Find(delegate (BaseBlock block)
		{
			return block.xPosition == x && block.yPosition == y;
		});
	}
	
	//**************************************************************************
	// Line remove
	
	private void CheckFilledLines()
	{
		int [] shifts;
		int linesCleared = fieldData.ClearFilledLines(out shifts);
		if (linesCleared == 0)
		{
			return;
		}
		
		if (linesCleared > 0)
		{
			SoundPlayer.Instance.PlaySound(SoundConst.WALLBURN).Volume = 1.0f;
			SendMessageUpwards(GamePlayController.HANDLE_ROWS_CLEARED, linesCleared);
		}
		
		for (int i = blocks.Count - 1; i >= 0; i--)
		{
			BaseBlock block = blocks[i];
			int shift = shifts[block.yPosition];
			if (shift < 0)
			{
				blocks.RemoveAt(i);
				Destroy(block.gameObject);
				
			} else if (shift > 0)
			{
				block.yPosition += shift;
			}
		}
	}
}
