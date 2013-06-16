ARLabel - Autoresizing Label
=============================

Subclassed version of UILabel that automatically adjusts label font size to fit its frame, specifically designed to work good with animations.

![ScreenShot](https://raw.github.com/ivankovacevic/ARLabel/master/screenshot.png)


## Requirements ##

Include **QuartzCore.framework** under **"Link Binary With Libraries"** in your project settings.


## Example usage ##

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

