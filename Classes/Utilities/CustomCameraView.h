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

@interface CustomCameraView : UIViewController

@property(nonatomic,assign)id delegate;

-(id)initWithPopUp:(BOOL)popup;

-(void)setPopUp;

-(void)unhideButtons;

@property (strong, nonatomic) MasterScrollView *scrollView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *savedButtons;

@property BOOL isReturningFromBackButton;

@property NSMutableArray *arrayOfTakenPhotos;
@property NSMutableArray *arrayOfScrollview;

@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;
@property (weak, nonatomic) IBOutlet UIButton *savedButton1;
@property (weak, nonatomic) IBOutlet UIButton *savedButton2;
@property (weak, nonatomic) IBOutlet UIButton *savedButton3;
@property (weak, nonatomic) IBOutlet UIButton *savedButton4;
@property (weak, nonatomic) IBOutlet UIButton *savedButton5;

@property (atomic) BOOL isPoppingUp;

@property (weak, nonatomic) IBOutlet UIButton *x1;
@property (weak, nonatomic) IBOutlet UIButton *x2;
@property (weak, nonatomic) IBOutlet UIButton *x3;
@property (weak, nonatomic) IBOutlet UIButton *x4;
@property (weak, nonatomic) IBOutlet UIButton *x5;

-(void) moveImageUpToLatestBlank:(UIButton *)sender;

@end
