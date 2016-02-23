using UnityEngine;
using System.Collections;

public class InGameUI : MonoBehaviour {

	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	//-------------------
	// Editor connections
	public TextMesh scoreText;
	public TextMesh waveText;
	public TextMesh rushText;
	public TextMesh speedText;
	public TextMesh scoreBonusText;
	public Transform container;
	
	public void ShowScoreIncrease(int scoreIncrease)
	{
		scoreBonusText.gameObject.SetActive(true);
		scoreBonusText.text = "+" + scoreIncrease;
		scoreShowTime = Time.time;
		if (nextFigure)
		{
			nextFigure.gameObject.SetActive(false);
		}
	}
	
	//--------------------------------------------------------------------------
	
	public void UpdateTexts(int score, int wave, int speed, int rush, bool isRushing)
	{
		scoreText.text = "SCORE: " + score;
		waveText.text = "WAVE: " + wave;
		string rushString = isRushing ? "RUSH: " : "RUSH IN: ";
		rushText.text = rushString + rush;
		speedText.text = "SPEED: " + speed;
	}
	
	//--------------------------------------------------------------------------
	
	public void UpdateNextFigure(System.Type figureType)
	{
		DeleteCurrentFigure();
		CreateFigure(figureType);
	}
	
	//--------------------------------------------------------------------------
	
	void Update()
	{
		if (scoreBonusText.gameObject.activeInHierarchy)
		{
			if (Time.time - scoreShowTime > 1.0f)
			{
				scoreBonusText.gameObject.SetActive(false);
				if (nextFigure)
				{
					nextFigure.gameObject.SetActive(true);
				}
			}
		}
	}
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	private float scoreShowTime;
	private GameObject nextFigure;
	
	//**************************************************************************
	// Handling next figure
	
	private void DeleteCurrentFigure()
	{
		if (nextFigure)
		{
			Destroy(nextFigure);
		}
	}
	
	//--------------------------------------------------------------------------
	
	private void CreateFigure(System.Type figureType)
	{
		BaseFigure figure = FigureGenerator.CreateFigure(figureType);
		figure.visualOnly = true;
		nextFigure = figure.gameObject;
		figure.transform.parent = container;
		figure.transform.localPosition = Vector3.zero;
		
		if (scoreBonusText.gameObject.activeInHierarchy)
		{
			nextFigure.SetActive(false);
		}
	}
}
