
#import "CustomCameraView.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import "AppConstant.h"
#import "MessagesView.h"
#import "ProgressHUD.h"
#import <Parse/Parse.h>
#import "KLCPopup.h"
#import "UIColor+JSQMessages.h"
#import <Photos/Photos.h>
#import "MessagesView.h"
#import "NavigationController.h"
#import "utilities.h"
#import "AppDelegate.h"
#import "SelectChatroomView.h"
#import "NewVollieVC.h"
#import "ParseVolliePackage.h"
#import "MainInboxVC.h"

#import <MediaPlayer/MediaPlayer.h>

@interface CustomCameraView () <UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, AVCaptureFileOutputRecordingDelegate, UIScrollViewDelegate, NewVollieDelegate, RefreshMessagesDelegate>

@property (nonatomic, strong) ALAssetsLibrary *library;
@property AVCaptureSession *captureSession;
@property AVCaptureStillImageOutput *stillImageOutput;
@property AVCaptureMovieFileOutput *movieFileOutput;
@property AVCaptureDevice *device;
@property AVCaptureFlashMode *flashMode;
@property AVCaptureFocusMode *focusmode;
@property UIImagePickerController *picker;
@property UIPageControl *pageControl;

//https://developer.apple.com/library/ios/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/ConfiguringanAudioSession/ConfiguringanAudioSession.html
// bug for audio, maybe read

@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (nonatomic) UIImageView *movingImage;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIButton *counterButton;
@property (nonatomic) UIView * animationFrame;
@property (nonatomic) NSObject * objectSelectedForOrderChange;

@property (weak, nonatomic) NSTimer *timer;
@property BOOL didPickImageFromAlbum;
@property BOOL movingImagePosition;
@property int initialScrollOffsetPosition;
@property UIRefreshControl *refreshControl;
@property BOOL didViewJustLoad;

@property KLCPopup *pop;
@property UIActivityIndicatorView *spinner;

@property BOOL isCapturingVideo;
@property int captureVideoNowCounter;

@property MPMoviePlayerController *moviePlayer;

@property NSTimer *progressTimer;
@property NSDate *startDate;

@property UIView *videoView;
@property CGRect newImagePosition;

@property BOOL firstCameraFlip;
@property int camFlipCount;

@property NSString *textFromNextVC;

@end


@implementation CustomCameraView

@synthesize delegate;
@synthesize myDelegate;

- (id)initWithPopUp:(BOOL)popup
{
    self = [super init];
    if (self)
    {
        self.isPoppingUp = popup;
    }
    return self;
}

-(void) clearCameraStuff
{
    if(self.photosFromNewVC.count)
    {
        //do NOTHING
    }
    else
    {
        [self.arrayOfTakenPhotos removeAllObjects];
        [self moveImageUpToLatestBlank:0];
        [self unhideButtons];
        [self performSelector:@selector(popRoot) withObject:self afterDelay:1.0f];
    }
}

-(void) popRoot
{
    [self.navigationController popToRootViewControllerAnimated:0];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self runCamera];
    [self deallocSession];

    self.firstCameraFlip = true;
    self.camFlipCount = 0;

    self.captureVideoNowCounter = 0;
    self.takePictureButton.userInteractionEnabled = NO;
    self.switchCameraButton.userInteractionEnabled = NO;
    self.flashButton.userInteractionEnabled = NO;
    self.cameraRollButton.userInteractionEnabled = NO;
    
    if (_isPoppingUp)
    {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.spinner startAnimating];
        self.spinner.frame = CGRectMake(self.view.frame.size.width/2 + 10, self.view.frame.size.height + 28, 40, 40);
        [self.view addSubview:self.spinner];
    }

    if (!self.scrollView)
    {
        self.scrollView = [(AppDelegate *)[[UIApplication sharedApplication] delegate] scrollView];
    }

//    self.nextButton.hidden = YES;
    self.counterButton.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCameraStuff) name:NOTIFICATION_CLEAR_CAMERA_STUFF object:0];

    //Taking screenshots of videos

    _didViewJustLoad = true;

    _x1.backgroundColor = [UIColor volleyFamousOrange];
    _x2.backgroundColor = [UIColor volleyFamousOrange];
    _x3.backgroundColor = [UIColor volleyFamousOrange];
    _x4.backgroundColor = [UIColor volleyFamousOrange];
    _x5.backgroundColor = [UIColor volleyFamousOrange];
    self.counterButton.backgroundColor = [UIColor volleyFamousOrange];

    self.navigationController.navigationBarHidden = 1;

    self.cancelButton.hidden = !_isPoppingUp;
    self.leftButton.hidden = YES;
    self.rightButton.hidden = _isPoppingUp;

    self.cancelButton.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor blackColor];

    //NOT ADDED.
    _refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_refreshControl beginRefreshing];

//    [self removeBackgroundsAndHideObjects];

    [self moveImageUpToLatestBlank:0];
    if (self.photosFromNewVC.count)
    {
        self.arrayOfTakenPhotos = self.photosFromNewVC;
        [self loadImagesSaved];
    }
    else
    {
        self.arrayOfTakenPhotos = [NSMutableArray new];
    }

    for (UIButton *button in self.savedButtons)
    {
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 10;
        button.layer.borderWidth = 3;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
//        [button addTarget:self action:@selector(dragOut:withEvent:)forControlEvents:UIControlEventTouchDragInside];
        [button.imageView setContentMode:UIViewContentModeScaleAspectFill];
    }

    [self setLatestImageOffAlbum];

    self.switchCameraButton.backgroundColor = [UIColor clearColor];
    self.flashButton.backgroundColor = [UIColor clearColor];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(didTapForFocusAndExposurePoint:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];

    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressFocusAndExposure:)];
    press.delegate = self;
    [self.view addGestureRecognizer:press];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScrollview:) name:NOTIFICATION_ENABLESCROLLVIEW object:0];

    /*
    if (!_isPoppingUp)
    {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPopup) name:NOTIFICATION_CAMERA_POPUP object:0];
    }
     */
//    [self dismissPopup];

}

- (void)removeInputs
{
    for (AVCaptureInput *input in self.captureSession.inputs)
    {
        [self.captureSession removeInput:input];
    }

    for(AVCaptureOutput *output in self.captureSession.outputs)
    {
        [self.captureSession removeOutput:output];
    }
}

-(void)dismissPopup
{
    [self stopCaptureSession];
    [self runCamera];
}


-(void)enableScrollview:(NSNotification *)notification
{
    self.scrollView.scrollEnabled = YES;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:1];
#warning GETS CALLED WITH MESSAGESVIEW SIMULTANEOUSLY.

//    if(self.photosFromNewVC.count)
//    {
//        NSLog(@"%li in photosfromNewVC in if statement", self.photosFromNewVC.count);
//        [self clearCameraStuff];
//        NSLog(@"%li in photosfromNewVC after clear camera", self.photosFromNewVC.count);
//        self.arrayOfTakenPhotos = self.photosFromNewVC;
//    }
//    else
//    {
//        self.arrayOfTakenPhotos = [NSMutableArray new];
        [self clearCameraStuff];
//    }

    self.navigationController.navigationBarHidden = 1;
    NSLog(@"%li in photosfromNewVC after if statement", self.photosFromNewVC.count);

    //Only way to check which camera is up and what screen is present.
    if (self.scrollView.contentOffset.x == 0)
    {
        if (!_didViewJustLoad && !_isPoppingUp)
        {
            [self.scrollView setContentOffset:CGPointMake(1, 0)];
            [self.scrollView setContentOffset:CGPointMake(0, 0)];
        }
    }
}

- (void)setPopUp
{
    [[UIApplication sharedApplication] setStatusBarHidden:1 withAnimation:UIStatusBarAnimationSlide];

    _isPoppingUp = YES;
    
    self.cancelButton.hidden = !_isPoppingUp;
    self.leftButton.hidden = YES;
    self.rightButton.hidden = _isPoppingUp;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self runCamera];

    if (self.comingFromNewVollie == true)
    {
        self.rightButton.hidden = true;
        self.cancelButton.hidden = false;
        [[UIApplication sharedApplication] setStatusBarHidden:1 withAnimation:UIStatusBarAnimationSlide];
    }

    self.cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.switchCameraButton.imageView.contentMode = UIViewContentModeScaleAspectFit;

    if (!_didViewJustLoad)
    {
        if (self.navigationController.visibleViewController == self && self.scrollView.contentOffset.x  < 2)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:1 withAnimation:UIStatusBarAnimationSlide];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:1];
            self.scrollView.scrollEnabled = YES;
        }
        else
        {
//            [[UIApplication sharedApplication] setStatusBarHidden:0 withAnimation:UIStatusBarAnimationSlide];
        }
        } else {
            _didViewJustLoad = NO;
//            self.scrollView.scrollEnabled = NO;
        }

//    if(self.photosFromNewVC.count)
//    {
//        self.arrayOfTakenPhotos = self.photosFromNewVC;
//    }
//    else
//    {
//        self.arrayOfTakenPhotos = [NSMutableArray new];
//        [self clearCameraStuff];
//    }

    self.takePictureButton.hidden = self.arrayOfTakenPhotos.count < 5 ? NO : YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (!_isPoppingUp)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        self.scrollView.scrollEnabled = NO;
    }

    self.scrollView.scrollEnabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

