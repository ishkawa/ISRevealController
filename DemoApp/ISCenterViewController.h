#import <UIKit/UIKit.h>

@interface ISCenterViewController : UIViewController <ISRevealControllerDelegate>

@property NSInteger value;
@property (retain, nonatomic) IBOutlet UILabel *label;

@end
