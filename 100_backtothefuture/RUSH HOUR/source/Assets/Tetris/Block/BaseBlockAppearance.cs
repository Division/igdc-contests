using UnityEngine;
using System.Collections;

public class BaseBlockAppearance : MonoBehaviour {
	
	//**************************************************************************
	//
	// ColorPair
	//
	//**************************************************************************
	
	public class ColorPair
	{
		public ColorPair (Color[] inColor, Material inMaterial)
		{
			color = inColor;
			material = inMaterial;
			startTime = Time.time;
			targetTime = Time.time;
		}
		
		public void AnimateColor(Color targetColor, float animationDuration = 0.5f)
		{
			color[1] = targetColor;
			startTime = Time.time;
			targetTime = Time.time + animationDuration;
		}
		
		public Color currentColor { get { return color[1]; } 
							        set { color[0] = color[1] = value; startTime = targetTime; } }
		
		public Color[] color;
		public Material material;
		public float startTime;
		public float targetTime;
	};
	
	//**************************************************************************
	//
	// Public
	//
	//**************************************************************************
	
	//-------------------
	// Editor connections
	public Transform blockObject;
	public Color blueColor;
	public Color redColor;
	public Color grenColor;
	public Color whiteColor;
	public Color yellowColor;
	public Color blackColor;
	
	//-------------------
	// Const
	const string NAME_OUTER_SPACE = "Box007";
	const string NAME_INNER_SPACE = "Object002";
	const string NAME_CIRCLE = "Object003";
	const string NAME_FRONT = "Object004";
	
	const string MATERIAL_OUTER_SPACE = "OuterMaterial";
	const string MATERIAL_INNER_SPACE = "InnerMaterial";
	const string MATERIAL_CIRCLE = "CircleMaterial";
	const string MATERIAL_FRONT = "FrontMaterial";
	
	//-------------------
	// Properties
	public ColorPair outerPair { get { return pairs[0]; } }
	public ColorPair innerPair { get { return pairs[1]; } }
	public ColorPair circlePair { get { return pairs[2]; } }
	public ColorPair frontPair { get { return pairs[3]; } }
	
	//**************************************************************************
	// Predefined animations
	
	public void SetDefaultColors()
	{
		outerPair.currentColor = whiteColor;
		innerPair.currentColor = Color.red;
		circlePair.currentColor = Color.white;
		frontPair.currentColor = grenColor;
	}
	
	//--------------------------------------------------------------------------
	
	public void SetTexture(string textureName)
	{
		Texture texture = Resources.Load(textureName) as Texture;
		circleMaterial.mainTexture = texture;
	}
	
	//--------------------------------------------------------------------------
	
	public void SetColors(Color mainColor, Color frontColor, float duration = 0)
	{
		if (duration > 0)
		{
			outerPair.AnimateColor(mainColor, duration);
			innerPair.AnimateColor(mainColor, duration);
			frontPair.AnimateColor(mainColor, duration);
			circlePair.AnimateColor(frontColor, duration);
		} else 
		{
			outerPair.currentColor = mainColor;
			innerPair.currentColor = mainColor;
			frontPair.currentColor = mainColor;
			circlePair.currentColor = frontColor;
		}
		
	}
	
	//**************************************************************************
	//
	// MonoBehaviour
	//
	//**************************************************************************
	
	void Awake() 
	{
		AssignObjects();
		AssignMaterials();
		InitColors();
	}
	
	//--------------------------------------------------------------------------
	
	void Update() 
	{
		ProcessColors();
	}
	
	//**************************************************************************
	//
	// Protected
	//
	//**************************************************************************
	
	//-------------------
	// Internal game objects
	protected GameObject outerSpace;
	protected GameObject innerSpace;
	protected GameObject circle;
	protected GameObject front;
	
	//-------------------
	// Materials
	protected Material outerSpaceMaterial;
	protected Material innerSpaceMaterial;
	protected Material circleMaterial;
	protected Material frontMaterial;
	
	//-------------------
	// Colors
	protected Color[] outerColor;
	protected Color[] innerColor;
	protected Color[] circleColor;
	protected Color[] frontColor;
	protected ColorPair[] pairs;
	
	//**************************************************************************
	// Initialization
	
	protected void AssignObjects()
	{
		outerSpace = blockObject.Find(NAME_OUTER_SPACE).gameObject;
		innerSpace = blockObject.Find(NAME_INNER_SPACE).gameObject;
		circle = blockObject.Find(NAME_CIRCLE).gameObject;
		front = blockObject.Find(NAME_FRONT).gameObject;
	}
	
	//--------------------------------------------------------------------------
	
	protected void AssignMaterials()
	{
		outerSpaceMaterial = new Material(Resources.Load(MATERIAL_OUTER_SPACE) as Material);
		innerSpaceMaterial = new Material(Resources.Load(MATERIAL_INNER_SPACE) as Material);
		circleMaterial = new Material(Resources.Load(MATERIAL_CIRCLE) as Material);
		frontMaterial = new Material(Resources.Load(MATERIAL_FRONT) as Material);
		
		outerSpace.renderer.material = outerSpaceMaterial;
		innerSpace.renderer.material = innerSpaceMaterial;
		circle.renderer.material = circleMaterial;
		front.renderer.material = frontMaterial;
	}
	
	//--------------------------------------------------------------------------
	
	protected void InitColors()
	{
		Color color;
		
		color = Color.white;
		outerColor = new Color[] {color, color, color};
		
		innerColor = new Color[] {color, color, color};
		
		circleColor = new Color[] {color, color, color};
		
		frontColor = new Color[] {color, color, color};
		
		pairs = new ColorPair[] { new ColorPair(outerColor, outerSpaceMaterial),
								  new ColorPair(innerColor, innerSpaceMaterial),
								  new ColorPair(circleColor, circleMaterial),
								  new ColorPair(frontColor, frontMaterial) };
	}
	
	//**************************************************************************
	// Animation
	
	protected void ProcessColors()
	{
		
		foreach (ColorPair pair in pairs)
		{
			float koef = Mathf.Max(Time.time - pair.startTime, 0.001f) / (pair.targetTime - pair.startTime);
			pair.color[2] = Color.Lerp(pair.color[0], pair.color[1], koef);
			pair.material.color = pair.color[2];
		}
	}
	
}
