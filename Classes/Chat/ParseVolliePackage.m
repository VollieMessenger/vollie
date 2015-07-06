//
//  StreetLegal.m
//  Volley
//
//  Created by Kyle on 7/6/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "ParseVolliePackage.h"
#import "AppConstant.h"
#import "AppDelegate.h"
#import "utilities.h"
#import "pushnotification.h"

@implementation ParseVolliePackage

-(void)logSomething
{
    NSLog(@"LOGGIN LIKE A BEAVER");
}

-(void)logSomethingWithAnArray:(NSMutableArray*)array
{
    for (NSString *string in array)
    {
//        NSLog(string);
    }
}

-(void)sendPhotosWithPhotosArray:(NSMutableArray*)photosArray andText:(NSString*)text andRoom:(PFObject *)roomNumber andSet:(PFObject*)setID
{
    self.savedImageFiles = [NSMutableArray new];
    self.savedPhotoObjects = [NSMutableArray new];
    self.countDownForLastPhoto = (int)photosArray.count;

    for (id imageOrFile in photosArray)
    {
        if ([imageOrFile isKindOfClass:[UIImage class]])
        {
            UIImage *image = imageOrFile;
            PFFile *imageFile = [PFFile fileWithName:@"image.png"
                                                data:UIImageJPEGRepresentation(image, .5)];
            PFObject *picture = [self basicParseObjectSetupWith:imageOrFile
                                                            and:image
                                                       andArray:photosArray
                                                         andSet:setID
                                                        andRoom:roomNumber];
            [picture setObject:imageFile forKey:PF_PICTURES_PICTURE];

            NSLog(@"%@", picture);

            [self.savedPhotoObjects addObject:picture];
            [self.savedImageFiles addObject:imageFile];
            [self saveParseObjectInBackgroundWith:picture andText:text andRoom:roomNumber andSet:setID];
        }
        else if ([imageOrFile isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic = imageOrFile;
            NSString *path = dic.allKeys.firstObject;
            UIImage *image = dic.allValues.firstObject;
            PFFile *videoFile = [PFFile fileWithName:@"video.mov" contentsAtPath:path];
            PFObject *video = [self basicParseObjectSetupWith:imageOrFile
                                                          and:image
                                                     andArray:photosArray
                                                       andSet:setID
                                                      andRoom:roomNumber];
            [video setValue:@YES forKey:PF_PICTURES_IS_VIDEO];

            [video setValue:[NSDate dateWithTimeIntervalSinceNow:[photosArray indexOfObject:dic]]forKey:PF_PICTURES_UPDATEDACTION];

            [self.savedPhotoObjects addObject:video];
            [self.savedImageFiles addObject:videoFile];
            [self saveParseObjectInBackgroundWith:video andText:text andRoom:roomNumber andSet:setID];
        }
    }
}

-(PFObject*)basicParseObjectSetupWith:(id)imageOrFile and:(UIImage *)image andArray:(NSMutableArray*)photosArray andSet:(PFObject*)setID andRoom:(PFObject*)room
{
    PFObject *object = [PFObject objectWithClassName:PF_PICTURES_CLASS_NAME];
    [object setValue:[PFUser currentUser] forKey:PF_PICTURES_USER];
    [object setValue:@YES forKey:PF_CHAT_ISUPLOADED];
    [object setValue:[NSDate dateWithTimeIntervalSinceNow:[photosArray indexOfObject:object]]forKey:PF_PICTURES_UPDATEDACTION];
    [object setValue:setID forKey:PF_PICTURES_SETID];
    [object setValue:room forKey:PF_PICTURES_CHATROOM];
    UIImage *thumbnail = ResizeImage(image, image.size.width, image.size.height);
    PFFile *file = [PFFile fileWithName:@"thumbnail.png" data:UIImageJPEGRepresentation(thumbnail, .2)];
    [object setValue:[NSDate dateWithTimeIntervalSinceNow:[photosArray indexOfObject:image]]forKey:PF_PICTURES_UPDATEDACTION];
    [object setObject:file forKey:PF_PICTURES_THUMBNAIL];

    return object;
}

-(void)saveParseObjectInBackgroundWith:(PFObject*)object andText:(NSString*)text andRoom:(PFObject *)roomNumber andSet:(PFObject*)setID
{
    //    NSLog(@"I'M SAVING THIS: %@", object);
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            NSLog(@"saved a pic or video");
            self.countDownForLastPhoto --;
            if(self.countDownForLastPhoto == 0)
            {
//                [self.selectedSet setValue:object forKey:@"lastPicture"];
//                [self.selectedSet saveInBackground];
//                [self.selectedRoom setValue:object forKey:@"lastPicture"];
//                [self.selectedRoom saveInBackground];
                SendPushNotification(roomNumber, @"New Picture!");
//                UpdateMessageCounter(roomNumber, @"New Picture!", lastPicture);
                [self checkForTextAndSendItWithText:text andRoom:roomNumber andSet:setID];
            }
        }
    }];
}

-(void)checkForTextAndSendItWithText:(NSString*)text andRoom:(PFObject *)roomNumber andSet:(PFObject*)setID

{
    if (![text isEqualToString:@""] && ![text isEqualToString:@"Type Message Here..."])
    {
        PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
        object[PF_CHAT_USER] = [PFUser currentUser];
        object[PF_CHAT_ROOM] = roomNumber;
        object[PF_CHAT_TEXT] = text;
        object[PF_CHAT_SETID] = setID;
        roomNumber[@"lastMessage"] = text;

        [object setValue:[NSDate date] forKey:PF_PICTURES_UPDATEDACTION];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error)
            {
                NSLog(@"saved yo text boy");
//                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
            }
        }];
    }
    else
    {
//        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
        //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OPEN_CHAT_VIEW object:chatView userInfo:@{@"view": chatView}];
        NSLog(@"didn't save anything");
    }
}


@end
