using UnityEngine;
using System.Collections;

public class PauseMenu : BaseMenu {
	
	private void HandleExit()
	{
		MenuHandler.Instance.ShowMainMenu();
	}
	
	//--------------------------------------------------------------------------
	
	private void HandleResume()
	{
		MenuHandler.Instance.ShowResumeTetrisController();
	}
	
	//--------------------------------------------------------------------------
	
	void Update()
	{
		if (Input.GetKeyDown(KeyCode.Escape))
		{
			HandleResume();
		}
	}
	
}
