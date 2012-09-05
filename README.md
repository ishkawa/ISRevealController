## Requirements

iOS4 or later

## Usage

- add files in `ISRevealController/` to your xcode project.
- import `ISRevealController` in `YOUR_PROJECT_NAME-Prefix.pch`

```objectivec
#import "ISRevealController.h"
```

- init ISRevealController with root viewcontroller.

```objectivec
UIViewController *viewController = [[[UIViewController alloc] init] autorelease];
ISRevealController *revealController = 
[[[ISRevealController alloc] initWithRootViewController:viewController] autorelease];
```

- reveal sub viewcontroller

```objectivec
UIViewController *subViewController = [[[UIViewController alloc] init] autorelease];
[self.revealController revealSubViewController:subViewController
                                     direction:ISRevealControllerDirectionRight
                                      animated:YES];
```

- hide sub viewcontroller

```objectivec
[self.revealController hideSubViewControllerAnimated:YES];
```

## UIViewController extension

`revealController` property is added in `UIViewController+Reveal.h`, and it will be set automatically.  
so you don't have to set `viewController.revealController` manually. 

```objectivec
#import <UIKit/UIKit.h>

@class ISRevealController;

@interface UIViewController (Reveal)

@property (readonly) ISRevealController *revealController;

@end
```

## ARC Support

set `-fno-objc-arc` option for `ISRevealController.m` in Build Phases -> Compile Sources.

## License

MIT
