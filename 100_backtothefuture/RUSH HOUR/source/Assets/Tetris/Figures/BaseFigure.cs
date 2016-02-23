using UnityEngine;
using System.Collections.Generic;
using System.Collections;

public abstract class BaseFigure : MonoBehaviour {
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	public const string CALLBACK_FIGURE_LANDED = "HandleFigureLanded";
	public const string TWEEN_HORIZONTAL = "Horizontal";
	public const string TWEEN_VERTICAL = "Vertical";
	
	public bool visualOnly { get; set; }
	public int xPosition { get; set; }
	public int yPosition { get; set; }
	public TetrisFieldData fieldData { get; set; }
	public int numberOfOrientations { get { return collisionData.Count; } }
	public FigureCollisionData currentCollisionData { get { return collisionData[currentOrientation]; } }
	public List<BaseBlock> blocksToAdd { get { return blocks; } }
	
	//**************************************************************************
	// Controls
	
	virtual public void FallDown()
	{
		int newYPosition = yPosition + 1;
		bool outOfBounds;
		bool hasCollision = TestCollision(xPosition, newYPosition, currentOrientation, out outOfBounds);
		
		controlDisabled = hasCollision;
		
		AnimateToNewPosition(xPosition, newYPosition, currentOrientation, hasCollision);
	}
	
	//--------------------------------------------------------------------------
	
	virtual public void Move(int side)
	{
		if (controlDisabled)
		{
			return;
		}
		
		int newXPosition = xPosition + side;
		bool outOfBounds;
		if (TestCollision(newXPosition, yPosition, currentOrientation, out outOfBounds))
		{
			SoundPlayer.Instance.PlaySound(SoundConst.HIT_WALL);
			return;
		}
		
		string message = side < 0 ? TetrisController.PLAY_SOUND_MOVE_LEFT : TetrisController.PLAY_SOUND_MOVE_RIGHT;
		SendMessageUpwards(message);
		
		AnimateToNewPosition(newXPosition, yPosition, currentOrientation, false);
	}
	
	//--------------------------------------------------------------------------
	
	// Default action is rotation (orientation change)
	virtual public void PerformAction()
	{
		if (numberOfOrientations <= 1)
		{
			return;
		}
		
		int newOrientation = NextOrientation();
		int newXPosition = xPosition;
		bool hasCollision = false;
		bool outOfBounds;
		
		if (TestCollision(xPosition, yPosition, newOrientation, out outOfBounds))
		{
			hasCollision = true;
			// If new orientation collides, try to make a shift for 2 points max
			bool shiftFound = false;
			for (int i = 1; i <= 2; i++ )
			{
				newXPosition = xPosition + i;
				if (!TestCollision(newXPosition, yPosition, newOrientation, out outOfBounds))
				{
					shiftFound = true;
					break;
				}
				
				newXPosition = xPosition - i;
				if (!TestCollision(newXPosition, yPosition, newOrientation, out outOfBounds))
				{
					shiftFound = true;
					break;
				}
			}
			
			if (!shiftFound)
			{
				return;
			}
		}
		
		SendMessageUpwards(TetrisController.PLAY_SOUND_ROTATE);
		
		AnimateToNewPosition(newXPosition, yPosition, newOrientation, hasCollision);
	}
	
	//**************************************************************************
	// Reset
		
	public void ResetTransform()
	{
		transform.localPosition = LocalPositionForXY(xPosition, yPosition);
		transform.rotation = Quaternion.Euler(0, 0, currentCollisionData.rotationAngle);
		ApplyBlockContainerPosition();
	}
	
	//**************************************************************************
	//
	// MonoNehaviour
	//
	//**************************************************************************
	
	void Start()
	{
		InitializeBlockContainer();
		InitializeFigure();
		ResetTransform();
		
		if (visualOnly)
		{
			return;
		}
		
		bool outOfBounds;
		if (fieldData.TestFigureCollision(currentCollisionData, xPosition, yPosition, out outOfBounds)) 
		{
			if (outOfBounds)
			{
				SendMessageUpwards(TetrisController.HANDLE_GAME_OVER);
			}
		}
	}
	
	//--------------------------------------------------------------------------
	
	void FixedUpdate()
	{
		if (visualOnly)
		{
			return;
		}
		MoveIfRequired();
	}
	
	//**************************************************************************
	//
	// Protected
	//
	//**************************************************************************
	
	//**************************************************************************
	// Utils
	
	protected int NextOrientation()
	{
		return (currentOrientation + 1) % numberOfOrientations;
	}
	
	//--------------------------------------------------------------------------
	
