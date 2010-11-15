//--------------------------Unit Specific, User Tunable Parameters-------------------------//
unitsize(1inch);

// Biological data for user, in decreasing order of importance
// Default values are taken from Drew Wagner's hands.
real averageFingerLength = 4; // Fingers straight out, knuckle to fingertips, not including thumb.
real comfortableKeySpan = 7; // Splay your fingers, measure distance from Pinkytip to Thumbtip. 
real fingerWidth = 5/8; // The width of your middle fingertip
//real forearmLength = 13; // Center of elbow to knuckles
//real eyeHeight = 23; // Bottom of elbow held at side to eye level

// Keyboard Construction Parameters
real keyboardDepth= 18; // Make larger for more uniform key travel, but deeper keyboard
real mainShaftDiameter = .24;
real mainBearingDiameter = 0.5;
real mainShaftSurroundingMaterialThickness = 3/8;  // Make larger for more material around bearing.
real caseThickness = 0.25;
real radialKeyGap = .03; // If the adjacent keys rub front-back, increase this number.
real bottomTouchpointHeight = 0; // Height of bottom touchpoint relative to rotation axis.

//--------------------------Derived Parameters-------------------------//
//  Everything below is relative to the above parameters, thus independent of units.
//  Most of these derived parameters are tuned for a keyboard is ergonomic
//  for Drew's Hands.  If you are not Drew, set Biological Data before tuning these.

int rowCount = 5; // The number of rows in the keyboard.
real caseGap = radialKeyGap*2;

pair touchpointStart = (keyboardDepth
		-2*caseThickness
		-mainBearingDiameter/2 
		-mainShaftSurroundingMaterialThickness
		-caseGap
		,bottomTouchpointHeight);  // Location of the top front of the lowermost touch point
real rotationDistanceAtFront = 1.5*fingerWidth;  // Change this to modify how far the keys travel
real touchpointLength = 0.5*averageFingerLength;  // Depth of each touchpoint (larger for more piano-like keys)

real depressedLedge = fingerWidth/8;  // When sliding a chord, how far your finger drops to next key

//pair eyeLocation = touchpointStart + (forearmLength,eyeHeight); // Used in visibility gap computations.
real sidewaysVisibilityTolerance = 1.5*radialKeyGap;  // Increase if bottom of an adjacent touchpoint is visible when a key is depressed.
real frontbackVisibilityTolerance = 1.5*radialKeyGap;  // Increase if bottom of the next higher row is visible when a key is depressed.

real keyTravelAngle = degrees(rotationDistanceAtFront/abs(touchpointStart));

//--------------------------Subroutines-------------------------//
import graph;
path slot(pair c1, pair c2, real r)
{
	real l = abs(c2-c1);
	path p = arc((0,0),r,90,270,CCW)--arc((l,0),r,270,90,CCW)--cycle;
	p = rotate(degrees(c2-c1))*p;
	p = shift(c1)*p;
	return p;
};

//// Move a point p left horizontally until it hits the right side of a circle of radius r
//pair move_in_horizontally(real r, pair p){
	//pair[] l = intersectionpoints((0,p.y)--p, r*unitcircle());
	//assert(l.length==1, "Radius Cannot Be Achieved; Try Lower Key Travel");
	//return l[0];
//}

pair rotate_up_to_new_height(real h, pair p){
	assert(p.y<h, "Height Cannot Be Achieved; Keyboard it probably silly tall; Try Lower Key Travel");
	real r = abs(p);
	// r*sin(theta)=h
	real theta = asin(h/r);
	return (r*cos(theta),h);
}

path rotary_touchpoint(path previousTouchpoint, bool bottomKey=false){
	pair prevUpperLeftCorner = (min(previousTouchpoint).x, max(previousTouchpoint).y);
	real rFront = abs(prevUpperLeftCorner)-radialKeyGap;

	// Compute the top, front corner of the touchpoint
	pair topfront = prevUpperLeftCorner - unit(prevUpperLeftCorner)*radialKeyGap;
	topfront = rotate_up_to_new_height(prevUpperLeftCorner.y+depressedLedge, topfront);
	topfront = rotate(keyTravelAngle)*topfront;
	//assert(rFront>0, "Rearmost key went beyond rotation axis; try increasing keyboard size");
	//pair topfront = move_in_horizontally(rFront, prevUpperLeftCorner);

	// The top, back corner of the touchpoint
	pair topback = topfront - (touchpointLength, 0);
	real rBack = abs(topback);

	// The bottom, back corner of the touchpoint
	pair bottomback = rotate(-keyTravelAngle)*topback;
	bottomback = rotate(-degrees(sidewaysVisibilityTolerance/rBack))*bottomback;

	// The bottom, front of the touchpoint. 
	// Needs to be low enough to not be visible when the row in front is depressed.
	pair bottomfront = prevUpperLeftCorner - unit(prevUpperLeftCorner)*radialKeyGap;
	if(bottomKey==false)	bottomfront = rotate(-keyTravelAngle)*bottomfront;
	bottomfront = rotate(-degrees(frontbackVisibilityTolerance/rFront))*bottomfront;

	//dot(topfront,red);	
	//dot(bottomfront,red);	
	//dot(topback,red);	
	//dot(bottomback,red);	

	// Construct the actual curve!
	path p = arc((0,0),bottomfront,topfront,CCW)--arc((0,0),topback,bottomback,CW)--cycle;	
	return p;
}
	
//--------------------------Generate all paths, no duplication-------------------------//
path[] touchpointProfiles;
touchpointProfiles[0] = rotary_touchpoint(touchpointStart, true);
for(int i=1; i<rowCount; ++i)
{
	touchpointProfiles[i] = rotary_touchpoint(touchpointProfiles[i-1]);
}
//--------------------------Drawing, with duplication of replicate parts-------------------------//

draw(scale(mainShaftDiameter/2)*unitcircle); // The axis of rotation

for(path p:touchpointProfiles)
{
	draw(p);
}

