#define RAY_MAX_DIST 100
#define RAY_SUF_DIST 1e-2
#define RAY_STEP 100

// 二维旋转矩阵
float2x2 RotationByAngle(float a)
{
    float s = sin(a);
    float c = cos(a);
    return float2x2(c, -s, s, c);
}

// 圆球距离
// sphere.xyz 是中心位置
// sphere.w 是半径
float sdSphere( float3 p, float s )
{
    return length(p)-s;
}

float sdEllipsoid( in float3 p, in float3 r )
{
    float k0 = length(p/r);
    float k1 = length(p/(r*r));
    return k0*(k0-1.0)/k1;
}

// 立方体距离
// center 中心点
// size 大小
float sdCube(float3 p, float3 center, float3 size)
{
    p -= center;
    p = abs(p)-size;
    return length(max(p, 0.)) +
        min(max(p.x, max(p.y, p.z)), 0.);
}

float sdCube(float2 p, float2 center, float2 size)
{
    p -= center;
    p = abs(p)-size;
    return length(max(p, 0.)) +
        min(max(p.x, p.y), 0.);
}

// 高度
float sdPlane(float3 p, float height)
{
    return p.y - height;
}

// 陀螺
float sdGyroid(float3 p,
    float scale,
    float thickness,
    float bias)
{
    float3 gp = p * scale;
    float result =
        abs(dot(sin(gp), cos(gp.zxy)) - bias)
        / scale - thickness;
    result *= 0.8;
    return result;
}

// 胶囊
float sdCapsule(float3 p, float3 a, float3 b, float r)
{
    float3 ap = p - a;
    float3 ab = b - a;
    float t = dot(ap, ab) / dot(ab, ab);
    t = saturate(t);
    float3 c = a + ab * t;
    return length(p - c) - r;
}

// 圆柱距离
float sdCylinder(float3 p, float3 a, float3 b, float r)
{
    float3 ap = p - a;
    float3 ab = b - a;
    float t = dot(ap, ab) / dot(ab, ab);
    float3 c = a + ab * t;
    float x = length(p - c) - r;
                
    float y = (abs(t - 0.5) - 0.5) * length(ab);
    float e = length(float2(max(x, 0), max(y, 0)));
    float i = min(max(x, y), 0);
    return e + i;
}

// 法线示例 
float3 GetNormalDemo(float3 p)
{
    float2 e = float2(1e-3, 0);
    float4 sphere = float4(0.0, 0.0, 0.0, 0.5);
    float3 n = sdSphere(p, sphere) - float3(
        sdSphere(p - e.xyy, sphere),
        sdSphere(p - e.yxy, sphere),
        sdSphere(p - e.yyx, sphere)
    );
    return normalize(n);
}

// 射线示例
float RaycastDemo(float3 ro, float3 rd)
{
    float d = 0;
    float4 sphere = float4(0.0, 0.0, 0.0, 0.5);
    for (int i = 0; i < RAY_STEP; i++)
    {
        float3 p = ro + rd * d;
        float dS = sdSphere(p, sphere);
        d += dS;
        if (d > RAY_MAX_DIST) break;
    }
    return d;
}

// 阴影示例
float AttenuationDemo(float3 p, float3 n, float3 l)
{
    float shadow = RaycastDemo(p + n * RAY_SUF_DIST * 2, l);
    return 1 - step(RAY_MAX_DIST, shadow);
}

// 两原型融合
float smin(float a, float b, float k)
{
    // 边角差值高度
    float h = max(k-abs(a-b),0.0);
    // 融合两者，减去差值
    // h*h 是为了用二次方的弧度
    // /k 是为了保持高度
    // *0.25 是为了降低减去的高度
    return min(a, b) - h*h/k*0.25;
}

float2 smin( float2 a, float2 b, float k )
{
    float h = saturate(0.5+0.5*(b.x-a.x)/k);
    return lerp(b, a, h) - k*h*(1.0-h);
}

float smax( float a, float b, float k )
{
    float h = max(k-abs(a-b),0.0);
    return max(a, b) + h*h*0.25/k;
}

// 建立相机坐标系
void buildWUV(float3 ro, float3 ta,
    out float3 w,
    out float3 u,
    out float3 v)
{
    w = normalize(ta - ro);
    u = normalize(cross(w, float3(0.0, 1.0, 0.0)));
    v = cross(u, w);
}
