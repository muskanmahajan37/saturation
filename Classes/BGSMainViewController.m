//
//  BGSMainViewController.m
//  Saturation
//
//  Created by Shawn Roske on 12/15/09.
//  Copyright 2009 Bitgun. All rights reserved.
//

#import "BGSMainViewController.h"
#import "SaturationAppDelegate.h"

@interface BGSMainViewController (Private)

- (void)loadCircles;
- (void)fadeInCircles;
- (UIColor *)randomColor;

- (void)showSettings:(id)sender;
- (void)showDetailView:(id)sender;

- (void)circlesFaded:(NSString *)animationID finished:(NSNumber *)finished context:(NSObject *)context;
- (void)logoFaded:(NSString *)animationID finished:(NSNumber *)finished context:(NSObject *)context;

- (void)zoomToPoint:(CGPoint)point;

@end


@implementation BGSMainViewController

@synthesize background;
@synthesize logo;
@synthesize kulerLogo;
@synthesize circleView;
@synthesize scrollView;
@synthesize entry;
@synthesize settingsButton;
@synthesize infoButton;

- (UIImageView *)logo
{
	if (logo == nil)
	{
		NSString *p = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"logo-saturation.png"];
		UIImage *i = [UIImage imageWithContentsOfFile:p];
		UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(46.0f, 
																		137.0f, 
																		i.size.width, 
																		i.size.height)];
		[iv setImage:i];
		[self setLogo:iv];
		[iv release];
	}
	return logo;
}

- (UIImageView *)kulerLogo
{
	if (kulerLogo == nil)
	{
		NSString *p = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"logo-kuler.png"];
		UIImage *i = [UIImage imageWithContentsOfFile:p];
		UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(293.0f, 
																		140.0f, 
																		i.size.width, 
																		i.size.height)];
		[iv setImage:i];
		[self setKulerLogo:iv];
		[iv release];
	}
	return kulerLogo;
}

- (UIImageView *)background
{
	if (background == nil)
	{
		NSString *p = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"background.png"];
		UIImage *i = [UIImage imageWithContentsOfFile:p];
		UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 
																		0.0f, 
																		i.size.width, 
																		i.size.height)];
		[iv setImage:i];
		[self setBackground:iv];
		[iv release];
	}
	return background;
}

- (UIView *)circleView
{
	if (circleView == nil)
	{
		NSLog(@"creating a new circleview");
		UIView *v = [[UIView alloc] initWithFrame:self.view.bounds];
		[v setAutoresizesSubviews:YES];
		[v setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
		[v sizeToFit];
		[self setCircleView:v];
		[v release];
	}
	return circleView;
}

- (BGSCircleScrollView *)scrollView
{
	if (scrollView == nil)
	{
		BGSCircleScrollView *v = [[BGSCircleScrollView alloc] initWithFrame:self.view.bounds];
		[v setDelegate:self];
		[self setScrollView:v];
		[v release];
	}
	return scrollView;
}

- (void)setEntry:(NSDictionary *)newEntry
{
	if (newEntry != entry)
	{
		[entry release];
		entry = [newEntry retain];
	}
	
	if (circleView != nil)
	{
		[self.circleView removeFromSuperview];
		self.circleView = nil;
		[self.scrollView setZoomScale:1.0f animated:NO];
		[self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
		[self.scrollView addSubview:self.circleView];
		//[self.view insertSubview:self.circleView atIndex:1];
		[self loadCircles];
		[self fadeInCircles];
	}
}

- (UIButton *)settingsButton
{
	if (settingsButton == nil)
	{
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setShowsTouchWhenHighlighted:YES];
		NSString *p = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"button-gear.png"];
		UIImage *i = [UIImage imageWithContentsOfFile:p];
		[btn setImage:i forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
		[btn setFrame:CGRectMake(10.0f, 
								 self.view.bounds.size.height-i.size.height-10.0f, 
								 i.size.width, 
								 i.size.height)];
		[self setSettingsButton:btn];
		[btn release];
	}
	return settingsButton;
}

- (void)showSettings:(id)sender
{
	SaturationAppDelegate *ad = (SaturationAppDelegate *)[[UIApplication sharedApplication] delegate];
	[ad showListView];
}

- (UIButton *)infoButton
{
	if (infoButton == nil)
	{
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setShowsTouchWhenHighlighted:YES];
		NSString *p = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"button-info.png"];
		UIImage *i = [UIImage imageWithContentsOfFile:p];
		[btn setImage:i forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(showDetailView:) forControlEvents:UIControlEventTouchUpInside];
		[btn setFrame:CGRectMake(self.view.bounds.size.width-i.size.width-10.0f, 
								 self.view.bounds.size.height-i.size.height-10.0f, 
								 i.size.width, 
								 i.size.height)];
		[self setInfoButton:btn];
		[btn release];
	}
	return infoButton;
}

- (void)showDetailView:(id)sender
{
	SaturationAppDelegate *ad = (SaturationAppDelegate *)[[UIApplication sharedApplication] delegate];
	[ad showDetailFor:self.entry];
}

