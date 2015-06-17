//
//  CardCellView.m
//  Volley
//
//  Created by Kyle on 6/17/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "CardCellView.h"
//#import "CustomChatView.h"
#import "AppConstant.h"
#import "KLCPopup.h"
#import <Parse/Parse.h>
#import "CustomCollectionViewCell.h"
#import "messages.h"
#import "pushnotification.h"
//#import "camera.h"
#import "ProgressHUD.h"
#import "DidFavoriteView.h"
#import "NSDate+TimeAgo.h"
#import "AppDelegate.h"
#import "pushnotification.h"
#import "utilities.h"
#import "VollieCardData.h"

#import <MediaPlayer/MediaPlayer.h>



@interface CardCellView ()

@property KLCPopup *popUp;
@property NSMutableArray *arrayOfScrollView;
@property UIPageControl *pageControl;
@property MPMoviePlayerController *moviePlayer;
@property BOOL doubleTapBlocker;
@property VollieCardData *cardData;

@end

@implementation CardCellView
{
    UITapGestureRecognizer *tap;
    PFImageView *longPressImageView;
    JSQMessagesBubbleImage *outgoingBubbleImageData;
    JSQMessagesBubbleImage  *incomingBubbleImageData;
    JSQMessagesBubbleImageFactory *bubbleFactory;
    NSString *setId_;
    UIColor *backgroundColor_;
    NSMutableArray *setPicturesObjects;
    NSMutableArray *setCommentsObjects;
    NSMutableArray *setComments;
    NSMutableArray *objectIds;
    NSMutableArray *arrayOfPictures;
    PFImageView *popUpImageView;
    int x;
}

@synthesize popUp;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:1];
//    [self isSetFavorited];
    [self finishReceivingMessage:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Change send button to orange
    //    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:[UIColor volleyFamousOrange] forState:UIControlStateNormal];
    //    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:[[UIColor volleyFamousOrange] jsq_colorByDarkeningColorWithValue:0.1f] forState:UIControlStateHighlighted];
    //    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

    self.doubleTapBlocker = false;

    if (!self.senderId || self.senderDisplayName)
    {
        self.senderId = [[PFUser currentUser].objectId copy];
        self.senderDisplayName = [[PFUser currentUser][PF_USER_FULLNAME] copy];
    }

    self.automaticallyScrollsToMostRecentMessage = 1;
    self.showLoadEarlierMessagesHeader = 0;
    self.collectionView.loadEarlierMessagesHeaderTextColor = [UIColor volleyFamousGreen];

    NSParameterAssert(self.senderId != nil);
    NSParameterAssert(setId_ != nil);
    NSParameterAssert(self.senderDisplayName != nil);
    NSParameterAssert(self.room != nil);

    [self.collectionViewPictures registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @""
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMessages) name:NOTIFICATION_REFRESH_CUSTOMCHAT object:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMessages) name:NOTIFICATION_REFRESH_CHATROOM object:0];

    bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:backgroundColor_];
    incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:backgroundColor_];

//    self.inputToolbar.contentView.textView.backgroundColor = backgroundColor_;
//    self.inputToolbar.contentView.textView.textColor = [UIColor whiteColor];
//    self.inputToolbar.contentView.textView.placeHolderTextColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.95f];
//
//    self.inputToolbar.contentView.leftBarButtonItem = nil;

    [self finishReceivingMessage:0];

    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap:)];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.view addGestureRecognizer:longPress];

    //    UITapGestureRecognizer *doubleTapFolderGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
    //    [doubleTapFolderGesture setNumberOfTapsRequired:2];
    //    [doubleTapFolderGesture setNumberOfTouchesRequired:1];
    //    [self.view addGestureRecognizer:doubleTapFolderGesture];
}

