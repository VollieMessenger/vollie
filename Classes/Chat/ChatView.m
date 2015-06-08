#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"
#import "NSDate+TimeAgo.h"
#import "AppConstant.h"
//#import "camera.h"
#import "utilities.h"
#import "messages.h"
#import "pushnotification.h"
#import "UIColor+JSQMessages.h"
#import "CustomCameraView.h"
#import "CustomChatView.h"
#import "CustomCollectionViewCell.h"
#import "ChatView.h"
#import "ChatroomUsersView.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ChatView () <CustomCameraDelegate>
{
    JSQMessagesBubbleImageFactory *bubbleFactory;
    CustomChatView *chat;
    UITapGestureRecognizer *tap;
    PFImageView *longPressImageView;
    BOOL isLoading;
    int x;
    int intForOrderedPictures;
    
    UIImage *randomImage;
    CGPoint startLocation;
    UICollectionViewFlowLayout *flowLayoutPictures;
    NSDictionary *pictureToSetId;
    NSMutableDictionary *colorForSetId;
    NSDictionary *messageToSetId;
    UIColor *selectedColor;
    UIColor *newColor;
    CGFloat rowHeight;
    CGRect collectionViewFrame;
    NSMutableArray *arrayOfTitleUsers;
    NSMutableArray *arrayOfNames;
    
    BOOL didSendPhotos;
    BOOL isLoadingPopup;
    BOOL isCommentingOnPictures;
    NSMutableArray *messages;
    NSMutableArray *messageObjects;
    NSMutableArray *messageObjectIds;
    NSMutableArray *pictureObjects;
    NSMutableArray *pictureObjectIds;
    NSMutableArray *unassignedCommentArray;
    NSMutableArray *unassignedCommentArrayIds;

    NSMutableArray *arrayOfAvailableColors;
    NSMutableArray *arrayOfSetIdPicturesObjects;
    NSMutableArray *arrayOfSetIdComments;

    JSQMessagesBubbleImage *outgoingBubbleImageData;
    JSQMessagesBubbleImage *incomingBubbleImageData;

    BOOL isSelectingItem;
}

@property MPMoviePlayerController *moviePlayer;
@property int countDownForPictureRefresh;
@property BOOL didViewJustLoad;
@property NSString *name_;
@property KLCPopup *pop;
@property int isLoadingEarlierCount;
@property UIRefreshControl *refreshControl;
@property UIRefreshControl *refreshControl2;

@end

@implementation ChatView

@synthesize room_;

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    if (isCommentingOnPictures)
    {
        [self sendMessage:text PictureSet:self.selectedSetForPictures];
        [self actionDismiss];
    }
    else
    {
        [self sendMessage:text PictureSet:0];
    }
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    if (self.inputToolbar.contentView.textView.isFirstResponder)
    {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }

    if (isCommentingOnPictures)
    {
        [self actionDismiss];
    }
    else
    {
        /*
         CATransition* transition = [CATransition animation];
         transition.duration = 0.3;
         transition.type = kCATransitionPush;
         transition.subtype = kCATransitionFromTop;
         transition.timingFunction = UIViewAnimationCurveEaseInOut;
         transition.fillMode = kCAFillModeRemoved;
         [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
         [self.navigationController pushViewController:self.customCameraView animated:1];
         */

        //[self.navigationController pushViewController:cam animated:0];

        NavigationController *navCamera = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navCamera];

        if ([navCamera.viewControllers.firstObject isKindOfClass:[CustomCameraView class]])
        {
            CustomCameraView *cam = (CustomCameraView *)navCamera.viewControllers.firstObject;
            [cam setPopUp];
            cam.delegate = self;
            [self presentViewController:[(AppDelegate *)[[UIApplication sharedApplication] delegate] navCamera] animated:0 completion:0];
        }
    }
}

- (id)initWith:(PFObject *)room name:(NSString *)name
{
    self = [super init];
    if (self)
    {
        self.room_ = room;
        self.name_ = name;
    }
    return self;
}


- (void) refresh
{
    self.showTypingIndicator = 1;
    // [self scrollToBottomAnimated:1];
    [self loadChat];
}


//NOt used
-(void) refresh2 {
    _isLoadingEarlierCount++;
    [self loadChat];
}

#pragma mark - DELEGATES

