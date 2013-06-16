//
//  ARLabel.m
//  Autoresizing Label
//
//  Created by Ivan Kovacevic on 5/15/13.
//  Copyright (c) 2013 Ivan Kovacevic, e-mail: ivan.kovacevic@gmail.com
//
//  Hosted at: https://github.com/ivankovacevic/ARLabel
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished
// to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ARLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface ARLabel ()
{
	BOOL initialized;
	BOOL frameIsSetForTheFirstTime;
}

@end


@implementation ARLabel

- (id)initWithFrame:(CGRect)frame
{
	initialized = NO;
	frameIsSetForTheFirstTime = NO;
	
	self = [super initWithFrame:frame];
	if (self)
	{
		// Initialization code
		_autoAdjustFontSizeWithTextChange = NO;
		
		initialized = YES;
	}
	return self;
}

- (void)setEnlargedSize:(CGSize)enlargedSize
{
	if (!CGSizeEqualToSize(enlargedSize, _enlargedSize))
	{
		// This code can be potentially called within an animation block. Animating these changes would
		// mess everything up. Therefor we apply the following "trick" to exclude these changes from
		// being animated. They are executed instantaneously...
		
		[CATransaction begin]; // We enclose this in a CATransacion block to be able to set setDisableActions
		[CATransaction setDisableActions:YES]; // <-- Disable potential animation of the following changes
		
		_enlargedSize = enlargedSize;
		CGRect oldFrame = self.frame;
		
		self.transform = CGAffineTransformIdentity;
		super.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, enlargedSize.width, enlargedSize.height);
		[self setFontSizeThatFits];
		
		if (frameIsSetForTheFirstTime == NO)
			frameIsSetForTheFirstTime = YES;
		
		if (!CGRectEqualToRect(oldFrame, CGRectZero))
			self.frame = oldFrame;
		
		
		[CATransaction commit];
	}
}


- (void)setFrame:(CGRect)frame
{
	if (!CGSizeEqualToSize(frame.size, self.frame.size))
	{
		// There are two scenarios here:
		//  1. The label has already gonne through init method and the frame was already set
		//     either during the initialization with initWithFrame:, or later by directly setting
		//     the frame property.
		//  2. The label is still in phase of initialization
		//
		// If it is the later (2.) than we allow the frame to be set in the usual way(remeber this
		// method has overriden the default UILabel setFrame: method) by simply calling setFrame:
		// on super.
		// However once that is done, each subsequent call to setFrame: will not actually set the
		// frame, but will instead only apply a transform to the whole layer/view. This enables
		// animations as one would expect(font size change is animated).
		//
		// Few things to note here: I use BOOL variables to check state here. One would maybe
		// think that it would be enough to check, for example, if current frame is CGRectZero.
		// However when initialization is done with initWithFrame: method, once setFrame: is called
		// the bounds are already set, that is, the size part of the frame is already set. The origin
		// is not. That is so because the frame property is actually a calculated property of position,
		// bounds, anchorPoint and transformation of the underlying layer. The super class implementation
		// of initWithFrame: sets the bounds part. The origin is not zero at that moment, but at negative
		// values of half the size, because center is actually at 0,0.
		
		if (initialized && frameIsSetForTheFirstTime)
		{
			CGFloat scaleX = frame.size.width / self.frame.size.width;
			CGFloat scaleY = frame.size.height / self.frame.size.height;
			CGAffineTransform currentTransform = self.transform;
			
			if (CGSizeEqualToSize(self.frame.size, CGSizeZero))
			{
				// This is a special case. If someone resized the label to zero size and after that
				// tried to resize it back it would not work because current affine transform is zero.
				// The same goes for current frame sizes that are zero, so multiplying anything with zero
				// would produce zero again. However, bounds property stays the same and is not affected
				// with transformations as the frame property. The reason for this is that frame is,
				// as mentioned in the previous comment, a calculated property. So changing the transform
				// changes the frame, but not bounds. Therefor using bounds here resolves the issue.
				
				scaleX = frame.size.width / self.bounds.size.width;;
				scaleY = frame.size.height / self.bounds.size.height;;
				currentTransform = CGAffineTransformIdentity;
			}
			
			self.transform = CGAffineTransformScale(currentTransform, scaleX, scaleY);
			self.center = CGPointMake((frame.origin.x + (frame.size.width / 2)), (frame.origin.y + (frame.size.height / 2)));
			
		}
		else
		{
			super.frame = frame;
			[self setFontSizeThatFits];
			frameIsSetForTheFirstTime = YES;
		}
		
	}
	// If only the position(origin) of the frame is changing, apply that by changing center property.
	else if (!CGPointEqualToPoint(frame.origin, self.frame.origin))
	{
		self.center = CGPointMake((frame.origin.x + (frame.size.width / 2)), (frame.origin.y + (frame.size.height / 2)));
	}
	
}


- (void)setText:(NSString *)text
{
	if (self.text == nil || _autoAdjustFontSizeWithTextChange)
	{
		super.text = text;
		[self setFontSizeThatFits];
	}
	else
		super.text = text;
}


- (void)setFont:(UIFont *)font
{
	super.font = font;
	[self setFontSizeThatFits];
}


- (void)setFontSizeThatFits
{
	// This method is here to solve problems that the built-in UILabel adjustsFontSizeToFitWidth has. For
	// example fitting size also by height and centering by height(this is an accidental fix)...
	// The hardcoded values here are derived from experimentation and the purpose of them is to reduce the font
	// by a small amout, because otherwise the text would be, in some cases, drawn beyond label boundaries.
	
	CGFloat maxFontSizeCorrection;
	if (self.bounds.size.height > 8.0)
		maxFontSizeCorrection = 4.0;
	else
		maxFontSizeCorrection = self.bounds.size.height > 4.0 ? self.bounds.size.height - 4.0 : 0.0;
	
	CGFloat maxFontSize = self.bounds.size.height - maxFontSizeCorrection;
	CGFloat fontSizeThatFits;
	NSString *templateText = (_textForFontSizeCalculation == nil) ? self.text : _textForFontSizeCalculation;
	
	[templateText sizeWithFont:[self.font fontWithSize:maxFontSize]
	               minFontSize:1.0
	            actualFontSize:&fontSizeThatFits
	                  forWidth:self.bounds.size.width
	             lineBreakMode:NSLineBreakByTruncatingTail];
	
	super.font = [self.font fontWithSize:fontSizeThatFits];
}

@end