//- (void)isSetFavorited
//{
//    if (!_isFavoritesSets)
//    {
//        UIBarButtonItem *favorites = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"STAR5"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self action:@selector(actionStar)];
//        self.navigationItem.rightBarButtonItem = favorites;
//
//        //IF HAS BEEN FAVORITED.
//        PFQuery *query = [PFQuery queryWithClassName:PF_FAVORITES_CLASS_NAME];
//#warning MAY ACCIDENTLY FIND ONE THAT IS NOT FAVORITED.
//        [query whereKey:PF_FAVORITES_SET equalTo:[PFObject objectWithoutDataWithClassName:PF_SET_CLASS_NAME objectId:setId_]];
//        [query whereKey:PF_FAVORITES_USER equalTo:[PFUser currentUser]];
//
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//         {
//             if (!error)
//             {
//                 if (objects.count > 0)
//                 {
//                     UIBarButtonItem *favorites = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"STAR6"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self action:@selector(actionStar)];
//                     self.navigationItem.rightBarButtonItem = favorites;
//                 }
//                 else
//                 {
//                     UIBarButtonItem *favorites = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"STAR5"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ] style:UIBarButtonItemStyleBordered target:self action:@selector(actionStar)];
//                     self.navigationItem.rightBarButtonItem = favorites;
//                 }
//             }
//         }];
//    }
//    else
//    {
//        UIBarButtonItem *favorites = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"STAR7"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self action:@selector(actionStar)];
//        self.navigationItem.rightBarButtonItem = favorites;
//        
//    }
//}

- (id)initWithSetId:(NSString *)setId andColor:(UIColor *)backgroundColor andPictures:(NSArray *)pictures andComments:(NSArray *)messages
{
    self = [super init];
    if (self) {
        if ([[UIColor stringFromColor:backgroundColor] isEqualToString:@"0 0 0 0"]) {
            backgroundColor_ = [UIColor volleyBubbleGreen];
        } else {
            backgroundColor_ = backgroundColor;
        }
        if (!self.senderId) {
            self.senderId = [PFUser currentUser].objectId;
            self.senderDisplayName = [PFUser currentUser][PF_USER_FULLNAME];
        }
        setId_ = setId;
        self.setIDforCardCheck = setId;

        setPicturesObjects = [NSMutableArray arrayWithArray:pictures];
        setComments = [NSMutableArray arrayWithArray:messages];


        //Loading PFFile into memory or at least cache
        [self loadPicutresFilesInBackground];
    }
    return self;
}

-(void)loadPicutresFilesInBackground
{
    for (PFObject *picture in setPicturesObjects)
    {
        PFFile *file = [picture valueForKey:PF_PICTURES_PICTURE];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        }];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.view addGestureRecognizer:tap];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.view removeGestureRecognizer:tap];
    return YES;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionView) return setComments.count;
    else if (collectionView == self.collectionViewPictures) return setPicturesObjects.count;
    else return 0;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.doubleTapBlocker == false)
    {
        self.doubleTapBlocker = true;
        [self tappedAvatarPicWithIndexPath:indexPath];
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:1];
}

-(void)stopTheDTapBlocker
{
    self.doubleTapBlocker = false;
}

-(void)tappedAvatarPicWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSelector:@selector(stopTheDTapBlocker) withObject:self afterDelay:.5];

