#import "UIViewController+Reveal.h"
#import "ISRevealController.h"

@implementation UIViewController (Reveal)

- (ISRevealController *)revealController
{
    ISRevealController *revealController = nil;
    UIViewController *viewController = self;
    
    while (viewController) {
        if ([viewController.parentViewController isKindOfClass:[ISRevealController class]]) {
            revealController = (ISRevealController *)viewController.parentViewController;
            break;
        }
        viewController = viewController.parentViewController;
    }
    return revealController;
}

@end