- (void)sendBackPictures:(NSArray *)array withBool:(bool)didTakePicture andComment:(NSString *)comment
{
    didSendPhotos = YES;
    [ProgressHUD show:@"Saving..." Interaction:1];

    x = (int)array.count;

    __block int numberOfSets;

    [self.room_ fetchInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
        if (!error)
        {

    numberOfSets = [[self.room_ valueForKey:PF_CHATROOMS_ROOMNUMBER] intValue];

    PFObject *set = [PFObject objectWithClassName:PF_SET_CLASS_NAME];
    [set setValue:room_ forKey:PF_SET_ROOM];
    [set setValue:[PFUser currentUser] forKey:PF_SET_USER];
    [set setValue:@(numberOfSets) forKey:PF_SET_ROOMNUMBER];


    _countDownForPictureRefresh = (int)array.count;


    NSMutableArray *arrayOfPicturesObjectsTemp = [NSMutableArray new];

    for (id imageOrFile in array)
    {
        PFFile *imageOrVideoFile;
        PFObject *picture;

        if ([imageOrFile isKindOfClass:[UIImage class]])
        {
            UIImage *image = imageOrFile;

                imageOrVideoFile = [PFFile fileWithName:@"image.png"
                                                data:UIImageJPEGRepresentation(image, .5)];

            picture = [PFObject objectWithClassName:PF_PICTURES_CLASS_NAME];

            UIImage *thumbnail = ResizeImage(image, image.size.width, image.size.height);

            PFFile *file = [PFFile fileWithName:@"thumbnail.png" data:UIImageJPEGRepresentation(thumbnail, .2)];

            [picture setValue:file forKey:PF_PICTURES_THUMBNAIL];
            [picture setValue:[PFUser currentUser] forKey:PF_PICTURES_USER];
            [picture setValue:room_ forKey:PF_PICTURES_CHATROOM];
            [picture setValue:@YES forKey:PF_CHAT_ISUPLOADED];
            [picture setValue:[NSDate dateWithTimeIntervalSinceNow:[array indexOfObject:image]]forKey:PF_PICTURES_UPDATEDACTION];
            [picture setValue:set forKey:PF_PICTURES_SETID];
            [arrayOfPicturesObjectsTemp addObject:picture];

        }
        else if ([imageOrFile isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic = imageOrFile;
            NSString *path = dic.allKeys.firstObject;
            UIImage *image = dic.allValues.firstObject;

            imageOrVideoFile = [PFFile fileWithName:@"video.mov" contentsAtPath:path];

            picture = [PFObject objectWithClassName:PF_PICTURES_CLASS_NAME];
            [picture setValue:[PFUser currentUser] forKey:PF_PICTURES_USER];
            [picture setValue:room_ forKey:PF_PICTURES_CHATROOM];
            [picture setValue:@YES forKey:PF_CHAT_ISUPLOADED];

            [picture setValue:[NSDate dateWithTimeIntervalSinceNow:[array indexOfObject:imageOrFile]]forKey:PF_PICTURES_UPDATEDACTION];

            UIImage *thumbnail = ResizeImage(image, image.size.width, image.size.height);
            PFFile *fileThumb = [PFFile fileWithName:@"thumbnail.png" data:UIImageJPEGRepresentation(thumbnail, .2)];

            [picture setObject:fileThumb forKey:PF_PICTURES_THUMBNAIL];
            [picture setValue:set forKey:PF_PICTURES_SETID];

            [picture setValue:@YES forKey:PF_PICTURES_IS_VIDEO];

            [arrayOfPicturesObjectsTemp addObject:picture];
    }

        __block BOOL didSaveLastPicture = false;

        [picture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (succeeded)
            {
                x--;

                [picture setValue:imageOrVideoFile forKey:PF_PICTURES_PICTURE];
                [picture saveInBackground];

                [pictureObjects addObject:picture];
                [pictureObjectIds addObject:picture.objectId];

                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[pictureObjects indexOfObject:picture] inSection:0];

                _countDownForPictureRefresh--;

#warning SHOULD BE FIRST PICTURE BUT BEWARE, NOT THE CASE.
                if (!didSaveLastPicture)
                {

                    didSaveLastPicture = true;
                    self.selectedSetForPictures = set;
                    [set setValue:picture forKey:PF_SET_LASTPICTURE];
                    [set saveInBackground];

                    [self.room_ setValue:@(numberOfSets + 1) forKey:PF_CHATROOMS_ROOMNUMBER];
                    [self.room_ saveInBackground];

                    if (set.objectId > 0 && ![colorForSetId objectForKey:set.objectId])
                    {
                        NSLog(@"color chosen.");
                        if (arrayOfAvailableColors.count == 0) {
                            [arrayOfAvailableColors addObjectsFromArray:[AppConstant arrayOfColors]];
                        }
                        newColor = [arrayOfAvailableColors objectAtIndex:0];
                        [arrayOfAvailableColors removeObject:newColor];
                        NSString *colorString = [UIColor stringFromColor:newColor];
                        NSDictionary *dict = [NSDictionary dictionaryWithObject:colorString forKey:set.objectId];
                        [colorForSetId addEntriesFromDictionary:dict];
                    }
                }

#warning COULD CAUSE PROBLEMS
                [self.collectionViewPictures insertItemsAtIndexPaths:@[indexPath]];
//                [self.collectionView reloadData];

                if (_countDownForPictureRefresh == 0)
                {
                    SendPushNotification(room_, @"New Picture!");
                    UpdateMessageCounter(room_, @"New Picture!", arrayOfPicturesObjectsTemp.lastObject);

                    //                  numberOfSets // use to find selected color
                    NSLog(@"picture loaded");
                    [self commentBarColorEnabled:newColor];

                    [self scrollToBottomAnimated:1];

                    didSendPhotos = NO;

                    PostNotification(NOTIFICATION_CLEAR_CAMERA_STUFF);

                    [ProgressHUD showSuccess:@"Saved" Interaction:1];
                }
            } else {
                [ProgressHUD showError:@"Picture Saving Error"];
            }
        }];
    }
        }
        else
        {
            [ProgressHUD showError:@"Network Error"];
        }
    }];
}

