using UnityEngine;
using System.Collections.Generic;

public class PlankFigure : BaseFigure {
	
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
		data.yOffset = -2;
		collisionData.Add(data);
		
		//
		data = new FigureCollisionData();
		data.geometry = new int [,]  { {1},
									   {1},
									   {1},
									   {1} };
		data.xOffset = -1;
		data.yOffset = 0;
		data.rotationAngle = 0;
		collisionData.Add(data);
		
		//
		GenerateVisualDataByCollisionData(collisionData[0]);
	}
	
}