//  [self stopCaptureSession];

    if (_isPoppingUp)
    {
        self.scrollView.scrollEnabled = NO;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }

    [self stopCaptureSession];
    
    if (self.captureSession.isRunning)
    {
        [self.captureSession stopRunning];
    }
}

- (void)unhideButtons
{
    self.takePictureButton.alpha = 1;
    self.cameraRollButton.alpha = 1;
    self.takePictureButton.hidden = NO;
    self.cameraRollButton.hidden = NO;
}


//Drag photos on top of other photos, then switch positions.
#warning NOT USED DISABLE PLEASE
- (IBAction)dragOut: (id)sender withEvent: (UIEvent *) event
{

}
/*
 return;
 UIButton *selected = (UIButton *)sender;
 //    [self.view bringSubviewToFront:selected];
 selected.center = [[[event allTouches] anyObject] locationInView:self.view];
 for (UIButton *button in self.savedButtons) {
 if (button != selected)
 if (CGRectContainsPoint(button.bounds, selected.center) ) {
 // Point lies inside the bounds.
 //Swap button animated
 if ( [button pointInside:selected.center withEvent:event] ) {
 // Point lies inside the bounds
 }
 }
 }

 NSSet* allTouches = [event touchesForView:selected];
 UITouch* touch = allTouches.anyObject;
 UIView* touchView = [touch view];//button

 //Use this to know where the button is in the frame of the other buttons.
 CGRect aRect = self.view.frame;
 if (CGRectContainsPoint(aRect, selected.center))

 if (touch.phase == UITouchPhaseEnded) {
 //        [self.view sendSubviewToBack:selected];
 }
 //    [selected setFrame:CGRectMake(selected.center.x, selected.center.y, 50, 50)];
 */

-(void) runCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
#warning FIX THIS EVENTUALLLYYYYY
//      [self stopCaptureSession];

        if (!self.captureSession) [self setupCaptureSessionAndStartRunning];
        else [self startRunningCaptureSession];

    } else if (self.didPickImageFromAlbum)   _didPickImageFromAlbum = NO;
}

- (void)startRunningCaptureSession
{
    if (!self.captureSession.isRunning)
    {
        [self.captureSession startRunning];
        self.videoPreviewView.hidden = NO;
        [self.spinner stopAnimating];
    }
}


#pragma mark - IBACTIONS

- (IBAction)onAlbumPressed:(UIButton *)button
{
    [UIView animateWithDuration:.3f animations:^{
        button.transform = CGAffineTransformMakeScale(1.8,1.8);
        button.transform = CGAffineTransformMakeScale(1,1);
        button.transform = CGAffineTransformMakeScale(1.8,1.8);
        button.transform = CGAffineTransformMakeScale(1,1);
    }];
    if (self.arrayOfTakenPhotos.count == 5) {
        [ProgressHUD showError:@"No More Pictures"];
    } else {
        [self setupImagePicker];
    }
}

- (void)stopCaptureSession
{
    if (self.captureSession)
    {
        [self.captureSession stopRunning];
    }
}

//PART OF CAMERA TOUCHDOWN EVENT.
- (IBAction)buttonRelease:(UIButton *)button
{
    [UIView animateWithDuration:.3f animations:^{
        button.transform = CGAffineTransformMakeScale(.8,.8);
        button.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
}

- (IBAction)onTakePhotoPressed:(UIButton *)button
{
    [UIView animateWithDuration:.3f animations:^{
        button.transform = CGAffineTransformMakeScale(1.8,1.8);
        button.transform = CGAffineTransformMakeScale(1,1);
        button.transform = CGAffineTransformMakeScale(1.8,1.8);
        button.transform = CGAffineTransformMakeScale(1,1);
    }];

    if (self.captureSession)
    {
        [self captureNow];
    }
}

- (IBAction)onFlashPressed:(id)sender
{
    if (self.flashMode == AVCaptureFlashModeOn) {
        self.flashMode = AVCaptureFlashModeOff;
        [self.flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
    } else if (self.flashMode == AVCaptureFlashModeOff) {
        self.flashMode = AVCaptureFlashModeOn;
        [self.flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    }
}
- (IBAction)didPressCloseButton:(UIButton *)sender
{
    if (sender.isHidden == NO)

        if (self.arrayOfTakenPhotos.count == 5)
        {
            self.takePictureButton.hidden = NO;
            self.cameraRollButton.hidden = NO;
            self.counterButton.hidden = NO;

            [UIView animateWithDuration:.5 animations:^{
                self.takePictureButton.alpha = 0;
                self.takePictureButton.alpha = 1;
                self.cameraRollButton.alpha = 0;
                self.cameraRollButton.alpha = 1;
            }];
        }

    switch (sender.tag)
    {
        case 0:
            self.x1.hidden = YES;
            self.savedButton1.hidden = YES;

            //Would not return the dictionaries, have to use button for index of items.
            [self.arrayOfTakenPhotos removeObjectAtIndex:0];
            self.savedButton1.imageView.image = nil;
            [self moveImageUpToLatestBlank:self.x1];
            break;

        case 1:

            self.x2.hidden = YES;
            self.savedButton2.hidden = YES;
            [self.arrayOfTakenPhotos removeObjectAtIndex:1];
            self.savedButton2.imageView.image = nil;
            [self moveImageUpToLatestBlank:self.x2];
            break;
        case 2:
            self.x3.hidden = YES;
            self.savedButton3.hidden = YES;
            [self.arrayOfTakenPhotos removeObjectAtIndex:2];
            self.savedButton3.imageView.image = nil;
            [self moveImageUpToLatestBlank:self.x3];
            break;
        case 3:
            self.x4.hidden = YES;
            self.savedButton4.hidden = YES;
            [self.arrayOfTakenPhotos removeObjectAtIndex:3];  //kyle note this is where it crashes
            self.savedButton4.imageView.image = nil;
            [self moveImageUpToLatestBlank:self.x4];
            break;
        case 4:
            self.x5.hidden = YES;
            self.savedButton5.hidden = YES;
            [self.arrayOfTakenPhotos removeObjectAtIndex:4];
            self.savedButton5.imageView.image = nil;
            [self moveImageUpToLatestBlank:self.x5];
            self.cameraRollButton.hidden = NO;
            self.takePictureButton.hidden = NO;
            break;

        default:
            break;
    }
}



- (IBAction)onCloseCameraPressed:(UIButton *)sender
{
//    [self stopCaptureSession];

    if (self.picker)
    {
        [self.picker dismissViewControllerAnimated:1 completion:0];
    }


    self.isPoppingUp = NO;
/*
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromBottom;
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    transition.fillMode = kCAFillModeForwards;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
 */

//  [self.navigationController popViewControllerAnimated:NO];

    self.cancelButton.hidden = YES;
    self.rightButton.hidden = NO;

    PostNotification(NOTIFICATION_CAMERA_POPUP);

    [[UIApplication sharedApplication] setStatusBarHidden:0 withAnimation:UIStatusBarAnimationSlide];

    [self dismissViewControllerAnimated:0 completion:0];

    self.didPickImageFromAlbum = NO;
}

-(void)freezeCamera
{
    NSLog(@"frozen!");
}


-(IBAction)didSlideRight:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0) animated:YES];
}

- (void)updateUI:(NSTimer *)timer
{
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:self.startDate];
    if (elapsedTime <= 10)
    {
        self.videoView.frame = CGRectMake(self.animationFrame.frame.origin.x, (self.animationFrame.frame.origin.y + self.animationFrame.frame.size.height) - elapsedTime * 6.5, 65, elapsedTime * 6.5);
    }
    else
    {
        [self.takePictureButton setImage:[UIImage imageNamed:@"snap-1"] forState:UIControlStateNormal];
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        [self captureStopVideoNow];
    } 
}

#pragma mark - IMAGE PICKER

- (void)setupImagePicker
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        self.picker = [[UIImagePickerController alloc] init];

        self.picker.allowsEditing = 0;

        [self.picker setAutomaticallyAdjustsScrollViewInsets:1];

        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

        self.picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.picker.sourceType];

        self.picker.delegate = self;

        self.picker.navigationBar.backgroundColor = [UIColor volleyFamousGreen];

