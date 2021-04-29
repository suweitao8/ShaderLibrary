// 反向点乘
float ndot(float2 a, float2 b )
{
    return a.x*b.x - a.y*b.y;
}

// 圆形
// r 半径
float sdCircle( float2 p, float r )
{
    return length(p) - r;
}

// 圆角盒子
// b 长宽
// r 半径
float sdRoundedBox( in float2 p, in float2 b, in float4 r )
{
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    float2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}

// 盒子
// b 长宽
float sdBox( in float2 p, in float2 b )
{
    float2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

// 方向性的盒子
// a 左边的点
// b 右边的点
// th 厚度
float sdOrientedBox( in float2 p, in float2 a, in float2 b, float th )
{
    float l = length(b-a);
    float2  d = (b-a)/l;
    float2  q = (p-(a+b)*0.5);
    q = mul(q, float2x2(d.x,-d.y,d.y,d.x));
    q = abs(q)-float2(l,th)*0.5;
    return length(max(q,0.0)) + min(max(q.x,q.y),0.0);    
}

// 线段
// a 左边的点
// b 右边的点
float sdSegment( in float2 p, in float2 a, in float2 b )
{
    float2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

// 棱形
// b 长宽
float sdRhombus( in float2 p, in float2 b ) 
{
    float2 q = abs(p);
    float h = clamp((-2.0*ndot(b, q)+ndot(b,b))/dot(b,b),-1.0,1.0);
    float d = length( q - 0.5*b*float2(1.0-h,1.0+h) );
    return d * sign( q.x*b.y + q.y*b.x - b.x*b.y );
}

// 梯形
// r1 底部长度
// r2 顶部长度
// he 高度
float sdTrapezoid( in float2 p, in float r1, float r2, float he )
{
    float2 k1 = float2(r2,he);
    float2 k2 = float2(r2-r1,2.0*he);
    p.x = abs(p.x);
    float2 ca = float2(p.x-min(p.x,(p.y<0.0)?r1:r2), abs(p.y)-he);
    float2 cb = p - k1 + k2*clamp( dot(k1-p,k2)/dot(k2, k2), 0.0, 1.0 );
    float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot(ca, ca),dot(cb, cb)) );
}

// 平行四边形
// wi 宽
// he 高
// sk 上下横轴的距离
float sdParallelogram( in float2 p, float wi, float he, float sk )
{
    float2 e = float2(sk,he);
    p = (p.y<0.0)?-p:p;
    
    // horizontal edge
    float2  w = p - e; w.x -= clamp(w.x,-wi,wi);
    float2  d = float2(dot(w,w), -w.y);
    
    // vertical edge
    float s = p.x*e.y - p.y*e.x;
    p = (s<0.0)?-p:p;
    float2  v = p - float2(wi,0); v -= e*clamp(dot(v,e)/dot(e,e),-1.0,1.0);
    d = min( d, float2(dot(v,v), wi*he-abs(s)));
     
    return sqrt(d.x)*sign(-d.y);
}

// 等边三角形
float sdEquilateralTriangle(  in float2 p )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - 1.0;
    p.y = p.y + 1.0/k;
    if( p.x+k*p.y>0.0 ) p=float2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0, 0.0 );
    return -length(p)*sign(p.y);
}

// 等腰三角形
// q x为宽, y为高(应为负数，以上顶点为中心)
float sdTriangleIsosceles( in float2 p, in float2 q )
{
    p.x = abs(p.x);
    float2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0 );
    float2 b = p - q*float2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0 );
    float s = -sign( q.y );
    float2 d = min( float2( dot(a,a), s*(p.x*q.y-p.y*q.x) ),
                  float2( dot(b,b), s*(p.y-q.y)  ));
    return -sqrt(d.x)*sign(d.y);
}

// 三角形
// p012 三个顶点相对于p的位置
float sdTriangle( in float2 p, in float2 p0, in float2 p1, in float2 p2 )
{
    float2 e0 = p1-p0, e1 = p2-p1, e2 = p0-p2;
    float2 v0 = p -p0, v1 = p -p1, v2 = p -p2;
    float2 pq0 = v0 - e0*clamp( dot(v0,e0)/dot(e0,e0), 0.0, 1.0 );
    float2 pq1 = v1 - e1*clamp( dot(v1,e1)/dot(e1,e1), 0.0, 1.0 );
    float2 pq2 = v2 - e2*clamp( dot(v2,e2)/dot(e2,e2), 0.0, 1.0 );
    float s = sign( e0.x*e2.y - e0.y*e2.x );
    float2 d = min(min(float2(dot(pq0,pq0), s*(v0.x*e0.y-v0.y*e0.x)),
                     float2(dot(pq1,pq1), s*(v1.x*e1.y-v1.y*e1.x))),
                     float2(dot(pq2,pq2), s*(v2.x*e2.y-v2.y*e2.x)));
    return -sqrt(d.x)*sign(d.y);
}

// 不均匀胶囊
// r1 下半径
// r2 上半径
// h 高度
float sdUnevenCapsule( float2 p, float r1, float r2, float h )
{
    p.x = abs(p.x);
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(p,float2(-b,a));
    if( k < 0.0 ) return length(p) - r1;
    if( k > a*h ) return length(p-float2(0.0,h)) - r2;
    return dot(p, float2(a,b) ) - r1;
}

// 五边形
// r 半径
float sdPentagon( in float2 p, in float r )
{
    const float3 k = float3(0.809016994,0.587785252,0.726542528); // pi/5: cos, sin, tan
    p.y = -p.y;
    p.x = abs(p.x);
    p -= 2.0*min(dot(float2(-k.x,k.y),p),0.0)*float2(-k.x,k.y);
    p -= 2.0*min(dot(float2( k.x,k.y),p),0.0)*float2( k.x,k.y);
    p -= float2(clamp(p.x,-r*k.z,r*k.z),r);    
    return length(p)*sign(p.y);
}

// todo 六边形
float sdHexagon( in float2 p, in float r )
{
    const float3 k = float3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= float2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p)*sign(p.y);
}

// 绘制数字
float drawDigit(in int n, in float2 p)
{		
    // digit bitmap by P_Malin (https://www.shadertoy.com/view/4sf3RN)
    int lut[10];
    lut[0] = 480599;
    lut[1] = 139810;
    lut[2] = 476951;
    lut[3] = 476999;
    lut[4] = 71028;
    lut[5] = 464711;
    lut[6] = 464727;
    lut[7] = 476228;
    lut[8] = 481111;
    lut[9] = 481095;
    
    float2 xy = float2(p*float2(4,5));
    int   id = 4*xy.y + xy.x;
    return float( (lut[n]>>id) & 1 );
}

// Debug
float3 DebugSDF2D( in float d )
{
    float3 col = 0.;
    col = 1.0 - sign(d) * float3(0.1,0.4,0.7);
    col *= 1.0 - exp(-3.0*abs(d));
    col *= 0.8 + 0.2*cos(150.0*d);
    col = lerp( col, 1.0, 1.0-smoothstep(0.0,0.01,abs(d)) );
    return col;
}