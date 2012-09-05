#import "ISViewController.h"

@implementation ISViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:@"Simulate Memory Warning"
                                          style:UIBarButtonItemStyleBordered
                                         target:[UIApplication sharedApplication]
                                         action:@selector(_performMemoryWarning)] autorelease];
        
        self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:@"Done"
                                          style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(dismiss)] autorelease];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    ISCmdLog;
    
    [super didReceiveMemoryWarning];
}

- (void)dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
