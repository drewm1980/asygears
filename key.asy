//--------------------------Unit Specific, User Tunable Parameters-------------------------//
unitsize(1inch);
real paperwidth=24inches;
real paperheight=12inches;
size(paperwidth,paperheight,IgnoreAspect);

// Biological data for user, in decreasing order of importance
// Default values are taken from Drew Wagner's hands.
real averageFingerLength = 4; // Fingers straight out, knuckle to fingertips, not including thumb.
real comfortableKeySpan = 7; // Splay your fingers, measure distance from Pinkytip to Thumbtip. 
real fingerWidth = 5/8; // The width of your middle fingertip

// Keyboard Construction Parameters
real keyboardDepth= 18; // Make larger for more uniform key travel, but deeper keyboard
real mainShaftDiameter = .24;
real mainBearingDiameter = 0.5;
real mainShaftSurroundingMaterialThickness = 3/8;  // Make larger for more material around bearing.
real caseThickness = 0.25;
real keyGap = .05; 
real bottomTouchpointHeight = 0; // Height of bottom touchpoint relative to rotation axis.

//--------------------------Derived Parameters-------------------------//
//  Everything below is relative to the above parameters, thus independent of units.
//  Most of these derived parameters are tuned for a keyboard is ergonomic
//  for Drew's Hands.  If you are not Drew, set Biological Data before tuning these.

int rowCount = 5; // The number of rows in the keyboard.
real radialKeyGap = keyGap;// If the adjacent keys rub front-back, increase this 
real caseGap = radialKeyGap*2;

pair touchpointStart = (keyboardDepth
		-2*caseThickness
		-mainBearingDiameter/2 
		-mainShaftSurroundingMaterialThickness
		-caseGap
		,bottomTouchpointHeight);  // Location of the top front of the lowermost touch point
real rotationDistanceAtFront = 1.5*fingerWidth;  // Change this to modify how far the keys travel
real touchpointLength = 0.5*averageFingerLength;  // Depth of each touchpoint (larger for more piano-like keys)

real frontKeySupportSize = touchpointLength/3;

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

pair rotate_up_to_new_height(real h, pair p){
	assert(p.y<h, "Height Cannot Be Achieved; Keyboard it probably silly tall; Try Lower Key Travel");
	real r = abs(p);
	// r*sin(theta)=h
	real theta = asin(h/r);
	return (r*cos(theta),h);
}

struct Touchpoint{
	pair bottomfront;
	pair topfront;
	pair topback;
	pair bottomback;
	path p;
	
	static Touchpoint Touchpoint(pair prevUpperLeftCorner, bool isFirst=false)
	{
		Touchpoint tp = new Touchpoint;
		//pair prevUpperLeftCorner = previousTouchpoint.topback;
		real rFront = abs(prevUpperLeftCorner)-radialKeyGap;

		// Compute the top, front corner of the touchpoint
		pair topfront = prevUpperLeftCorner - unit(prevUpperLeftCorner)*radialKeyGap;
		topfront = rotate_up_to_new_height(prevUpperLeftCorner.y+depressedLedge, topfront);
		topfront = rotate(keyTravelAngle)*topfront;

		// The top, back corner of the touchpoint
		pair topback = topfront - (touchpointLength, 0);
		real rBack = abs(topback);

		// The bottom, back corner of the touchpoint
		pair bottomback = rotate(-keyTravelAngle)*topback;
		bottomback = rotate(-degrees(sidewaysVisibilityTolerance/rBack))*bottomback;

		// The bottom, front of the touchpoint. 
		// Needs to be low enough to not be visible when the row in front is depressed.
		pair bottomfront = prevUpperLeftCorner - unit(prevUpperLeftCorner)*radialKeyGap;
		if(isFirst==false)	bottomfront = rotate(-keyTravelAngle)*bottomfront;
		bottomfront = rotate(-degrees(frontbackVisibilityTolerance/rFront))*bottomfront;

		tp.bottomfront = bottomfront;
		tp.topfront = topfront;
		tp.topback = topback;
		tp.bottomback = bottomback;
		tp.p = arc((0,0),bottomfront,topfront,CCW)--arc((0,0),topback,bottomback,CW)--cycle;	
		return tp;
	}

	static Touchpoint Touchpoint(Touchpoint previousTouchpoint)
	{
		Touchpoint tp = Touchpoint(previousTouchpoint.topback);	
		return tp;
	}
}
from Touchpoint unravel Touchpoint;

path arc_with_radius(pair a, pair b, real r){
	// If the requested r is too small to be achieveable, just return a line.
	if(r<abs(b-a)/2){
		return a--b;
	}
	pair mp = (a+b)/2;
	real h = sqrt(r^2 - abs(mp-a)^2);
	pair center = rotate(90)*unit(b-a)*h + mp;
	return arc(center, a, b, CCW);
}

