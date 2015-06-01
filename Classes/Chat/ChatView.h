
#import "JSQMessages.h"

#import "KLCPopup.h"

#import <Parse/Parse.h>

#import <UIKit/UIKit.h>


#import "MasterScrollView.h"

@interface ChatView : JSQMessagesViewController

<JSQMessagesCollectionViewDelegateFlowLayout,

JSQMessagesCollectionViewDataSource,

UITextViewDelegate>

- (id)initWith:(PFObject *)room name:(NSString *)name;

-(void) refresh;

@property PFObject *room_;

@property PFObject *message_;

@property BOOL isNewChatroomWithPhotos;

@property (strong, nonatomic) PFObject *selectedSetForPictures;

@property BOOL isSendingTextMessage;

@end