- (id)initWithEntry:(NSDictionary *)entryData
{
	if (self = [super init])
	{
		isZooming = NO;
		hasAnimated = NO;
		[self setEntry:entryData];
	}
	return self;
}

- (void)loadView 
{	
	CGRect frame = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
	
	UIView *v = [[UIView alloc] initWithFrame:frame];
	[v setBackgroundColor:CC_BACKGROUND];
	[v setAutoresizesSubviews:YES];
	[v setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[v sizeToFit];
	self.view = v;
	[v release];
	
	[self.view addSubview:self.background];
	
	[self.view addSubview:self.scrollView];
	[self.scrollView addSubview:self.circleView];
	[self.scrollView setContentSize:self.view.bounds.size];
	
	[self.view addSubview:self.logo];
	[self.view addSubview:self.kulerLogo];
	
	[self.view addSubview:self.settingsButton];
	[self.view addSubview:self.infoButton];
	
	[self loadCircles];
}

- (void)loadCircles
{
	initialCircles = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < ROWS*COLS; i++)
	{
		int row = i/COLS;
		int col = i%COLS;
		BGSCircleView *circle = [[BGSCircleView alloc] initWithFrame:CGRectMake(col*(self.view.frame.size.width/COLS), 
																				row*(self.view.frame.size.height/ROWS), 
																				self.view.frame.size.width/COLS, 
																				self.view.frame.size.height/ROWS)];
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
		[self fadeInCircles];
		
		[UIView beginAnimations:@"kulerLogoFade" context:self.kulerLogo];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelay:0.4];
		[UIView setAnimationDuration:0.6];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(logoFaded:finished:context:)];
		
		[self.kulerLogo setAlpha:0.0f];
		
		[UIView commitAnimations];
		
		[UIView beginAnimations:@"logoFade" context:self.logo];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelay:1.0];
		[UIView setAnimationDuration:0.6];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(logoFaded:finished:context:)];
		
		[self.logo setAlpha:0.0f];
		
		[UIView commitAnimations];
		
		hasAnimated = YES;
	}
	
	[self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)fadeInCircles
{
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

- (void)circlesFaded:(NSString *)animationID finished:(NSNumber *)finished context:(NSObject *)context
{
	NSLog(@"Circles Faded");
	[initialCircles release];
}


- (void)logoFaded:(NSString *)animationID finished:(NSNumber *)finished context:(NSObject *)context
{
	UIView *v = (UIView *)context;
	[v removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc 
{
	[background release];
	[initialCircles release];
	[logo release];
	[kulerLogo release];
	[circleView release];
	[scrollView release];
	[entry release];
    [super dealloc];
}

- (UIColor *)randomColor
{
	NSArray *swatches = [self.entry objectForKey:@"swatches"];
	int i = arc4random()%[swatches count];
	NSDictionary *swatch = [swatches objectAtIndex:i];
	return CC_FROM_SWATCH(swatch);
}

- (void)dupeCircle:(BGSCircleView *)circle1
{
	CGRect smallerRect = CGRectMake(circle1.frame.origin.x+PADDING, 
									circle1.frame.origin.y+PADDING, 
									circle1.frame.size.width-PADDING*2, 
									circle1.frame.size.height-PADDING*2);
	[circle1 setNewColor:[self randomColor]];
	BGSCircleView *circle2 = [[BGSCircleView alloc] initWithFrame:smallerRect];
	[circle2 setColor:circle1.color];
	[circle2 setNewColor:[self randomColor]];
	[self.circleView addSubview:circle2];
	
	BGSCircleView *circle3 = [[BGSCircleView alloc] initWithFrame:smallerRect];
	[circle3 setColor:circle1.color];
	[circle3 setNewColor:[self randomColor]];
	[self.circleView addSubview:circle3];
	
	BGSCircleView *circle4 = [[BGSCircleView alloc] initWithFrame:smallerRect];
	[circle4 setColor:circle1.color];
	[circle4 setNewColor:[self randomColor]];
	[self.circleView addSubview:circle4];
	
	CGRect original = circle1.frame;
	
	circle1.animating = circle2.animating = circle3.animating = circle4.animating = YES;
	
	[UIView beginAnimations:@"shrink" context:[[NSArray arrayWithObjects:circle1, circle2, circle3, circle4, nil] retain]];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(shrinkComplete:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.5f];
    
	[circle1 setFrame:CGRectMake(original.origin.x, 
								 original.origin.y, 
								 original.size.width/2, 
								 original.size.height/2)];
	[circle2 setFrame:CGRectMake(original.origin.x+original.size.width/2, 
								 original.origin.y, 
								 original.size.width/2, 
								 original.size.height/2)];
	[circle3 setFrame:CGRectMake(original.origin.x, 
								 original.origin.y+original.size.height/2, 
								 original.size.width/2, 
								 original.size.height/2)];
	[circle4 setFrame:CGRectMake(original.origin.x+original.size.width/2, 
								 original.origin.y+original.size.height/2, 
								 original.size.width/2, 
								 original.size.height/2)];
    
    [UIView commitAnimations];
}

- (void)shrinkComplete:(NSString *)animationID finished:(NSNumber *)finished context:(NSObject *)context
{
	NSArray *circles = (NSArray *)context;
	for (BGSCircleView *circle in circles)
	{
		[circle setColor:circle.newColor];
		circle.animating = NO;
	}
	[circles release];
}

- (void)zoomToPoint:(CGPoint)point
{
	isZooming = YES;
	
	CGRect zoomRect = CGRectMake(point.x-fmodf(point.x, CUTOFF_PX),
								 point.y-fmodf(point.y, CUTOFF_PX), 
								 CUTOFF_PX*COLS, 
								 CUTOFF_PX*ROWS);
	
	// find all circles that intersect with this rect
	// create a new rect taking into account all these circles

	CGRect fullRect = zoomRect;
	BOOL correctRatio = NO;
	int attempts = 0;
	do
	{
		for (UIView *v in self.circleView.subviews)
		{
			if ([v isKindOfClass:[BGSCircleView class]])
			{
				BGSCircleView *cv = (BGSCircleView *)v;
				NSLog(@"cv.frame: %@", NSStringFromCGRect(cv.frame));
				NSLog(@"fullRect: %@", NSStringFromCGRect(fullRect));
				NSLog(@"interset? %i", CGRectIntersectsRect(cv.frame, fullRect));
				if (CGRectIntersectsRect(cv.frame, fullRect))
					fullRect = CGRectUnion(cv.frame, fullRect);
			}
		}
		NSLog(@"fullRect: %@", NSStringFromCGRect(fullRect));
		NSLog(@"correct aspect? %i", (fullRect.size.width/COLS == fullRect.size.height/ROWS));
		if (fullRect.size.width/COLS == fullRect.size.height/ROWS)
		{
			correctRatio = YES;
		}
		else
		{
			fullRect = CGRectIntersection(self.circleView.frame, CGRectMake(fullRect.origin.x, 
																			fullRect.origin.y, 
																			fullRect.size.height*(COLS/ROWS), 
																			fullRect.size.height));
			NSLog(@"calculated fullRect: %@", NSStringFromCGRect(fullRect));
		}
		attempts++;
	} 
	while (!correctRatio && attempts < 4);
	
	[self.scrollView zoomToRect:fullRect animated:YES];
	lastZoomedRect = fullRect;
}

#pragma mark -
#pragma mark Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (isZooming) return;
	
	for (UITouch *touch in touches)
	{
		CGPoint point = [touch locationInView:self.view];
		if ([[touch view] isKindOfClass:[BGSCircleView class]])
		{
			BGSCircleView *v = (BGSCircleView *)[touch view];
			if (v.frame.size.width <= CUTOFF_PX*2)
				[self zoomToPoint:point];
			else if (!v.animating)
				[self dupeCircle:(BGSCircleView *)[touch view]];
		}		
	}
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (isZooming) return;
	
	for (UITouch *touch in touches)
	{
		CGPoint point = [touch locationInView:self.view];
		UIView *v = [self.view hitTest:point withEvent:event];
		if ([v isKindOfClass:[BGSCircleView class]])
		{
			BGSCircleView *cv = (BGSCircleView *)v;
			if (cv.frame.size.width <= CUTOFF_PX*2)
				[self zoomToPoint:point];
			else if (!cv.animating)
				[self dupeCircle:cv];
		}
	}
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (isZooming) return;
	
	UITouch *touch = [touches anyObject];
	if ([touch tapCount] > 1)
	{
		CGPoint point = [touch locationInView:self.view];
		[self zoomToPoint:point];
	}
	[super touchesEnded:touches withEvent:event];
}

#pragma mark -
#pragma mark ScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.circleView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	for (UIView *v in self.circleView.subviews)
	{
		if ([v isKindOfClass:[BGSCircleView class]])
		{
			BGSCircleView *cv = (BGSCircleView *)v;
			if (!CGRectContainsRect(lastZoomedRect, cv.frame))
				[cv removeFromSuperview];
		}
	}
	for (UIView *v in self.circleView.subviews)
	{
		if ([v isKindOfClass:[BGSCircleView class]])
		{
			BGSCircleView *cv = (BGSCircleView *)v;
			cv.frame = CGRectMake((cv.frame.origin.x-lastZoomedRect.origin.x)*scale, 
								  (cv.frame.origin.y-lastZoomedRect.origin.y)*scale, 
								  cv.frame.size.width*scale, 
								  cv.frame.size.height*scale);
			[cv setNeedsDisplay];
		}
	}
	
	[self.scrollView setZoomScale:1.0f animated:NO];
	[self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
	
	self.circleView.frame = self.view.bounds;
	
	[self.circleView removeFromSuperview];
	[self.scrollView removeFromSuperview];
	self.scrollView = nil;
	[self.view addSubview:self.scrollView];
	[self.scrollView addSubview:self.circleView];
	[self.scrollView setContentSize:self.view.bounds.size];
	
	isZooming = NO;
}

@end
