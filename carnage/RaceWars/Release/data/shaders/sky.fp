uniform sampler2D texture;
uniform sampler2D lines;
uniform sampler2D normalMap;
uniform vec4 clr;

uniform vec3 LightDir; // world-space

uniform int LightCount;
uniform vec3 Light0; // world-space position of first light
uniform vec3 Light1;
uniform vec3 Light2;
uniform vec3 Light3;
uniform vec3 Light4;
uniform vec3 Light5;

uniform float SunlightPower;

varying vec2 texcoord;
varying vec3 pos; // world-space position

const float kc = 0.5;
const float kl = 0.005;
const float kq = 0.0001;

void main() {

	vec4 tl = texture2D(lines,texcoord);
	float blend = (tl.r+tl.g+tl.b)/3.0;
	//float blend = 0.1;
	
	vec4 diffColor = texture2D(texture,texcoord);
	//vec4 diffColor = vec4(0.2,0.09,0.38,1);
	
	vec3 normal = normalize(texture2D(normalMap,texcoord).xyz*2.0 - vec3(1.0,1.0,1.0));
	normal.y = -normal.y;
	
	float diff = max(dot(normal,LightDir),0.0);
	//float diff = 1.0;
	
	vec4 res = vec4(diffColor*diff*SunlightPower*2.0);	
	res.a = 1.0;		
		
	vec4 CarColor = vec4(0.3,1.0,1.0,1.0);
	
	vec3 cLightDir;
	float Dist;
	
	if (LightCount > 0) {
		cLightDir = Light0-pos;
		Dist = length(cLightDir);
		cLightDir /= Dist;
		diff = max(dot(normal,cLightDir),0.0);
		diff /= kc + kl*Dist + kq*Dist*Dist;
		res += CarColor * diff;
	}
	
	if (LightCount > 1) {
		cLightDir = Light1-pos;
		Dist = length(cLightDir);
		cLightDir /= Dist;
		diff = max(dot(normal,cLightDir),0.0);
		diff /= kc + kl*Dist + kq*Dist*Dist;
		res += CarColor * diff;	
	}
	
	if (LightCount > 2) {
		cLightDir = Light2-pos;
		Dist = length(cLightDir);
		cLightDir /= Dist;
		diff = max(dot(normal,cLightDir),0.0);
		diff /= kc + kl*Dist + kq*Dist*Dist;
		res += CarColor * diff;	
	}	
	
	if (LightCount > 3) {
		cLightDir = Light3-pos;
		Dist = length(cLightDir);
		cLightDir /= Dist;
		diff = max(dot(normal,cLightDir),0.0);
		diff /= kc + kl*Dist + kq*Dist*Dist;
		res += CarColor * diff;	
	}	

	if (LightCount > 4) {
		cLightDir = Light4-pos;
		Dist = length(cLightDir);
		cLightDir /= Dist;
		diff = max(dot(normal,cLightDir),0.0);
		diff /= kc + kl*Dist + kq*Dist*Dist;
		res += CarColor * diff;	
	}	
	
	if (LightCount > 5) {
		cLightDir = Light5-pos;
		Dist = length(cLightDir);
		cLightDir /= Dist;
		diff = max(dot(normal,cLightDir),0.0);
		diff /= kc + kl*Dist + kq*Dist*Dist;
		res += CarColor * diff;	
	}	

	if (blend > 0.1) {
		res = mix(res,clr,0.2);
	}
	
	
	gl_FragColor = res;
}