using UnityEngine;
using System.Collections;

// Class used for detecting touches and gestures
public class TouchListener : MonoBehaviour {
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	//-------------------
	// Parameters
	public string messageName = "OnButtonTouch";
	public bool isActive = true;
	public string param = "";
	
	//**************************************************************************
	// Check if touch is inside listener
	
	public bool CheckTouch(Vector3 pos) 
	{
		return TouchHitsObject(pos, gameObject);
	}
	
	//**************************************************************************
	//
	// MonoBehaviour
	//
	//**************************************************************************
	
	void Awake()
	{
		cameraToUse = GameObject.FindWithTag(TetrisConst.TAG_MENU_CAMERA).camera;
	}
	
	//**************************************************************************
	//
	// Protected
	//
	//**************************************************************************
	
	protected bool isDown = false;
	protected Camera cameraToUse;
	//**************************************************************************
	// Input events
	
	virtual protected void OnTouchDown(Vector3 pos) 
	{
		if (!isActive) 
		{
			return;
		}
		
		if (CheckTouch(pos)) 
		{
			isDown = true;
			SendMessage("OnButtonDown", SendMessageOptions.DontRequireReceiver);
			renderer.material.color = Color.green;
		}
	}
	
	//--------------------------------------------------------------------------
	
	virtual protected void OnTouchUp(Vector3 pos) {
		if (!isActive) return;
		if (!isDown) return;
		
		// Check for click event
		bool touchInside = false;
		if (messageName.Length > 0 && CheckTouch(pos)) 
		{
			touchInside = true;
			if (param.Length == 0) {
				SendMessageUpwards(messageName);
			} else {
				SendMessageUpwards(messageName, param);
			}
		}
		
		
		SendMessage("OnButtonUp", touchInside, SendMessageOptions.DontRequireReceiver);
		
		renderer.material.color = Color.white;
		isDown = false;
	}
	
	//**************************************************************************
	// Utils
	
	public bool TouchHitsObject(Vector3 mouse, GameObject obj) 
	{
		Ray ray = cameraToUse.ScreenPointToRay(mouse);
		ray.origin -= ray.direction * 100;
		if (obj.collider) 
		{
			RaycastHit hitInfo = new RaycastHit();
			bool res = obj.collider.Raycast(ray, out hitInfo, 100000);
			return res;
		}
		
		return false;
	}
}
