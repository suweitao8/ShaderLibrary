// 绘制数字
float drawDigit(in int n, in float2 p)
{		
    // digit bitmap by P_Malin (https://www.shadertoy.com/view/4sf3RN)
    int lut[10] = new int[10] {
        480599,
        139810,
        476951,
        476999,
        71028,
        464711,
        464727,
        476228,
        481111,
        481095,
    };
    // lut[0] = 480599;
    // lut[1] = 139810;
    // lut[2] = 476951;
    // lut[3] = 476999;
    // lut[4] = 71028;
    // lut[5] = 464711;
    // lut[6] = 464727;
    // lut[7] = 476228;
    // lut[8] = 481111;
    // lut[9] = 481095;
    
    float2 xy = float2(p*float2(4,5));
    int   id = 4*xy.y + xy.x;
    return float( (lut[n]>>id) & 1 );
}