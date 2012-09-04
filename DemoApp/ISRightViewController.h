#import <UIKit/UIKit.h>

@class ISRevealController;

@interface ISRightViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
