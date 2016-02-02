

#import <Parse/Parse.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
void		ParsePushUserAssign		(void);
void		ParsePushUserResign		(void);

//-------------------------------------------------------------------------------------------------------------------------------------------------
void		SendPushNotification	(PFObject *room, NSString *text);
void        SendPushNotificationWithChat    (PFObject *chat, PFObject *room, NSString *text);