//        [self stopCaptureSession];

        [self presentViewController:self.picker animated:1 completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            [[UIApplication sharedApplication] setStatusBarHidden:0 withAnimation:UIStatusBarAnimationSlide];
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];

    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];

    AVAsset *movie = [AVAsset assetWithURL:videoURL];
    CMTime movieLength = movie.duration;
    if (movie) {
        if (CMTimeCompare(movieLength, CMTimeMake(10.5, 1)) == -1)
        {
            AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
            AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
            generate1.appliesPreferredTrackTransform = YES;
            NSError *err = NULL;
            CMTime time = CMTimeMake(1, 2);
            CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];

            UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
            UIImage *video = [UIImage imageNamed:@"video"];
            one = [self drawImage:video inImage:one atPoint:CGPointMake((one.size.width/2 - video.size.width/2) , (one.size.height/2 - video.size.height/2))];


            NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithFormat:@"outputC%i.mov", _captureVideoNowCounter]];
            NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:outputPath])
            {
                [fileManager removeItemAtPath:outputPath error:0];
            }

                dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [UIView animateWithDuration:.3f animations:^
                                {
                                    for (UIButton *button in self.savedButtons) {
                                        button.alpha = .5;
                                        button.userInteractionEnabled = NO;
                                    }
                                }];
                               [self setButtonsWithImage:one withVideo:true AndURL:outputURL];
                               [self.videoView removeFromSuperview];
                               [self.animationFrame removeFromSuperview];
                           });

            //Convert this giant file to something more managable.
            [self convertVideoToLowQuailtyWithInputURL:videoURL outputURL:outputURL handler:^(NSURL *output, bool success) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:.3f animations:^{
                            for (UIButton *button in self.savedButtons)
                            {
                                button.alpha = 1;
                                button.userInteractionEnabled = 1;
                            }
                        }];
                    });
                    //SAY THE BUTTON IS OKAY TO SEND.
                } else {
                }
            }];

            [picker dismissViewControllerAnimated:1 completion:0];
            return;
        } else {
            [picker dismissViewControllerAnimated:1 completion:0];
            [ProgressHUD showError:@"Video Too Long (10s)"];
            return;
        }
    }


    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];

    if (image.size.height/image.size.width * 9 != 16)
    {
        image = [self getSubImageFrom:image WithRect:CGRectMake(0, 0, 1080, 1920)];
    } else {
    }

    self.didPickImageFromAlbum = YES;

    [picker dismissViewControllerAnimated:1 completion:^
    {
        [self setButtonsWithImage:image withVideo:false AndURL:0];

        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarHidden:1 withAnimation:UIStatusBarAnimationSlide];
        self.scrollView.scrollEnabled = YES;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:1 completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarHidden:1 withAnimation:UIStatusBarAnimationSlide];
        self.scrollView.scrollEnabled = YES;
    }];
}

- (void)setLatestImageOffAlbum
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
        if (fetchResult) {
            PHAsset *lastAsset = [fetchResult lastObject];
            [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                       targetSize:CGSizeMake(330, 320)
                                                      contentMode:PHImageContentModeDefault
                                                          options:PHImageRequestOptionsVersionCurrent
                                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                                        dispatch_async(dispatch_get_main_queue(),
               ^{
                    //kyle note
                    CGSize smallerPhoto =CGSizeMake(200, 200);
                    UIImage *squareImage = [self squareImageWithImage:result scaledToSize:smallerPhoto];
                    [[self cameraRollButton] setImage:squareImage forState:UIControlStateNormal];
                });
            }];
        }
    }
    else
    {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
        {
            // Within the group enumeration block, filter to enumerate just photos.
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if ([group numberOfAssets] > 0)
                // Chooses the photo at the last index
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop)
            {
                    // The end of the enumeration is signaled by asset == nil.
                    if (alAsset) {
                        ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                        UIImage *image = [self cropImageCameraRoll:[UIImage imageWithCGImage:[representation fullScreenImage]]];
                        self.cameraRollButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        self.cameraRollButton.imageView.image = image;
                        // Stop the enumerations
                        *stop = YES; *innerStop = YES;
                    }
                }];
        } failureBlock: ^(NSError *error) {
        }];
    }
    self.cameraRollButton.layer.masksToBounds = 1;
    self.cameraRollButton.layer.cornerRadius = 10;
    self.cameraRollButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cameraRollButton.layer.borderWidth = 3;
}

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;

    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);

    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }

    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);


    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

#pragma mark - CAMERA

// Create and configure a capture session and start it running
- (void)setupCaptureSessionAndStartRunning
{
    self.didPickImageFromAlbum = NO;

    NSError *error = nil;

    AVCaptureSession *session = [[AVCaptureSession alloc] init];

    session.sessionPreset = AVCaptureSessionPresetHigh; //FULL SCREEN;
    //    session.sessionPreset = AVCaptureSessionPresetPhoto;

    //    NOT USED YET
    //    CGRect layerRect = [[[self view] layer] bounds];
    //    [self.videoPreviewView setBounds:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //    CGPoint point = CGPointMake(CGRectGetMidY(layerRect), CGRectGetMidX(layerRect));

    // Find a suitable AVCaptureDevice
    self.device = [AVCaptureDevice
                   defaultDeviceWithMediaType:AVMediaTypeVideo];

    [self setFlashMode:AVCaptureFlashModeOn forDevice:self.device];

    if ([self.device isFocusPointOfInterestSupported] && [self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        [self didTapForFocusAndExposurePoint:self.view.gestureRecognizers.lastObject];
    }

    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device
                                                                        error:&error];
    if (!input)
    {
        return;
    }

    if ([session canAddInput:input])
    {
    [session addInput:input];
    }


    //ADD AUDIO INPUT

    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }

    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];

    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];


    //Stackoverflow help
    dispatch_queue_t layerQ = dispatch_queue_create("layerQ", NULL);
    dispatch_async(layerQ, ^
    {
        // Start the session running to start the flow of data
        [session startRunning];

        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        [self.stillImageOutput automaticallyEnablesStillImageStabilizationWhenAvailable];

        if ([session canAddOutput:self.stillImageOutput])
        {
            [session addOutput:self.stillImageOutput];
        }

        self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        self.movieFileOutput.minFreeDiskSpaceLimit = 1024*1024*10; // 10 MB
        self.movieFileOutput.maxRecordedDuration = CMTimeMake(10, 1);

        if ([session canAddOutput:_movieFileOutput])
        {
            [session addOutput:_movieFileOutput];
        }
        
        [session setSessionPreset:AVCaptureSessionPreset1280x720];

        // Assign session to an ivar.
        self.captureSession = session;

        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
        CGRect videoRect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        previewLayer.frame = [UIScreen mainScreen].bounds; // Assume you want the preview layer to fill the view.
        CGRect bounds = videoRect;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.bounds=bounds;
        previewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

        //Main thread does GUI
        dispatch_async(dispatch_get_main_queue(), ^
        {
        [self.videoPreviewView.layer addSublayer:previewLayer];
            self.takePictureButton.userInteractionEnabled = YES;
            self.takePictureButton.userInteractionEnabled = YES;
            self.switchCameraButton.userInteractionEnabled = YES;
            self.flashButton.userInteractionEnabled = YES;
            self.cameraRollButton.userInteractionEnabled = YES;
            [self.spinner stopAnimating];
        });

        });
}

-(void)deallocSession
{
    [self.videoPreviewView.layer.sublayers.lastObject removeFromSuperlayer];
    for(AVCaptureInput *input1 in self.captureSession.inputs) {
        [self.captureSession removeInput:input1];
    }

    for (AVCaptureOutput *output1 in self.captureSession.outputs)
    {
        [self.captureSession removeOutput:output1];
    }

    [self.captureSession stopRunning];
    self.captureSession = nil;
    self.stillImageOutput = nil;
    self.device = nil;
    
//    input=nil;
//    captureVideoPreviewLayer=nil;
//    stillImageOutput=nil;
//    self.vImagePreview=nil;
}

-(void) didTapForFocusAndExposurePoint:(UITapGestureRecognizer *)point
{
    //currently not working and not important for current build. users do not
    //expect to have exposure settings
//    if (point.state == UIGestureRecognizerStateEnded)
//    {
//        CGPoint save = [point locationInView:self.view];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
//        view.layer.borderWidth = 3;
//        view.layer.cornerRadius = 10;
//        view.layer.borderColor = [UIColor whiteColor].CGColor;
//        view.center = save;
//        view.alpha = 0;
//        [UIView animateWithDuration:0.3f animations:^{
//            [self.view addSubview:view];
//            view.alpha = 1;
//            view.alpha = 0;
//        } completion:^(BOOL finished) {
//            [view removeFromSuperview];
//        }];
//
//        NSString *save2 = NSStringFromCGPoint(save);
//        save = CGPointMake(save.y/self.view.frame.size.height, (1 -save.x/self.view.frame.size.width));
//        save2 = NSStringFromCGPoint(save);
//
//        if ([self.device lockForConfiguration:0]) {
//            if (point) {
//                [self.device setFocusPointOfInterest:save];
//                [self.device setExposurePointOfInterest:save];
//            }
//            [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
//            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
//            [self.device unlockForConfiguration];
//        }
//    }
}

//- (IBAction)handleDrag:(UIButton *)sender forEvent:(UIEvent *)event
//{
//    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
//    point.y = sender.center.y; //Always stick to the same y value
//
//    sender.center = point;
//}

