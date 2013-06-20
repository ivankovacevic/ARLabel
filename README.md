ARLabel - Autoresizing Label
=============================

Ever had one of the following problems with UILabel?

- Unable to determine the correct font size to fit width and HEIGHT
- UILabel adjustsFontSizeToFitWidth does not work as expected
- Could not animate font size change

That is where ARLabel comes in. Forget font size altogether! ARLabel works automatically by setting its font size to fit its frame. So working with ARLabel is more like working with plain UIView. Just set the frame to desired size and forget everything else. You want animated font size change? Just set a different frame inside an UIView animation block.

![ScreenShot](https://raw.github.com/ivankovacevic/ARLabel/master/screenshot.png)

## How does it work? ##

The core funcionallity revolves around calling the CGAffineTransformScale function, which transforms the size of underlying layer altogether. Enlarging would however produce blurry text that's why there is a nice property called **enlargedSize** which you can set upfront to the expected size that you are going to enlarge your label. What happens in the background is that the label is immediately created with that size and transformed(shrunk) to current frame size. Then when you enlarge it, it is actually transformed back to its original state/size. It's a sort of reversed logic :)

Beside that there is a bunch of other small tricks included in the implementation that handle all the weird border cases

## What's with all the comments?! ##

Well I probably did exagerate a bit with the comments in the files. However I did not want to wonder again why I did something the way I did, that's why I wrote every detail down. The comments in the .h file can help you understand all the extra properties that you can use.

## Requirements ##

Beside the obvious, that you need to include ARLabel .h and .m files in your project also do this: 
Include **QuartzCore.framework** under **"Link Binary With Libraries"** in your project settings.


## Example usage ##

Basically you can use it as you would use UILabel anyway. All the properties that ARLabel implements are optional.
However you would want to set **enlargedSize** if you want nice looking text.

```objc
ARLabel *testLabel = [[ARLabel alloc] initWithFrame:CGRectMake(110, 100, 100, 50)];
testLabel.text = @"Test";
testLabel.enlargedSize = CGSizeMake(200, 100);

[self.view addSubview:testLabel];

[UIView animateWithDuration:3.0
                      delay:5.0
                    options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                 animations:^{
                                 testLabel.frame = CGRectMake(60, 200, 200, 100);
                             }
                 completion:nil];
```

