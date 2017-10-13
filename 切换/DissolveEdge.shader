Shader "Custom/DissolveEdge" {
	Properties{
		_DissAmount("DissAmount", Range(0, 3)) = 0
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

				//将坐标原点移至屏幕中心（原理：在当前点(0.5,0.5)显示点(0,0)的内容，也就是按向量(-0.5,-0.5)平移后的内容）
				float2 pos = float2(i.screenPos.x - 0.5, i.screenPos.y - 0.5);
				pos.x*=1.2;
				
				float x = pos.x;
				float y = pos.y;
				
				//当前点离屏幕中心的距离
				float r = sqrt(pow(pos.x, 2) + pow(pos.y, 2));
				
				float t;
				float3 finalcolor;

				float theta = atan2(y,x);
					
				float e=2.71828;
				float pi=3.14159;
				
				float s1 = pow(2.718, sin(theta)) - 2 * cos(4 * theta) + sin((15 * 24 + 1) / 24 * (1 * theta - 3.14));

				//三叶草-不规则
				float s31=pow(2.71828,y/r)+cos(3*atan2(y,x));
				float s32=pow(e,sin(theta))+cos(3*theta);

				//5叶草——不规则
				float s51 = pow(2.718, sin(theta)) - 2 * cos(5 * theta) +pow(sin((2 * theta - 3.14)/24),5);
				
				//海星
				float s6=pow( 2.71828,y/r) - 0.5*cos(7*atan2(y,x)) + sin( (33*atan2(y,x)-pi)/7);
				
				//尝试
				float s7=pow(e,sin(theta))-0.7*cos(5*theta-0.7);


				_DissAmount*=2.7;
				float inc=r*(12+s7) - _DissAmount;
				//加上形变
				inc-=0.35*r*s32*_DissAmount;

				float edge=0.5;
				t = 1 - smoothstep(0, 1,inc*edge);
				

				finalcolor = lerp(rgb, rgbBg, t);
				
				 if(t>0.9&&t<1){

					//finalcolor = float3(0.5,0.11,1);
					
					//fixed3 t1 = tex2D(_BackTex, i.uv*1.01).rgb;

					//finalcolor=t1;


				 }

				 //老版
				 //if(t>0.5){
					
					//fixed3 t1 = tex2D(_BackTex, i.uv*(2-t)).rgb;

					//finalcolor=t1;
				 //}



				 if(t>0.4&&t<0.6){
					finalcolor = float3(1,0,0);
				 }

				return float4(finalcolor, 1);
			}

				ENDCG
		}
	}
}