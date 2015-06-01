
#import <UIKit/UIKit.h>
#import "MasterScrollView.h"

@interface MessagesView : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property NSArray *savedPhotos;

@property  NSMutableArray *messages;

@property bool isSelectingChatroomForPhotos;

@property BOOL isArchive;

@property (strong, nonatomic) MasterScrollView *scrollView;

- (void)loadInbox;
- (id)initWithArchive:(BOOL)isArchive;
- (void)refreshMessages;
@end
