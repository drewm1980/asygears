// Tools for working with asymptote paths.
// Most of these should already be a part of asymptote

path remove_subpath(path p, int start, int stop)
{
	path p1 = subpath(p,0,start);
	path p2 = subpath(p,stop,length(p));
	return p1&p2;
}

void test_remove_subpath(){
	path p = (0,0)--(0,1)--(0,1)--(0,2);
	path p2 = remove_subpath(p,1,2);
	assert(p2==(0,0)--(0,1)--(0,2));
	write("test 1 passed!");
}
test_remove_subpath();

path remove_redundant_control_points(path p){
	path pNew = p;
	int i=0;
	while(i<length(pNew))
	{
		pair p1 = point(pNew,i);
		pair p2 = point(pNew,i+1);
		if(p1 == p2){
			pNew = remove_subpath(pNew,i,i+1);
		}
		else{i = i+1;}
	}
	return pNew;
}

void test_remove_redundant_control_points(){
	path p = (0,0)--(0,1)--(0,1)--(0,2);
	path p2 = remove_redundant_control_points(p);
	assert(p2==(0,0)--(0,1)--(0,2));
	write("test 2 passed!");
}
test_remove_redundant_control_points();

path join(path[] paths){
	path[] ps = copy(paths);
	path p = ps[0];

}
