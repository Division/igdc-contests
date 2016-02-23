using UnityEngine;
using System.Collections;

public class PointBlock : BaseBlock {

	public override void SetupInitialAppearance()
	{
		appearance.SetColors(appearance.grenColor, appearance.blueColor);
		appearance.SetTexture("TexturePoint");
	}

}