- (void) commentBarColorEnabled:(UIColor *)color
{
#warning SET VALUE ON SENDING NEW PICTURES
    if (self.selectedSetForPictures)
    {
        NSLog(@"target");
        isCommentingOnPictures = YES;

        self.inputToolbar.contentView.textView.backgroundColor = color;
        self.inputToolbar.contentView.textView.textColor = [UIColor whiteColor];
        self.inputToolbar.contentView.textView.placeHolder = @"Attach a Comment...";
        self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;

        self.inputToolbar.contentView.textView.placeHolderTextColor = [UIColor lightTextColor];

//        [self.inputToolbar.contentView.textView becomeFirstResponder];

        [self performSelector:@selector(openTextView) withObject:self afterDelay:.5];

        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [button setImage:[[UIImage imageNamed:ASSETS_CLOSE] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        button.tintColor = [UIColor volleyFamousGreen];
        self.inputToolbar.contentView.leftBarButtonItem = button;
        
    }

}

//Clear comment bar of stuff.
- (void)actionDismiss
{
    isCommentingOnPictures = NO;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[[UIImage imageNamed:ASSETS_NEW_CAMERASQUARE ] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    button.tintColor = [UIColor volleyFamousGreen];
    button.imageView.tintColor = [UIColor volleyFamousGreen];
    self.inputToolbar.contentView.rightBarButtonItem.tintColor = [UIColor blueTintColor];

    self.selectedSetForPictures = nil;

    self.inputToolbar.contentView.textView.placeHolderTextColor = [UIColor lightGrayColor];
    self.inputToolbar.contentView.leftBarButtonItem = button;
    self.inputToolbar.contentView.textView.textColor = [UIColor darkTextColor];
    self.inputToolbar.contentView.textView.text = @"";

    self.inputToolbar.contentView.textView.backgroundColor = [UIColor whiteColor];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Attach a Comment..."])
    {
        textView.text = @"";
    }

    if (isCommentingOnPictures)
    {
        textView.text = @"";
    }

    [self.view addGestureRecognizer:tap];

    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    [super textViewDidEndEditing:textView];

    if (textView != self.inputToolbar.contentView.textView)
    {
        return;
    }

    [textView resignFirstResponder];
    [self scrollToBottomAnimated:1];
    [self.view removeGestureRecognizer:tap];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionViewPictures)
    {
        CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

        [cell format];
        
        if (pictureObjects.count > 0)
        {
            cell.backgroundColor = [UIColor clearColor];

            PFObject *pictureObject = pictureObjects[indexPath.item];
            PFUser *user = [pictureObject valueForKey:PF_PICTURES_USER];

            NSString *name = [user valueForKey:PF_USER_FULLNAME];

            NSMutableArray *array = [NSMutableArray arrayWithArray:[name componentsSeparatedByString:@" "]];
            [array removeObject:@" "];

            if (array.count == 2)
            {
                NSString *first = array.firstObject;
                NSString *last = array.lastObject;
                first = [first stringByPaddingToLength:1 withString:name startingAtIndex:0];
                last = [last stringByPaddingToLength:1 withString:name startingAtIndex:0];
                name = [first stringByAppendingString:last];
                cell.label.text = name;
            }

            if (pictureObject)
            {
                PFFile *file = [pictureObject objectForKey:PF_PICTURES_THUMBNAIL];
//                cell.imageView.file = file;
//                [cell.imageView loadInBackground];
            
                 [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                     if (!error) {
                         cell.imageView.image = [UIImage imageWithData:data];
                     }
                 }];
                
                PFObject *set = [[pictureObjects objectAtIndex:indexPath.item] valueForKey:PF_PICTURES_SETID];
                UIColor *setIdColor = [UIColor colorFromString:[colorForSetId objectForKey:set.objectId]];
                cell.imageView.layer.borderColor = setIdColor.CGColor;
                cell.label.backgroundColor = setIdColor;
            }
        }
        return cell;

    } else {

        JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
        if (messages.count)
        {
            JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
            //        JSQMessage *message = setComments[indexPath.item];
            cell.textView.textColor = [UIColor whiteColor];
            cell.messageBubbleTopLabel.textColor = [UIColor lightGrayColor];
            return cell;
        }
        return cell;
    }

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isSelectingItem) {
        isSelectingItem = YES;
        if (collectionView == self.collectionViewPictures) {
            [collectionView deselectItemAtIndexPath:indexPath animated:1];

            PFObject *picture = pictureObjects[indexPath.row];
            PFObject *set = [picture valueForKey:PF_PICTURES_SETID];
            NSString *setId = set.objectId;
            UIColor *colorForPicture = [UIColor colorFromString:[colorForSetId objectForKey:setId]];
            selectedColor = colorForPicture;
            
            if (self.inputToolbar.contentView.textView.isFirstResponder)
            {
                [self.inputToolbar.contentView.textView resignFirstResponder];
            }
            else
            {
                [self SortSetiDintoPicturesAndComments:setId andName:[[picture valueForKey:PF_PICTURES_USER] valueForKey:PF_USER_FULLNAME]];
            }
            
            self.automaticallyScrollsToMostRecentMessage = NO;
        }
    }
}