-(void)didLongPressFocusAndExposure:(UILongPressGestureRecognizer *)point
{
    if (point.state == UIGestureRecognizerStateBegan)
    {
        CGPoint save = [point locationInView:self.view];
//        CGPoint tempPoint = CGPointMake(save.x, self.x1.center.y);
//        save = tempPoint;
        if(self.arrayOfTakenPhotos.count > 1)
        {
        for (UIButton * button in self.savedButtons)
            {
                if (!button.hidden)
                {
                    if (CGRectContainsPoint(button.frame, save))
                    {
                        button.hidden = YES;
                        self.x1.hidden = YES;
                        self.x2.hidden = YES;
                        self.x3.hidden = YES;
                        self.x4.hidden = YES;
                        self.x5.hidden = YES;
                        [self createViewForImagePositionChange:button atPoint:save];
                    }
                }
            }
        }

        if (CGRectContainsPoint(self.takePictureButton.frame, save))
        {
            self.takePictureButton.transform = CGAffineTransformMakeScale(1.4,1.4);
            AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            NSError *error2 = nil;
            AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error2];
            if (audioInput)
            {
                [self.captureSession addInput:audioInput];
            }

            _isCapturingVideo = YES;

            self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateUI:) userInfo:nil repeats:YES];


            for (UIButton *button in self.savedButtons)
            {
                button.userInteractionEnabled = NO;
            }

            self.videoView = [UIView new];
            self.animationFrame = [UIView new];
            self.videoView.layer.masksToBounds = 1;
            self.videoView.backgroundColor = [UIColor volleyFamousOrange];
            self.videoView.alpha = .9f;
            self.videoView.layer.cornerRadius = 10;
            self.videoView.layer.rasterizationScale = [UIScreen mainScreen].scale;
            self.videoView.layer.shouldRasterize = 1;
            self.videoView.layer.borderWidth = 0;
            self.videoView.layer.borderColor = [UIColor whiteColor].CGColor;
            
            switch (self.arrayOfTakenPhotos.count)
            {
                case 0:
                    [self.animationFrame setFrame:self.savedButton1.frame];
                    break;
                case 1:
                    [self.animationFrame setFrame:self.savedButton2.frame];
                    break;
                case 2:
                    [self.animationFrame setFrame:self.savedButton3.frame];
                    break;
                case 3:
                    [self.animationFrame setFrame:self.savedButton4.frame];
                    break;
                case 4:
                    [self.animationFrame setFrame:self.savedButton5.frame];
                    break;
                    
                default:
                    break;
            }
            self.animationFrame.layer.masksToBounds = YES;
            self.animationFrame.layer.cornerRadius = 10;
            self.animationFrame.layer.borderWidth = 3;
            self.animationFrame.layer.borderColor = [UIColor whiteColor].CGColor;
            [self.view addSubview:self.videoView];
            [self.view addSubview:self.animationFrame];

            self.startDate = [NSDate date];

            [self.takePictureButton setImage:[UIImage imageNamed:@"record-1"] forState:UIControlStateNormal];

            [self captureVideoNow];
            return;
        }
    }
    else if (point.state ==UIGestureRecognizerStateEnded)
    {
        if (_isCapturingVideo)
        {
            [UIView animateWithDuration:.3f animations:^
            {
                self.takePictureButton.transform = CGAffineTransformMakeScale(1.8,1.8);
                self.takePictureButton.transform = CGAffineTransformMakeScale(1,1);
                self.takePictureButton.transform = CGAffineTransformMakeScale(1.8,1.8);
                self.takePictureButton.transform = CGAffineTransformMakeScale(1,1);
            }];

            [self.takePictureButton setImage:[UIImage imageNamed:@"snap-1"] forState:UIControlStateNormal];

            [self captureStopVideoNow];
            [self.progressTimer invalidate];
            AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            for (AVCaptureDeviceInput * input in self.captureSession.inputs) {
                if (input.device==audioCaptureDevice) {
                    [self.captureSession removeInput:input];
                }
            }
        }
        
        if (self.movingImagePosition) {
            for (UIButton *button in self.savedButtons)
            {
                if (CGRectEqualToRect(button.frame, self.newImagePosition))
                {
                    [UIView animateWithDuration:.4 animations:^{
                        [self.movingImage setFrame:self.newImagePosition];
                    } completion:^(BOOL finished) {
                        self.movingImagePosition = NO;
                        [self moveImageUpToLatestBlank:button];
                        button.hidden = NO;
                        [self.movingImage removeFromSuperview];
                    }];
                }
            }
        }
        
    } else if(point.state == UIGestureRecognizerStateChanged)
    {
        if (self.movingImagePosition)
        {
            CGPoint save = [point locationInView:self.view];
            CGPoint temp = CGPointMake(self.x3.center.x, self.x1.center.y);
            CGPoint new = CGPointMake(temp.x, save.y);
            [self.movingImage setCenter:new];
            [self insertImageInSlot];
        }
    }
}

-(void)insertImageInSlot
{
    for (UIButton *button in self.savedButtons) {
        if (!button.isHidden && CGRectContainsPoint(button.frame, self.movingImage.center)) {
            [self.arrayOfTakenPhotos removeObject:self.objectSelectedForOrderChange];
            [self.arrayOfTakenPhotos insertObject:self.objectSelectedForOrderChange atIndex:button.tag];
            [self moveImageUpToLatestBlank:button];
            button.hidden = YES;
            self.newImagePosition = button.frame;
        }
    }
}

-(IBAction)switchCameraTapped:(id)sender
{
    //Change camera source
    if(self.captureSession)
    {
        //Indicate that some changes will be made to the session
        [self.captureSession beginConfiguration];
//        self.camFlipCount++;
        AVCaptureInput* currentCameraInput = [self.captureSession.inputs objectAtIndex:0];
//        AVCaptureInput* audioInput = [self.captureSession.inputs objectAtIndex:1];
//        NSLog(@"1 %@", currentCameraInput);
//        NSLog(@"2 %@", audioInput);

//        if (self.camFlipCount >= 3)
//        {
//            currentCameraInput = [self.captureSession.inputs objectAtIndex:1];
//        }
//        for (AVCaptureInput* input in self.captureSession.inputs)
//        {
//            i++;
//            NSLog(@"%i, %@", i, input);
//        }
//        for (AVCaptureInput* input in self.captureSession.inputs)
//        {
//            NSLog(@"removing %@", input);
//            [self.captureSession removeInput:input];
//        }
//        NSLog(@"%@", currentCameraInput);
//        [self.captureSession removeInput:currentCameraInput];
//        NSLog(@"now removing %@", currentCameraInput);
        //TODO Fix how it's selfie mode twice in a row
//        [self cameraWithPosition:AVCaptureDevicePositionBack];

        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            [self.captureSession removeInput:currentCameraInput];
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
//            AVCaptureInput *tempInput = [self.captureSession.inputs objectAtIndex:1];
//            [self.captureSession removeInput:tempInput];
            [self.captureSession removeInput:currentCameraInput];
        }

        //Add input to session
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];

        if ([self.captureSession canAddInput:newVideoInput])
        {
        [self.captureSession addInput:newVideoInput];
        }
        
        //Commit all the configuration changes at once
        [self.captureSession commitConfiguration];
    }
}

// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        return device;
    }
    return nil;
}

- (void)captureNow
{
    self.takePictureButton.userInteractionEnabled = NO;

    AVCaptureConnection *videoConnection = nil;

    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }

    // Set flash mode
    if (self.flashMode == AVCaptureFlashModeOff) {
        [self setFlashMode:AVCaptureFlashModeOff forDevice:self.device];
    } else {
        [self setFlashMode:AVCaptureFlashModeOn forDevice:self.device];
    }

    // Flash the screen white and fade it out to give UI feedback that a still image was taken

    UIView *flashView = [[UIView alloc] initWithFrame:self.videoPreviewView.window.bounds];
    flashView.backgroundColor = [UIColor whiteColor];
    [self.videoPreviewView.window addSubview:flashView];

    float flashDuration = self.flashMode == AVCaptureFlashModeOff ? 0.6f : 1.5f;

    [UIView animateWithDuration:flashDuration
                     animations:^{
                         flashView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                     }
     ];

    if (self.device.position == AVCaptureDevicePositionFront)
    {
        //Put filter on image afterwards;
    }


    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                       completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         if (!error)
         {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             [self setButtonsWithImage:image withVideo:false AndURL:0];
             self.takePictureButton.userInteractionEnabled = YES;
         } else {
             self.takePictureButton.userInteractionEnabled = YES;
         }
     }];
}

