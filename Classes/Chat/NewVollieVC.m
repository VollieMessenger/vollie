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
#import <ParseUI/ParseUI.h>
#import "SelectRoomVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "KLCPopup.h"
#import "PopUpScrollView.h"
#import "UIColor+JSQMessages.h"
#import "ParseVolliePackage.h"

@interface NewVollieVC ()
<UITextViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
SecondDelegate>

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property CustomCameraView *cameraView;
@property NSMutableArray *arrayForScrollView;
@property UIPageControl *pageControl;
@property PFImageView *popUpImageView;
@property KLCPopup *popUp;

@end

@implementation NewVollieVC

@synthesize textDelegate;
//@synthesize refreshDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self basicSetUpAndInit];
    [self checkForPreviousVC];

    self.arrayForScrollView = [NSMutableArray new];
    self.pageControl = [UIPageControl new];

    if (!self.photosArray) self.photosArray = [NSMutableArray new];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self basicSetUpAndInit];

    self.showingCamera = NO;

    [self.navigationController setNavigationBarHidden: NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;

    if(self.comingFromCamera == true)
    {
//        [self.navigationItem setHidesBackButton:YES animated:NO];
//        NSLog(@"i came from the camera land");
//        [self checkForPreviousVC];
        self.textView.text = @"";
#warning need to fix to make it say type message here        
    }
//    NSLog(@"%li photos when newVollie appeared", self.photosArray.count);
}

-(void)basicSetUpAndInit
{
    self.textView.delegate = self;
    self.title = @"Create Vollie";
    [self.textView becomeFirstResponder];
    [self.textView setReturnKeyType:UIReturnKeySend];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setTintColor:[UIColor volleyFamousGreen]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:.98 alpha:1]];
    self.navigationController.navigationBar.titleTextAttributes =  @{
                                                                     NSForegroundColorAttributeName: [UIColor volleyFamousGreen],
                                                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:20.0f],
                                                                     NSShadowAttributeName:[NSShadow new]
                                                                     };
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if (self.whichRoom)
        {
            PFObject *set = [PFObject objectWithClassName:PF_SET_CLASS_NAME];
            [set setValue:self.whichRoom forKey:PF_SET_ROOM];
            [set setValue:[PFUser currentUser] forKey:PF_SET_USER];
//            [set saveInBackground];

//            ParseVolliePackage *package = [ParseVolliePackage new];
//            self.package;
            if (self.photosArray.count)
            {
                [self.package sendPhotosWithPhotosArray:self.photosArray
                                           andText:self.textView.text
                                           andRoom:self.whichRoom
                                            andSet:set];
            }
            else
            {
                [self.package checkForTextAndSendItWithText:self.textView.text
                                               andRoom:self.whichRoom
                                                andSet:set];
            }
             [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        }
        else
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            SelectRoomVC *selectRoomVC = (SelectRoomVC *)[storyboard instantiateViewControllerWithIdentifier:@"SelectRoomVC"];
            selectRoomVC.photosToSend = self.photosArray;
            selectRoomVC.textToSend = self.textView.text;
            selectRoomVC.package = self.package;
            [self.textDelegate newVollieDismissed:self.textView.text andPhotos:nil];

            [self.navigationController pushViewController:selectRoomVC animated:YES];
            [self.cameraView blankOutButtons];
            [self.cameraView unhideButtons];
        }
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
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    NavigationController *navCamera = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navCamera];
//    CustomCameraView *cam = (CustomCameraView *)navCamera.viewControllers.firstObject;
//    if (!self.showingCamera)[cam blankOutButtons];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (self.comingFromCamera)
    {
        CustomCameraView *cam = self.navigationController.viewControllers.firstObject;
        cam.photosFromNewVC = self.photosArray;
    }
}

- (void)secondViewControllerDismissed:(NSMutableArray *)photosForFirst
{
    //custom delegation method
//    self.photosArray = photosForFirst;
    self.textView.delegate = self;
    [self.textView becomeFirstResponder];
    for (UIImage * pic in photosForFirst) {
        if ([self.photosArray containsObject:pic]) {
            [self.photosArray removeObject:pic];
        }
    }
    [self.photosArray addObjectsFromArray:photosForFirst];
    [self.collectionView reloadData];
}

-(void)bringUpCameraView
{
    NavigationController *navCamera = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navCamera];
    if ([navCamera.viewControllers.firstObject isKindOfClass:[CustomCameraView class]])
    {
        CustomCameraView *cam = (CustomCameraView *)navCamera.viewControllers.firstObject;
        cam.delegate = self;
        self.cameraView = cam;
        if (self.photosArray.count >= 1){
            //            cam.arrayOfTakenPhotos = self.photosArray;
            [cam loadImagesSaved];
            self.showingCamera = YES;
        }
        cam.comingFromNewVollie = YES;
        cam.textFromLastVC = self.textView.text;
        cam.photosFromNewVC = self.photosArray;
//        NSLog(@"%li photos before popping up camera", self.photosArray.count);
        cam.myDelegate = self;

        [self presentViewController:[(AppDelegate *)[[UIApplication sharedApplication] delegate] navCamera] animated:YES completion:0];
        
//        [self presentViewController:cam animated:YES completion:nil];
    }
}

#pragma mark "ScrollView"
-(void)setUpPhotoScrollViewWithIndexPathItem:(NSInteger)indexPathItem
{
//    PopUpScrollView *newScrollView =
}


#pragma mark "CollectionView Stuff"

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    NewVolliePicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    //because cells are re-used we have to declare it visible by default.
    cell.hidden = false;
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.layer.cornerRadius = 10;
    cell.imageView.layer.masksToBounds = YES;
    if(self.photosArray.count > 0 && indexPath.item < self.photosArray.count)
    {
        id imageOrFile = self.photosArray[indexPath.item];
        if ([imageOrFile isKindOfClass:[UIImage class]])
        {
            cell.imageView.image = self.photosArray[indexPath.item];
        }
        else if ([imageOrFile isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic = imageOrFile;
            UIImage *image = dic.allValues.firstObject;
            cell.imageView.image = image;
        }
    }
    else
    {
        if (indexPath.item > 4)
        {
            cell.hidden = true;
            //adds buffer cells so collectionview will stick for iphone 4 and 5 users
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"Vollie-icon"];
        }
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
        return 7;
    }
    else
    {
        return 2;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"%li", self.photosArray.count);
//    if (indexPath.item + 1 > self.photosArray.count)
//    {
//        NSLog(@"%li", self.photosArray.count);
        if (self.comingFromCamera == true)
        {
//            if([self.textDelegate respondsToSelector:@selector(newVollieDismissed:)])
//            {
            [self.textDelegate newVollieDismissed:self.textView.text andPhotos:self.photosArray];
//            }

            self.comingFromCamera = false;
            self.showingCamera = YES;
            [self.textView resignFirstResponder];
//            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self bringUpCameraView];
        }
//    }
//    else
//    {
//        [self setUpPhotoScrollViewWithIndexPathItem:indexPath.item];
//    }
}

@end
