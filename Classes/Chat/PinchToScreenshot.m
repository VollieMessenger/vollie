//
//  PinchToScreenshot.m
//  Volley
//
//  Created by benjaminhallock@gmail.com on 2/26/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "PinchToScreenshot.h"

#import <AssetsLibrary/AssetsLibrary.h> // Save photo screenshot to custom album.

#import <Photos/PHPhotoLibrary.h>


//@implementation PinchToScreenshot
//{
//    UIView *view;
//
//    CGPoint pinchStartPoint;
//
//    CGPoint pinchEndPoint;
//
//    ALAssetsLibrary *assetLibrary;
//
//}
//
//#pragma mark = ASSETS LIBRARY NIGHTMARE
//
// - (void) setup
//{
//    [self addGesture];
//}
//
//
//- (void) didPinch:(UIPinchGestureRecognizer *)pinch
//{
//
//    if (pinch.state == UIGestureRecognizerStateBegan) {
//        view  = [[UIView alloc] init];
//        view.layer.masksToBounds = 1;
//        view.layer.cornerRadius = 10;
//        view.layer.borderWidth = 5;
//        view.layer.borderColor = [UIColor whiteColor].CGColor;
//        [self.view addSubview:view];
//    }
//
//    if (pinch.state == UIGestureRecognizerStateEnded) {
//
//        [UIView animateWithDuration:.3 animations:^{
//            view.alpha = 1;
//            view.alpha = 0;
//        } completion:^(BOOL finished) {
//
//            if (abs(pinchStartPoint.y - pinchEndPoint.y) < 100) {
//
//            } else {
//                [self TakeScreenshotAndShare:pinchStartPoint andEnd:pinchEndPoint];
//            }
//
//            [view removeFromSuperview];
//        }];
//
//
//    } else {
//
//        if (pinch.numberOfTouches > 1) {
//            pinchEndPoint = [pinch locationOfTouch:1 inView:self.view];
//            pinchStartPoint = [pinch locationOfTouch:0 inView:self.view];
//        }
//        view.backgroundColor = [UIColor redColor];
//        view.alpha = .3
//        ;
//        view.frame = CGRectMake(0, pinchEndPoint.y, self.view.frame.size.width, pinchStartPoint.y - pinchEndPoint.y);
//    }
//}
//
//- (void) addGesture
//{
//        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinch:)];
//        pinch.delegate = self;
//        [self.view addGestureRecognizer:pinch];
//}
//
////Save screenshot to library.
//- (void) saveImageToLibarary:(UIImage *)image
//{
//    assetLibrary = [[ALAssetsLibrary alloc] init];
//
//    NSString *albumName = @"Volley";
//
//    __block ALAssetsGroup* groupToAddTo;
//
//    //FIND THE FOLDER, IF NOT, CREATE FOLDER, FIND IT AGAIN, SAVE IMAGE.
//    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
//                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//                                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
//                                        groupToAddTo = group;
//                                        [self savePhotoToAlbum:groupToAddTo withImage:image andAlbumName:albumName];
//                                    }
//
//                                    if (stop && group == nil && groupToAddTo == nil)
//                                    {;
//                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Developer Error" message:@"Please create an Album Called 'Volley', some reason I can't do it for you, this is because the user manually deleted the album folder." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:0, nil];
//
//                                        __block __weak PinchToScreenshot *pinch = self;
//
//                                        [assetLibrary addAssetsGroupAlbumWithName:albumName
//                                                                      resultBlock:^(ALAssetsGroup *group) {
//                                                                          groupToAddTo = group;
//                                                                          if (!group) {
//                                                                              [alert show];
//                                                                          } else {
//
//                                                                        [pinch savePhotoToAlbum:groupToAddTo     withImage:image                 andAlbumName:albumName];
//                                                                          }
//                                                                      }
//                                                                     failureBlock:^(NSError *error) {
//                                                                     }];
//                                    }
//                                }
//                              failureBlock:^(NSError* error) {
//                              }];
//}
//
//- (void) savePhotoToAlbum:(ALAssetsGroup *)groupToAddTo withImage:(UIImage *)image andAlbumName:(NSString *)albumName
//{
//    CGImageRef img = [image CGImage];
//    [assetLibrary writeImageToSavedPhotosAlbum:img
//                                      metadata:0
//                               completionBlock:^(NSURL* assetURL, NSError* error) {
//                                   if (error.code == 0) {
//                                       // try to get the asset
//                                       [assetLibrary assetForURL:assetURL
//                                                     resultBlock:^(ALAsset *asset) {
//                                                         // assign the photo to the album
//                                                         [groupToAddTo addAsset:asset];
//                                                     }
//                                                    failureBlock:^(NSError* error) {
//                                                    }];
//                                   }
//                                   else {
//                                   }
//                               }];
//}
//
//
//- (void)TakeScreenshotAndShare:(CGPoint)start andEnd:(CGPoint )end
//{
//    //Save photo to custom Album
//
//    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
//    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//
//    //crop to parameters of pinch
//    CGRect crop = CGRectMake(0, MIN(pinchEndPoint.y, pinchStartPoint.y) * image.scale - 10, self.view.frame.size.width * image.scale, (abs(pinchStartPoint.y - pinchEndPoint.y) * image.scale) + 20);
//    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], crop);
//    image = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:UIImageOrientationUp];
//    CGImageRelease(imageRef);
//
//    //Add Icon to Image
//    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
//    UIImage *bannerImage = [UIImage imageNamed:@"Icon-Small"];
//    [image drawInRect:CGRectMake(0,0, image.size.width, image.size.height)];
//    [bannerImage drawInRect:CGRectMake(image.size.width - bannerImage.size.width - 3, image.size.height - bannerImage.size.height - 3, bannerImage.size.width, bannerImage.size.height)];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    //Use imageView to round corners and border, then take screenshot.
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    imageView.frame = CGRectMake(0, 0, image.size.width * image.scale, image.size.height * image.scale);
//    imageView.backgroundColor = [UIColor redColor];
//    imageView.layer.cornerRadius = 10 * image.scale;
//    //    imageView.layer.masksToBounds = 1;
//    imageView.layer.borderWidth = 5 * image.scale;
//    imageView.layer.backgroundColor = [UIColor clearColor].CGColor;
//
//    imageView.layer.borderColor = [UIColor blackColor].CGColor;
//    imageView.image = image;
//    UIGraphicsBeginImageContext(imageView.frame.size);
//    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//
//    NSData *data = UIImagePNGRepresentation(image);
//    image = [UIImage imageWithData:data];
//    //    [data writeToFile:@"foo.png" atomically:NO];
//    [self saveImageToLibarary:image];
//
//
//    NSArray *activityItems = [NSArray arrayWithObjects:@"(Sent Via Volley)",[UIImage imageWithData:data], nil];
//    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//    [self presentViewController:activityController animated:YES completion:nil];
//}
//
//@end
