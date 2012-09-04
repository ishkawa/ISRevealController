#import "ISRightViewController.h"
#import "ISCenterViewController.h"

@implementation ISRightViewController

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
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
    return 20;
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
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
    
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ISCenterViewController *centerViewController = [[[ISCenterViewController alloc] init] autorelease];
    ISRevealController *revealController = [[[ISRevealController alloc] init] autorelease];
    
    revealController.mainNavigationController.viewControllers = @[centerViewController];
    centerViewController.navigationItem.leftBarButtonItem.action = @selector(pop);
    centerViewController.value = indexPath.row;

    [self.navigationController pushViewController:revealController animated:YES];
}

@end
