using UnityEngine;
using System.Collections;

public class FigureGRight : BaseFigure {

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
		data.geometry = new int [,] { {1,1,1},
									  {1,0,0} };
		
		data.rotationAngle = -90;
		data.xOffset = 0;
		data.yOffset = -1;
		collisionData.Add(data);

		//
		data = new FigureCollisionData();
		data.geometry = new int [,] { {1,1}, 
									  {0,1},
									  {0,1} };
		
		data.rotationAngle = 0;
		data.xOffset = -1;
		data.yOffset = 0;
		data.yCollisionOffset = -1;
		collisionData.Add(data);

		//
		data = new FigureCollisionData();
		data.geometry = new int [,] { {0,0,1},
									  {1,1,1} };
		
		data.rotationAngle = 90;
		data.xOffset = 0;
		data.yOffset = 1;
		data.xCollisionOffset = -1;
		data.yCollisionOffset = -2;
		collisionData.Add(data);

		//
		data = new FigureCollisionData();
		data.geometry = new int [,] { {1,0}, 
									  {1,0},
									  {1,1} };
		data.rotationAngle = 180;
		data.xOffset = 1;
		data.yOffset = 0;
		data.xCollisionOffset = -2;
		collisionData.Add(data);
		
		GenerateVisualDataByCollisionData(collisionData[0]);
	}
}