- (void) didLongPress:(UILongPressGestureRecognizer *)longPress
{
    bool isTouching;
    CGPoint touch = [longPress locationInView:self.collectionViewPictures];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    spinner.frame = CGRectMake(self.view.frame.size.width/2 -50, self.view.frame.size.height/2 - 50, 100, 100);

    NSIndexPath *indexPath = [self.collectionViewPictures indexPathForItemAtPoint:touch];


    if (self.inputToolbar.contentView.textView.isFirstResponder)
    {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }

    if (indexPath && longPress.state == UIGestureRecognizerStateBegan)
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        //User long pressed image

        [[UIApplication sharedApplication] setStatusBarHidden:1 withAnimation:UIStatusBarAnimationFade];

        isTouching = YES;

        longPressImageView = [[PFImageView alloc] initWithFrame:self.view.bounds];

        longPressImageView.backgroundColor = [UIColor volleyFamousGreen];

        PFObject *picture = [pictureObjects objectAtIndex:indexPath.item];

        __block PFFile *file = [picture valueForKey:PF_PICTURES_PICTURE];

        if (!file)
        {
            [picture fetch];
            file = [picture valueForKey:PF_PICTURES_PICTURE];
        }

        if ([[picture valueForKey:PF_PICTURES_IS_VIDEO]  isEqual: @YES])
        {
                    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithFormat:@"cache%@.mov", picture.objectId]];
                    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
                    NSFileManager *fileManager = [NSFileManager defaultManager];

                    if (![fileManager fileExistsAtPath:outputPath])
                    {
                        [[file getData] writeToFile:outputPath atomically:1];
                    }

            self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:outputURL];
            [self.moviePlayer.view setFrame:self.view.window.frame];
            self.moviePlayer.fullscreen = NO;
            [self.moviePlayer prepareToPlay];
            longPressImageView.backgroundColor = [UIColor blackColor];

            [UIView animateWithDuration:1.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                longPressImageView.alpha = 0;
                longPressImageView.alpha = 1;
                [spinner startAnimating];
                [longPressImageView addSubview:spinner];
                [self.view.window addSubview:longPressImageView];
            } completion:0];

            self.moviePlayer.controlStyle = MPMovieControlStyleNone;
            [self.moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
            self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
            [self.moviePlayer play];
            [longPressImageView addSubview:self.moviePlayer.view];
            return;

        }

        if (file)
        {
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    [spinner stopAnimating];
                    [longPressImageView setContentMode:UIViewContentModeScaleAspectFill];
                    longPressImageView.image = [UIImage imageWithData:data];
                }
            }];

            longPressImageView.backgroundColor = [UIColor blackColor];

            [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                longPressImageView.alpha = 0;
                longPressImageView.alpha = 1;
                [spinner startAnimating];
                [longPressImageView addSubview:spinner];
                [self.view.window addSubview:longPressImageView];
            } completion:0];

        }
    }

    if (longPress.state == UIGestureRecognizerStateEnded)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:0];
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;

        [self.moviePlayer pause];
        [self.moviePlayer.view removeFromSuperview];
        self.moviePlayer = nil;

        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            longPressImageView.alpha = 1;
            longPressImageView.alpha = 0;
        }completion:^(BOOL finished){
            [longPressImageView removeFromSuperview];
        }];

        isTouching = NO;
    }
}

- (void) didTap:(UITapGestureRecognizer *)tap
{
    if (self.inputToolbar.contentView.textView.isFirstResponder)
    {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }
}


-(void)leaveChatroom:(NSNotification *) notification
{
    isLoading = YES;
    [self.navigationController popViewControllerAnimated:1];
    PostNotification(NOTIFICATION_REFRESH_INBOX);
    PostNotification(NOTIFICATION_ENABLESCROLLVIEW);
}

-(void)dismiss
{
    self.automaticallyScrollsToMostRecentMessage = YES;
    //    [self performSelector:@selector(dismiss2) withObject:self afterDelay:1.0];
}

-(void)dismiss2
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:0 completion:0];
    });
}


-(void) setNavigationBarColor
{
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor volleyFamousGreen]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:1];
    self.navigationController.navigationBar.titleTextAttributes =  @{
                                                                     NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:20.0f],
                                                                     NSShadowAttributeName:[NSShadow new]
                                                                     };
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationBarColor];
    [[UIDevice currentDevice] playInputClick];
    [self checkForNickname];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leaveChatroom:) name:NOTIFICATION_LEAVE_CHATROOM object:0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadChat) name:NOTIFICATION_REFRESH_CHATROOM object:0];

#warning REDUNDANT NOTIFICATION
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadChat) name:NOTIFICATION_REFRESH_CUSTOMCHAT object:0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:NOTIFICATION_CAMERA_POPUP object:0];

