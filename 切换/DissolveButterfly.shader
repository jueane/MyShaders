Shader "Custom/DissolveButterfly" {
	Properties{
		_DissAmount("DissAmount", Range(-10, 35)) = 1
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BackTex("BackGround", 2D) = "white"{}
	}
	SubShader{
			Pass{

				CGPROGRAM
				
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				float _DissAmount;
				sampler2D _MainTex;
				sampler2D _BackTex;

				struct a2v {
					float4 vertex:POSITION;

					float4 mainTex:TEXCOORD0;
					float4 bgTex:TEXCOORD1;
				};

				struct v2f{
					float4 pos:SV_POSITION;
					float4 screenPos:TEXCOORD3;

					float2 uv:TEXCOORD0;
					float2 uvBg:TEXCOORD1;
				};

				v2f vert(a2v v){
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
					o.screenPos = ComputeScreenPos(o.pos);
					
					o.uv = v.mainTex.xy;
					o.uvBg = v.bgTex.xy;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target{
					fixed3 rgb = tex2D(_MainTex, i.uv).rgb;
					fixed3 rgbBg = tex2D(_BackTex, i.uv).rgb;


					float2 pos = float2(i.screenPos.x - 0.5, i.screenPos.y - 0.5);
					float x = pos.x;
					float y = pos.y;

					float r = sqrt(pow(x, 2) + pow(y, 2));

					float t;
					float3 n;
					
					float theta = atan2(y,x);
					
					float e=2.71828;
					float pi=3.14159;
					
					//蝴蝶
					float s1 = pow(2.718, sin(theta)) - 2 * cos(4 * theta) + sin((15 * 24 + 1) / 24 * (1 * theta - 3.14));
					float s12 = pow(2.71828, sin(theta)) - 2 * cos(4 * theta) + sin((12 * 14 + 1) / 24 * (2* theta - pi));

					float s13=pow(2.71828,cos(theta-pi/2))-2*cos(4*(theta-pi/2))+pow(sin((theta-pi/2)/12),5);
					
					//三叶草
					float s3 =cos(3 *theta);
					//三叶草-不规则
					float s31=pow(2.71828,y/r)+cos(3*atan2(y,x));
					//5叶草
					float s5 =  cos(5 * atan2(y,x));
					//5叶草——不规则
					float s51 = pow(2.718, sin(theta)) - 2 * cos(5 * theta) +pow(sin((2 * theta - 3.14)/24),5);
					
					//海星
					float s6=pow( 2.71828,y/r) - 0.5*cos(7*atan2(y,x)) + sin( (33*atan2(y,x)-pi)/7);

					//菊花
					float s91=sin(7.04166666*(2*atan2(y,x)-3.14159));
					

					if (r<s6*0.1){
						n = float3(1, 0, 0);
					}else{
						n = float3(0, 1, 0);
					}

					return float4(n, 1);
				}

					ENDCG
			}
		}
}