//    if (setPicturesObjects.count && self.navigationController.visibleViewController == self && !self.inputToolbar.contentView.textView.isFirstResponder)
    if(setPicturesObjects.count)
    {

        self.arrayOfScrollView = [NSMutableArray arrayWithCapacity:setPicturesObjects.count];

        for (int i = 0; i < setPicturesObjects.count; i++) {
            [self.arrayOfScrollView addObject:[NSString stringWithFormat:@"%d",i]];
        }

        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.bounces = YES;
        scrollView.pagingEnabled = 1;
        scrollView.alwaysBounceHorizontal = 1;
        scrollView.delegate = self;
        scrollView.tag = 22;
        scrollView.directionalLockEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = 0;

        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, scrollView.frame.size.height - 20, scrollView.frame.size.width, 10)];
        [self.pageControl setNumberOfPages:setPicturesObjects.count];
        [self.pageControl setCurrentPage:indexPath.item];

        scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * setPicturesObjects.count, self.view.bounds.size.width);

        [scrollView setContentOffset:CGPointMake((self.view.frame.size.width * indexPath.row), 0) animated:0];
        int counter = 0;
        //Set the count.
        __block int count = (int)setPicturesObjects.count;
        for (PFObject *picture in setPicturesObjects)
        {
            counter += 1;
            CGRect rect = CGRectMake(([setPicturesObjects indexOfObject:picture] * self.view.bounds.size.width - 2) + 2, 0, self.view.frame.size.width, self.view.frame.size.height);

            PFImageView *popUpImageView2 = [[PFImageView alloc] initWithFrame:rect];

            PFFile *file = [picture valueForKey:PF_PICTURES_PICTURE];

            if (!file)
            {
                [picture fetch];
                file = [picture valueForKey:PF_PICTURES_PICTURE];
            }

            if ([[picture valueForKey:PF_PICTURES_IS_VIDEO] isEqual:@YES])
            {
                NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithFormat:@"cache%@.mov", picture.objectId]];
                NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
                NSFileManager *fileManager = [NSFileManager defaultManager];

                if (![fileManager fileExistsAtPath:outputPath])
                {
                    [[file getData] writeToFile:outputPath atomically:1];
                }
                MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:outputURL];

                moviePlayer.view.frame = rect;
                [moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
                [moviePlayer setFullscreen:1];
                [moviePlayer setMovieSourceType:MPMovieSourceTypeFile];

                UIButton *saveImageButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 40, 40)];

                saveImageButton.imageView.hidden = YES;

                saveImageButton.tag = [setPicturesObjects indexOfObject:picture];

                [saveImageButton addTarget:self action:@selector(didTapKLC:) forControlEvents:UIControlEventTouchUpInside];

                [saveImageButton setImage:[UIImage imageNamed:ASSETS_CLOSE] forState:UIControlStateNormal];
                saveImageButton.backgroundColor = [UIColor volleyFamousGreen];
                saveImageButton.layer.masksToBounds = 1;
                saveImageButton.layer.cornerRadius = 5;
                saveImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
                saveImageButton.layer.borderWidth = 2;

                [moviePlayer.view addSubview:saveImageButton];

                moviePlayer.controlStyle = MPMovieControlStyleNone;
                moviePlayer.view.layer.masksToBounds = YES;
                moviePlayer.view.contentMode = UIViewContentModeScaleToFill;
                moviePlayer.view.layer.cornerRadius = moviePlayer.view.frame.size.width/10;
                moviePlayer.view.layer.borderColor = [UIColor whiteColor].CGColor;
                moviePlayer.view.layer.borderWidth = 5;
                moviePlayer.view.layer.cornerRadius = 10;
                //              moviePlayer.repeatMode = MPMovieRepeatModeNone;
                moviePlayer.repeatMode = MPMovieRepeatModeOne;

                [moviePlayer prepareToPlay];
                if ([setPicturesObjects indexOfObject:picture] != indexPath.row)
                {
                    [moviePlayer setShouldAutoplay:false];
                }

                [scrollView addSubview:moviePlayer.view];
                [self.arrayOfScrollView replaceObjectAtIndex:counter-1 withObject:moviePlayer];
                count--;
                if (count == 0)
                {
                    //                    [[UIApplication sharedApplication] setStatusBarHidden:1 withAnimation:UIStatusBarAnimationFade];
                    [[UIApplication sharedApplication] setStatusBarHidden:1];

                    [ProgressHUD dismiss];

                    self.popUp = [KLCPopup popupWithContentView:scrollView
                                                       showType:KLCPopupShowTypeSlideInFromLeft
                                                    dismissType:KLCPopupDismissTypeSlideOutToLeft
                                                       maskType:KLCPopupMaskTypeDimmed
                                       dismissOnBackgroundTouch:0
                                          dismissOnContentTouch:0];

                    [self.popUp addSubview:self.pageControl];

                    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapKLC:)];
                    [self.popUp addGestureRecognizer:tap2];

                    [self.popUp show];
                }

            } else if (file) {

                //Gets cache if available
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                 {
                     if (!error)
                     {
                         popUpImageView2.image = [UIImage imageWithData:data];
                         popUpImageView2.layer.masksToBounds = YES;
                         popUpImageView2.userInteractionEnabled = YES;

                         UIButton *saveImageButton2 = [[UIButton alloc] initWithFrame:CGRectMake(popUpImageView2.frame.size.width - 55, popUpImageView2.frame.size.height - 55, 40, 40)];
                         saveImageButton2.imageView.image = [UIImage imageWithData:data];
                         saveImageButton2.imageView.hidden = YES;
                         saveImageButton2.tag = [setPicturesObjects indexOfObject:picture];
                         [saveImageButton2 addTarget:self action:@selector(downloadPicture:) forControlEvents:UIControlEventTouchUpInside];
                         [saveImageButton2 setImage:[UIImage imageNamed:ASSETS_BACK_BUTTON_DOWN] forState:UIControlStateNormal];
                         saveImageButton2.backgroundColor = [UIColor volleyFamousGreen];
                         saveImageButton2.layer.masksToBounds = 1;
                         saveImageButton2.layer.cornerRadius = 5;
                         saveImageButton2.layer.borderColor = [UIColor whiteColor].CGColor;
                         saveImageButton2.layer.borderWidth = 2;
                         [popUpImageView2 addSubview:saveImageButton2];

                         UIButton *closeImageButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 40, 40)];
                         closeImageButton.imageView.hidden = YES;
                         closeImageButton.tag = [setPicturesObjects indexOfObject:picture];
                         [closeImageButton addTarget:self action:@selector(didTapKLC:) forControlEvents:UIControlEventTouchUpInside];
                         [closeImageButton setImage:[UIImage imageNamed:ASSETS_CLOSE] forState:UIControlStateNormal];
                         closeImageButton.backgroundColor = [UIColor volleyFamousGreen];
                         closeImageButton.layer.masksToBounds = 1;
                         closeImageButton.layer.cornerRadius = 5;
                         closeImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
                         closeImageButton.layer.borderWidth = 2;
                         [popUpImageView2 addSubview:closeImageButton];

                         popUpImageView2.layer.cornerRadius = 10;
                         popUpImageView2.layer.borderColor = [UIColor whiteColor].CGColor;
                         popUpImageView2.layer.borderWidth = 5;

                         UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapKLC:)];
                         tap2.delegate = self;
                         [popUpImageView addGestureRecognizer:tap2];

                         [scrollView addSubview:popUpImageView2];
                         [self.arrayOfScrollView addObject:popUpImageView2];
                         [self.arrayOfScrollView replaceObjectAtIndex:counter-1 withObject:popUpImageView2];
                         count--;
                         if (count == 0)
                         {
                             [[UIApplication sharedApplication] setStatusBarHidden:1 withAnimation:UIStatusBarAnimationFade];

                             [ProgressHUD dismiss];

                             self.popUp = [KLCPopup popupWithContentView:scrollView
                                                                showType:KLCPopupShowTypeSlideInFromLeft
                                                             dismissType:KLCPopupDismissTypeSlideOutToLeft
                                                                maskType:KLCPopupMaskTypeDimmed
                                                dismissOnBackgroundTouch:0
                                                   dismissOnContentTouch:0];

                             [self.popUp addSubview:self.pageControl];

                             UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapKLC:)];
                             [self.popUp addGestureRecognizer:tap2];

                             [self.popUp show];
                         }
                     }
                     
                 } progressBlock:^(int percentDone) {
                     if (percentDone < 90) {
                         [ProgressHUD show:[NSString stringWithFormat:@"%i", percentDone]];
                     }
                 }];
            }
        }//end for loop
        NSObject *object = self.arrayOfScrollView[indexPath.row];
        if ([object isKindOfClass:[MPMoviePlayerController class]])
        {
            MPMoviePlayerController *mp = [self.arrayOfScrollView objectAtIndex:indexPath.row];
            [mp play];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 22)
    {
        CGFloat index = scrollView.contentOffset.x / self.view.frame.size.width;

        int xx = roundf(index);

        for (MPMoviePlayerController *object in self.arrayOfScrollView)
        {
            if ([object isKindOfClass:[MPMoviePlayerController class]])
            {
                [object stop];
            }
        }

        NSObject *object = [self.arrayOfScrollView objectAtIndex:xx];
        if ([object isKindOfClass:[MPMoviePlayerController class]])
        {
            MPMoviePlayerController *mp = [self.arrayOfScrollView objectAtIndex:xx];
            [mp play];
            [mp stop];
            [mp play];
        }

        [self.pageControl setCurrentPage:xx];
    }
}

