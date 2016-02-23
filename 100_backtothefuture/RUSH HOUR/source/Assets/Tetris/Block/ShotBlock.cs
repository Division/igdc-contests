using UnityEngine;
using System.Collections;

public class ShotBlock : BaseBlock {
	
	public bool isActive { get; set; }
	
	public override void SetupInitialAppearance()
	{
		appearance.SetTexture("TextureShotItem");
		
		if (isActive)
		{
			SetupActiveAppearance();
		} else 
		{
			appearance.SetColors(appearance.grenColor, appearance.grenColor);
		}
	}
	
	//--------------------------------------------------------------------------
	
	override protected void PositionReached()
	{
		SendMessageUpwards(BlockController.CALLBACK_HANDLE_SHOT_POSITION_REACHED);
	}
	
}