//    self.title = self.name_;
    //Disable automatic keyboard helper
    _isLoadingEarlierCount = 1;

    self.automaticallyScrollsToMostRecentMessage = 1;
    self.showLoadEarlierMessagesHeader = 0;

    self.collectionView.loadEarlierMessagesHeaderTextColor = [UIColor lightGrayColor];

    if (!self.message_ && room_)
    {
        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
        [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
        [query whereKey:PF_MESSAGES_ROOM  equalTo:room_];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error & objects.count)
            {
                _message_ = objects.firstObject;
            }
        }];
    }

    self.didViewJustLoad = YES;

    [self.collectionViewPictures registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];


    //BAR BUTTONS
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @""
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[[UIImage imageNamed:ASSETS_NEW_CAMERASQUARE] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    button.tintColor = [UIColor volleyFamousGreen];
    self.inputToolbar.contentView.leftBarButtonItem = button;


    //Change send button to blue
    [self.inputToolbar.contentView.leftBarButtonItem setTitleColor:[UIColor blueTintColor] forState:UIControlStateNormal];
    [self.inputToolbar.contentView.leftBarButtonItem setTitleColor:[[UIColor blueTintColor] jsq_colorByDarkeningColorWithValue:0.1f] forState:UIControlStateHighlighted];


    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStyleBordered target:self action:@selector(popUpNames)];
    barButton.image = [UIImage imageNamed:ASSETS_TYPING];
    self.navigationItem.rightBarButtonItem = barButton;

    /*
     UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
     UIButton *buttonNames = [UIButton buttonWithType:UIButtonTypeCustom];
     buttonNames.titleLabel.text = name_;
     buttonNames.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:20];
     [buttonNames addTarget:self action:@selector(popUpNames) forControlEvents:UIControlEventTouchUpInside];
     [view1 addSubview:buttonNames];
     self.navigationItem.titleView = view1;
     self.navigationItem.titleView.frame = view1.frame;
     */

    if (_isNewChatroomWithPhotos && !_isSendingTextMessage)
    {
        [self performSelector:@selector(openTextView) withObject:self afterDelay:.5];
    }

    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap:)];
    tap.delegate = self;

    //Enable swiping when it returns from sending a message with pictures;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.view addGestureRecognizer:longPress];

    //INIT
    messages = [[NSMutableArray alloc] init];
    pictureObjects = [NSMutableArray new];
    pictureObjectIds = [NSMutableArray new];
    messageObjects = [NSMutableArray new];
    messageToSetId = [NSDictionary new];
    messageObjectIds = [NSMutableArray new];
    colorForSetId = [NSMutableDictionary new];
    unassignedCommentArray = [NSMutableArray new];
    unassignedCommentArrayIds = [NSMutableArray new];

    //Set up colors to pic from everytime, use same one for first object.
    arrayOfAvailableColors = [NSMutableArray arrayWithArray: [AppConstant arrayOfColors]];

    //CURRENT USER
    PFUser *user = [PFUser currentUser];
    self.senderId = user.objectId;
    self.senderDisplayName = user[PF_USER_FULLNAME];

    //BUBBLES
    bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor lightGrayColor]];
    incomingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor lightGrayColor]];

    //CLEAR!!

    [_message_ fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            if ([object valueForKey:PF_MESSAGES_COUNTER])
            {
                NSNumber *number = [object objectForKey:PF_MESSAGES_COUNTER];
                // Fetch the inbox message first? Object may not have been updated from push in background??
                if ([number intValue] > 0)
                {
                    ClearMessageCounter(self.message_);
                }
            }
        }
    }];

    //LOAD!!
    [self loadChat];
}

-(void)checkForNickname
{
    if (_message_)
    {
        if (_message_[PF_MESSAGES_NICKNAME]) {
            NSString *nickname = _message_[PF_MESSAGES_NICKNAME];
            self.title = nickname;
        }
        else
        {
            NSString *description = self.title;
            NSMutableArray *array = [NSMutableArray arrayWithArray:[description componentsSeparatedByString:@" "]];
            [array removeObject:@" "];
            NSString *senderName = [NSString new];
            if (array.count == 2)
            {
                NSString *first = [NSString stringWithFormat:@"%@ ", array.firstObject];
                NSString *last = array.lastObject;
                senderName = [first stringByAppendingString:last];
                self.title = first;
            }
        }
    }
}

