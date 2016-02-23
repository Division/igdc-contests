using UnityEngine;
using System.Collections;

public class AboutMenu : MonoBehaviour {

	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	private void HandleBack()
	{
		MenuHandler.Instance.ShowMainMenu();
	}
	
}
