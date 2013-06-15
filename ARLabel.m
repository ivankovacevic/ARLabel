//
//  ARLabel.m
//  Autoresizing Label
//
//  Created by Ivan Kovacevic on 5/15/13.
//  Copyright (c) 2013 Ivan Kovacevic, e-mail: ivan.kovacevic@gmail.com
//
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
		// Lets check if it is the first time the frame is set to some concrete values. If it is
		// not, we set the frame the reqular way. If it is, we only apply a transformation to the
		// frame. For example checking only if frame is zero here (and not using additional BOOL var)
		// is not enough because if the label is initialized with [[... alloc] initWithFrame: ...];
		// then the super class implementation has already set the bounds(frame property is actually
		// a combination of position, bounds and anchorPoint of the underlying layer)
		// which corresponds to size, however the origin is left unset(Center is at 0,0 and the origin
		// at negative values). The super implementation then calls this setFrame to complete
		// setting the frame. So to correctly detect that, we use here a BOOL variable initialized,
		// which is set to YES at the end of our init method
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
				// with transformations as the frame property. The reason for this is that frame is
				// a calculated property from different other values and obviously transformation is one
				// of them. So using bounds here resolves the issue
				
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
	
	if (self.text == nil || self.autoAdjustFontSizeWithTextChange)
	{
		super.text = text;
		[self setFontSizeThatFits];
	}
	else
		super.text = text;
}


- (void)setFontSizeThatFits
{
	// The hardcoded values here are derived from experimentation and the purpose of them is to reduce the font
	// by a small amout, because otherwise the text would be, in some cases, drawn beyond label boundaries.
	
	CGFloat maxFontSizeCorrection;
	if (self.bounds.size.height > 8.0)
		maxFontSizeCorrection = 4.0;
	else
		maxFontSizeCorrection = self.bounds.size.height > 4.0 ? self.bounds.size.height - 4.0 : 0.0;
	
	CGFloat maxFontSize = self.bounds.size.height - maxFontSizeCorrection;
	CGFloat fontSizeThatFits;
	NSString *templateText = (self.textForFontSizeCalculation == nil) ? self.text : self.textForFontSizeCalculation;
	
	[templateText sizeWithFont:[self.font fontWithSize:maxFontSize]
				   minFontSize:1.0
				actualFontSize:&fontSizeThatFits
					  forWidth:self.bounds.size.width
				 lineBreakMode:NSLineBreakByTruncatingTail];
	
	self.font = [self.font fontWithSize:fontSizeThatFits];
}

@end