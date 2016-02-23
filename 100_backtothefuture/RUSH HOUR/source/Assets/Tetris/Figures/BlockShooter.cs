using UnityEngine;
using System.Collections;

public class BlockShooter : BaseFigure {
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	override public void PerformAction()
	{
		if (blocks.Count == 0)
		{
			return;
		}
		
		BaseBlock block = blocks[blocks.Count - 1];
		blocks.Remove(block);
		
		int targetY = fieldData.TraceVertical(xPosition, yPosition + blocks.Count - 3, true);
		if (targetY >= 0)
		{
			fieldData.FillPoint(xPosition, targetY);
			currentCollisionData.geometry[0, blocks.Count] = 0;
			SendMessageUpwards(BlockController.CALLBACK_HANDLE_SHOT, block);
			block.xPosition = xPosition;
			block.yPosition = targetY;
		}
		
		if (blocks.Count == 0)
		{
			NotifyFigureLanded();
		} else
		{
			blocks[blocks.Count - 1].SetupActiveAppearance();
		}
		
		SoundPlaybackController sound = SoundPlayer.Instance.PlaySound(SoundConst.SHOT);
		sound.Volume = 0.6f;
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
		data.geometry = new int [,] { {1,1,1,1} }; // Vertical
		
		data.rotationAngle = -90;
		data.xOffset = 0;
		data.yOffset = -3;
		collisionData.Add(data);
		
		//
		GenerateVisualDataByCollisionData(collisionData[0]);
		
		((ShotBlock)blocks[blocks.Count - 1]).isActive = true;
	}
	
	//--------------------------------------------------------------------------
	
	override protected System.Type GetBlockType()
	{
		return typeof(ShotBlock);
	}
	
}
