using UnityEngine;
using System.Collections;

public class GameOverMenu : MonoBehaviour {

	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	public TextMesh scoreText;
	
	public int score { get; set; }
	
	//**************************************************************************
	//
	// MonoBehaviour
	//
	//**************************************************************************
	
	public void UpdateWithScore(int newScore)
	{
		score = newScore;
		
		int bestScore = 0;
		if (PlayerPrefs.HasKey(TetrisConst.CONFIG_BEST_SCORE))
		{
			bestScore = PlayerPrefs.GetInt(TetrisConst.CONFIG_BEST_SCORE);
		}
		
		string scoreString = "";
		
		if (bestScore > 0 && score <= bestScore)
		{
			if (score == bestScore)
			{
				scoreString = "YOU REACHED\nYOUR LAST BEST SCORE: " + score;
			} else 
			{
				scoreString = "SCORE: " + score + "\nBEST SCORE: " + bestScore;
			}
		} else 
		{
			scoreString = "NEW BEST SCORE: " + score;
		}
		
		scoreText.text = scoreString;
	}
	
	//--------------------------------------------------------------------------
	
	private void HandleRestart()
	{
		MenuHandler.Instance.ShowNewGameTetrisController();
	}
	
	//--------------------------------------------------------------------------
	
	private void HandleExit()
	{
		MenuHandler.Instance.ShowMainMenu();
	}
}