- (void)didTapKLC:(UITapGestureRecognizer *)tap
{
    if (self.doubleTapBlocker == false)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:0 withAnimation:UIStatusBarAnimationFade];
        [popUp dismiss:1];

        for (MPMoviePlayerController *object in self.arrayOfScrollView) {
            if ([object isKindOfClass:[MPMoviePlayerController class]])
            {
                [object stop];
            }
        }

        if (self.popUp.isBeingDismissed) {
            self.popUp = nil;
            self.arrayOfScrollView = nil;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //This is called ALWAYS because of longPress???
    CGPoint point = [touch locationInView:self.view];
    if (popUp.isBeingShown)
    {
        if (point.x < self.view.frame.size.width - 50 && point.y < self.view.frame
            .size.width - 50)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    PostNotification(NOTIFICATION_REFRESH_CUSTOMCHAT);
}

- (void) dismiss
{
    [popUpImageView dismissPresentingPopup];
}

-(void)downloadPicture:(id)sender
{
    UIButton *button = (UIButton *)sender;
    PFFile *file = [[setPicturesObjects objectAtIndex:button.tag] valueForKey:PF_PICTURES_PICTURE];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], 0, 0, 0);
            [ProgressHUD showSuccess:@"Saved to Camera Roll"];
        }
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionViewPictures)
    {
        CustomCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

        if (setPicturesObjects.count > 0)
        {
            [cell format];

            PFFile *file = [setPicturesObjects[indexPath.item] valueForKey:PF_PICTURES_THUMBNAIL];

            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    cell.imageView.image = [UIImage imageWithData:data];
                }
            }];

            cell.backgroundColor = [UIColor clearColor];

            NSString *name = [[setPicturesObjects[indexPath.item] valueForKey:PF_PICTURES_USER] valueForKey:PF_USER_FULLNAME];

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

            cell.imageView.layer.borderColor = backgroundColor_.CGColor;
            cell.label.backgroundColor = backgroundColor_;
        }
        return cell;
    }
    else
    {
        JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
        //        JSQMessage *message = setComments[indexPath.item];
        cell.textView.textColor = [UIColor whiteColor];
        cell.messageBubbleTopLabel.textColor = [UIColor lightGrayColor];
        return cell;
    }
}

