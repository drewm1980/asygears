import gearsgen.asy

// Draw the origin
unitsize(1inch);
real crossSize = 1;
draw((0,crossSize)--(0,-crossSize));
draw((-crossSize,0)--(crossSize,0));

draw(involute(1,0,1,20));

