#import <UIKit/UIKit.h>
#import "UIViewController+Reveal.h"

typedef enum {
    ISRevealControllerDirectionNeutral = 0,
    ISRevealControllerDirectionLeft,
    ISRevealControllerDirectionRight
} ISRevealControllerDirection;

typedef enum {
    ISRevealControllerPanOptionDisabled     = 0x00,
    ISRevealControllerPanOptionLeftEnabled  = 0x01,
    ISRevealControllerPanOptionRightEnabled = 0x02
} ISRevealControllerPanOption;

@protocol ISRevealControllerDelegate;


@interface ISRevealController : UIViewController

@property (readonly, nonatomic, retain) UINavigationController *mainNavigationController;
@property (readonly, nonatomic, retain) UIViewController *subViewController;
@property (readonly, nonatomic) ISRevealControllerDirection revealDirection;
@property (nonatomic, assign) ISRevealControllerPanOption panOption;
@property (nonatomic, assign) id <ISRevealControllerDelegate> delegate;

- (id)initWithRootViewController:(UIViewController *)viewController;
- (void)setMainViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)setSubViewController:(UIViewController *)viewController direction:(ISRevealControllerDirection)direction;
- (void)revealSubViewController:(UIViewController *)viewController
                      direction:(ISRevealControllerDirection)direction
                       animated:(BOOL)animted;

- (void)hideSubViewControllerAnimated:(BOOL)animated;
- (void)setFullOffsetEnabled:(BOOL)enabled
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion;

@end


@protocol ISRevealControllerDelegate <NSObject>

- (void)revealController:(ISRevealController *)revealController didPanToDirection:(ISRevealControllerDirection)direction;

@end