- (void) didTap:(UITapGestureRecognizer *)tap
{
//    if (self.inputToolbar.contentView.textView.isFirstResponder){
//        [self.inputToolbar.contentView.textView resignFirstResponder];
//    }
    [self.view removeGestureRecognizer:tap];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return setComments[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = setComments[indexPath.item];

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

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.inputToolbar.contentView.textView.isFirstResponder) {
//        [self.inputToolbar.contentView.textView resignFirstResponder];
//    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    JSQMessage *message = [setComments objectAtIndex:indexPath.item];

    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:message.date];
    //    NSDate *date = [NSDate dateWithTimeInterval: seconds sinceDate:message.date];
    //NSAttributedString *string = [[NSAttributedString alloc] initWithString:[date dateTimeUntilNow]];

    if (indexPath.item - 1 > -1) {
        JSQMessage *previousMessage = [setComments objectAtIndex:indexPath.item - 1];

        if (abs([message.date timeIntervalSinceDate:previousMessage.date]) > 60 * 60) {
            return [[JSQMessagesTimestampFormatter new] attributedTimestampForDate:message.date];
        }
    } else
    {
        return [[JSQMessagesTimestampFormatter new] attributedTimestampForDate:message.date];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [setComments objectAtIndex:indexPath.item];

    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    if (indexPath.item - 1 > -1) {
        JSQMessage *previousMessage = [setComments objectAtIndex:indexPath.item - 1];
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
    if (array.count == 2)
    {
        NSString *first = [NSString stringWithFormat:@"%@ ", array.firstObject];
        NSString *last = array.lastObject;
        senderName = [first stringByAppendingString:last];
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

    if (indexPath.item - 1 > -1) {
        JSQMessage *message = [setComments objectAtIndex:indexPath.item];
        JSQMessage *previousMessage = [setComments objectAtIndex:indexPath.item - 1];
        if (abs([message.date timeIntervalSinceDate:previousMessage.date]) > 60 * 60) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
    } else {
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
    JSQMessage *currentMessage = [setComments objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [setComments objectAtIndex:indexPath.item - 1];
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

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
}

- (void)didLongPress:(UILongPressGestureRecognizer *)longPress
{
    bool isTouching;
    CGPoint touch = [longPress locationInView:self.collectionViewPictures];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    spinner.frame = CGRectMake(self.view.frame.size.width/2 -50, self.view.frame.size.height/2 - 50, 100, 100);

    NSIndexPath *indexPath = [self.collectionViewPictures indexPathForItemAtPoint:touch];

//    if (self.inputToolbar.contentView.textView.isFirstResponder)
//    {
//        [self.inputToolbar.contentView.textView resignFirstResponder];
//    }

    if (indexPath && longPress.state == UIGestureRecognizerStateBegan)
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        //User long pressed image

        [[UIApplication sharedApplication] setStatusBarHidden:1 withAnimation:UIStatusBarAnimationFade];

        isTouching = YES;

        longPressImageView = [[PFImageView alloc] initWithFrame:self.view.bounds];

        longPressImageView.backgroundColor = [UIColor volleyFamousGreen];

        PFObject *picture = [setPicturesObjects objectAtIndex:indexPath.item];

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











@end