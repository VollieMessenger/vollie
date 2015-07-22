//
//  NewJSQTestVCViewController.m
//  Volley
//
//  Created by Kyle on 7/16/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "NewJSQTestVCViewController.h"
#import "messages.h"
#import "pushnotification.h"
#import "ProgressHUD.h"
#import "NSDate+TimeAgo.h"
#import "AppDelegate.h"
#import "pushnotification.h"
#import "utilities.h"
#import "AppConstant.h"

@interface NewJSQTestVCViewController ()
@property NSMutableArray *messages;
@property NSString *setId;
@property NSString *senderName;
@property NSString *senderID;
@property JSQMessagesBubbleImage *outgoingBubbleImageData;
@property JSQMessagesBubbleImage  *incomingBubbleImageData;
@property JSQMessagesBubbleImageFactory *bubbleFactory;
//@property NSString *senderDisplayName;
//@property NSString *senderId;

@end

@implementation NewJSQTestVCViewController

-(id)initWithSetId:(NSString *)setId andMessages:(NSArray *)messages
{
    self = [super init];
    if (self)
    {
        self.senderID = [PFUser currentUser].objectId;
        self.senderDisplayName = [PFUser currentUser][PF_USER_FULLNAME];
        self.setId = setId;
        self.setIDforCardCheck = setId;
        self.messages = [NSMutableArray arrayWithArray:messages];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.collectionView.backgroundColor = [UIColor orangeColor];
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    //    self.view.layer.backgroundColor = [UIColor purpleColor].CGColor;
    //    [self scrollToBottomAnimated:YES];

    //Change send button to orange
    //    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:[UIColor volleyFamousOrange] forState:UIControlStateNormal];
    //    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:[[UIColor volleyFamousOrange] jsq_colorByDarkeningColorWithValue:0.1f] forState:UIControlStateHighlighted];
    //    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

//    self.doubleTapBlocker = false;

    if (!self.senderId || self.senderDisplayName)
    {
        self.senderId = [[PFUser currentUser].objectId copy];
        self.senderDisplayName = [[PFUser currentUser][PF_USER_FULLNAME] copy];
    }

//    NSLog(@"i have %li messages", self.messages.count);

    self.automaticallyScrollsToMostRecentMessage = 1;
    self.showLoadEarlierMessagesHeader = 0;
    self.collectionView.loadEarlierMessagesHeaderTextColor = [UIColor volleyFamousGreen];

//    NSParameterAssert(self.senderId != nil);
//    NSParameterAssert(setId_ != nil);
//    NSParameterAssert(self.senderDisplayName != nil);
//    NSParameterAssert(self.room != nil);

//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
//                                   initWithTitle: @""
//                                   style: UIBarButtonItemStyleBordered
//                                   target: nil action: nil];
//    [self.navigationItem setBackBarButtonItem: backButton];


    self.bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [self.bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor blueColor]];
    self.incomingBubbleImageData = [self.bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor volleyBorderGrey]];

}

-(void)viewDidAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}


#pragma mark "JSQmessagesCollectionView"
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];

    if ([message.senderId isEqualToString:self.senderId])
    {
        return self.outgoingBubbleImageData;
    }
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    // do we need this tho?
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // we need to put the segue stuff in here
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
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];

//    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
//    NSInteger seconds = [tz secondsFromGMTForDate:message.date];
    //    NSDate *date = [NSDate dateWithTimeInterval: seconds sinceDate:message.date];
    //NSAttributedString *string = [[NSAttributedString alloc] initWithString:[date dateTimeUntilNow]];

    if (indexPath.item - 1 > -1) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];

        if (abs([message.date timeIntervalSinceDate:previousMessage.date]) > 60 * 60)
        {
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
//    NSArray* reversed = [[self.messages reverseObjectEnumerator] allObjects];

    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];

    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    if (indexPath.item - 1 > -1) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId])
    {
        cell.textView.textColor = [UIColor whiteColor];
        //             cell.cellTopLabel.hidden = YES;
    }
    else
    {
        cell.textView.textColor = [UIColor blackColor];
    }
    //        cell.textView.textColor = [UIColor whiteColor];
    //        [cell sizeToFit];
    //        cell.textView.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15.0];
    cell.textView.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];

    //        HelveticaNeue
    //        [cell sizeToFit];
    //        [cell sizeThatFits:17.0];
    cell.messageBubbleTopLabel.textColor = [UIColor lightGrayColor];
    return cell;
}

#pragma mark "Detailed JSQ Stuff"

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item - 1 > -1) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
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
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
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

@end
