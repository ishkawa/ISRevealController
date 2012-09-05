#import "ISAppDelegate.h"
#import "ISRevealController.h"
#import "ISCenterViewController.h"

@implementation ISAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ISCenterViewController *viewController = [[[ISCenterViewController alloc] init] autorelease];
    ISRevealController *revealController =
    [[[ISRevealController alloc] initWithRootViewController:viewController] autorelease];
    
    UINavigationController *navigationController = [[[UINavigationController alloc] init] autorelease];
    navigationController.navigationBarHidden = YES;
    navigationController.viewControllers = @[revealController];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end