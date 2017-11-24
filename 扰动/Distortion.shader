Shader "Custom/Distortion"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}

		_R("R",Range(0,1)) = 0
		_Width("Width",Range(0,0.5)) = 0

		[Toggle]_Show("Show",Range(0,1)) = 0
	}
		SubShader
		{
			// No culling or depth
			Cull Off ZWrite Off ZTest Always

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;
			half4 _MainTex_TexelSize;
			float _R;
			float _Width;
			bool _Show;

			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = i.uv - float2(0.5,0.5);
				uv.x *= _MainTex_TexelSize.y / _MainTex_TexelSize.x;

				float2 center = float2(1,1)*_R;

				float dis = sqrt(pow(uv.x, 2) + pow(uv.y, 2));


				float halfWid = _Width / 2;
				float centerR = _R + halfWid;

				fixed4 col=float4(0,0,0,0);

				float power = 1;
				if (dis > _R&&dis < _R + _Width) {
					power = 1 - abs(dis - centerR) / halfWid;
					col.r = power;
				}

					if (_Show) {
						if (dis > _R&&dis < _R + _Width) {
							power *= 10;
							col = tex2D(_MainTex, i.uv + float2(_MainTex_TexelSize.x* power, _MainTex_TexelSize.y*power));
						}
						else {
							col = tex2D(_MainTex, i.uv);
						}
					}
					return col;
				}
				ENDCG
			}
		}
}
