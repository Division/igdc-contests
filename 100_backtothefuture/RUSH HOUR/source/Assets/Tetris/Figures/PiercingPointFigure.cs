using UnityEngine;
using System.Collections;

public class PiercingPointFigure : BaseFigure {
	
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
		data.geometry = new int [,] { {1} };
		collisionData.Add(data);
		
		//
		GenerateVisualDataByCollisionData(collisionData[0]);
	}
	
	//--------------------------------------------------------------------------
	
	override protected bool TestCollision(int x, int y, int orientaion, out bool outUpperBounds)
	{
		outUpperBounds = false;
		bool isHorizontal = xPosition != x;
		
		bool hasCollision;
		if (isHorizontal)
		{
			hasCollision = fieldData.TestFigureCollision(currentCollisionData, x, y, out outUpperBounds);
		} else 
		{
			int targetY = fieldData.TraceVertical(x, y, false);
			hasCollision = targetY < 0 || targetY < y;
		}
		
		return hasCollision;
	}
	
	//--------------------------------------------------------------------------
	
	override protected System.Type GetBlockType()
	{
		return typeof(PointBlock);
	}
}
