//
//  IndentFixContainer.m
//  Volley
//
//  Created by Kyle Bendelow on 10/17/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "IndentFixContainer.h"
#import "CustomChatView.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface IndentFixContainer ()
@property (weak, nonatomic) IBOutlet UIView *viewForCustomChat;

@end

@implementation IndentFixContainer

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:self.chatViewVC];
    [self.viewForCustomChat addSubview:self.chatViewVC.view];
    [self.chatViewVC didMoveToParentViewController:self];
}

@end
