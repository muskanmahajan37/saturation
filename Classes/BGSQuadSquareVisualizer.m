//
//  BGSQuadSquareVisualizer.m
//  Saturation
//
//  Created by Shawn Roske on 1/9/10.
//  Copyright 2010 Bitgun. All rights reserved.
//

#import "BGSQuadSquareVisualizer.h"

@interface BGSQuadSquareVisualizer (Private)

- (UIColor *)randomColor;
- (void)loadCircles;
- (void)fadeInCircles;
- (void)dupeCircle:(UIView *)circle1;
- (void)circlesFaded:(NSString *)animationID finished:(NSNumber *)finished context:(NSObject *)context;

@end


@implementation BGSQuadSquareVisualizer

@synthesize entry;

/*
- (id)initWithFrame:(CGRect)frame andEntry:(NSDictionary *)entryData
{
    if (self = [super initWithFrame:frame]) 
	{
		isFadingIn = hasAnimated = NO;
		[self setEntry:entryData];
		[self loadCircles];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	self.circleView.frame = self.bounds;
}

- (void)dealloc 
{
	[entry release];
	[circleView release];
	[initialCircles release];
    [super dealloc];
}

- (void)loadCircles
{
	initialCircles = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < ROWS*COLS; i++)
	{
		int row = i/COLS;
		int col = i%COLS;
		BGSCircleView *circle = [[BGSCircleView alloc] initWithFrame:CGRectMake(col*(self.bounds.size.width/COLS), 
																				row*(self.bounds.size.height/ROWS), 
																				self.bounds.size.width/COLS, 
																				self.bounds.size.height/ROWS)];
		[circle setColor:[self randomColor]];
		[circle setHidden:YES];
		[initialCircles addObject:circle];
		[self.circleView addSubview:circle];
		[circle release];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	if (!hasAnimated)
	{
		if (animated)
		{
			isFadingIn = YES;
			
			CGFloat delay = 0.3;
			NSArray *circles = [initialCircles shuffledArray];
			for (BGSCircleView *c in circles)
			{
				[c setHidden:NO];
				[c setAlpha:0.0f];
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
				[UIView setAnimationDelay:delay];
				[UIView setAnimationDuration:0.6];
				
				if (c == [circles objectAtIndex:[circles count]-1])
				{
					[UIView setAnimationDelegate:self];
					[UIView setAnimationDidStopSelector:@selector(circlesFaded:finished:context:)];
				}
				
				[c setAlpha:1.0f];
				
				[UIView commitAnimations];
				
				delay += 0.4f;
			}		
		}
		else 
		{
			for (BGSCircleView *c in initialCircles)
				[c setHidden:NO];
			[initialCircles release];
			isFadingIn = NO;
			hasAnimated = YES;
		}		
	}
}

- (void)circlesFaded:(NSString *)animationID finished:(NSNumber *)finished context:(NSObject *)context
{
	isFadingIn = NO;
	hasAnimated = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	// nothing
}

- (UIColor *)randomColor
{
	NSArray *swatches = [self.entry objectForKey:@"swatches"];
	UIColor *color = CC_WHITE;
	if ([swatches count] > 0)
	{
		int i = arc4random()%[swatches count];
		NSDictionary *swatch = [swatches objectAtIndex:i];
		color = CC_FROM_SWATCH(swatch);		
	}
	return color;
}

- (void)dupeCircle:(BGSCircleView *)circle1
{
	if (circle1.frame.size.width <= CUTOFF) return;
	
	CGRect original = circle1.frame;
	
	[circle1 setNewColor:[self randomColor]];
	[circle1 setNewFrame:CGRectMake(original.origin.x, 
									original.origin.y, 
									original.size.width/2, 
									original.size.height/2)];
	
	BGSCircleView *circle2 = [[BGSCircleView alloc] initWithFrame:original];
	
	[circle2 setColor:circle1.color];
	[circle2 setNewColor:[self randomColor]];
	[circle2 setNewFrame:CGRectMake(original.origin.x+original.size.width/2, 
									original.origin.y, 
									original.size.width/2, 
									original.size.height/2)];
	
	[self.circleView addSubview:circle2];
	
	BGSCircleView *circle3 = [[BGSCircleView alloc] initWithFrame:original];
	
	[circle3 setColor:circle1.color];
	[circle3 setNewColor:[self randomColor]];
	[circle3 setNewFrame:CGRectMake(original.origin.x, 
									original.origin.y+original.size.height/2, 
									original.size.width/2, 
									original.size.height/2)];
	
	[self.circleView addSubview:circle3];
	
	BGSCircleView *circle4 = [[BGSCircleView alloc] initWithFrame:original];
	
	[circle4 setColor:circle1.color];
	[circle4 setNewColor:[self randomColor]];
	[circle4 setNewFrame:CGRectMake(original.origin.x+original.size.width/2, 
									original.origin.y+original.size.height/2, 
									original.size.width/2, 
									original.size.height/2)];
	
	[self.circleView addSubview:circle4];
	
	[circle1 animateWithDuration:0.5f andDelay:0.0f];
	[circle2 animateWithDuration:0.5f andDelay:0.0f];
	[circle3 animateWithDuration:0.5f andDelay:0.0f];
	[circle4 animateWithDuration:0.5f andDelay:0.0f];
}

#pragma mark -
#pragma mark Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (isFadingIn) return;
	
	for (UITouch *touch in touches)
	{
		if ([[touch view] isKindOfClass:[BGSCircleView class]])
		{
			BGSCircleView *v = (BGSCircleView *)[touch view];
			if (!v.animating)
				[self dupeCircle:(BGSCircleView *)[touch view]];
		}		
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (isFadingIn) return;
	
	for (UITouch *touch in touches)
	{
		CGPoint point = [touch locationInView:self];
		UIView *v = [self hitTest:point withEvent:event];
		if ([v isKindOfClass:[BGSCircleView class]])
		{
			BGSCircleView *cv = (BGSCircleView *)v;
			if (!cv.animating)
				[self dupeCircle:cv];
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// nothing
}
 
 */

@end