struct Body
{
	// Row indexing is zero-based, starting at lowest row.
	path oddPath; 
	path evenPath; 
	void operator init(Touchpoint[] tps)
	{
		path oddPath; 
		path evenPath; 
		// The start point and end points of the part of the path that defines the key supports and cutout.
		pair keysPathStart; 
		pair keysPathEnd;


		// Handle the bottom touchpoint row.
		{
			Touchpoint tp = tps[0];
			Touchpoint tpAbove = tps[1];
			keysPathStart= tp.bottomback;
			keysPathStart = rotate(-keyTravelAngle + degrees(-frontKeySupportSize/abs(keysPathStart)))*keysPathStart;
			keysPathStart = unit(keysPathStart)*abs(tpAbove.topfront);  
			evenPath = arc_with_radius(keysPathStart, tp.bottomfront, touchpointLength*2);
			evenPath = evenPath--arc((0,0),tp.bottomfront,tp.topfront,CCW)--tp.topback;
			oddPath = arc((0,0),keysPathStart,tpAbove.topfront);
		}

		// Handle the middle touchpoint rows.
		for(int i=1; i<rowCount-1; ++i)
		{
			Touchpoint tpBelow = tps[i-1];
			Touchpoint tp = tps[i];
			Touchpoint tpAbove = tps[i+1];

			pair p1, p2, p3, p4;
			p1 = tpBelow.topback;
			p4 = tpAbove.topfront;
			
			// We ether need a cutout out make room for the adjacent touchpoints...
			p2 = rotate(-keyTravelAngle)*tp.bottomfront;
			p3 = rotate(-keyTravelAngle)*tp.bottomback;
			pair offsetDirection = unit(rotate(-90)*(p2-p3));
			p2 += keyGap*offsetDirection;
			p3 += keyGap*offsetDirection;
			p2 += (p2-p3);  // Extend to make intersection with circle easier.
			p3 += (p3-p2);  // Extend to make intersection with circle easier.
			real rBelow = abs(tpBelow.topback);
			real rAbove = abs(tpAbove.topfront);
			p2 = intersectionpoint(p2--p3, circle((0,0),rBelow));
			p3 = intersectionpoint(p2--p3, circle((0,0),rAbove));
			path cutout = arc((0,0),p1,p2,CW)--arc((0,0),p3,p4,CCW);

			//... or we need the top of the current touchpoint.
			path top = tp.topfront--tp.topback;

			if(i%2==0) 
			{
				evenPath = evenPath--top;
				oddPath = oddPath--cutout;
			}else{
				evenPath = evenPath--cutout;
				oddPath = oddPath--top;
			}
		}

		// Handle the top touchpoint row.
		{
			int i = rowCount-1;
			Touchpoint tpBelow = tps[i-1];
			Touchpoint tp = tps[i];

			pair p1, p2, p3, p4;
			p1 = tpBelow.topback;
			
			p2 = rotate(-keyTravelAngle)*tp.bottomfront;
			p3 = rotate(-keyTravelAngle)*tp.bottomback;
			pair offsetDirection = unit(rotate(-90)*(p2-p3));
			p2 += keyGap*offsetDirection;
			p3 += keyGap*offsetDirection;
			p2 += (p2-p3);  // Extend to make intersection with circle easier.
			p3 += (p3-p2);  // Extend to make intersection with circle easier.
			real rBelow = abs(tpBelow.topback);
			real r = abs(tp.topback);
			p2 = intersectionpoint(p2--p3, circle((0,0),rBelow));
			p3 = intersectionpoint(p2--p3, circle((0,0),r));
			path cutout = arc((0,0),p1,p2,CW)--p3;
			pair keysPathEnd= p3;

			//... or we need the top and back of the current touchpoint.
			path top = tp.topfront--arc((0,0),tp.topback,keysPathEnd,CW);

			if(i%2==0) 
			{
				evenPath = evenPath--top;
				oddPath = oddPath--cutout;
			}else{
				evenPath = evenPath--cutout;
				oddPath = oddPath--top;
			}
		}
		
		// The rest of the body of the key, common to both parts.
		path commonPath;
		commonPath = keysPathEnd--(0,0)--keysPathStart;

		this.oddPath = oddPath--commonPath;
		this.evenPath = evenPath--commonPath;
	}
}
	
//--------------------------Generate all paths, no duplication-------------------------//
Touchpoint[] touchpoints;
touchpoints[0] = Touchpoint(touchpointStart);
for(int i=1; i<rowCount; ++i)
{
	touchpoints[i] = Touchpoint(touchpoints[i-1]);
}

Body body = Body(touchpoints);

//--------------------------Drawing, with duplication of replicate parts-------------------------//
//fill(scale(mainShaftDiameter/2)*unitcircle); // The axis of rotation
//for(Touchpoint t:touchpoints)
//{
	//fill(t.p);
//}
//draw(body.evenPath, green+linewidth(.008inches));
//draw(body.oddPath, blue+linewidth(.004inches));

pen cutpen = black+linewidth(.001inches);
draw(scale(mainShaftDiameter)*unitcircle,cutpen); // The axis of rotation
draw(scale(mainShaftDiameter/2)*unitcircle,cutpen); // The axis of rotation
for(Touchpoint t:touchpoints)
{
	draw(t.p, cutpen);
}
draw(body.evenPath,cutpen);
draw(body.oddPath, cutpen);

