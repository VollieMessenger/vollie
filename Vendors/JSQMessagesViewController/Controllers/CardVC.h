//
//  CardVC.h
//  Volley
//
//  Created by Kyle on 6/17/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSQMessagesCollectionView.h"
#import "JSQMessagesCollectionViewFlowLayout.h"
#import "JSQMessagesInputToolbar.h"

@interface CardVC : UIViewController <JSQMessagesCollectionViewDataSource,
JSQMessagesCollectionViewDelegateFlowLayout,
UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate >
@property (weak, nonatomic) IBOutlet UIImageView *unreadNotificationDot;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewPictures;
/**
 *  Returns the collection view object managed by this view controller.
 *  This view controller is the collection view's data source and delegate.
 */
@property (weak, nonatomic, readonly) JSQMessagesCollectionView *collectionView;
@property (copy, nonatomic) NSString *senderDisplayName;
@property (copy, nonatomic) NSString *senderId;
@property (assign, nonatomic) BOOL automaticallyScrollsToMostRecentMessage;
@property (copy, nonatomic) NSString *outgoingCellIdentifier;
@property (copy, nonatomic) NSString *outgoingMediaCellIdentifier;
@property (copy, nonatomic) NSString *incomingCellIdentifier;
@property (copy, nonatomic) NSString *incomingMediaCellIdentifier;
@property (assign, nonatomic) BOOL showTypingIndicator;
@property (assign, nonatomic) BOOL showLoadEarlierMessagesHeader;
@property (assign, nonatomic) CGFloat topContentAdditionalInset;
@property (nonatomic) BOOL reloaded;

#pragma mark - Class methods
+ (UINib *)nib;
+ (instancetype)messagesViewController;

#pragma mark - Messages view controller
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date;
- (void)didPressAccessoryButton:(UIButton *)sender;

- (void)finishSendingMessage;

- (void)finishReceivingMessage:(BOOL)animated;

- (void)scrollToBottomAnimated:(BOOL)animated;

@end
