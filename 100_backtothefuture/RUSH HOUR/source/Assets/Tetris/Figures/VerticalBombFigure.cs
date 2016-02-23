using UnityEngine;
using System.Collections.Generic;

public class VerticalBombFigure : BaseFigure {
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	override public void FallDown()
	{
		int newYPosition = yPosition + 1;
		AnimateToNewPosition(xPosition, newYPosition, currentOrientation, false);
	}
	
	//--------------------------------------------------------------------------
	
	override public void Move(int side)
	{
		int newXPosition = xPosition + side;
		if (newXPosition < 0 || newXPosition >= TetrisConst.FIELD_WIDTH)
		{
			SoundPlayer.Instance.PlaySound(SoundConst.HIT_WALL);
			return;
		}
		
		string message = side < 0 ? TetrisController.PLAY_SOUND_MOVE_LEFT : TetrisController.PLAY_SOUND_MOVE_RIGHT;
		SendMessageUpwards(message);
		
		AnimateToNewPosition(newXPosition, yPosition, currentOrientation, false);
	}
	
	//--------------------------------------------------------------------------
	
	override public void PerformAction()
	{
		// Do nothing
	}
	
	//**************************************************************************
	//
	// Protected
	//
	//**************************************************************************
	
	override protected void InitializeFigure()
	{
		FigureCollisionData data;
		
		//
		data = new FigureCollisionData();
		data.geometry = new int [,] { {1,1,1} }; // Vertical
		
		data.rotationAngle = -90;
		data.xOffset = 0;
		data.yOffset = -1;
		collisionData.Add(data);
		
		//
		GenerateVisualDataByCollisionData(collisionData[0]);
	}
	
	//--------------------------------------------------------------------------
	
	override protected void AnimateToNewPosition(int x, int y, int orientation, bool hasCollision)
	{
		List<Vector2> points;
		if (fieldData.GetCollisionPoints(currentCollisionData, x, y, out points))
		{
			Vector2[] localCollisionPoints;
			BaseBlock[] collidedBlocks = BlocksForCollision(x, y, points, out localCollisionPoints);
			
			for (int i = 0; i < collidedBlocks.Length; i++)
			{
				Vector2 localCollisionPoint = localCollisionPoints[i];
				currentCollisionData.geometry[(int)localCollisionPoint.x, (int)localCollisionPoint.y] = 0;
				
				BaseBlock block = collidedBlocks[i];
				blocks.Remove(block);
				block.xPosition = (int)points[i].x;
				block.yPosition = (int)points[i].y;
				
				SendMessageUpwards(BlockController.CALLBACK_HANDLE_BOMB, block);
			}
			
			foreach (Vector2 collisionPoint in points)
			{
				fieldData.ClearPoint((int)collisionPoint.x, (int)collisionPoint.y);
			}
			
			if (blocks.Count == 0)
			{
				NotifyFigureLanded();
			}
			
			SoundPlayer.Instance.PlaySound(SoundConst.EXPLOSION);
		}
		
		xPosition = x;
		yPosition = y;
	}
	
	//--------------------------------------------------------------------------
	
	// Never collide in MoveIfRequired method
	override protected bool TestCollision(int x, int y, int orientaion, out bool outUpperBounds)
	{
		outUpperBounds = false;
		return false;
	}
	
	//--------------------------------------------------------------------------
	
	protected BaseBlock GetBlock(int blockX, int blockY, int figureX, int figureY)
	{
		int deltaX = ((int)transform.localPosition.x) - figureX;
		int deltaY = (-(int)transform.localPosition.y) - figureY;
		
		//Debug.Log("Finding: " + blockX + "," + blockY + " fig:" + figureX + "," + figureY + " delta: " + deltaX + "," + deltaY);
		
		foreach (BaseBlock block in blocks)
		{
			int x = (int)((block.transform.position.x) / TetrisConst.BRICK_SIZE) - deltaX;
			int y = (int)(-(block.transform.position.y) / TetrisConst.BRICK_SIZE) - deltaY;
			
			if (x == blockX && y == blockY)
			{
				return block;
			}
		}
		
		Debug.LogError("Error finding block: " + deltaX + "," + deltaY);
		return null;
	}
	
	//--------------------------------------------------------------------------
	
	override protected System.Type GetBlockType()
	{
		return typeof(BombBlock);
	}
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	private BaseBlock[] BlocksForCollision(int x, int y, List<Vector2> worldCollisionPoints, out Vector2[] localCollisionPoints)
	{
		localCollisionPoints = new Vector2[worldCollisionPoints.Count];
		BaseBlock[] resultBlocks = new BaseBlock[worldCollisionPoints.Count];
		
		for (int i = 0; i < worldCollisionPoints.Count; i++)
		{
			int worldX = (int)worldCollisionPoints[i].x;
			int worldY = (int)worldCollisionPoints[i].y;
			
			int localX = worldX - x - currentCollisionData.xCollisionOffset - currentCollisionData.xOffset;
			int localY = worldY - y - currentCollisionData.yCollisionOffset - currentCollisionData.yOffset;
			
			localCollisionPoints[i] = new Vector2(localX, localY);
			resultBlocks[i] = GetBlock(worldX, worldY, x, y);
		}
		
		return resultBlocks;
	}

}
	
