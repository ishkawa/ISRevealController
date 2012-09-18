#import "ISRevealController.h"
#import <QuartzCore/QuartzCore.h>

#define OFFSET   268.f
#define DURATION 0.25f

@interface UIViewController ()

@property (nonatomic) UIViewController *parentViewController;

@end


@interface ISRevealController ()

@property (nonatomic, retain) UINavigationController *mainNavigationController;
@property (nonatomic, retain) UIViewController *subViewController;
@property (nonatomic, retain) UIButton *hideButton;
@property (nonatomic, retain) UIScrollView *mainScrollView;
@property (nonatomic, retain) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic) ISRevealControllerDirection revealDirection;
@property (nonatomic) ISRevealControllerDirection panDirection;
@property (nonatomic) BOOL fullOffsetEnabled;

@property (nonatomic) CGPoint viewOrigin;
@property (nonatomic) CGPoint touchOrigin;
@property (nonatomic) CGPoint touchVelocity;
@property (nonatomic) NSTimeInterval touchTimestamp;
@property (nonatomic) NSTimeInterval touchInterval;

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

- (id)initWithRootViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        [self initialize];
        self.mainNavigationController.viewControllers = @[viewController];
        self.panOption = ISRevealControllerPanOptionDisabled;
    }
    return self;
}

- (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __iOS5 = ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0);
    });
    
    self.fullOffsetEnabled = NO;
    self.wantsFullScreenLayout = YES;
    self.revealDirection = ISRevealControllerDirectionNeutral;
    self.mainNavigationController = [[[UINavigationController alloc] init] autorelease];
    
    self.panRecognizer = [[[UIPanGestureRecognizer alloc] init] autorelease];
    [self.panRecognizer addTarget:self action:@selector(didPanned:)];
    [self.panRecognizer addObserver:self
                         forKeyPath:@"state"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
    
    if (__iOS5) {
        [self addChildViewController:self.mainNavigationController];
        [self.mainNavigationController didMoveToParentViewController:self];
    } else {
        self.mainNavigationController.parentViewController = self;
    }
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
    
    [self.view addGestureRecognizer:self.panRecognizer];

    UIView *mainView = self.mainNavigationController.view;
    CGFloat extension = 5.f;
    CGRect frame = CGRectMake(mainView.frame.origin.x-extension,
                              mainView.frame.origin.y-extension,
                              mainView.frame.size.width+extension*2,
                              mainView.frame.size.height+extension*2);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
    mainView.layer.shadowOpacity = .5f;
    mainView.layer.shadowColor = [UIColor blackColor].CGColor;
    mainView.layer.shadowPath = path.CGPath;
    mainView.layer.shadowOffset = CGSizeMake(0, 0);
    [self.view addSubview:mainView];
    
    self.hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hideButton.hidden = YES;
    self.hideButton.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.hideButton addTarget:self
                        action:@selector(hideSubViewController)
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
        [self.mainNavigationController viewWillAppear:animated];
        [self.subViewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!__iOS5) {
        [self.mainNavigationController viewDidAppear:animated];
        [self.subViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!__iOS5) {
        [self.mainNavigationController viewWillDisappear:animated];
        [self.subViewController viewWillDisappear:animated];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (!__iOS5) {
        [self.mainNavigationController viewDidDisappear:animated];
        [self.subViewController viewDidDisappear:animated];
    }
    [super viewDidDisappear:animated];
}

- (void)viewWillUnload
{
    [self.view removeGestureRecognizer:self.panRecognizer];
    [super viewWillUnload];
}

- (void)viewDidUnload
{
    self.hideButton = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [self.panRecognizer removeObserver:self forKeyPath:@"state"];
    
    [_mainNavigationController release];
    [_subViewController release];
    [_hideButton release];
    
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)object;
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.panDirection = ISRevealControllerDirectionNeutral;
        }
            
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            
            if (self.panDirection == ISRevealControllerDirectionNeutral) {
                [self hideSubViewControllerAnimated:YES];
            } else {
                if (self.panDirection != self.revealDirection) {
                    self.revealDirection = ISRevealControllerDirectionNeutral;
                    [self animateOnInertiaWithHandler:^{
                        [self hideSubViewControllerAnimated:YES];
                    }];
                } else {
                    [self animateOnInertiaWithHandler:^{
                        [self setRevealDirection:self.revealDirection
                                        animated:YES
                                      completion:nil];
                    }];
                }
            }
        }
    }
}

