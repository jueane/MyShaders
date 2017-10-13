Shader "Custom/DissolveButterflyReady10012" {
	Properties{
		_DissAmount("DissAmount", Range(0, 3)) = 1
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BackTex("BackGround", 2D) = "white"{}
		_DissolveTex("DissolveTex", 2D) = "white" {}

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
				sampler2D _DissolveTex;

				struct a2v {
					float4 vertex:POSITION;

					float4 mainTex:TEXCOORD0;
					float4 bgTex:TEXCOORD1;
					float4 disTex:TEXCOORD2;
				};

				struct v2f{
					float4 pos:SV_POSITION;
					float4 screenPos:TEXCOORD3;

					float2 uv:TEXCOORD0;
					float2 uvBg:TEXCOORD1;
					float2 uvDis:TEXCOORD2;
				};

				v2f vert(a2v v){
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
					o.screenPos = ComputeScreenPos(o.pos);


					o.uv = v.mainTex.xy;
					o.uvBg = v.bgTex.xy;
					o.uvDis = v.disTex.xy;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target{
					fixed3 rgb = tex2D(_MainTex, i.uv).rgb;
					fixed3 rgbBg = tex2D(_BackTex, i.uv).rgb;
					fixed3 rgbDis = tex2D(_DissolveTex, i.uv).rgb;

					//将坐标原点移至屏幕中心
					float2 pos = float2(i.screenPos.x - 1, i.screenPos.y);

					float x = pos.x;
					float y = pos.y*-0.7;

					//当前点离屏幕中心的距离
					float r = sqrt(pow(pos.x, 2) + pow(pos.y, 2));

					float t;
					float3 color;

					float theta = asin(y / r);

					//最新效果
					float s = pow(2.718, theta) - 22 * cos(7 * theta) + sin((9 * 5 + 1) / 12 * (1 * theta - 3.14));
					//float s = pow(2.718, theta) - 0.3 * cos(77 * theta) + sin((9 * 5 + 1) / 12 * (5 * theta - 3.14));
					//float s = pow(2.718, theta) - 1 * cos(77 * theta) + sin((192 * 0.1 + 1) / 992 * (0.2 * theta - 1.14));

					_DissAmount*=30;
					t = 1 - smoothstep(0, 1, r * 5 - _DissAmount*2 / (s*0.05 + 9)*rgbDis.r);
					//t*=rgbDis.r;

					color = lerp(rgb, rgbBg, t);

					return float4(color, 1);
				}

					ENDCG
			}
		}
}