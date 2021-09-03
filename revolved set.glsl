#version 300 es

precision mediump float;
out vec4 outColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float sdBrot( in vec2 c )
{
    c = vec2(c.y, c.x);
    #if 1
    {
        float c2 = dot(c, c);
        // skip computation inside M1 - http://iquilezles.org/www/articles/mset_1bulb/mset1bulb.htm
        if( 256.0*c2*c2 - 96.0*c2 + 32.0*c.x - 3.0 < 0.0 ) return 0.0;
        // skip computation inside M2 - http://iquilezles.org/www/articles/mset_2bulb/mset2bulb.htm
        if( 16.0*(c2+2.0*c.x+1.0) - 1.0 < 0.0 ) return 0.0;
    }
    #endif

    // iterate
    float di =  1.0;
    vec2 z  = vec2(0.0);
    float m2 = 0.0;
    vec2 dz = vec2(0.0);
    for( int i=0; i<32; i++ )
    {
        if( m2>1024.0 ) { di=0.0; break; }

		// Z' -> 2·Z·Z' + 1
        dz = 2.0*vec2(z.x*dz.x-z.y*dz.y, z.x*dz.y + z.y*dz.x) + vec2(1.0,0.0);
			
        // Z -> Z² + c			
        z = vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y ) + c;
			
        m2 = dot(z,z);
    }

    z = vec2(z.y, z.x);
    // distance	
	// d(c) = |Z|·log|Z|/|Z'|
	float d = 0.5*sqrt(dot(z,z)/dot(dz,dz))*log(dot(z,z));
    if( di>0.5 ) d=0.0;
	
    return d;
}



vec2 opRevolution( in vec3 p, float w )
{
    return vec2( length(p.yz) - w, p.x);
}

//---------------------------------

float map(in vec3 pos)
{
    float d = 1.;
    // cross 2D
    /*{
    vec3 q = pos - vec3(0.0,0.0,-2.0);
    d = min(d,opExtrussion(q, sdBrot( q.xy), 0.005 ));
    }*/
    
    // revolved cross
    {
    vec3 q = pos - vec3(.66,.66,1.);
    d = min(d, sdBrot(opRevolution(q,0.)));
    }

    return d;
}

// http://iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
vec3 calcNormal( in vec3 pos )
{
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    return normalize( e.xyy*map( pos + e.xyy*ep ) + 
					  e.yyx*map( pos + e.yyx*ep ) + 
					  e.yxy*map( pos + e.yxy*ep ) + 
					  e.xxx*map( pos + e.xxx*ep ) );
}

// http://iquilezles.org/www/articles/rmshadows/rmshadows.htm
float calcSoftshadow( in vec3 ro, in vec3 rd, float tmin, float tmax, const float k )
{
	float res = 1.0;
    float t = tmin;
    for( int i=0; i<50; i++ )
    {
		float h = map( ro + rd*t );
        res = min( res, k*h/t );
        t += clamp( h, 0.03, 0.20 );
        if( res<0.005 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );
}

#define AA 2

void main() {
	vec3 tot = vec3(0.0);
    
    #if AA>1
    for( int m=0; m<AA; m++ )
    for( int n=0; n<AA; n++ )
    {
        // pixel coordinates
        vec2 o = vec2(float(m),float(n)) / float(AA) - 0.5;
        vec2 p = (-u_resolution.xy + 2.0*(gl_FragCoord.xy+o))/u_resolution.y;
        #else    
        vec2 p = (-u_resolution.xy + 2.0*gl_FragCoord.xy)/u_resolution.y;
        #endif
 
        vec3 ro = vec3(-.0,3.0,6.0);
        vec3 rd = normalize(vec3(p-vec2(0.0,1.0),-2.0)) * 0.63;

        float t = 5.0;
        for( int i=0; i<64; i++ )
        {
            vec3 p = ro + t*rd;
            float h = map(p);
            if( abs(h)<0.001 || t>10.0 ) break;
            t += h;
        }

        vec3 col = vec3(0.0, 0.0039, 0.0078);

        if( t<10.0 )
        {
            vec3 pos = ro + t*rd;
            vec3 nor = calcNormal(pos);
            vec3  lig = normalize(vec3(-5.,-1.,-1.));
            float dif = clamp(dot(nor,lig),0.0,0.5);
            float sha = calcSoftshadow( pos, lig, 0.001, 1.0, 1.0 );

            vec3  lig2 = normalize(vec3(6.,200.,-4.));
            float dif2 = clamp(dot(nor,lig2),0.0,1.);
            float sha2 = calcSoftshadow( pos, lig2, 0.001, 1.0, 2.0 );

            col = vec3(0.1255, 0.0, 0.4745) + dif*sha*vec3(0.9176, 0.0, 1.0) + dif2*sha2*vec3(1.0, 0.0, 0.0);
        }

        col = sqrt( col );
	    tot += col;
    #if AA>1
    }
    tot /= float(AA*AA);
    #endif

	outColor = vec4( tot, 1.0 );
}