- (void)animateOnInertiaWithHandler:(void (^)(void))handler
{
    CGFloat width  = self.mainNavigationController.view.frame.size.width -20;
    CGFloat origin = self.mainNavigationController.view.frame.origin.x;
    CGFloat destination;
    
    switch (self.revealDirection) {
        case ISRevealControllerDirectionNeutral: destination = 0.f; break;
        case ISRevealControllerDirectionLeft:    destination = width; break;
        case ISRevealControllerDirectionRight:   destination = -width; break;
    }
    NSTimeInterval duration = fabs((destination - origin)/self.touchVelocity.x);
    if (duration < .1f) {
        duration = .1f;
    }
    if (duration < .3f) {
        [UIView animateWithDuration:duration
                         animations:^{
                             self.mainNavigationController.view.frame =
                             CGRectMake(destination,
                                        self.mainNavigationController.view.frame.origin.y,
                                        self.mainNavigationController.view.frame.size.width,
                                        self.mainNavigationController.view.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             if (handler) {
                                 handler();
                             }
                         }];
    } else {
        if (handler) {
            handler();
        }
    }
}

#pragma mark -

- (void)didPanned:(UIPanGestureRecognizer *)recognizer
{
    NSTimeInterval timestamp = [[recognizer valueForKey:@"_lastTouchTime"] floatValue];
    
    self.touchVelocity  = [recognizer velocityInView:self.view];
    self.touchInterval  = timestamp - self.touchInterval;
    self.touchTimestamp = timestamp;
    
    if (self.panDirection != ISRevealControllerDirectionNeutral) {
        if (recognizer.state != UIGestureRecognizerStateEnded) {
            CGPoint point = [recognizer locationInView:self.view];
            CGFloat dx = point.x - self.touchOrigin.x;
            CGFloat ratio = OFFSET/self.mainNavigationController.view.frame.size.width;
            
            self.mainNavigationController.view.frame =
            CGRectMake(self.viewOrigin.x + dx*ratio,
                       self.mainNavigationController.view.frame.origin.y,
                       self.mainNavigationController.view.frame.size.width,
                       self.mainNavigationController.view.frame.size.height);

            if (self.panDirection == ISRevealControllerDirectionLeft && self.touchVelocity.x < -100) {
                self.panDirection = ISRevealControllerDirectionRight;
            }
            if (self.panDirection == ISRevealControllerDirectionRight && self.touchVelocity.x > 100) {
                self.panDirection = ISRevealControllerDirectionLeft;
            }
            
            if (self.revealDirection == ISRevealControllerDirectionLeft && self.mainNavigationController.view.frame.origin.x < 0) {
                [self hideSubViewControllerAnimated:NO];
                self.revealDirection = self.panDirection;
                
                if ([self.delegate respondsToSelector:@selector(revealController:didPanToDirection:)]) {
                    [self.delegate revealController:self didPanToDirection:self.panDirection];
                }
            }
            else if (self.revealDirection == ISRevealControllerDirectionRight && self.mainNavigationController.view.frame.origin.x > 0) {
                [self hideSubViewControllerAnimated:NO];
                self.revealDirection = self.panDirection;
                
                if ([self.delegate respondsToSelector:@selector(revealController:didPanToDirection:)]) {
                    [self.delegate revealController:self didPanToDirection:self.panDirection];
                }
            }
        }
        
        return;
    }
    
    CGPoint velocity = self.touchVelocity;
    if (velocity.x > 100 && fabs(velocity.x) > fabs(velocity.y)) {
        if (self.revealDirection == ISRevealControllerDirectionNeutral && !(self.panOption & ISRevealControllerPanOptionLeftEnabled)) {
            return;
        }
        self.panDirection = ISRevealControllerDirectionLeft;
    }
    if (velocity.x < -100 && fabs(velocity.x) > fabs(velocity.y)) {
        if (self.revealDirection == ISRevealControllerDirectionNeutral && !(self.panOption & ISRevealControllerPanOptionRightEnabled)) {
            return;
        }
        self.panDirection = ISRevealControllerDirectionRight;
    }
    
    if (self.panDirection != ISRevealControllerDirectionNeutral) {
        self.touchOrigin   = [recognizer locationInView:self.view];
        self.viewOrigin    = self.mainNavigationController.view.frame.origin;

        BOOL isImplemented = [self.delegate respondsToSelector:@selector(revealController:didPanToDirection:)];
        if (isImplemented && !self.subViewController) {
            [self.delegate revealController:self didPanToDirection:self.panDirection];
        }
    }
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
    
    self.subViewController.view.userInteractionEnabled = NO;
    [self setOffset:sign * width
           animated:YES
         completion:^{
             self.mainNavigationController.viewControllers = @[ viewController ];
             [self hideSubViewControllerAnimated:YES];
         }];
}

- (void)setSubViewController:(UIViewController *)viewController direction:(ISRevealControllerDirection)direction
{
    // FIXME: duplicated (revealSubViewController:direction:animated:)
    
    if (direction == ISRevealControllerDirectionNeutral) {
        NSLog(@"invalid direction");
        return;
    }
    
    // TODO: find recursively and remember all?
    for (UIView *subview in [self.mainNavigationController.visibleViewController.view subviews]) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            if (scrollView.scrollsToTop) {
                self.mainScrollView = scrollView;
                self.mainScrollView.scrollsToTop = NO;
                break;
            }
        }
    }
    
    [self removeSubViewController:self.subViewController];
    [self insertSubViewController:viewController];
    
    self.subViewController = viewController;
    self.revealDirection = direction;
}

- (void)revealSubViewController:(UIViewController *)viewController
                      direction:(ISRevealControllerDirection)direction
                       animated:(BOOL)animated
{
    if (direction == ISRevealControllerDirectionNeutral) {
        NSLog(@"invalid direction");
        return;
    }
    
    // TODO: find recursively and remember all?
    for (UIView *subview in [self.mainNavigationController.visibleViewController.view subviews]) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            if (scrollView.scrollsToTop) {
                self.mainScrollView = scrollView;
                self.mainScrollView.scrollsToTop = NO;
                break;
            }
        }
    }
    
    [self removeSubViewController:self.subViewController];
    [self insertSubViewController:viewController];
    [self setRevealDirection:direction
                    animated:animated
                  completion:nil];
    
    self.subViewController = viewController;
}

- (void)putSubViewController:(UIViewController *)viewController
                   direction:(ISRevealControllerDirection)direction
{
}

- (void)hideSubViewController
{
    [self hideSubViewControllerAnimated:YES];
}

- (void)hideSubViewControllerAnimated:(BOOL)animated
{
    self.mainScrollView.scrollsToTop = YES;
    self.mainScrollView = nil;
    
    [self setRevealDirection:ISRevealControllerDirectionNeutral
                    animated:animated
                  completion:^{
                      [self removeSubViewController:self.subViewController];
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

- (void)removeSubViewController:(UIViewController *)viewController
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

- (void)insertSubViewController:(UIViewController *)viewController
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
        viewController.parentViewController = self;
        
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