- (void) popUpNames
{
    if (isLoadingPopup == NO)
    {
        isLoadingPopup = YES;
        ChatroomUsersView *manage = [[ChatroomUsersView alloc] initWithRoom:room_];
        manage.message = _message_;
        manage.title = @"Settings";
        [self.navigationController showDetailViewController:[[NavigationController alloc] initWithRootViewController:manage] sender:self];
        isLoadingPopup = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:1];

    self.navigationController.navigationBarHidden = NO;

    [self checkForNickname];

    if (room_ && _isNewChatroomWithPhotos && self.selectedSetForPictures)
    {
        NSNumber *countOfSets = [room_ valueForKey:PF_CHATROOMS_ROOMNUMBER];
//        [self commentBarColorEnabled:([countOfSets intValue] - 1)];
//        _isNewChatroomWithPhotos = NO;
    }

//    if (_message_)
//    {
//        if (_message_[PF_MESSAGES_NICKNAME]) {
//            NSString *nickname = _message_[PF_MESSAGES_NICKNAME];
//            self.title = nickname;
//        }
//        else
//        {
////            self.title = description;
//        }
//    }

    if (!self.didViewJustLoad && !didSendPhotos) {
#warning REPLACE WITH NOTIFICATION.
        [self loadChat];
    } else {
        self.didViewJustLoad = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self actionDismiss];
    isSelectingItem = NO;

    [ProgressHUD dismiss];

    [super viewWillDisappear:animated];

//    [_message_ fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (!error) {
//            if ([object valueForKey:PF_MESSAGES_COUNTER])
//            {
//                NSString *number = [object objectForKey:PF_MESSAGES_COUNTER];
//                // Fetch the inbox message first? Object may not have been updated from push in background??
//                if ([number intValue] > 0)
//                {
//                    ClearMessageCounter(self.message_);
//                }
//            }
//        }
//    }];
}

#pragma mark - Backend methods

- (void)loadChat
{
    if (isLoading == NO)
    {
        isLoading = YES;
        self.collectionView.hidden = _didViewJustLoad;
        self.collectionViewPictures.hidden = _didViewJustLoad;

        PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
        [query whereKey:PF_CHAT_ROOM equalTo:room_];
        JSQMessage *message_last = [messages lastObject];
        PFObject *picture_last = [pictureObjects lastObject];

        if (message_last && picture_last)
        {
            if (message_last.date > picture_last.createdAt)
            {
                [query whereKey:PF_CHAT_CREATEDAT greaterThan:message_last.date];
            }
            else
            {
                [query whereKey:PF_CHAT_CREATEDAT greaterThan:picture_last.createdAt];
            }
        }

        [query includeKey:PF_CHAT_USER];
        [query includeKey:PF_CHAT_SETID];
        [query orderByDescending:PF_PICTURES_UPDATEDACTION];

        [query setLimit:200 * _isLoadingEarlierCount];
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 int count = (int)messages.count + (int)pictureObjects.count;

                 NSMutableArray *indexPaths = [NSMutableArray new];
                 NSMutableArray *indexPathsPictures = [NSMutableArray new];
                 //Loading into array
                 for (PFObject *object in [objects reverseObjectEnumerator])
                 {
                     if ([object objectForKey:PF_PICTURES_THUMBNAIL])
                     {
                         // IS A PICTURE, ADD TO PICTURES
                         if ([object valueForKey:PF_CHAT_ISUPLOADED])
                         {
                             if (![pictureObjectIds containsObject:object.objectId])
                             {
                                 [pictureObjects addObject:object];
                                 [pictureObjectIds addObject:object.objectId];
                                 NSIndexPath *index = [NSIndexPath indexPathForItem:[pictureObjects indexOfObject:object] inSection:0];
                                 [indexPathsPictures addObject:index];
                             }
                         }
                     }
                     else
                     {
                         // IS A COMMENT, ADD TO COMMENTS;
                         if (![messageObjectIds containsObject:object.objectId])
                         {
                             [self addMessage:object];
                             [messageObjects addObject:object];
                             [messageObjectIds addObject:object.objectId];
                             NSIndexPath *index = [NSIndexPath indexPathForItem:[messageObjects indexOfObject:object] inSection:0];
                             [indexPaths addObject:index];
                         }
                     }
                 }

                 //Sorting colors new
                 for (PFObject *picture in pictureObjects)
                 {
                     PFObject *setObject = [picture valueForKey:PF_PICTURES_SETID];
                     if(setObject.objectId)
                     {
                         NSString *setID = setObject.objectId;
                         if (setID.length > 0 && ![colorForSetId objectForKey:setID])
                         {
                             if (arrayOfAvailableColors.count == 0) {
                                 [arrayOfAvailableColors addObjectsFromArray:[AppConstant arrayOfColors]];
                             }
                             UIColor *randomColor = [arrayOfAvailableColors objectAtIndex:0];
                             [arrayOfAvailableColors removeObject:randomColor];
                            NSString *colorString = [UIColor stringFromColor:randomColor];
                            NSDictionary *dict = [NSDictionary dictionaryWithObject:colorString forKey:setID];
                             [colorForSetId addEntriesFromDictionary:dict];
                         }
                     }

                     else
                     {
                         NSLog(@"unassigned message");
                     }
                 }


                 //Sorting out what to do with the data
                 int newCount = (int)messages.count + (int)pictureObjects.count;

                 if (objects.count && _isLoadingEarlierCount == 1)
                 {
                     //Should help the cache show up after network times out.
                     self.collectionViewPictures.hidden = NO;
                     self.collectionView.hidden = NO;
                     [self finishReceivingMessage:0];
                 }
                 else if (_isLoadingEarlierCount > 1)
                 {
                     //Checking load earlier, did new messages show up?
                     //Make sure this doesn't scroll to bottom.
                     
                     if (newCount - count == 0)
                     {
                         [ProgressHUD showSuccess:@"Last Message" Interaction:1];
                     }
                     
                     [self.collectionViewPictures reloadData];
                     [self.collectionView reloadData];
                     ClearMessageCounter(self.message_);
                     [_refreshControl endRefreshing];
                     [_refreshControl2 endRefreshing];
                     return;
                 }
                 else if (!count)
                 {
                     [self performSelector:@selector(openTextView) withObject:self afterDelay:.5f];
                 }
                 else if (newCount > 200)
                 {
                     self.showLoadEarlierMessagesHeader = 1;
                 }
                 isLoading = NO;

                 if (_isNewChatroomWithPhotos)
                 {
                     //New chatroom didn't have cache, so self.editing never called.
                     self.collectionViewPictures.hidden = NO;
                     self.collectionView.hidden = NO;
                     [self finishReceivingMessage:1];
                 }

//                 if (indexPathsPictures.count) [self.collectionViewPictures insertItemsAtIndexPaths:indexPathsPictures];
//                 if (indexPaths.count) [self.collectionView insertItemsAtIndexPaths:indexPaths];

                 if (self.editing)
                 { // WONT LOAD OFFLINE CACHE
                     self.editing = !self.editing;

                     self.showTypingIndicator = NO;
                     self.collectionView.hidden = NO;
                     self.collectionViewPictures.hidden = NO;
                     [self finishReceivingMessage:1];

                     if (picture_last && newCount > count) {
                         NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
                         if ([userDefualts boolForKey:PF_KEY_SHOULDVIBRATE]) {
                             [JSQSystemSoundPlayer jsq_playMessageReceivedAlert];
                         } else {
                             [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                         }
                     }
                 } else {
                     self.editing = !self.editing;
                 }
             } else {
                 self.collectionViewPictures.hidden = NO;
                 self.collectionView.hidden = NO;

                 if ([query hasCachedResult] && (self.navigationController.visibleViewController == self))
                 {
#warning IF NO INTERNET, SHOW THE CACHE
                     [ProgressHUD showError:@"Network error"];
                 }
             }
         }];
    }
}

