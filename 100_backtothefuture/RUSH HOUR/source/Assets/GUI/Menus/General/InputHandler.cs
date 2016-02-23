using UnityEngine;
using System.Collections;

public class InputHandler : MonoBehaviour {

	private Vector3 prevPos = Vector3.zero;
	
	// Update is called once per frame
	void Update () {
		#if UNITY_EDITOR || UNITY_WEBPLAYER || UNITY_STANDALONE
		HandleMouseInput();
		#endif
		
		
		#if UNITY_IPHONE || UNITY_ANDROID
		HandleTouchInput();
		#endif
	}
	
	//--------------------------------------------------------------------------
	
	private void HandleMouseInput() 
	{
		if (Input.GetKeyDown(KeyCode.Mouse0)) 
		{
			BroadcastMessage("OnTouchDown", Input.mousePosition, SendMessageOptions.DontRequireReceiver);
		}
		
		if (Input.GetKeyUp(KeyCode.Mouse0)) 
		{
			BroadcastMessage("OnTouchUp", Input.mousePosition, SendMessageOptions.DontRequireReceiver);
		}
		
		if ((Input.mousePosition - prevPos).sqrMagnitude > 0) 
		{
			BroadcastMessage("OnTouchMoved", Input.mousePosition, SendMessageOptions.DontRequireReceiver);
		}
		
		prevPos = Input.mousePosition;
	}
	
	//--------------------------------------------------------------------------
	
	private void HandleTouchInput() {
		
		if (Input.touchCount > 0) {
			Touch touch = Input.touches[0];
			
			switch (touch.phase) {
			case TouchPhase.Began:
				BroadcastMessage("OnTouchDown", new Vector3(touch.position.x, touch.position.y, 0), SendMessageOptions.DontRequireReceiver);
				break;
				
			case TouchPhase.Ended:
			case TouchPhase.Canceled:
				BroadcastMessage("OnTouchUp", new Vector3(touch.position.x, touch.position.y, 0), SendMessageOptions.DontRequireReceiver);
				break;
				
			case TouchPhase.Moved:
				BroadcastMessage("OnTouchMoved", new Vector3(touch.position.x, touch.position.y, 0), SendMessageOptions.DontRequireReceiver);
				break;
			}
			
		}
	}
	
}
