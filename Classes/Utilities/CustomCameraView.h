//
//  AddRecommendationViewController.h
//  Recommend
//

#import "CustomCameraView.h"
#import <UIKit/UIKit.h>
#import "MessagesView.h"
#import "MasterScrollView.h"

#pragma mark - DELEGATE
@protocol CustomCameraDelegate <NSObject>
-(void)sendBackPictures:(NSArray *)images withBool:(bool)didTakePicture andComment:(NSString *)comment;
@end

@protocol SecondDelegate <NSObject>
-(void) secondViewControllerDismissed:(NSMutableArray *)photosForFirst;
@end

@protocol PushToCardDelegate <NSObject>
-(void) pushToCard;
@end

@interface CustomCameraView : UIViewController
{
//    id                              myDelegate;
}
@property (nonatomic, assign) id<SecondDelegate>    myDelegate;
@property (nonatomic, assign) id<PushToCardDelegate> pushToCardDelegate;
@property(nonatomic,assign)id delegate;

-(id)initWithPopUp:(BOOL)popup;

-(void)setPopUp;

-(void)unhideButtons;

@property (strong, nonatomic) MasterScrollView *scrollView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *savedButtons;

@property BOOL isReturningFromBackButton;
@property BOOL sentToNewVollie;

@property NSMutableArray *arrayOfTakenPhotos;
@property NSMutableArray *arrayOfScrollview;

@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;
@property (weak, nonatomic) IBOutlet UIButton *savedButton1;
@property (weak, nonatomic) IBOutlet UIButton *savedButton2;
@property (weak, nonatomic) IBOutlet UIButton *savedButton3;
@property (weak, nonatomic) IBOutlet UIButton *savedButton4;
@property (weak, nonatomic) IBOutlet UIButton *savedButton5;

@property (atomic) BOOL isPoppingUp;

//kyle's new VC properties:
@property (atomic) BOOL comingFromNewVollie;
@property NSString *textFromLastVC;
@property NSString *messageText;
@property NSMutableArray *photosFromNewVC;

@property (weak, nonatomic) IBOutlet UIButton *x1;
@property (weak, nonatomic) IBOutlet UIButton *x2;
@property (weak, nonatomic) IBOutlet UIButton *x3;
@property (weak, nonatomic) IBOutlet UIButton *x4;
@property (weak, nonatomic) IBOutlet UIButton *x5;

-(void) moveImageUpToLatestBlank:(UIButton *)sender;
-(void) freezeCamera;
-(void)blankOutButtons;
-(void)loadImagesSaved;

@end
