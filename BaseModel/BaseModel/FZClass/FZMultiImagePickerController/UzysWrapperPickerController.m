#import "UzysWrapperPickerController.h"

@interface UzysWrapperPickerController ()

@end

@implementation UzysWrapperPickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -  View Controller Setting /Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}
- (UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
