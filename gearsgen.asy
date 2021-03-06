import math;

// internal gear
bool internal = false;

// number of teeth
real N = 5;

// module
real m = 1.0;

// clearance
real c = 0.0;

// addendum offset
real off_a = 0.0;

// addendum/dedendum multiplier
real mul_a = 0.5;
real mul_d = 0.5;

// pitch
real p = 0.0;

// spacing
real s = 0.0;

// tip relief
real tr = 0.0;

// x- and y-offset, rotation
real off_x = 0.0;
real off_y = 0.0;
real off_r = 0.0;

// skip dxf header/footer generation
real e_mode = 0;

path linedata;

// theta in radians
pair frompolar(real r, real theta){
	return r*(cos(theta),sin(theta));
}

// Compute point on the involute of a unit circle parameterized by angle phi
// For reference, this can be found on mathworld.wolfram.com/CircleInvolute.html
// From Wolfram alpha, involute arc length function is phi^2/2
//   phi is tangential angle.
pair involute(real phi)
{
	real cphi = cos(phi);
	real sphi = sin(phi);
	return (cphi + phi*sphi, sphi - phi*cphi);
}
// Compute point on the involute of a unit circle parameterized by alpha
// For reference, this can be found on en.wikipedia.org/wiki/involute
pair involute_polar(real alpha)
{
	real r = sec(alpha); 
	real theta = tan(alpha) - alpha;
	return r*(cos(theta),sin(theta));
}
// Use the alpha parameterization to find the intersection of
// the involute of a unit circle with a larger circle of radius r
pair involute_intersect_with_r(real r)
{
	// r = sec(alpha) = 1/cos(alpha)
	// 1/r = cos(alpha)
	// alpha = acos(1/r)
	assert(r>0,"r must be strictly positive!");
	real alpha = acos(1/r);
	assert(abs(cos(alpha)-1)/r<.00001, "Error this should be invertible");
	real theta = tan(alpha) - alpha;
	return r*(cos(theta),sin(theta));
}

// Numerical approximation to the involute curve of a circle. 
path involute_path(real r, real phi_start, real phi_stop, int segments)
{
	path outpath = frompolar(r, phi_start);


	real deltaphi = (phi_stop - phi_start) / steps;
	for(int i = 1; i<=steps; ++i)
	{
		real phi = phi_start + i*deltaphi;
		pair s = frompolar(r,phi);
		pair p = s + rotate(-90)*frompolar(r*i*deltaphi, phi);

		outpath = outpath--p;
	}
	return outpath;
}


//// angles phi, phi_step in radians
//void involute_intersect_with_r2(real r1, real r2, real phi, real phi_step)
		//while(1)
        //{
			////sx = cos(phi) * r1
			////sy = sin(phi) * r1
			//pair s = frompolar(r1,phi);

			//x = r1 * phi
			//px = sx + sin(phi) * x;
			//py = sy - cos(phi) * x;

			//if sqrt(px**2 + py**2) > r2
				//if phi_step > 1e-10
					//return involute_intersect_with_r2(r1, r2, phi-phi_step, phi_step/2)
				//return [ phi, atan2(py, px) ]
			//phi = phi + phi_step
        //}


if (internal)
{
	//p, c = c, p;
	real temp = c;
	c = p;
	p = temp;

	s = s * -1.0;
	real t = 0.0;
}

real Dw = m*N;
real Dr = Dw - 2.0*mul_d*m;
real Do = Dw + 2.0*(mul_a*m + off_a);

//// phi_o = angle to the intersection point of the involute and the Do circle
//phi_o = involute_intersect_with_r2(Dr/2, Do/2, 1.0, 1.0)[1];

//// phi_tr = angle where the involute intersects the Do-2tr circle
//phi_tr = involute_intersect_with_r2(Dr/2, Do/2 - tr, 1.0, 1.0)[0];

//// ti = angle to the intersection point of the involute and the Dw circle
//ti = involute_intersect_with_r2(Dr/2, Dw/2, 1.0, 1.0)[1];

//// ts = angle for implementing spacing at Dw
//ts = pi*s / Dw;

//// t = angle span of bottom land
//t = pi/N - ti*2 + ts*2;

//for i in range(N)
    //{
		//phi1 = 2*pi*i/N - t/2 + off_r*(pi/180);
		//phi2 = phi1 + t;
		//phi3 = 2*pi*(i+1)/N - t/2 + off_r*(pi/180);
		//if c != 0
			//{
				//line(cos(phi1)*(Dr/2), sin(phi1)*(Dr/2), cos(phi1)*(Dr/2-c), sin(phi1)*(Dr/2-c));
			//line(cos(phi1)*(Dr/2-c), sin(phi1)*(Dr/2-c), cos(phi2)*(Dr/2-c), sin(phi2)*(Dr/2-c));
			//}
		//if c != 0
			//{
				//line(cos(phi2)*(Dr/2), sin(phi2)*(Dr/2), cos(phi2)*(Dr/2-c), sin(phi2)*(Dr/2-c));
			//}
		//ax, ay = involute(Dr/2, phi2, phi2 + phi_tr, 10);
		//bx, by = involute(Dr/2, phi3, phi3 - phi_tr, 10);
		//if t > 0
			//{
				//axt, ayt = ax, ay;
				//bxt, byt = bx, by;
				//phi_xo = phi_o + (tr/2)/(Do/2);
				//ax = cos(phi2 + phi_xo) * Do/2;
				//ay = sin(phi2 + phi_xo) * Do/2;
				//bx = cos(phi3 - phi_xo) * Do/2;
				//by = sin(phi3 - phi_xo) * Do/2;
				//line(axt, ayt, ax, ay);
				//line(bxt, byt, bx, by);
			//}
		//if p != 0
			//{
				//aa = atan2(ay, ax);
				//ar = sqrt(ay**2 + ax**2) + p;
				//ba = atan2(by, bx);
				//br = sqrt(by**2 + bx**2) + p;
				//line(ax, ay, cos(aa)*ar, sin(aa)*ar);
				//line(cos(aa)*ar, sin(aa)*ar, cos(ba)*br, sin(ba)*br);
				//line(bx, by, cos(ba)*br, sin(ba)*br);
			//}
		//else
			//{
				//line(ax, ay, bx, by);
			//}
    //}