-(void)captureVideoNow
{
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithFormat:@"output%i.mov", _captureVideoNowCounter]];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath])
    {
        _captureVideoNowCounter++;
        [self captureVideoNow];
        return;
//        NSError *error;
//        if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
            //Error - handle if requried
    }

    [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

-(void)captureStopVideoNow
{
    [self.movieFileOutput stopRecording];
    NSURL *url = [self.movieFileOutput outputFileURL];

//    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (url.path))
//    {
//    UISaveVideoAtPathToSavedPhotosAlbum(url.path, 0, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//    }
}


-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{

    AVAsset *movie = [AVAsset assetWithURL:outputFileURL];

    if (movie)
    {
        //Get Image of first frame for picture.
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:outputFileURL options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];

        UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
        UIImage *video = [UIImage imageNamed:@"video"];

        one = [self drawImage:video inImage:one atPoint:CGPointMake((one.size.width/2 - video.size.width/2) , (one.size.height/2 - video.size.height/2))];

        NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithFormat:@"outputC%i.mov", _captureVideoNowCounter]];
        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];

        if ([fileManager fileExistsAtPath:outputPath])
        {
            [fileManager removeItemAtPath:outputPath error:0];
        }


        dispatch_async(dispatch_get_main_queue(), ^
        {
            [UIView animateWithDuration:.3f animations:^
             {
                 for (UIButton *button in self.savedButtons) {
                     button.alpha = .5;
                     button.userInteractionEnabled = NO;
                 }
             }];
            [self setButtonsWithImage:one withVideo:true AndURL:outputURL];
            [self.videoView removeFromSuperview];
            [self.animationFrame removeFromSuperview];
        });

        //Convert this giant file to something more managable.
        [self convertVideoToLowQuailtyWithInputURL:outputFileURL outputURL:outputURL handler:^(NSURL *output, bool success) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.3f animations:^{
                for (UIButton *button in self.savedButtons)
                {
                    button.alpha = 1;
                    button.userInteractionEnabled = 1;
                }
                }];
                });

                //SAY THE BUTTON IS OKAY TO SEND.
            } else {
            }
        }];

        return;
    }
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                    outputURL:(NSURL *)outputURL
                                     handler:(void (^)(NSURL *output, bool success))handler
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType =AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.status == AVAssetExportSessionStatusCompleted)
        {
            //Need main thread for gui stuff.
            handler(outputURL,true);
        } else if (exportSession.status == AVAssetExportSessionStatusFailed)
        {
            handler(0,false);
        }

    }];
}

//Save to camera roll
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{
    if (error == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Saved to camera roll" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
}

-(void) animateNextButton
{
    if (!self.nextButton.isHidden)
    {
        [UIView animateKeyframesWithDuration:.5f delay:0.0f options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
            self.nextButton.transform = CGAffineTransformMakeScale(1.0,1.0);
            self.nextButton.transform = CGAffineTransformMakeScale(2.0,2.0);
            self.nextButton.transform = CGAffineTransformMakeScale(1.0,1.0);
        } completion:0];
    }
}

//Depending on number of pictures, line them up accordingly when deleted.
- (void)setButtonsWithImage:(UIImage *)image withVideo:(BOOL)isVideoTag AndURL:(NSURL *)videoURL
{
    self.nextButton.hidden = NO;
    if (image)
    {
        if (!isVideoTag && !videoURL)
        {
        [self.arrayOfTakenPhotos addObject:image];
        }
        else
        {
//            Attach IMAGE TO PFFILE
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:image forKey:videoURL.path];
            [self.arrayOfTakenPhotos addObject:dictionary];
        }

    self.counterButton.titleLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.arrayOfTakenPhotos.count];

    if (_arrayOfTakenPhotos.count < 5 && self.takePictureButton.isHidden)
    {
        [UIView animateWithDuration:1 animations:^{
//            self.takePictureButton.alpha = 0;
            self.takePictureButton.alpha = 1;
//            self.nextButton.alpha = 0;
//            self.nextButton.alpha = 1;
//            self.counterButton.alpha = 0;
            self.counterButton.alpha = 1;
            self.takePictureButton.hidden = NO;
            self.cameraRollButton.hidden = NO;
        }];
    }
    if (self.savedButton1.hidden)
    {
//        self.nextButton.hidden = NO;
        self.counterButton.hidden = NO;
        if (isVideoTag)
        {
            self.savedButton1.titleLabel.text = videoURL.path;
        }
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(animateNextButton) userInfo:0 repeats:1];

        [self.savedButton1 setImage:image forState:UIControlStateNormal];
        self.savedButton1.hidden = NO;
        self.x1.hidden = NO;
    }
    else if (self.savedButton2.hidden)
    {
        [self.savedButton2 setImage:image forState:UIControlStateNormal];
        self.savedButton2.hidden = NO;
        if (isVideoTag)
        {
        self.savedButton2.titleLabel.text = videoURL.path;
        }
        self.x2.hidden = NO;
    }
    else if (self.savedButton3.hidden)
    {
        [self.savedButton3 setImage:image forState:UIControlStateNormal];
        if (isVideoTag)
        {
        self.savedButton3.titleLabel.text = videoURL.path;
        }
        self.savedButton3.hidden = NO;
        self.x3.hidden = NO;
    }
    else if (self.savedButton4.hidden)
    {
        [self.savedButton4 setImage:image forState:UIControlStateNormal];
        if (isVideoTag)
        {
            self.savedButton4.titleLabel.text = videoURL.path;
        }
        self.savedButton4.hidden = NO;
        self.x4.hidden = NO;
    }
    else if (self.savedButton5.hidden)
    {
        [self.savedButton5 setImage:image forState:UIControlStateNormal];
        if (isVideoTag)
        {
            self.savedButton5.titleLabel.text = videoURL.path;
        }
        self.savedButton5.hidden = NO;
        self.x5.hidden = NO;

        [ProgressHUD showSuccess:@"Hit Next"];

        [UIView animateWithDuration:.3f animations:^{
            self.takePictureButton.alpha = 1;
            self.takePictureButton.alpha = 0;
            self.cameraRollButton.alpha = 1;
            self.cameraRollButton.alpha = 0;
//            self.nextButton.alpha = 0;
            self.nextButton.alpha = 1;
        } completion:^(BOOL finished) {
            self.takePictureButton.hidden = YES;
            self.cameraRollButton.hidden = YES;
        }];
    }
}}

-(void) newVollieDismissed:(NSString *)textForCam andPhotos:(NSMutableArray*)photosArray
{
    self.textFromNextVC = textForCam;
    self.photosFromNewVC = photosArray;
    NSLog(self.textFromNextVC);
    NSLog(@"%li in photo array", photosArray.count);
}

//NEXT BUTTON PRESSED
- (IBAction)didPressNextButton:(UIButton *)button
{
    [UIView animateWithDuration:.3 animations:^{
        button.transform = CGAffineTransformMakeScale(0.3,0.3);
        button.transform = CGAffineTransformMakeScale(1,1);
    }];

//    button.userInteractionEnabled = NO;
    if (_arrayOfTakenPhotos.count == 0)
    {
        [ProgressHUD showError:@"No Pictures Taken"];
        button.userInteractionEnabled = YES;
    }
    else
    {
        if(self.comingFromNewVollie == true)
        {
            if([self.myDelegate respondsToSelector:@selector(secondViewControllerDismissed:)])
            {
                [self.myDelegate secondViewControllerDismissed:self.arrayOfTakenPhotos];
                self.comingFromNewVollie = false;
            }
            PostNotification(NOTIFICATION_CAMERA_POPUP);

            [[UIApplication sharedApplication] setStatusBarHidden:0 withAnimation:UIStatusBarAnimationSlide];

            [self dismissViewControllerAnimated:NO completion:nil];
        }
        else if (self.isPoppingUp)
        {
            self.isPoppingUp = NO;

            self.cancelButton.hidden = YES;
            self.rightButton.hidden = NO;

//            [delegate sendBackPictures:self.arrayOfTakenPhotos withBool:YES andComment:@""];

            button.userInteractionEnabled = YES;

            [self dismissViewControllerAnimated:0 completion:0];

            [[UIApplication sharedApplication] setStatusBarHidden:0 withAnimation:UIStatusBarAnimationSlide];

            PostNotification(NOTIFICATION_CAMERA_POPUP);
        }
        else
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            NewVollieVC *vc = (NewVollieVC *)[storyboard instantiateViewControllerWithIdentifier:@"NewVollieVC"];
            vc.photosArray = self.arrayOfTakenPhotos;
            vc.comingFromCamera = true;
            vc.textFromLastVC = self.textFromNextVC;
            vc.textDelegate = self;
            ParseVolliePackage *package = [ParseVolliePackage new];
            package.refreshDelegate = self;
            vc.package = package;
            [self.navigationController pushViewController:vc animated:NO];
            button.userInteractionEnabled = YES;
        }
    }
}

-(void)reloadAfterMessageSuccessfullySent
{
//    NSLog(@"reload method called in camera");
    self.scrollView.didJustFinishSendingVollie = YES;
    [self didSlideRight:self];
    NavigationController *navInbox = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navInbox];
    MainInboxVC *inbox = (MainInboxVC*)navInbox.viewControllers.firstObject;
    [inbox goToMostRecentChatRoom];
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            self.flashButton.hidden = YES;
        }
    }
}

/*
 -(UIImage *)cropImage:(UIImage *)imageTaken
 {
 UIImage* imageCropped;
 CGFloat side = MIN(imageTaken.size.width, imageTaken.size.height);
 CGFloat x = imageTaken.size.width / 2 - side / 2 + 300;
 CGFloat y = imageTaken.size.height / 2 - side / 2 - 300;
 CGRect cropRect = CGRectMake(x,y,640,640);
 CGImageRef imageRef = CGImageCreateWithImageInRect([imageTaken CGImage], cropRect);
 imageCropped = [UIImage imageWithCGImage:imageRef scale:imageCropped.scale orientation:imageTaken.imageOrientation];
 CGImageRelease(imageRef);
 return imageCropped;
 }
 */


