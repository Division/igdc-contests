using UnityEngine;
using System.Collections;

public class BaseBlock : MonoBehaviour {
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	public int xPosition { get; set; }
	public int yPosition { get; set; }
	
	virtual public void HandleLanded()
	{
		isLanded = true;
		xPosition = (int)(transform.localPosition.x / TetrisConst.BRICK_SIZE);
		yPosition = -(int)(transform.localPosition.y / TetrisConst.BRICK_SIZE);
		SetupLandedAppearance();
	}
	
	//**************************************************************************
	// Appearance
	
	public virtual void SetupInitialAppearance()
	{
		appearance.SetColors(appearance.grenColor, appearance.blueColor);
		appearance.SetTexture("TextureDefaultItem");
	}
	
	//--------------------------------------------------------------------------
	
	public virtual void SetupLandedAppearance()
	{
		appearance.SetColors(appearance.yellowColor, appearance.blueColor, 0.2f);
	}
	
	//--------------------------------------------------------------------------
	
	public virtual void SetupActiveAppearance()
	{
		appearance.SetColors(appearance.blueColor, appearance.redColor, 0.1f);
	}
	
	//**************************************************************************
	//
	// MonoBehaviour
	//
	//**************************************************************************
	
	void Awake()
	{
		appearance = GetComponent<BaseBlockAppearance>();
	}
	
	//--------------------------------------------------------------------------
	
	void Start()
	{
		SetupInitialAppearance();
		Invoke("SetSelfVisible", 0.05f); // Hack to get rid of white color blimming :(
	}
	
	//--------------------------------------------------------------------------
	
	void SetSelfVisible()
	{
		gameObject.transform.GetChild(0).gameObject.SetActive(true);
	}
	
	//--------------------------------------------------------------------------
	
	void FixedUpdate () 
	{
		if (!isLanded)
		{
			return;
		}
		
		Vector3 newPosition = LocalPositionForXY(xPosition, yPosition);
		Vector3 delta = newPosition - transform.localPosition;
		
		float distance = delta.magnitude;
		float currentSpeed = distance / 6;
		if (currentSpeed > 0.01f)
		{
			delta /= distance;
			newPosition = transform.localPosition + delta * currentSpeed;
		} else if (!positionReached)
		{
			positionReached = true;
			PositionReached();
		}
		
		transform.localPosition = newPosition;
	}
	
	//--------------------------------------------------------------------------
	
	void Update()
	{
		transform.rotation = Quaternion.identity;
	}
	
	//**************************************************************************
	//
	// Protected
	//
	//**************************************************************************
	
	protected bool isLanded = false;
	protected bool positionReached = false;
	protected BaseBlockAppearance appearance;
	
	//--------------------------------------------------------------------------
	
	virtual protected void PositionReached()
	{
		
	}
	
	//**************************************************************************
	//
	// Private
	//
	//**************************************************************************
	
	
	//**************************************************************************
	// Utils
	
	private Vector3 LocalPositionForXY(int x, int y)
	{
		Vector3 halfBrickOffset = new Vector3(TetrisConst.BRICK_SIZE / 2.0f, -TetrisConst.BRICK_SIZE / 2.0f);
		Vector3 position = new Vector3(x * TetrisConst.BRICK_SIZE, -y * TetrisConst.BRICK_SIZE);
		return position + halfBrickOffset;
	}
}
