#import "ISLeftViewController.h"
#import "ISCenterViewController.h"

#import "ISViewController.h"

@implementation ISLeftViewController

- (void)viewDidLoad
{
    ISCmdLog;
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    ISCmdLog;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    ISCmdLog;
    [super viewDidAppear:animated];
    [self.revealController setFullOffsetEnabled:NO
                                       animated:YES
                                     completion:nil];
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
    self.tableView = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    ISCmdLog;
    [_tableView release];
    [super dealloc];
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Set Main View";
            break;
            
        case 1:
            cell.textLabel.text = @"Present Modal View";
            break;
    }
    
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            ISCenterViewController *viewController = [[[ISCenterViewController alloc] init] autorelease];
            viewController.value = indexPath.row;
            
            [self.revealController setMainViewController:viewController animated:YES];
            
            break;
        }
            
        case 1: {
            ISViewController *vc = [[[ISViewController alloc] init] autorelease];
            UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
            nc.view.backgroundColor = [UIColor whiteColor];
            [self.revealController setFullOffsetEnabled:YES
                                               animated:YES
                                             completion:^{
                                                 [self presentModalViewController:nc animated:YES];
                                             }];
            break;
        }
    }
    return;
}

@end