// get sub image
- (UIImage*)getSubImageFrom:(UIImage *)imageTaken WithRect:(CGRect)rect
{
    CGFloat height = imageTaken.size.height;
    CGFloat width = imageTaken.size.width;

    CGFloat newWidth = height * 9 / 16;
    CGFloat newX = abs((width - newWidth)) / 2;

    CGRect cropRect = CGRectMake(newX,0, newWidth ,height);

    UIGraphicsBeginImageContext(cropRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-cropRect.origin.x, -cropRect.origin.y, imageTaken.size.width, imageTaken.size.height);
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, cropRect.size.width, cropRect.size.height));
    // draw image
    [imageTaken drawInRect:drawRect];

    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return subImage;
}

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)aperture withOrientation:(UIImageOrientation)orientation {
    // convert y coordinate to origin bottom-left
    CGFloat orgY = aperture.origin.y + aperture.size.height - imageToCrop.size.height,
    orgX = -aperture.origin.x,
    scaleX = 1.0,
    scaleY = 1.0,
    rot = 0.0;
    CGSize size;

    switch (orientation) {
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            size = CGSizeMake(aperture.size.height, aperture.size.width);
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            size = aperture.size;
            break;
        default:
            assert(NO);
            return nil;
    }


    switch (orientation) {
        case UIImageOrientationRight:
            rot = 1.0 * M_PI / 2.0;
            orgY -= aperture.size.height;
            break;
        case UIImageOrientationRightMirrored:
            rot = 1.0 * M_PI / 2.0;
            scaleY = -1.0;
            break;
        case UIImageOrientationDown:
            scaleX = scaleY = -1.0;
            orgX -= aperture.size.width;
            orgY -= aperture.size.height;
            break;
        case UIImageOrientationDownMirrored:
            orgY -= aperture.size.height;
            scaleY = -1.0;
            break;
        case UIImageOrientationLeft:
            rot = 3.0 * M_PI / 2.0;
            orgX -= aperture.size.height;
            break;
        case UIImageOrientationLeftMirrored:
            rot = 3.0 * M_PI / 2.0;
            orgY -= aperture.size.height;
            orgX -= aperture.size.width;
            scaleY = -1.0;
            break;
        case UIImageOrientationUp:
            break;
        case UIImageOrientationUpMirrored:
            orgX -= aperture.size.width;
            scaleX = -1.0;
            break;
    }

    // set the draw rect to pan the image to the right spot
    CGRect drawRect = CGRectMake(orgX, orgY, imageToCrop.size.width, imageToCrop.size.height);

    // create a context for the new image
    UIGraphicsBeginImageContextWithOptions(size, NO, imageToCrop.scale);
    CGContextRef gc = UIGraphicsGetCurrentContext();

    // apply rotation and scaling
    CGContextRotateCTM(gc, rot);
    CGContextScaleCTM(gc, scaleX, scaleY);

    // draw the image to our clipped context using the offset rect
    CGContextDrawImage(gc, drawRect, imageToCrop.CGImage);

    // pull the image from our cropped context
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();

    // pop the context to get back to the default
    UIGraphicsEndImageContext();

    // Note: this is autoreleased
    return cropped;
}

-(UIImage *)cropImageCameraRoll:(UIImage *)imageTaken
{

    CGFloat height = imageTaken.size.height;
    CGFloat width = imageTaken.size.width;

    CGFloat newWidth = height * 9 / 16;
    CGFloat newX = abs((width - newWidth)) / 2;

    CGRect cropRect = CGRectMake(newX,0, newWidth ,height);

    CGImageRef imageRef = CGImageCreateWithImageInRect([imageTaken CGImage], cropRect);
    UIImage *imageCropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    //    CGImageRef imageRef = CGImageCreateWithImageInRect([imageTaken CGImage], cropRect);
    //   UIImage *imageCropped = [UIImage imageWithCGImage:imageRef scale:imageTaken.scale orientation:imageTaken.imageOrientation];
    //    if (imageCropped.size.height/ imageCropped.size.width != 16/9) {
    //        return [UIImage imageWithCGImage:CGImageCreateWithImageInRect([imageTaken CGImage], cropRect) scale:imageTaken.scale orientation:imageTaken.imageOrientation];
    //    }
    return ResizeImage(imageCropped, 1080, 1920);
}

-(void)removeBackgroundsAndHideObjects
{
    self.savedButton1.hidden = YES;
    self.savedButton2.hidden = YES;
    self.savedButton3.hidden = YES;
    self.savedButton4.hidden = YES;
    self.savedButton5.hidden = YES;
}

-(IBAction)didTapButtonSaved:(UIButton *)sender
{
    if (sender.isHidden == NO)
    {
        int index = (int)sender.tag;

        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.bounces = YES;
        scrollView.pagingEnabled = 1;
        scrollView.alwaysBounceHorizontal = 1;
        scrollView.delegate = self;
        scrollView.tag = 22;
        scrollView.directionalLockEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = 0;


        _arrayOfScrollview = [NSMutableArray arrayWithCapacity:self.arrayOfTakenPhotos.count];

        scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * self.arrayOfTakenPhotos.count, self.view.bounds.size.width);


        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, scrollView.frame.size.height - 20, scrollView.frame.size.width, 10)];
        [self.pageControl setNumberOfPages:_arrayOfTakenPhotos.count];
        [self.pageControl setCurrentPage:(index)];

        [scrollView setContentOffset:CGPointMake((self.view.frame.size.width * index), 0) animated:0];

        int count = (int)self.arrayOfTakenPhotos.count;

        for (id pictureOrDic in self.arrayOfTakenPhotos)
        {
            CGRect rect = CGRectMake(([self.arrayOfTakenPhotos indexOfObject:pictureOrDic] * self.view.bounds.size.width - 2) + 2, 0, self.view.frame.size.width, self.view.frame.size.height);

            if ([pictureOrDic isKindOfClass:[NSDictionary class]]) // VIDEO
            {
                NSDictionary *dic = (NSDictionary *)pictureOrDic;
                NSString *path = dic.allKeys.firstObject;
                NSURL *url = [NSURL fileURLWithPath:path];


                MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
                moviePlayer.view.frame = rect;
                moviePlayer.view.userInteractionEnabled = 1;
                [moviePlayer setScalingMode:MPMovieScalingModeAspectFill];

                moviePlayer.controlStyle = MPMovieControlStyleNone;
                [moviePlayer setFullscreen:1];
                [moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
                moviePlayer.view.layer.masksToBounds = YES;
                moviePlayer.view.contentMode = UIViewContentModeScaleToFill;
                moviePlayer.view.layer.cornerRadius = self.moviePlayer.view.frame.size.width/10;
                moviePlayer.view.layer.borderColor = [UIColor whiteColor].CGColor;
                moviePlayer.view.layer.borderWidth = 5;
                moviePlayer.view.layer.cornerRadius = 10;

    //          moviePlayer.repeatMode = MPMovieRepeatModeNone;
                moviePlayer.repeatMode = MPMovieRepeatModeOne;

                [moviePlayer prepareToPlay];

                UIButton *saveImageButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 40, 40)];

                saveImageButton.imageView.hidden = YES;

                [saveImageButton addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];

                [saveImageButton setImage:[UIImage imageNamed:ASSETS_CLOSE] forState:UIControlStateNormal];
                saveImageButton.backgroundColor = [UIColor volleyFamousGreen];
                saveImageButton.layer.masksToBounds = 1;
                saveImageButton.layer.cornerRadius = 5;
                saveImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
                saveImageButton.layer.borderWidth = 2;

                [moviePlayer.view addSubview:saveImageButton];

                if ([self.arrayOfTakenPhotos indexOfObject:pictureOrDic] != index)
                {
                    [moviePlayer setShouldAutoplay:NO];
                } else {
                    [moviePlayer play];
                    [moviePlayer stop];
                    [moviePlayer play];
                }

                [scrollView addSubview:moviePlayer.view];
                [self.arrayOfScrollview addObject:moviePlayer];

                count--;
                if (count == 0)
                {
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
                    [self.pop addGestureRecognizer:tap];

                    self.pop = [KLCPopup popupWithContentView:scrollView showType:KLCPopupShowTypeSlideInFromLeft dismissType:KLCPopupDismissTypeSlideOutToLeft maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:0 dismissOnContentTouch:0];
                    [self.pop show];
                    [self.pop addSubview:self.pageControl];
                }
            }
            else if ([pictureOrDic isKindOfClass:[UIImage class]])
            {
                UIImageView *popUpImageView;
                UIImage *image = (UIImage *)pictureOrDic;
                popUpImageView = [[UIImageView alloc] initWithFrame:rect];
                popUpImageView.image = image;
                popUpImageView.layer.masksToBounds = YES;
                popUpImageView.contentMode = UIViewContentModeScaleToFill;
                popUpImageView.layer.cornerRadius = popUpImageView.frame.size.width/10;
                popUpImageView.layer.borderColor = [UIColor whiteColor].CGColor;
                popUpImageView.layer.borderWidth = 5;
                popUpImageView.layer.cornerRadius = 10;
                popUpImageView.userInteractionEnabled = YES;

                UIButton *saveImageButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 40, 40)];

                saveImageButton.imageView.hidden = YES;

                [saveImageButton addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];

                [saveImageButton setImage:[UIImage imageNamed:ASSETS_CLOSE] forState:UIControlStateNormal];
                saveImageButton.backgroundColor = [UIColor volleyFamousGreen];
                saveImageButton.layer.masksToBounds = 1;
                saveImageButton.layer.cornerRadius = 5;
                saveImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
                saveImageButton.layer.borderWidth = 2;

                [popUpImageView addSubview:saveImageButton];

                [scrollView addSubview:popUpImageView];
                [self.arrayOfScrollview addObject:popUpImageView];

                count--;
                if (count == 0)
                {
                    self.pop = [KLCPopup popupWithContentView:scrollView showType:KLCPopupShowTypeSlideInFromLeft dismissType:KLCPopupDismissTypeSlideOutToLeft maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:0 dismissOnContentTouch:0];

                    [self.pop show];

                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
                    [self.pop addGestureRecognizer:tap];

                    [self.pop addSubview:self.pageControl];
                }
            //Hid it in the KLCPopup code.
            }
        }
    } //end for loop
}
//KLCPopup
- (void)didTap:(UITapGestureRecognizer *)tap
{
    [[UIApplication sharedApplication] setStatusBarHidden:1 withAnimation:UIStatusBarAnimationSlide];
    [self.pop dismiss:1];

    for (MPMoviePlayerController *object in self.arrayOfScrollview)
    {
        if ([object isKindOfClass:[MPMoviePlayerController class]])
        {
            [object stop];
        }
    }
    
    if (self.pop.isBeingDismissed) {
        self.pop = nil;
        self.arrayOfScrollview = nil;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 22)
    {

        CGFloat index = scrollView.contentOffset.x / self.view.frame.size.width;

        int xx = roundf(index);
        xx++;

        for (MPMoviePlayerController *object in self.arrayOfScrollview)
        {
            if ([object isKindOfClass:[MPMoviePlayerController class]])
            {
                [object stop];
            }
        }

        xx--;
        NSObject *object = [self.arrayOfScrollview objectAtIndex:xx];
        if ([object isKindOfClass:[MPMoviePlayerController class]])
        {
            MPMoviePlayerController *mp = [self.arrayOfScrollview objectAtIndex:xx];
            [mp play];
            [mp stop];
            [mp play];
        }
        //   UIView *view = [scrollView.subviews objectAtIndex:xx];

        [self.pageControl setCurrentPage:(xx)];
    }
}

