//
//  BGSVisualOptionView.m
//  Saturation
//
//  Created by Shawn Roske on 1/9/10.
//  Copyright 2010 Bitgun. All rights reserved.
//

#import "BGSVisualOptionView.h"
#import "SaturationAppDelegate.h"

@interface BGSVisualOptionView (Private)

- (NSString *)iconFilenameForType:(int)type selected:(BOOL)selected;

@end



@implementation BGSVisualOptionView

@synthesize background;
@synthesize icon;
@synthesize selectedIcon;
@synthesize iconButton;
@synthesize isSelected;
@synthesize hasBackground;
@synthesize visualizationType;

- (void)setHasBackground:(BOOL)newHasBackground
{
	hasBackground = newHasBackground;
	[self.background removeFromSuperview];
	if (self.hasBackground)
		[self insertSubview:self.background atIndex:0];
}
- (UIImageView *)background
{
	if (background == nil)
	{
		NSString *p = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"button-favorite-background.png"];
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

- (void)setIsSelected:(BOOL)newIsSelected
{
	isSelected = newIsSelected;
	[self.iconButton setImage:(self.isSelected ? self.selectedIcon : self.icon) forState:UIControlStateNormal];
}

- (UIImage *)icon
{
	if (icon == nil)
	{
		NSString *p = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[self iconFilenameForType:self.visualizationType selected:NO]];
		UIImage *i = [UIImage imageWithContentsOfFile:p];
		[self setIcon:i];
	}
	return icon;
}
- (UIImage *)selectedIcon
{
	if (selectedIcon == nil)
	{
		NSString *p = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[self iconFilenameForType:self.visualizationType selected:YES]];
		UIImage *i = [UIImage imageWithContentsOfFile:p];
		[self setSelectedIcon:i];
	}
	return selectedIcon;
}

- (UIButton *)iconButton
{
	if (iconButton == nil)
	{
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setShowsTouchWhenHighlighted:YES];
		[self setIconButton:btn];
		[btn release];
	}
	return iconButton;
}

- (id)initWithFrame:(CGRect)frame andType:(int)type
{
    if (self = [super initWithFrame:frame]) 
	{
		self.visualizationType = type;
		self.isSelected = NO;
		self.hasBackground = YES;
		[self addSubview:self.background];
		[self addSubview:self.iconButton];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	self.iconButton.frame = CGRectMake(self.bounds.origin.x+1.0f, 
									   self.bounds.origin.y+2.0f, 
									   self.bounds.size.width-1.0f, 
									   self.bounds.size.height-3.0f);
}

- (void)dealloc 
{
	[icon release];
	[selectedIcon release];
	[background release];
    [super dealloc];
}

- (NSString *)iconFilenameForType:(int)type selected:(BOOL)selected
{
	NSString *filename = (selected ? @"icon-favorite-selected.png" : @"icon-favorite-unselected.png");
	switch (type) {
		case kSimpleCircle:
			filename = (selected ? @"icon-circles-selected.png" : @"icon-circles-unselected.png");
			break;
		case kSimpleParticles:
			filename = (selected ? @"icon-random-selected.png" : @"icon-random-unselected.png");
			break;
	}
	return filename;
}

@end
