using UnityEngine;
using System.Collections;

public class BombBlock : BaseBlock {
	
	public override void SetupInitialAppearance()
	{
		appearance.SetColors(appearance.blackColor, appearance.redColor);
		appearance.SetTexture("TextureBomb");
	}

}
