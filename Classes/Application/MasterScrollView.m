//
//  MasterScrollView.m
//  Volley
//
//  Created by benjaminhallock@gmail.com on 1/28/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "MasterScrollView.h"
#import "CustomCameraView.h"
#import "CustomChatView.h"
#import "ChatView.h"
#import "AppDelegate.h"
#import "pushnotification.h"
#import "utilities.h"
#import "messages.h"
#import "AppConstant.h"
#import "MomentsVC.h"
#import "FullWidthChat.h"
#import "MainInboxVC.h"

@implementation MasterScrollView
{
    CGFloat lastContentOffset;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.delegate = self;
        self.bounces = NO;
        self.scrollEnabled = YES;
        self.pagingEnabled = YES;
        self.directionalLockEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.didJustFinishSendingVollie = NO;
    }
    return self;
}

- (void)openView:(UIViewController *)view2
{
    NavigationController *_navInbox = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navInbox];

//    if ([_navInbox.viewControllers.lastObject isKindOfClass:[CustomChatView class]])
//    {
//        CustomChatView *chat = _navInbox.viewControllers.lastObject;
//        ChatView *chat2 = [_navInbox.viewControllers objectAtIndex:_navInbox.viewControllers.count - 2];
//        NSLog(@"%@",_navInbox.viewControllers);
//        if (chat2.room_ == chat.room)
//        {
//            //Your in the same chatroom
//            [_navInbox popViewControllerAnimated:1];
//            [_navInbox popViewControllerAnimated:1];
//            [_navInbox pushViewController:view2 animated:YES];
//            //Already done on viewdiddissapaer
////            PostNotification(NOTIFICATION_REFRESH_CHATROOM);
//            return;
//        }
//        else
//        {
//            //Your in a completely different chatroom.
//            [_navInbox popToRootViewControllerAnimated:0];
//        }
//    }
//    else if ([_navInbox.viewControllers.lastObject isKindOfClass:[ChatView class]])
//    {
//        //Your in a different chat.
//        [_navInbox popViewControllerAnimated:0];
//    }
//    else
//    {
//        //New Conversation Perhaps.
//        [_navInbox popToRootViewControllerAnimated:0];
//    }

    /// IF CUSTOM CHAT ROOM IS SAME AS ROOM BEFORE, POP THE STACK ONCE.
    [_navInbox popToRootViewControllerAnimated:NO];
    [_navInbox pushViewController:view2 animated:0];
    [self setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0) animated:0];

}


- (BOOL) checkIfCurrentChatIsEqualToRoom:(NSString *)roomId didComeFromBackground:(BOOL)isBack
{
    NavigationController *nav = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navInbox];
    NavigationController *flashbacks = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navFavorites];\
    
    
    if([nav.visibleViewController isKindOfClass:[CustomCameraView class]])
    {
        NSLog(@"i'm a camera");
        return YES;
    }
    
    if (nav.presentedViewController)
    {
        return NO;
    }
    
    if ([nav.viewControllers.lastObject isKindOfClass:[ChatView class]])
    {
        ChatView *chatView = nav.viewControllers.lastObject;
        if ([chatView.room_.objectId isEqualToString: roomId])
        {
            [chatView refresh];
            return YES;
        }
        else
        {
            //POP CURRENT ROOM IF NOT PUSH ROOM.//ACTUALLY NO, ONLY IF COMING FROM BACKGROUND.
            if (isBack)
            {
                [nav popToRootViewControllerAnimated:0];
            }
        }
    }
    
    if ([nav.viewControllers.lastObject isKindOfClass:[CustomChatView class]])
    {
        NSInteger target=nav.viewControllers.count - 2;
        if ([nav.viewControllers[target] isKindOfClass:[MomentsVC class]])
        {
            {
                MomentsVC *vc = nav.viewControllers[target];
                if ([vc.room.objectId isEqualToString:roomId])
                {
                    NSLog(@"User is currently looking at this chat");
                    return YES;
                }
            }
        }
        if ([nav.viewControllers[target] isKindOfClass:[MainInboxVC class]])
        {
            MomentsVC *vc = nav.viewControllers[target+1];
            if ([vc.room.objectId isEqualToString:roomId])
            {
                NSLog(@"User is currently looking at this chat");
                return YES;
            }
        }
        

        
//        ChatView *chatView = nav.viewControllers[target];
//        if ([chatView.room_.objectId isEqualToString: roomId])
//        {
//            [chatView refresh];
//            return YES;
//        }
    }
    
    
    if ([nav.viewControllers.lastObject isKindOfClass:[CustomCameraView class]])
    {
//        NSInteger target=nav.viewControllers.count - 2;
//        MomentsVC *chatView = nav.viewControllers[target];
//        if ([chatView.room.objectId isEqualToString:roomId])
//        {
//            NSLog(@"User is currently looking at this chat");
            return YES;
//        }
        //        ChatView *chatView = nav.viewControllers[target];
        //        if ([chatView.room_.objectId isEqualToString: roomId])
        //        {
        //            [chatView refresh];
        //            return YES;
        //        }
    }
    
    if ([nav.viewControllers.lastObject isKindOfClass:[FullWidthChat class]])
    {
        NSInteger target=nav.viewControllers.count - 2;
        MomentsVC *chatView = nav.viewControllers[target];
        if ([chatView.room.objectId isEqualToString:roomId])
        {
            NSLog(@"User is currently looking at this chat");
            return YES;
        }
        //        ChatView *chatView = nav.viewControllers[target];
        //        if ([chatView.room_.objectId isEqualToString: roomId])
        //        {
        //            [chatView refresh];
        //            return YES;
        //        }
    }
    
    if ([flashbacks.viewControllers.lastObject isKindOfClass:[CustomChatView class]])
    {
        CustomChatView *chatView = flashbacks.viewControllers.lastObject;
        if ([chatView.room.objectId isEqualToString:roomId])
        {
            return YES;
        }
    }

    return NO;
}

/*
 - (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
 {
 [self gestureRecognizer:self.gestureRecognizers.firstObject shouldRecognizeSimultaneouslyWithGestureRecognizer:self.gestureRecognizers.lastObject];

 lastContentOffset = scrollView.contentOffset.x;
 }

 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

 if (lastContentOffset < (int)scrollView.contentOffset.x) {
 // moved right
 }
 else if (lastContentOffset > (int)scrollView.contentOffset.x) {
 // moved left
 }
 }
 */


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //IF DRAGGING IS UP, LOCK IT BACK DOWN TO NO.

    if (gestureRecognizer.state != 0 && otherGestureRecognizer.state != 1)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    lastContentOffset = scrollView.contentOffset.x;
    if (lastContentOffset < self.bounds.size.width - 1)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:1 withAnimation:UIStatusBarAnimationSlide];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:0 withAnimation:UIStatusBarAnimationSlide];
        if (self.didJustFinishSendingVollie)
        {
            NSLog(@"was just programatically sent to inbox");
        }
    }
}


@end