- (void)openTextView
{
    if (!_isSendingTextMessage)
    {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
    }
    else
    {
        _isSendingTextMessage = NO;
    }
}

- (void)addMessage:(PFObject *)object
{
    PFUser *user = object[PF_CHAT_USER];
    NSDate *date = object[PF_PICTURES_UPDATEDACTION];
    PFObject *set = object[PF_CHAT_SETID];
    if (!set)
    {
        // if it doesn't exist, set one?
    }
    else
    {
        
    }
    if (!date) date = [NSDate date];
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:user.objectId
                                             senderDisplayName:user[PF_USER_FULLNAME]
                                                         setId:set.objectId
                                                          date:date
                                                          text:object[PF_CHAT_TEXT]];
    [messages addObject:message];
}

- (void)sendMessage:(NSString *)text PictureSet:(PFObject *)set
{
    PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
    object[PF_CHAT_USER] = [PFUser currentUser];
    object[PF_CHAT_ROOM] = room_;
    object[PF_CHAT_TEXT] = text;
    [object setValue:[NSDate date] forKey:PF_PICTURES_UPDATEDACTION];
    if (set)
    {
        [object setObject:set forKey:PF_CHAT_SETID];
    }
    else
    {
        __block int numberOfSets;
        numberOfSets = [[self.room_ valueForKey:PF_CHATROOMS_ROOMNUMBER] intValue];
        PFObject *set = [PFObject objectWithClassName:PF_SET_CLASS_NAME];
        [set setValue:room_ forKey:PF_SET_ROOM];
        [set setValue:[PFUser currentUser] forKey:PF_SET_USER];
        [set setValue:@(numberOfSets) forKey:PF_SET_ROOMNUMBER];
        [object setObject:set forKey:PF_CHAT_SETID];
    }
    [self finishSendingMessage];

    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error && succeeded)
         {
             [self addMessage:object];
             [self finishSendingMessage];
             [messageObjectIds addObject:object.objectId];
             [JSQSystemSoundPlayer jsq_playMessageSentSound];
             SendPushNotification(room_, text);
             UpdateMessageCounter(room_, text, nil);
         }
         else {
             [ProgressHUD showError:@"Network error."];
             [object deleteInBackground];
         }
     }];
}

//YOU CLICK ON PICTURE, LET ME FIND ALL THE COMMENTS, AND PICTURES IMAGES
- (void) SortSetiDintoPicturesAndComments:(NSString *)setId andName:(NSString *)user
{
    arrayOfSetIdComments = [NSMutableArray new];
    arrayOfSetIdPicturesObjects = [NSMutableArray new];
    int count = 0;
    if (pictureObjects.count)
    {
        for (PFObject *picture in pictureObjects)
        {
            count += 1;
            PFObject *set = [picture valueForKey:PF_PICTURES_SETID];
            if ([set.objectId isEqualToString:setId]) {
                [arrayOfSetIdPicturesObjects addObject:picture];
            }
            if (count == pictureObjects.count)
            {
                [self SortCommentsByPictureToSetId:setId andUserId:user];
            }
        }
    }
    else
    {
        [self SortCommentsByPictureToSetId:setId andUserId:user];
    }
}

