//
//  RoomObject.h
//  Volley
//
//  Created by Kyle Bendelow on 8/4/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Parse/Parse.h>

@interface Chat : PFObject

/*
 #define		PF_MESSAGES_CLASS_NAME				@"Messages"				//	Class name
 #define		PF_MESSAGES_HIDE_UNTIL_NEXT			@"shouldHideUntilNext"	//	Class name
 #define		PF_MESSAGES_USER					@"user"					//	Pointer to User
 #define		PF_MESSAGES_USER_DONOTDISTURB		@"userPush"					//	Pointer to
 #define		PF_MESSAGES_ROOM					@"room"				   //	Pointer to Room
 #define		PF_MESSAGES_DESCRIPTION				@"description"			//	String
 #define		PF_MESSAGES_LASTUSER				@"lastUser"				//	Pointer lastuser
 #define		PF_MESSAGES_LASTMESSAGE				@"lastMessage"			//	String
 #define		PF_MESSAGES_LASTPICTURE				@"lastPicture"			//	Chat pointer
 #define		PF_MESSAGES_LASTPICTUREUSER			@"lastPictureUser"	//	PFuser
 #define		PF_MESSAGES_COUNTER					@"counter"				//	Number
 #define		PF_MESSAGES_UPDATEDACTION			@"updatedAction"		//	Date
 #define		PF_MESSAGES_NICKNAME                @"nickname"             //	Date
 */

@property PFObject *roomNumber;
@property NSString *description;
@property NSString *lastMessage;
@property PFObject *lastPicture;
//@property PFObject *


-(NSArray *)getParseInformation;

@end
