#import "ISRevealController.h"

#define OFFSET   280.f
#define DURATION 0.25f

@interface ISRevealController ()

@property (nonatomic, retain) UINavigationController *mainNavigationController;
@property (nonatomic, retain) UIViewController *subViewController;
@property (nonatomic, retain) UIButton *hideButton;
@property (nonatomic) ISRevealControllerDirection revealDirection;
@property (nonatomic) BOOL fullOffsetEnabled;

@end

@implementation ISRevealController

static BOOL __iOS5;

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.fullOffsetEnabled = NO;
    self.wantsFullScreenLayout = YES;
    self.revealDirection = ISRevealControllerDirectionNeutral;
    self.mainNavigationController = [[[UINavigationController alloc] init] autorelease];
    [self addChildViewController:self.mainNavigationController];
    [self.mainNavigationController didMoveToParentViewController:self];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __iOS5 = ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0);
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.subViewController) {
        [self.view addSubview:self.subViewController.view];
        if (self.subViewController.wantsFullScreenLayout) {
            self.subViewController.view.frame = [UIScreen mainScreen].bounds;
        } else {
            self.subViewController.view.frame = [UIScreen mainScreen].applicationFrame;
        }
    }
    [self.view addSubview:self.mainNavigationController.view];
    
    self.hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hideButton.hidden = YES;
    self.hideButton.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.hideButton addTarget:self
                        action:@selector(hideSideViewController)
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.hideButton];
    
    [self setFullOffsetEnabled:self.fullOffsetEnabled
                      animated:NO
                    completion:nil];
    
    [self setRevealDirection:self.revealDirection
                    animated:NO
                  completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!__iOS5) {
        [self.subViewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!__iOS5) {
        [self.subViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!__iOS5) {
        [self.subViewController viewWillDisappear:animated];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (!__iOS5) {
        [self.subViewController viewDidDisappear:animated];
    }
    [super viewDidDisappear:animated];
}

#pragma mark -

- (void)setMainViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!animated) {
        self.mainNavigationController.viewControllers = @[ viewController ];
        return;
    }
    CGFloat sign = self.revealDirection == ISRevealControllerDirectionLeft ? 1.f : -1.f;
    CGFloat width = self.view.frame.size.width;
    
    [self setOffset:sign * width
           animated:YES
         completion:^{
             self.mainNavigationController.viewControllers = @[ viewController ];
             [self hideSideViewControllerAnimated:YES];
         }];
}

- (void)revealSubViewController:(UIViewController *)viewController
                      direction:(ISRevealControllerDirection)direction
                       animated:(BOOL)animated
{
    [self removeSideViewController:self.subViewController];
    [self insertSideViewController:viewController];
    [self setRevealDirection:direction
                    animated:animated
                  completion:nil];
    
    self.subViewController = viewController;
}

- (void)hideSideViewController
{
    [self hideSideViewControllerAnimated:YES];
}

- (void)hideSideViewControllerAnimated:(BOOL)animated
{
    [self setRevealDirection:ISRevealControllerDirectionNeutral
                    animated:animated
                  completion:^{
                      [self removeSideViewController:self.subViewController];
                      self.subViewController = nil;
                  }];
}

#pragma mark - animation

- (void)setOffset:(CGFloat)offset
         animated:(BOOL)animated
       completion:(void (^)(void))handler
{
    void (^animations)(void) = ^{
        self.mainNavigationController.view.frame =
        CGRectMake(offset,
                   self.mainNavigationController.view.frame.origin.y,
                   self.mainNavigationController.view.frame.size.width,
                   self.mainNavigationController.view.frame.size.height);
        
        self.hideButton.frame =
        CGRectMake(offset,
                   self.hideButton.frame.origin.y,
                   self.hideButton.frame.size.width,
                   self.hideButton.frame.size.height);
    };
    
    void (^completion)(BOOL) = ^(BOOL finished) {
        self.hideButton.hidden = (self.revealDirection == ISRevealControllerDirectionNeutral);
        
        if (handler) {
            handler();
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:DURATION
                         animations:animations
                         completion:completion];
    } else {
        animations();
        completion(YES);
    }
    
    Block_release(animations);
    Block_release(completion);
}

- (void)setRevealDirection:(ISRevealControllerDirection)revealDirection
                  animated:(BOOL)animated
                completion:(void (^)(void))completion
{
    self.revealDirection = revealDirection;
    
    CGFloat absoluteOffset = self.fullOffsetEnabled ? self.view.frame.size.width : OFFSET;
    CGFloat offset;
    switch (self.revealDirection) {
        case ISRevealControllerDirectionNeutral: offset = 0.f; break;
        case ISRevealControllerDirectionLeft:    offset = absoluteOffset; break;
        case ISRevealControllerDirectionRight:   offset = -absoluteOffset; break;
    }
    
    [self setOffset:offset
           animated:animated
         completion:completion];
}

#pragma mark - manage child viewcontrollers

- (void)removeSideViewController:(UIViewController *)viewController
{
    if (__iOS5) {
        [viewController willMoveToParentViewController:nil];
        [viewController removeFromParentViewController];
        [viewController.view removeFromSuperview];
    } else {
        [viewController viewWillDisappear:NO];
        [viewController.view removeFromSuperview];
        [viewController viewDidDisappear:NO];
    }
}

- (void)insertSideViewController:(UIViewController *)viewController
{
    if (viewController.wantsFullScreenLayout) {
        viewController.view.frame = [UIScreen mainScreen].bounds;
    } else {
        viewController.view.frame = [UIScreen mainScreen].applicationFrame;
    }
    
    if (__iOS5) {
        [self.view insertSubview:viewController.view belowSubview:self.mainNavigationController.view];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    } else {
        [viewController viewWillAppear:NO];
        [self.view insertSubview:viewController.view belowSubview:self.mainNavigationController.view];
        [viewController viewDidAppear:NO];
    }
}

#pragma mark - toggle full offset enabled

- (void)setFullOffsetEnabled:(BOOL)enabled
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion
{
    if (!self.subViewController) {
        return;
    }
    CGFloat sign   = self.revealDirection == ISRevealControllerDirectionLeft ? 1.f : -1.f;
    CGFloat offset = enabled ? self.view.frame.size.width : OFFSET;

    self.fullOffsetEnabled = enabled;
    [self setOffset:sign * offset
           animated:animated
         completion:completion];
}

@end
