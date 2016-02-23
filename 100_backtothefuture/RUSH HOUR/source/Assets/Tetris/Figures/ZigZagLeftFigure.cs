using UnityEngine;
using System.Collections;

public class ZigZagLeftFigure : BaseFigure {

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
		data.geometry = new int [,] { {1,1,0},
									  {0,1,1} };
		
		data.rotationAngle = -90;
		data.xOffset = -1;
		data.yOffset = -1;
		collisionData.Add(data);

		//
		data = new FigureCollisionData();
		data.geometry = new int [,] { {0,1}, 
									  {1,1},
									  {1,0} };
		
		data.rotationAngle = 0;
		data.xOffset = -1;
		data.yOffset = 1;
		data.yCollisionOffset = -1;
		collisionData.Add(data);
		
		GenerateVisualDataByCollisionData(collisionData[0]);
	}
}
