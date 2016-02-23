using UnityEngine;
using System.Collections;

public class QuadFigure : BaseFigure {

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
		data.geometry = new int [,] { {1,1}, {1,1} };
		
		data.rotationAngle = -90;
		data.xOffset = 0;
		data.yOffset = 0;
		collisionData.Add(data);

		//
		GenerateVisualDataByCollisionData(collisionData[0]);
	}
	
}