using UnityEngine;
using System.Collections.Generic;

public class TetrisFieldData {
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	public int[,] fieldCollisionData { get { return fieldData; } }
	
	//**************************************************************************
	// Reset
	
	public void Reset()
	{
		fieldData = new int[TetrisConst.FIELD_WIDTH, TetrisConst.FIELD_HEIGHT];
	}
	
	//**************************************************************************
	// Fill
	
	public void FillFigure(FigureCollisionData data, int x, int y)
	{
		for (int i = 0; i < data.geometry.GetLength(0); i++)
		{
			for (int j = 0; j < data.geometry.GetLength(1); j++)
			{
				if (data.geometry[i, j] != 0)
				{
					int realX = x + i + data.xCollisionOffset + data.xOffset;
					int realY = y + j + data.yCollisionOffset + data.yOffset;
					FillPoint(realX, realY);
				}
			}
		}
	}
	
	//--------------------------------------------------------------------------
	
	public void FillPoint(int x, int y)
	{
		if (x < 0 || x >= TetrisConst.FIELD_WIDTH || y < 0 || y >= TetrisConst.FIELD_HEIGHT)
		{
			return;
		}
		
		fieldData[x,y] = 1;
	}
	
	//--------------------------------------------------------------------------
	
	public void ClearPoint(int x, int y)
	{
		if (x < 0 || x >= TetrisConst.FIELD_WIDTH || y < 0 || y >= TetrisConst.FIELD_HEIGHT)
		{
			return;
		}
		
		fieldData[x,y] = 0;
	}
	
	//**************************************************************************
	// Collision
	
	public bool TestFigureCollision(FigureCollisionData data, int x, int y, out bool isOutUpperBounds)
	{
		isOutUpperBounds = false;
		for (int i = 0; i < data.geometry.GetLength(0); i++)
		{
			for (int j = 0; j < data.geometry.GetLength(1); j++)
			{
				if (data.geometry[i, j] != 0)
				{
					int realX = x + i + data.xCollisionOffset + data.xOffset;
					int realY = y + j + data.yCollisionOffset + data.yOffset;
					
					if (realY <= 0)
					{
						isOutUpperBounds = true;
					}
					
					if (TestPointCollision(realX, realY))
					{
						return true;
					}
				}
			}
		}
		
		isOutUpperBounds = false;
		return false;
	}
	
	//--------------------------------------------------------------------------
	
	public bool GetCollisionPoints(FigureCollisionData data, int x, int y, out List<Vector2>collisionPoints)
	{
		collisionPoints = new List<Vector2>();
		
		for (int i = 0; i < data.geometry.GetLength(0); i++)
		{
			for (int j = 0; j < data.geometry.GetLength(1); j++)
			{
				if (data.geometry[i, j] != 0)
				{
					int realX = x + i + data.xCollisionOffset + data.xOffset;
					int realY = y + j + data.yCollisionOffset + data.yOffset;
					if (TestPointCollision(realX, realY))
					{
						collisionPoints.Add(new Vector2(realX, realY));
					}
				}
			}
		}
		
		return collisionPoints.Count > 0;
	}
	
	//--------------------------------------------------------------------------
	
	public bool TestPointCollision(int x, int y)
	{
		if (x < 0 || x >= TetrisConst.FIELD_WIDTH || y >= TetrisConst.FIELD_HEIGHT)
		{
			return true;
		}
		
		if (y < 0)
		{
			return false;
		}
		
		return fieldData[x, y] != 0;
	}
	
	//--------------------------------------------------------------------------
	
	public int TraceVertical(int fromX, int fromY, bool firstOccurance)
	{
		int result = -1;
		
		if (fromY < 0)
		{
			fromY = 0;
		}
		
		if (firstOccurance)
		{
			for (int i = fromY; i < TetrisConst.FIELD_HEIGHT; i++)
			{
				if (fieldData[fromX, i] != 0)
				{
					if (result != -1)
					{
						break;
					}
				} else {
					result = i;
				}
			}
		} else 
		{
			for (int i = TetrisConst.FIELD_HEIGHT - 1; i >= fromY; i--)
			{
				if (fieldData[fromX, i] == 0)
				{
					result = i;
					break;
				}
			}
		}
		
		return result;
	}
	
	//--------------------------------------------------------------------------
	
	public bool CheckFigureOutUpperBounds(FigureCollisionData data, int x, int y)
	{
		for (int i = 0; i < data.geometry.GetLength(0); i++)
		{
			for (int j = 0; j < data.geometry.GetLength(1); j++)
			{
				if (data.geometry[i, j] != 0)
				{
					int realY = y + j + data.yCollisionOffset + data.yOffset;
					if (realY < 0)
					{
						return true;
					}
				}
			}
		}
		
		return false;
	}
	
	//**************************************************************************
	// Filled lines
	
	// Returns number of rows cleared and vertical shift values for every row
	public int ClearFilledLines(out int [] rowShifts)
	{
		rowShifts = new int[TetrisConst.FIELD_HEIGHT];
		
		int numberCleared = 0;
		
		for (int i = TetrisConst.FIELD_HEIGHT - 1; i >= 0; i--)
		{
			if (CheckRowFilled(i))
			{
				numberCleared++;
				rowShifts[i] = -1;
			} else {
				rowShifts[i] = numberCleared;
				if (numberCleared > 0)
				{
					MoveRow(i, i + numberCleared);
				}
			}
		}
		
		return numberCleared;
	}
	

	//--------------------------------------------------------------------------
	
	public bool CheckRowFilled(int row)
	{
		for (int i = 0; i < TetrisConst.FIELD_WIDTH; i++)
		{
			if (fieldData[i, row] == 0)
			{
				return false;
			}
		}
		
		return true;
	}
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	private int[,] fieldData;
	
	//--------------------------------------------------------------------------
	
	private void MoveRow(int from, int to)
	{
		for (int i = 0; i < TetrisConst.FIELD_WIDTH; i++)
		{
			fieldData[i, to] = fieldData[i, from];
			fieldData[i, from] = 0;
		}
	}
	
}
