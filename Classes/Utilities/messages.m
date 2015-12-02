
#import <Parse/Parse.h>

#import "AppConstant.h"

#import "messages.h"

#import "utilities.h"

NSString* CreateMessageItem(PFObject *room, NSArray *arrayOfUsers)
{

    //This entire thing pretty much is a chat room. Not a message. We definitely need to change names.
    NSString *returnString = [NSString new];

    for (PFUser *user in arrayOfUsers)
    { // WHOLE METHOD

        NSMutableArray *copyOfUsers = [NSMutableArray arrayWithArray:arrayOfUsers];
        NSString *string = [NSString new];
        [copyOfUsers removeObject:user];
 
        int x = 0;
        for (PFUser *user in copyOfUsers)
        {
            NSString *name = [user valueForKey:PF_USER_FULLNAME];
//            NSString *phoneNumber = [user valueForKey:PF_USER_USERNAME];

             NSMutableArray *array = [NSMutableArray arrayWithArray:[name componentsSeparatedByString:@" "]];
//             [array removeObject:@" "];
             NSString *first = array.firstObject;
//             first = [first stringByPaddingToLength:1 withString:name startingAtIndex:0];
//             last = [last stringByPaddingToLength:1 withString:nam startingAtIndex:0];
//             nam = [first stringByAppendingString:last];

            
            
            
            if (name.length && name)
            {
                string = [string stringByAppendingString:[NSString stringWithFormat:@"%@, ", first]];
            } else {
                x++;
            }
        }

        while (x > 0) {
            string = [@"*" stringByAppendingString:string];
            x--;
        }

        if (string.length > 2) {
            string = [string substringToIndex:string.length - 2];
    } else {
        string = @"****"; // Your names weren't long enough for some reason, perhaps if you invited a bunch of people who don't use the app
    }

        if ([user isEqual:[PFUser currentUser]])
        {
            returnString = string;
        }

	PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
	[query whereKey:PF_MESSAGES_USER equalTo:user];
	[query whereKey:PF_MESSAGES_ROOM equalTo:room];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			if ([objects count] == 0)
			{
				PFObject *message = [PFObject objectWithClassName:PF_MESSAGES_CLASS_NAME];
				message[PF_MESSAGES_USER] = user;
                message[PF_MESSAGES_ROOM] = room;
				message[PF_MESSAGES_DESCRIPTION] = string;
                message[PF_MESSAGES_HIDE_UNTIL_NEXT] = @NO;
				message[PF_MESSAGES_LASTUSER] = [PFUser currentUser];
                message[PF_MESSAGES_USER_DONOTDISTURB] = user;
				message[PF_MESSAGES_LASTMESSAGE] = @"";
				message[PF_MESSAGES_UPDATEDACTION] = [NSDate date];
				[message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
				{
                    if (error)
                    {
                        
                    }
                }];
			}
		}
	}];
    }// END FOR LOOP
    return returnString;
}

void HideMessageItem(PFObject *message)
{
    [message setValue:@YES forKey:PF_MESSAGES_HIDE_UNTIL_NEXT];
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (!error)
        {
            
        }
	}];
}


void UpdateMessageCounter(PFObject *room, NSString *lastMessage, PFObject *pictureAttached)
{
	PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
	[query whereKey:PF_MESSAGES_ROOM equalTo:room];
	[query setLimit:1000];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			for (PFObject *message in objects)
			{
                __block BOOL isCurrentUser = NO;
				PFUser *user = message[PF_MESSAGES_USER];
                if ([user.objectId isEqualToString:[PFUser currentUser].objectId] == NO) {
                    [message incrementKey:PF_MESSAGES_COUNTER byAmount:@1];
                    isCurrentUser = YES;
                }
				message[PF_MESSAGES_LASTUSER] = [PFUser currentUser];

                if (lastMessage.length)
                {
				message[PF_MESSAGES_LASTMESSAGE] = lastMessage;
                }

                [message setValue:@NO forKey:PF_MESSAGES_HIDE_UNTIL_NEXT];

                
                if (pictureAttached)
                {
                    message[PF_MESSAGES_LASTPICTURE] = pictureAttached;
                    message[PF_MESSAGES_LASTPICTUREUSER] = [PFUser currentUser];
                }
				message[PF_MESSAGES_UPDATEDACTION] = [NSDate date];

				[message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
				{
                    if (error)
                    {
                    }
                    else
                    {
                        if (isCurrentUser) PostNotification(NOTIFICATION_REFRESH_INBOX);
                    }
				}];
			}
		}

	}];
}


void ClearMessageCounter(PFObject *message)
{
    message[PF_MESSAGES_COUNTER] = @0;
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (!error)
        {
            //Need to clear orange dot in inbox.
            PostNotification(NOTIFICATION_RELOAD_INBOX);
        }
        else
        {
        }
    }];
}
