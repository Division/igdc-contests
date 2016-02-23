using UnityEngine;
using System.Collections;

public class MainMenu : BaseMenu 
{
	
	private void HandleNewGame()
	{
		MenuHandler.Instance.ShowNewGameTetrisController();
	}
	
	//--------------------------------------------------------------------------
	
	private void HandleAbout()
	{
		MenuHandler.Instance.ShowAbout();
	}
	
}