-(void) moveImageUpToLatestBlank:(UIButton *)sender
{
    self.counterButton.titleLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.arrayOfTakenPhotos.count];
    if (self.movingImagePosition) {
        if (self.arrayOfTakenPhotos.count>=1){
            if ([[self.arrayOfTakenPhotos objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                NSArray * choice = [self.arrayOfTakenPhotos[0] allObjects];
                [self.savedButton1 setImage:choice[0] forState:UIControlStateNormal];
            } else {
                [self.savedButton1 setImage:self.arrayOfTakenPhotos[0] forState:UIControlStateNormal];
            }
        }
        
        if (self.arrayOfTakenPhotos.count>=2){
            if ([[self.arrayOfTakenPhotos objectAtIndex:1] isKindOfClass:[NSDictionary class]]) {
                NSArray * choice = [self.arrayOfTakenPhotos[1] allObjects];
                [self.savedButton2 setImage:choice[0] forState:UIControlStateNormal];
            } else {
                [self.savedButton2 setImage:self.arrayOfTakenPhotos[1] forState:UIControlStateNormal];
            }
        }
        
        if (self.arrayOfTakenPhotos.count>=3){
            if ([[self.arrayOfTakenPhotos objectAtIndex:2] isKindOfClass:[NSDictionary class]]) {
                NSArray * choice = [self.arrayOfTakenPhotos[2] allObjects];
                [self.savedButton3 setImage:choice[0] forState:UIControlStateNormal];
            } else {
                [self.savedButton3 setImage:self.arrayOfTakenPhotos[2] forState:UIControlStateNormal];
            }
        }
        
        if (self.arrayOfTakenPhotos.count>=4){
            if ([[self.arrayOfTakenPhotos objectAtIndex:3] isKindOfClass:[NSDictionary class]]) {
                NSArray * choice = [self.arrayOfTakenPhotos[3] allObjects];
                [self.savedButton4 setImage:choice[0] forState:UIControlStateNormal];
            } else {
                [self.savedButton4 setImage:self.arrayOfTakenPhotos[3] forState:UIControlStateNormal];
            }
        }
        
        if (self.arrayOfTakenPhotos.count>=5){
            if ([[self.arrayOfTakenPhotos objectAtIndex:4] isKindOfClass:[NSDictionary class]]) {
                NSArray * choice = [self.arrayOfTakenPhotos[4] allObjects];
                [self.savedButton5 setImage:choice[0] forState:UIControlStateNormal];
            } else {
                [self.savedButton5 setImage:self.arrayOfTakenPhotos[4] forState:UIControlStateNormal];
            }
        }
    } else {
        switch (sender.tag) {
            case 0:
                if (self.arrayOfTakenPhotos.count>=1){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[0] allObjects];
                        [self.savedButton1 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton1 setImage:self.arrayOfTakenPhotos[0] forState:UIControlStateNormal];
                    }
                }
                
                if (self.arrayOfTakenPhotos.count>=2){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:1] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[1] allObjects];
                        [self.savedButton2 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton2 setImage:self.arrayOfTakenPhotos[1] forState:UIControlStateNormal];
                    }
                }

                if (self.arrayOfTakenPhotos.count>=3){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:2] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[2] allObjects];
                        [self.savedButton3 setImage:choice[0]forState:UIControlStateNormal];
                    } else {
                        [self.savedButton3 setImage:self.arrayOfTakenPhotos[2] forState:UIControlStateNormal];
                    }
                }

                if (self.arrayOfTakenPhotos.count>=4){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:3] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[3] allObjects];
                        [self.savedButton4 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton4 setImage:self.arrayOfTakenPhotos[3] forState:UIControlStateNormal];
                    }
                }

                if (self.arrayOfTakenPhotos.count==5){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:4] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[4] allObjects];
                        [self.savedButton4 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton4 setImage:self.arrayOfTakenPhotos[4] forState:UIControlStateNormal];
                    }
                }

                break;
                
            case 1:
                if (self.arrayOfTakenPhotos.count>=2){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:1] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[1] allObjects];
                        [self.savedButton2 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton2 setImage:self.arrayOfTakenPhotos[1] forState:UIControlStateNormal];
                    }
                }
                
                if (self.arrayOfTakenPhotos.count>=3){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:2] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[2] allObjects];
                        [self.savedButton3 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton3 setImage:self.arrayOfTakenPhotos[2] forState:UIControlStateNormal];
                    }
                }
                
                if (self.arrayOfTakenPhotos.count>=4){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:3] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[3] allObjects];
                        [self.savedButton4 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton4 setImage:self.arrayOfTakenPhotos[3] forState:UIControlStateNormal];
                    }
                }
                
                if (self.arrayOfTakenPhotos.count==5){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:4] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[4] allObjects];
                        [self.savedButton5 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton5 setImage:self.arrayOfTakenPhotos[4] forState:UIControlStateNormal];
                    }
                }
                
                break;
                
            case 2:
                if (self.arrayOfTakenPhotos.count>=3){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:2] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[2] allObjects];
                        [self.savedButton3 setImage:choice[0]forState:UIControlStateNormal];
                    } else {
                        [self.savedButton3 setImage:self.arrayOfTakenPhotos[2] forState:UIControlStateNormal];
                    }
                }
                
                if (self.arrayOfTakenPhotos.count>=4){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:3] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[3] allObjects];
                        [self.savedButton4 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton4 setImage:self.arrayOfTakenPhotos[3] forState:UIControlStateNormal];
                    }
                }
                
                if (self.arrayOfTakenPhotos.count==5){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:4] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[4] allObjects];
                        [self.savedButton5 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton5 setImage:self.arrayOfTakenPhotos[4] forState:UIControlStateNormal];
                    }
                }
                
                break;
                
            case 3:
                if (self.arrayOfTakenPhotos.count>=4){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:3] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[3] allObjects];
                        [self.savedButton4 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton4 setImage:self.arrayOfTakenPhotos[3] forState:UIControlStateNormal];
                    }
                }
                
                if (self.arrayOfTakenPhotos.count==5){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:4] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[4] allObjects];
                        [self.savedButton5 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton5 setImage:self.arrayOfTakenPhotos[4] forState:UIControlStateNormal];
                    }
                }
                
                break;
                
            case 4:
                if (self.arrayOfTakenPhotos.count==5){
                    if ([[self.arrayOfTakenPhotos objectAtIndex:4] isKindOfClass:[NSDictionary class]]) {
                        NSArray * choice = [self.arrayOfTakenPhotos[4] allObjects];
                        [self.savedButton5 setImage:choice[0] forState:UIControlStateNormal];
                    } else {
                        [self.savedButton5 setImage:self.arrayOfTakenPhotos[4] forState:UIControlStateNormal];
                    }
                }
                
                break;
                
            default:
                break;
        }
    }

