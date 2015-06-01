
#import <UIKit/UIKit.h>

@interface ChatroomUsersView : UITableViewController <UIAlertViewDelegate>

- (id)initWithRoom:(PFObject *)room;

@property PFObject *message;

@end
