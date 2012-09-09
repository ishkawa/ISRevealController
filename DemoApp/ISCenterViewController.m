#import "ISCenterViewController.h"
#import "ISLeftViewController.h"
#import "ISRightViewController.h"

#import "ISViewController.h"

@implementation ISCenterViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.value = 0;
        self.navigationItem.title = @"Demo";
        self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:@"Left"
                                          style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(openLeftView)] autorelease];
        
        self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:@"Right"
                                          style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(openRightView)] autorelease];
    }
    return self;
}
- (void)viewDidLoad
{
    ISCmdLog;
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    ISCmdLog;
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.label.text = [NSString stringWithFormat:@"value: %d", self.value];
}


- (void)viewDidAppear:(BOOL)animated
{
    ISCmdLog;
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    ISCmdLog;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    ISCmdLog;
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    ISCmdLog;
    [super didReceiveMemoryWarning];
}

- (void)viewWillUnload
{
    ISCmdLog;
    [super viewWillUnload];
}

- (void)viewDidUnload
{
    ISCmdLog;
    self.label = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    ISCmdLog;
    [_label release];
    [super dealloc];
}

#pragma mark - action

- (void)openLeftView
{
    [self.revealController revealSubViewController:[self leftViewController]
                                         direction:ISRevealControllerDirectionLeft
                                          animated:YES];
}

- (void)openRightView
{
    [self.revealController revealSubViewController:[self rightViewController]
                                         direction:ISRevealControllerDirectionRight
                                          animated:YES];
}

- (UIViewController *)leftViewController
{
    ISLeftViewController *viewController = [[[ISLeftViewController alloc] init] autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    return navigationController;
}

- (UIViewController *)rightViewController
{
    ISRightViewController *viewController = [[[ISRightViewController alloc] init] autorelease];
    
    return viewController;
}

- (void)pop
{
    [self.navigationController.parentViewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark - reveal controller delegate

- (void)revealController:(ISRevealController *)revealController didPanToDirection:(ISRevealControllerDirection)direction
{
    if (direction == ISRevealControllerDirectionLeft) {
        [self.revealController setSubViewController:[self leftViewController] direction:ISRevealControllerDirectionLeft];
    }
    if (direction == ISRevealControllerDirectionRight) {
        [self.revealController setSubViewController:[self rightViewController] direction:ISRevealControllerDirectionRight];
    }
}

@end
