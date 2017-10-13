Shader "Custom/DrawImage" {
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
					
					//透明度
					float t=0;
					float3 n;
					

					float r2=sqrt(pow(x+0.1,2)+pow(y*_ScreenParams.y/_ScreenParams.x,2));

					float r3=sqrt(pow(x,2)+pow(y,2));

					float r4=sqrt(pow(x,2)+pow(y/4,2));

					

					//n=float3(0,0,0);

					float inside=0;


					//绿色圆点
					if(r2<0.01){
						n.y=1;
					}

					//绿色方块
					if(x>0.1&&x<0.2 && y< 0.1 && y>0){
						n.y=1;
					}
					
					//蓝色圆形,纵
					if(r4<0.15){

						float t2=r4;
						
						n.x=0.5-t2;

						inside=1;
					}

					//蓝色圆形,横
					if(r3<0.3){
						float t1=r3/0.05;
						
							t=t1;
							n.x=1-t;
						
						inside=1;
					}



					//蓝色长条
					if(x>-0.3 && x<-0.2 && y<0.03 && y>-0.03){

						float xin=float2(-0.3,0);

						float dis=distance(float2(-0.3,0),float2(x,y));

						dis=dis/sqrt(pow(0.05,2)+pow(0.03,2));

						//if(dis>0.24){

						//n=float3(0,3,1);
						//}else{

						//	n=float3(0,0,1);
						//}

						//if(dis<t){
						//	t=dis;
						//n=float3(t,0,1);
						//}
					}

					

					if(inside==1){
						n=float3(1,0,0);

						float dis=distance(float2(0,0),float2(x,y));

						n.x=dis/0.5;

					}else{
					}



					
					return float4(n, 1);
				}

					ENDCG
			}
		}
}