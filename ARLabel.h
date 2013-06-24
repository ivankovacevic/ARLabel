//
//  ARLabel.h
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


#import <UIKit/UIKit.h>

@interface ARLabel : UILabel

// Note: The built-in UILabel adjustsFontSizeToFitWidth has its problems, that is
//       why ARLabel uses its own logic to apply the font size. If you want the
//       same functionality also when the text is changing then remeber to set
//       the following property to YES.

// Set this property to YES to automatically adjust the font size of the text to fit
// current label frame on every text change. The default value is NO and the font size
// is calculated only the first time the text is set. The reason for this is better
// performance in the scenario that the label text is changed very frequently.
@property (assign, nonatomic) BOOL autoAdjustFontSizeWithTextChange;

// This property allows you to set a sort of template text to calculate the font
// size by, but which will never be displayed on the label. This is useful if you
// don't want to use the above autoAdjustFontSizeWithTextChange property but still
// want that text with different lengths fits the label. For example if you are
// going to display different dates inside the same label "24 June 2013" will
// obviously not have the same width as "24 September 2013", so you can set this
// property to the text with the greatest length that you are going to encounter
// and the font will be adjusted to that one. This is also handy for text with
// the same length, but that will still have different width because the font used
// is not a monospaced(fixed-width) font.
@property (strong, nonatomic) NSString *textForFontSizeCalculation;

// This property is responsible for better and clear looking text in case you are
// enlarging the size of the label greater than its initial size. If this property is
// not set the text is going to look blurry when enlarged. So set this to the maximum
// size you anticipate your label is going to change.
@property (assign, nonatomic) CGSize enlargedSize;


@end
