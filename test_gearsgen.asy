include gearsgen;
path p = involute(1,0,6,100);

// Draw the origin
unitsize(1inch);
real crossSize = .1;
draw((0,crossSize)--(0,-crossSize));
draw((-crossSize,0)--(crossSize,0));
draw(unitcircle);

draw(p,blue);
//dot(p,red);
draw(scale(2)*unitcircle);
dot(involute_intersect_with_r(2),red);