//    if (sender) {
//        if (sender == self.x1) {
//            [self.savedButton1 setImage:self.savedButton2.imageView.image forState:UIControlStateNormal];
//            [self.savedButton2 setImage:self.savedButton3.imageView.image forState:UIControlStateNormal];
//            [self.savedButton3 setImage:self.savedButton4.imageView.image forState:UIControlStateNormal];
//            [self.savedButton4 setImage:self.savedButton5.imageView.image forState:UIControlStateNormal];
//        } else if (sender == self.x2) {
//            [self.savedButton2 setImage:self.savedButton3.imageView.image forState:UIControlStateNormal];
//            [self.savedButton3 setImage:self.savedButton4.imageView.image forState:UIControlStateNormal];
//            [self.savedButton4 setImage:self.savedButton5.imageView.image forState:UIControlStateNormal];
//        } else if (sender == self.x3) {
//            [self.savedButton3 setImage:self.savedButton4.imageView.image forState:UIControlStateNormal];
//            [self.savedButton4 setImage:self.savedButton5.imageView.image forState:UIControlStateNormal];
//        } else if (sender == self.x4) {
//            [self.savedButton4 setImage:self.savedButton5.imageView.image forState:UIControlStateNormal];
//        }
//    }

    switch (self.arrayOfTakenPhotos.count) {
        case 4:
//            self.nextButton.hidden = NO;
            if (!self.movingImagePosition) {
                self.x1.hidden = NO;
                self.x2.hidden = NO;
                self.x3.hidden = NO;
                self.x4.hidden = NO;
            }
            self.x5.hidden = 1;
            self.savedButton1.hidden = NO;
            self.savedButton2.hidden = NO;
            self.savedButton3.hidden = NO;
            self.savedButton4.hidden = NO;
            self.savedButton5.hidden = 1;
            break;

        case 3:
//            self.nextButton.hidden = NO;
            if (!self.movingImagePosition) {
                self.x1.hidden = NO;
                self.x2.hidden = NO;
                self.x3.hidden = NO;
            }
            self.x4.hidden = 1;
            self.x5.hidden = 1;
            self.savedButton1.hidden = NO;
            self.savedButton2.hidden = NO;
            self.savedButton3.hidden = NO;
            self.savedButton4.hidden = 1;
            self.savedButton5.hidden = 1;
            break;

        case 2:
//            self.nextButton.hidden = NO;
            if (!self.movingImagePosition) {
                self.x1.hidden = NO;
                self.x2.hidden = NO;
            }
            self.x3.hidden = 1;
            self.x4.hidden = 1;
            self.x5.hidden = 1;
            self.savedButton1.hidden = NO;
            self.savedButton2.hidden = NO;
            self.savedButton3.hidden = 1;
            self.savedButton4.hidden = 1;
            self.savedButton5.hidden = 1;
            break;

        case 1:
//            self.nextButton.hidden = NO;
            if (!self.movingImagePosition) {
                self.x1.hidden = NO;
            }
            self.x2.hidden = 1;
            self.x3.hidden = 1;
            self.x4.hidden = 1;
            self.x5.hidden = 1;
            self.nextButton.hidden = NO;
            self.savedButton1.hidden = NO;
            self.savedButton2.hidden = 1;
            self.savedButton3.hidden = 1;
            self.savedButton4.hidden = 1;
            self.savedButton5.hidden = 1;
            break;

        case 0:
            self.nextButton.hidden = YES;
            self.counterButton.hidden = YES;
            self.x1.hidden = 1;
            self.x2.hidden = 1;
            self.x3.hidden = 1;
            self.x4.hidden = 1;
            self.x5.hidden = 1;
            self.savedButton1.hidden = 1;
            self.savedButton2.hidden = 1;
            self.savedButton3.hidden = 1;
            self.savedButton4.hidden = 1;
            self.savedButton5.hidden = 1;
            break;

        case 5:
//            self.nextButton.hidden = NO;
            self.x1.hidden = 0;
            self.x2.hidden = 0;
            self.x3.hidden = 0;
            self.x4.hidden = 0;
            self.x5.hidden = 0;
            self.savedButton1.hidden = 0;
            self.savedButton2.hidden = 0;
            self.savedButton3.hidden = 0;
            self.savedButton4.hidden = 0;
            self.savedButton5.hidden = 0;
            break;

        default:
            break;
    }
}

//NOT USED YET.....
- (void) loadImagesSaved
{
    if (_arrayOfTakenPhotos.count > 0)
    {
//        self.isReturningFromBackButton = NO;

        switch (self.arrayOfTakenPhotos.count) {
            case 1:
                self.savedButton1.hidden = NO;
                self.x1.hidden = NO;
                [self.savedButton1 setImage:_arrayOfTakenPhotos[0] forState:UIControlStateNormal];
                break;

            case 2:
                [self.savedButton1 setImage:_arrayOfTakenPhotos[0] forState:UIControlStateNormal];
                [self.savedButton2 setImage:_arrayOfTakenPhotos[1] forState:UIControlStateNormal];
                self.savedButton1.hidden = NO;
                self.x1.hidden = NO;
                self.savedButton2.hidden = NO;
                self.x2.hidden = NO;
                break;

            case 3:
                [self.savedButton1 setImage:_arrayOfTakenPhotos[0] forState:UIControlStateNormal];
                [self.savedButton2 setImage:_arrayOfTakenPhotos[1] forState:UIControlStateNormal];
                [self.savedButton3 setImage:_arrayOfTakenPhotos[2] forState:UIControlStateNormal];
                self.savedButton1.hidden = NO;
                self.x1.hidden = NO;
                self.savedButton2.hidden = NO;
                self.x2.hidden = NO;
                self.savedButton3.hidden = NO;
                self.x3.hidden = NO;
                break;

            case 4:
                [self.savedButton1 setImage:_arrayOfTakenPhotos[0] forState:UIControlStateNormal];
                [self.savedButton2 setImage:_arrayOfTakenPhotos[1] forState:UIControlStateNormal];
                [self.savedButton3 setImage:_arrayOfTakenPhotos[2] forState:UIControlStateNormal];
                [self.savedButton4 setImage:_arrayOfTakenPhotos[3] forState:UIControlStateNormal];
                break;
                
            case 5:
                [self.savedButton1 setImage:_arrayOfTakenPhotos[0] forState:UIControlStateNormal];
                [self.savedButton2 setImage:_arrayOfTakenPhotos[1] forState:UIControlStateNormal];
                [self.savedButton3 setImage:_arrayOfTakenPhotos[2] forState:UIControlStateNormal];
                [self.savedButton4 setImage:_arrayOfTakenPhotos[3] forState:UIControlStateNormal];
                [self.savedButton5 setImage:_arrayOfTakenPhotos[4] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
    }
}

-(void)createViewForImagePositionChange:(UIButton *)sender atPoint:(CGPoint)point
{
//    sender.hidden = YES;
    self.movingImagePosition = YES;
    self.movingImage = [[UIImageView alloc]initWithFrame:sender.frame];
    self.movingImage.layer.masksToBounds = YES;
    self.movingImage.layer.cornerRadius = 10;
    self.movingImage.layer.borderWidth = 3;
    self.movingImage.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.movingImage setContentMode:UIViewContentModeScaleAspectFill];
    self.movingImage.center = point;
    if ([[self.arrayOfTakenPhotos objectAtIndex:sender.tag] isKindOfClass:[NSDictionary class]]) {
        NSArray * choice = [self.arrayOfTakenPhotos[sender.tag] allObjects];
        [self.movingImage setImage:choice[0]];
    } else {
        [self.movingImage setImage:self.arrayOfTakenPhotos[sender.tag]];
    }
    self.objectSelectedForOrderChange = self.arrayOfTakenPhotos[sender.tag];
    [self.view addSubview:self.movingImage];
}

- (UIImage*) drawImage:(UIImage*) fgImage
              inImage:(UIImage*) bgImage
              atPoint:(CGPoint)  point
{
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
    [fgImage drawInRect:CGRectMake( point.x, point.y, fgImage.size.width, fgImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

-(void)blankOutButtons
{
    self.arrayOfTakenPhotos = [NSMutableArray new];
    self.savedButton1.hidden = YES;
    self.savedButton2.hidden = YES;
    self.savedButton3.hidden = YES;
    self.savedButton4.hidden = YES;
    self.savedButton5.hidden = YES;
    self.x1.hidden = YES;
    self.x2.hidden = YES;
    self.x3.hidden = YES;
    self.x4.hidden = YES;
    self.x5.hidden = YES;
    self.nextButton.hidden = YES;
    self.counterButton.hidden = YES;
}

@end
