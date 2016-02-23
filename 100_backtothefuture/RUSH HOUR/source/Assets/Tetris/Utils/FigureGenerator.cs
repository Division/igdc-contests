using UnityEngine;
using System.Collections;

public class FigureGenerator : MonoBehaviour {
	
	//--------------------------------------------------------------------------
	
	public static BaseFigure CreateFigure(System.Type type)
	{
		GameObject plank = new GameObject(type.ToString());
		BaseFigure figure = plank.AddComponent(type) as BaseFigure;
		return figure;
	}
	
	//--------------------------------------------------------------------------
	
	public static BaseBlock CreateBlock(System.Type blockType)
	{
		GameObject blockPrefab = Instantiate(Resources.Load(TetrisConst.BLOCK_PREFAB_NAME)) as GameObject;
		blockPrefab.name = "Block";
		return blockPrefab.AddComponent(blockType) as BaseBlock;
	}
	
}
