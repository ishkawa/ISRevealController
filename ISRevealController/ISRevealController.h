#import <UIKit/UIKit.h>
#import "UIViewController+Reveal.h"

typedef enum {
    ISRevealControllerDirectionNeutral = 0,
    ISRevealControllerDirectionLeft,
    ISRevealControllerDirectionRight
} ISRevealControllerDirection;

@interface ISRevealController : UIViewController

@property (readonly, nonatomic, retain) UINavigationController *mainNavigationController;
@property (readonly, nonatomic, retain) UIViewController *subViewController;
@property (readonly, nonatomic) ISRevealControllerDirection revealDirection;

- (id)initWithRootViewController:(UIViewController *)viewController;
- (void)setMainViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)revealSubViewController:(UIViewController *)viewController
                      direction:(ISRevealControllerDirection)direction
                       animated:(BOOL)animted;

- (void)hideSubViewControllerAnimated:(BOOL)animated;
- (void)setFullOffsetEnabled:(BOOL)enabled
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion;

@end
