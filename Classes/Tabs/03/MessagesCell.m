
#import <Parse/Parse.h>

#import <ParseUI/ParseUI.h>

#import "AppConstant.h"

#import "utilities.h"

#import "UIColor+JSQMessages.h"

#import "MessagesCell.h"


@interface MessagesCell ()
{
	PFObject *message;
}
@end

@implementation MessagesCell

@synthesize imageUser;
@synthesize labelDescription, labelLastMessage, labelInitials;
@synthesize labelElapsed;
@synthesize imageNew;

-(void) format
{
        self.labelNumberOfPeople.text = @"";
        imageUser.layer.cornerRadius = 10;
        imageUser.layer.masksToBounds = YES;
        labelInitials.layer.borderWidth = 1;
    
   //  self.selectionStyle = UITableViewCellSelectionStyleNone;

   //    self.imageUser.image = [UIImage imageNamed:@"Blank V"];

        self.contactsPeople.image = [[UIImage imageNamed:@"contacts icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        UIColor *lightGray = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:0.8f];

        self.contactsPeople.tintColor = lightGray;
        self.labelNumberOfPeople.textColor = lightGray;
        labelInitials.layer.borderColor = [UIColor whiteColor].CGColor;
        labelInitials.layer.cornerRadius = labelInitials.frame.size.height/2.7;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        imageUser.contentMode = UIViewContentModeScaleAspectFill;
        imageNew.image = [UIImage imageNamed:ASSETS_READ];
}


- (void)bindData:(PFObject *)message_
{
	message = message_;

    PFObject *room = message[PF_MESSAGES_ROOM];


    if (message[PF_MESSAGES_NICKNAME]) {
        labelDescription.text = message[PF_MESSAGES_NICKNAME];
    } else {
        NSString *description = message[PF_MESSAGES_DESCRIPTION];
        if (description.length) {
            labelDescription.text = description;
        }
    }

    NSArray *array = [room valueForKey:PF_CHATROOMS_USEROBJECTS];
    self.labelNumberOfPeople.text = [NSString stringWithFormat:@"%lu", (array.count - 1)];

/*
    PFRelation *users = [room objectForKey:PF_CHATROOMS_USERS];
    PFQuery *query = users.query;
#warning QUERY IS RUNNING EVERY TIME YOU SCROLL AND REFRESH
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSString *titleOfUsers;

            for (PFUser *user in objects)
            {
                if ([user valueForKey:PF_USER_ISVERIFIED])
                {
            NSString *name = user[PF_USER_FULLNAME];
            titleOfUsers = [titleOfUsers stringByAppendingString:[NSString stringWithFormat:@"%@, ", name]];
            titleOfUsers = [titleOfUsers substringToIndex:[titleOfUsers length] - 2];
                }
                else
                {
                    titleOfUsers = [@"*" stringByAppendingString:titleOfUsers];
                }
            }
            self.labelDescription.text = titleOfUsers;
    }
    }];
*/
	labelLastMessage.text = message[PF_MESSAGES_LASTMESSAGE];
    labelDescription.textColor = [UIColor volleyLabelGrey];
    labelInitials.backgroundColor = self.tableBackgroundColor;

    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:message.updatedAt];
	labelElapsed.text = TimeElapsed(seconds);
	int counter = [message[PF_MESSAGES_COUNTER] intValue];
    if (counter > 0) {
        imageNew.image = [UIImage imageNamed:ASSETS_UNREAD];
    } else {
        imageNew.image = [UIImage imageNamed:ASSETS_READ];
    }
}

- (NSString *)setNameWithObjects:(NSArray *)objects
{
    if (objects.count > 0) {
    NSString *titleOfUsers = [NSString stringWithFormat:@""];

    for (PFUser *user in objects) {
    [user fetchIfNeededInBackground];
    NSString *name = user[PF_USER_FULLNAME];
    titleOfUsers = [titleOfUsers stringByAppendingString:[NSString stringWithFormat:@"%@, ", name]];
    }

    titleOfUsers = [titleOfUsers substringToIndex:[titleOfUsers length] - 2];
    [UIView animateWithDuration:1.0 animations:^{
        labelDescription.text = titleOfUsers;
        labelDescription.textColor = self.tableBackgroundColor;
    }];
    return titleOfUsers;
    } else {
        return @"";
    }
}

@end
