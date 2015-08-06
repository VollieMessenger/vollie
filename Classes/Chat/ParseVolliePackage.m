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
#import "ProgressHUD.h"
#import "messages.h"

@implementation ParseVolliePackage

@synthesize refreshDelegate;


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

//            NSLog(@"%@", picture);

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
            [video setObject:videoFile forKey:PF_PICTURES_PICTURE];

            [video setValue:[NSDate dateWithTimeIntervalSinceNow:[photosArray indexOfObject:dic]]forKey:PF_PICTURES_UPDATEDACTION];

            [self.savedPhotoObjects addObject:video];
            [self.savedImageFiles addObject:videoFile];
            [self saveParseObjectInBackgroundWith:video andText:text andRoom:roomNumber andSet:setID];
        }
    }
}

-(PFObject*)basicParseObjectSetupWith:(id)imageOrFile and:(UIImage *)image andArray:(NSMutableArray*)photosArray andSet:(PFObject*)setID andRoom:(PFObject*)room
{
    UIImage *thumbnail = ResizeImage(image, image.size.width, image.size.height);
    PFFile *file = [PFFile fileWithName:@"thumbnail.png" data:UIImageJPEGRepresentation(thumbnail, .2)];
    //we could make a second "bigger" thumbnail in case it's the main photo
    PFObject *object = [PFObject objectWithClassName:PF_PICTURES_CLASS_NAME];
    [object setValue:[PFUser currentUser] forKey:PF_PICTURES_USER];
    [object setValue:@YES forKey:PF_CHAT_ISUPLOADED];
    [object setValue:[NSDate dateWithTimeIntervalSinceNow:[photosArray indexOfObject:object]]
              forKey:PF_PICTURES_UPDATEDACTION];
    [object setValue:setID
              forKey:PF_PICTURES_SETID];
    [object setValue:room
              forKey:PF_PICTURES_CHATROOM];
    [object setValue:[NSDate dateWithTimeIntervalSinceNow:[photosArray indexOfObject:image]]
              forKey:PF_PICTURES_UPDATEDACTION];
    [object setObject:file
               forKey:PF_PICTURES_THUMBNAIL];
    
    return object;
}

-(void)saveParseObjectInBackgroundWith:(PFObject*)object andText:(NSString*)text andRoom:(PFObject *)roomNumber andSet:(PFObject*)setID
{
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            NSLog(@"began uploading a pic or video");
            self.countDownForLastPhoto --;
            if(self.countDownForLastPhoto == 0)
            {
                [setID setValue:object forKey:@"lastPicture"];
                [setID saveInBackground];

                [roomNumber setValue:object forKey:@"lastPicture"];
                [roomNumber saveInBackground];

                self.lastPicFromPackage = object;

                if(![text isEqualToString:@""] && ![text isEqualToString:@"Type Message Here..."])
                {
                    [self checkForTextAndSendItWithText:text andRoom:roomNumber andSet:setID];
                }
                else
                {
                    [self showSuccessNotificationWithString:@"New Picture!"
                                                  andObject:object
                                              andRoomNumber:roomNumber];


                }
            }
            else
            {
//                NSLog(@"%i more pics to send", self.countDownForLastPhoto);
            }
        }
        else
        {
            [self showErrorNotification];
        }
    }];
}

-(void)checkForTextAndSendItWithText:(NSString*)text andRoom:(PFObject *)roomNumber andSet:(PFObject*)setID

{
//    NSLog(@"yo i'm checking text");
//    if (![text isEqualToString:@""] && ![text isEqualToString:@"Type Message Here..."])
//    {
        PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
        object[PF_CHAT_USER] = [PFUser currentUser];
        object[PF_CHAT_ROOM] = roomNumber;
        object[PF_CHAT_TEXT] = text;
        object[PF_CHAT_SETID] = setID;
        roomNumber[@"lastMessage"] = text;

        [object setValue:[NSDate date] forKey:PF_PICTURES_UPDATEDACTION];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if(!error)
            {
                [self showSuccessNotificationWithString:text
                                              andObject:object
                                          andRoomNumber:roomNumber];
            }
            else
            {
                [self showErrorNotification];
            }
        }];
}

-(void)hideProgressHUD
{
    [ProgressHUD dismiss];
}

-(void)showErrorNotification
{
    [ProgressHUD showError:@"Failed to Send!"];
    [self performSelector:@selector(hideProgressHUD) withObject:nil afterDelay:1.0];
}

-(void)showSuccessNotificationWithString:(NSString *)string andObject:(PFObject*)object andRoomNumber:(PFObject*)roomNumber
{
    SendPushNotification(roomNumber, string);
    if (self.lastPicFromPackage)
    {
        UpdateMessageCounter(roomNumber, string, self.lastPicFromPackage);
    }
    else
    {
        UpdateMessageCounter(roomNumber, string, object);
    }
    [ProgressHUD showSuccess:@"Sent Vollie!"];
    [self.refreshDelegate reloadAfterMessageSuccessfullySent];
    [self performSelector:@selector(hideProgressHUD) withObject:nil afterDelay:1.0];
}

@end
