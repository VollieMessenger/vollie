

#import <UIKit/UIKit.h>
#import "JSQMessagesInputToolbar.h"
#import "ParseVolliePackage.h"
#import <Parse/Parse.h>

@protocol CreateChatroomDelegate <NSObject>

-(void)sendObjectsWithSelectedChatroom:(PFObject *)object andText:(NSString *)text andComment:(NSString *)comment;

@end

@interface CreateChatroomView : UIViewController <UISearchBarDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic,assign) id<CreateChatroomDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSString * sendingMessage;
@property NSMutableArray * photos;
@property ParseVolliePackage *package;

@property BOOL invite;

@property BOOL isTherePicturesToSend;

@end
