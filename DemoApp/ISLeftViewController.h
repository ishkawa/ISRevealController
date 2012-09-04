#import <UIKit/UIKit.h>

@class ISRevealController;

@interface ISLeftViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
