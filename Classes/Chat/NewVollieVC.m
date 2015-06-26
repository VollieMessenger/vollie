//
//  NewVollieVC.m
//  Volley
//
//  Created by Kyle on 6/19/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "NewVollieVC.h"
#import "AppDelegate.h"
#import "CustomCameraView.h"
#import "NewVolliePicCell.h"
#import "AppConstant.h"
#import <Parse/Parse.h>
#import "SelectChatroomView.h"
#import "SelectRoomVC.h"


@interface NewVollieVC ()
<UITextViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
SecondDelegate>

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property CustomCameraView *cameraView;

@end

@implementation NewVollieVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self basicSetUpAndInit];
    [self checkForPreviousVC];
//    self.cameraView = [[CustomCameraView alloc] initWithPopUp:NO];

}

-(void)basicSetUpAndInit
{
    self.textView.delegate = self;
    [self.textView becomeFirstResponder];
    [self.textView setReturnKeyType:UIReturnKeySend];
    self.collectionView.backgroundColor = [UIColor clearColor];
}

-(void)checkForPreviousVC
{
    if (self.textFromLastVC)
    {
        self.textView.text = self.textFromLastVC;
    }
    if ([self.textView.text isEqualToString:@"Type Message Here..."])
    {
        [self.textView setTextColor:[UIColor lightGrayColor]];
    }
    if (self.photosArray.count)
    {

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onDismissButtonTapped:(id)sender
{
//    [self dismissViewControllerAnimated:YES completion:nil];
//    CustomCameraView *camera = [[CustomCameraView alloc] initWithPopUp:NO];
//    camera.comingFromNewVollie = true;
//    camera.textFromLastVC = self.textView.text;
//    [self.navigationController pushViewController:camera animated:YES];
}

#pragma mark "TextView Stuff"

-(void) textViewDidChange:(UITextView *)textView
{
    if(![self.textView.text isEqualToString:@"Type Message Here..."])
    {
        self.textView.textColor = [UIColor blackColor];
        [self removePlaceHolderText];
    }
    else
    {
        self.textView.textColor = [UIColor lightGrayColor];
    }
}

-(void)removePlaceHolderText
{
    //this is for the random edgecases where a user might try to edit the placeholder text
    self.textView.text = [self returnStringButGetRidOf:@"Type Message Here..." fromTheString:self.textView.text];
    self.textView.text = [self returnStringButGetRidOf:@"Type " fromTheString:self.textView.text];
    self.textView.text = [self returnStringButGetRidOf:@"Message " fromTheString:self.textView.text];
    self.textView.text = [self returnStringButGetRidOf:@"Here.." fromTheString:self.textView.text];
}

-(NSString *)returnStringButGetRidOf:(NSString *)word fromTheString:(NSString *)string
{
    NSString *tempString = [string stringByReplacingOccurrencesOfString:word withString:@""];
    return tempString;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    //this code makes "done" or "return" button resign first responder
    if ([text isEqualToString:@"\n"])
    {


        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        SelectRoomVC *selectRoomVC = (SelectRoomVC *)[storyboard instantiateViewControllerWithIdentifier:@"SelectRoomVC"];
        [self.navigationController pushViewController:selectRoomVC animated:YES];
        
////        [textView resignFirstResponder];
////        return NO;
//        SelectChatroomView *selectView = [SelectChatroomView new];
////        self.delegate = selectView;
//        [[UIApplication sharedApplication] setStatusBarHidden:0];
////        [delegate sendBackPictures:_arrayOfTakenPhotos withBool:YES andComment:@""];
//        [self.navigationController pushViewController:selectView animated:0];
    }
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self.textView resignFirstResponder];
    if(self.textView.text.length == 0)
    {
        self.textView.textColor = [UIColor lightGrayColor];
        self.textView.text = @"Type Message Here...";
//        [self.textView resignFirstResponder];
    }
}

- (void)secondViewControllerDismissed:(NSString *)stringForFirst
{
    NSString *thisIsTheDesiredString = stringForFirst; //And there you have it.....
    NSLog(thisIsTheDesiredString);
}

#pragma mark "CollectionView Stuff"

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NewVolliePicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.layer.cornerRadius = 10;
    cell.imageView.layer.masksToBounds = YES;
    if(self.photosArray.count > 0 && indexPath.item < self.photosArray.count)
    {
        cell.imageView.image = self.photosArray[indexPath.item];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"Vollie-icon"];
    }
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.photosArray.count > 0 && self.photosArray.count < 5)
    {
        return self.photosArray.count + 1;
    }
    else if (self.photosArray.count == 5)
    {
        return 5;
    }
    else
    {
        return 2;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    CustomCameraView *camera = [[CustomCameraView alloc] initWithPopUp:NO];
//    self.cameraView.comingFromNewVollie = true;
//    self.cameraView.textFromLastVC = self.textView.text;
//    self.cameraView.photosFromNewVC = self.photosArray;
//    [self.navigationController pushViewController:self.cameraView animated:YES];

    NavigationController *navCamera = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navCamera];

    if ([navCamera.viewControllers.firstObject isKindOfClass:[CustomCameraView class]])
    {
        CustomCameraView *cam = (CustomCameraView *)navCamera.viewControllers.firstObject;
        [cam setPopUp];
        cam.delegate = self;
        cam.comingFromNewVollie = YES;
        cam.textFromLastVC = self.textView.text;
        cam.photosFromNewVC = self.photosArray;
        cam.myDelegate = self;
        

        [self presentViewController:[(AppDelegate *)[[UIApplication sharedApplication] delegate] navCamera] animated:0 completion:0];
    }

//    [self.cameraView.delegate freezeCamera];

}

@end