	protected Vector3 LocalPositionForXY(int x, int y)
	{
		Vector3 halfBrickOffset = new Vector3(TetrisConst.BRICK_SIZE / 2.0f, -TetrisConst.BRICK_SIZE / 2.0f);
		Vector3 position = new Vector3(x * TetrisConst.BRICK_SIZE, -y * TetrisConst.BRICK_SIZE);
		return position + halfBrickOffset;
	}
	
	//--------------------------------------------------------------------------
	
	protected Vector3 BlockContainerOffset(int orientation)
	{
		FigureCollisionData data = collisionData[currentOrientation];
		return new Vector3(-data.xOffset, data.yOffset) * TetrisConst.BRICK_SIZE;
	}
	
	//--------------------------------------------------------------------------
	
	virtual protected bool TestCollision(int x, int y, int orientaion, out bool outUpperBounds)
	{
		FigureCollisionData data = collisionData[orientaion];
		return fieldData.TestFigureCollision(data, x, y, out outUpperBounds);
	}
	
	//**************************************************************************
	// Generation
	
	abstract protected void InitializeFigure();
	
	//--------------------------------------------------------------------------
	
	protected void GenerateVisualDataByCollisionData(FigureCollisionData data)
	{
		for (int i = 0; i < data.geometry.GetLength(0); i++)
		{
			for (int j = 0; j < data.geometry.GetLength(1); j++)
			{
				int value = data.geometry[i, j];
				if (value != 0)
				{
					CreateBlock(j, -i);
				}
			}
		}
	}
	
	//**************************************************************************
	// Animation
	
	// Called after animation is completed
	protected void NotifyFigureLanded()
	{
		fieldData.FillFigure(currentCollisionData, xPosition, yPosition);
		SendMessageUpwards(CALLBACK_FIGURE_LANDED, this);
		Destroy(gameObject);
	}
	
	//--------------------------------------------------------------------------
	
	virtual protected void AnimateToNewPosition(int x, int y, int orientation, bool hasCollision)
	{
		bool updateRotation = orientation != currentOrientation;
		xPosition = x;
		
		if (!updateRotation && hasCollision)
		{
			
		} else
		{
			yPosition = y;
		}
		
		if (updateRotation)
		{
			currentOrientation = orientation;
			transform.rotation = Quaternion.Euler(0, 0, currentCollisionData.rotationAngle);
			ApplyBlockContainerPosition();
			
			if (hasCollision)
			{
				Vector3 newPosition = LocalPositionForXY(x, y);
				newPosition.y = transform.localPosition.y;
				transform.localPosition = newPosition;
			}
		}
	}
	
	//--------------------------------------------------------------------------
	
	protected void MoveIfRequired()
	{
		Vector3 newPosition = LocalPositionForXY(xPosition, yPosition);
		Vector3 delta = newPosition - transform.localPosition;
		
		bool outOfBounds;
		float distance = delta.magnitude;
		float currentSpeed = distance / 3;
		if (currentSpeed > 0.01f)
		{
			delta /= distance;
			newPosition = transform.localPosition + delta * currentSpeed;
		} else {
			if (TestCollision(xPosition, yPosition + 1, currentOrientation, out outOfBounds))
			{
				NotifyFigureLanded();
			}
		}
		
		transform.localPosition = newPosition;
	}
	
	//**************************************************************************
	// Blocks
	
	virtual protected System.Type GetBlockType()
	{
		return typeof(BaseBlock);
	}
	
	//--------------------------------------------------------------------------
	
	virtual protected void CreateBlock(int xOffset, int yOffset)
	{
		BaseBlock block = FigureGenerator.CreateBlock(GetBlockType());
		block.transform.parent = blockContainer.transform;
		blocks.Add(block);
		block.transform.localPosition = new Vector3(xOffset * TetrisConst.BRICK_SIZE, -yOffset * TetrisConst.BRICK_SIZE);
	}
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	protected GameObject blockContainer;
	protected int currentOrientation = 0;
	protected List<BaseBlock> blocks = new List<BaseBlock>();
	protected bool controlDisabled = false;
	
	//-------------------
	// Collision data for every orientation
	protected List<FigureCollisionData> collisionData = new List<FigureCollisionData>();

	//--------------------------------------------------------------------------
	
	private void InitializeBlockContainer()
	{
		blockContainer = new GameObject("BlockContainer");
		blockContainer.transform.parent = transform;
		blockContainer.transform.localPosition = Vector3.zero;
	}

	//--------------------------------------------------------------------------
	
	private void ApplyBlockContainerPosition()
	{
		blockContainer.transform.localPosition = transform.transform.InverseTransformPoint(transform.position - BlockContainerOffset(currentOrientation));
	}
	

}
