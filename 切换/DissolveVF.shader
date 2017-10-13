Shader "PengLu/Unlit/DissolveVF" {
	Properties{
		_MainTex("主材质", 2D) = "white" {}
		_DissolveTex("溶解贴图", 2D) = "white" {}		//噪波图
		_Tile("溶解贴图的平铺大小", Range(0.1, 1)) = 1	//噪波图的平铺系数，平铺倍数与之成反比 

		_Amount("溶解值", Range(0, 1)) = 0.5				//溶解值，低于这个值，像素将被抛弃
		_DissSize("溶解边缘大小", Range(0, 1)) = 0.1		//预溶解范围大小

		_DissColor("溶解主色", Color) = (1, 0, 0, 1)		//预溶解范围渐变颜色，与_AddColor配合形成渐变色
		_AddColor("叠加色", Color) = (1, 1, 0, 1)
	}

	SubShader{
			Tags{ "RenderType" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			LOD 100

			Pass{
				CGPROGRAM
				#pragma vertex vert  
				#pragma fragment frag  
				#pragma multi_compile_fog  

				#include "UnityCG.cginc"  
				#define vec2 float2  
				#define vec3 float3  
				#define vec4 float4  
				#define mod fmod  
				#define mix lerp  
				// 屏幕的尺寸  
				#define iResolution _ScreenParams  
				// 屏幕中的坐标，以pixel为单位  
				#define gl_FragCoord ((i.srcPos.xy/i.srcPos.w)*_ScreenParams.xy)  

				sampler2D _MainTex, _DissolveTex;
				fixed4 _MainTex_ST, _DissolveTex_ST;
				half _Tile, _Amount, _DissSize;
				half4 _DissColor, _AddColor;


				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					half2 texcoord : TEXCOORD0;
					float4 srcPos : TEXCOORD1;
					//UNITY_FOG_COORDS(1)
				};

				v2f vert(appdata_t v)
				{
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.srcPos = ComputeScreenPos(o.pos);
					//UNITY_TRANSFER_FOG(o, o.pos);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					//对主纹理采样  
					fixed4 col = tex2D(_MainTex, i.texcoord);
					//对噪波贴图进行采样，取R值 
					float ClipTex = tex2D(_DissolveTex, i.texcoord / _Tile).r;
					//获取裁剪量 
					float ClipAmount = ClipTex - _Amount;
					if (_Amount > 0)
					{
						//噪波图中R通道颜色值低于外部量_Amount，则被裁剪
						//if (ClipAmount < 0)
						//{
						//	
						//	//col.a = 0;
						//}
						float l = ClipAmount < 0 ? 0 : ClipAmount;
						col.a = lerp(0, col.a, l / _Amount) ;
						//然后处理没被裁剪的值
						//else{
							//if (ClipAmount < _DissSize)
							//{
							//	//针对没被裁剪的点，如果裁剪量小于预溶解范围则使用lerp函数做渐变处理
							//	float4 finalColor = lerp(_DissColor, _AddColor, ClipAmount / _DissSize);
							//	//将获得的渐变颜色与主颜色叠加融合  
							//	col = finalColor;
							//}
						//}
					}
					//UNITY_APPLY_FOG(i.fogCoord, col);
					//UNITY_OPAQUE_ALPHA(col.a);  //影响透明度
					return col;
				}
				ENDCG
			}
		}

}