//2ND CHAT VIEW
- (void)SortCommentsByPictureToSetId:(NSString *)setId andUserId:(NSString *)user
{
    if (messages.count == 0)
    {
        [self sendCustomChatWithSet:setId andUserID:user];
    }

    int count = 0;
    for (JSQMessage *commment in messages)
    {
        count += 1;
        if ([commment.setId isEqualToString:setId])
        {
            [arrayOfSetIdComments addObject:commment];
        }
        if (count == messages.count)
        {
            [self sendCustomChatWithSet:setId andUserID:user];
        }
    }
}

-(void)sendCustomChatWithSet:(NSString *)setId andUserID:(NSString *)message
{
    CustomChatView *chatt = [[CustomChatView alloc] initWithSetId:setId andColor:selectedColor andPictures:arrayOfSetIdPicturesObjects andComments:arrayOfSetIdComments];
    chatt.senderId = [self.senderId copy];
    chatt.senderDisplayName = [self.senderDisplayName copy];
    chatt.room = room_;

    NSString *title;

    if([message isEqualToString:self.senderDisplayName])
    {
        title = @"My Pictures";
    }
    else
    {
        title = [message stringByAppendingString:@"'s Pictures"];
    }

    [chatt setTitle:title];

    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    transition.fillMode = kCAFillModeForwards;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:chatt animated:1];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = messages[indexPath.item];
    UIColor *gray = [UIColor colorWithRed:.65f green:.65f blue:.65f alpha:1.0f];

    outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:gray];
    incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:gray];

    if (message.setId && pictureObjects.count && [colorForSetId valueForKey:message.setId])
    {
        UIColor *setIdColor = [UIColor colorFromString:[colorForSetId valueForKey:message.setId]];
        outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:setIdColor];
        incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:setIdColor];
    }

    if ([message.senderId isEqualToString:self.senderId])
    {
        return outgoingBubbleImageData;
    }
    return incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    PFObject *set = [[pictureObjects lastObject] valueForKey:PF_PICTURES_SETID];
    UIColor *setIdColor = [UIColor colorFromString:[colorForSetId objectForKey:set.objectId]];
    [self commentBarColorEnabled:setIdColor];
    if (collectionView == self.collectionViewPictures) {
        return [pictureObjects count];
    } else {
        return [messages count];
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */

    JSQMessage *message = [messages objectAtIndex:indexPath.item];

    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:message.date];
    NSDate *date = [NSDate dateWithTimeInterval: seconds sinceDate:message.date];

    NSAttributedString *string = [[NSAttributedString alloc] initWithString:[date dateTimeUntilNow]];

    if (indexPath.item - 1 > -1) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];

        if (abs([message.date timeIntervalSinceDate:previousMessage.date]) > 60 * 60) {
            return [[JSQMessagesTimestampFormatter new] attributedTimestampForDate:message.date];
        }
    } else {
        return [[JSQMessagesTimestampFormatter new] attributedTimestampForDate:message.date];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [messages objectAtIndex:indexPath.item];

    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    if (indexPath.item - 1 > -1) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    /**
     *  Don't specify attributes to use the defaults.
     */
    NSMutableArray *array = [NSMutableArray arrayWithArray:[message.senderDisplayName componentsSeparatedByString:@" "]];
    [array removeObject:@" "];
    NSString *senderName = [NSString new];
//    if (array.count == 2)
    {
        NSString *first = [NSString stringWithFormat:@"%@ ", array.firstObject];
        NSString *last = array.lastObject;
        senderName = [first stringByAppendingString:last];
//        self.title = first;
    }

    return [[NSAttributedString alloc] initWithString: senderName];

}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource
#pragma mark - JSQMessages collection view flow layout delegate
#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */

    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */

    if (indexPath.item - 1 > -1)
    {
        JSQMessage *message = [messages objectAtIndex:indexPath.item];
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];

        if (abs([message.date timeIntervalSinceDate:previousMessage.date]) > 60 * 60)
        {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
    }
    else
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }

    return 0.1f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }

    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    _isLoadingEarlierCount++;
    [self loadChat];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.inputToolbar.contentView.textView.isFirstResponder)
    {
        [self.inputToolbar.contentView.textView resignFirstResponder];
        return;
    }
    
    selectedColor = nil;
    JSQMessage *message = [messages objectAtIndex:indexPath.row];
    UIColor *colorForPicture = [UIColor colorFromString:[colorForSetId objectForKey:message.setId]];
    selectedColor = colorForPicture;
    
    if (message.setId && message.senderId)
    {
        if (!isSelectingItem)
        {
            isSelectingItem = YES;
            [self SortSetiDintoPicturesAndComments:message.setId andName:message.senderDisplayName];
        }
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    if (self.inputToolbar.contentView.textView.isFirstResponder) {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }
}

@end