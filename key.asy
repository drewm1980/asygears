import graph;
path slot(pair c1, pair c2, real r)
{
	real l = abs(c2-c1);
	path p = arc((0,0),r,90,270,CCW)--arc((l,0),r,270,90,CCW)--cycle;
	p = rotate(degrees(c2-c1))*p;
	p = shift(c1)*p;
	return p;
};

unitsize(1inch);
real crossSize = 1;
draw((0,crossSize)--(0,-crossSize));
draw((-crossSize,0)--(crossSize,0));

draw(slot((0,0),(1,0),0.5)); // unit
draw(slot((0,0),(1,1),0.5)); // diagonal
draw(slot((0,1),(1,2),0.5)); // shifted up 1
