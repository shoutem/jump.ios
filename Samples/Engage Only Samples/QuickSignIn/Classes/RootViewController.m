#import "RootViewController.h"
#import "debug_log.h"

@interface RootViewController ()

@end

@implementation RootViewController
@synthesize jrChildNavController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)loadView
{
    self.wantsFullScreenLayout = YES;
    [super setView:[[[UIView alloc] init] autorelease]];
    [super view].autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //return NO;
    BOOL b = [jrChildNavController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    DLog("%d", b);
    return b;
}

- (BOOL)shouldAutorotate
{
    BOOL b = YES;
    if ([[self modalViewController] respondsToSelector:@selector(shouldAutorotate)])
        b = [[self modalViewController] shouldAutorotate];
    else if ([jrChildNavController respondsToSelector:@selector(shouldAutorotate)])
        b = [jrChildNavController shouldAutorotate];
    DLog(@"should: %i", b);
    return b;
}



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    //DLog(@"toOrientation: %i duration: %f", toInterfaceOrientation, duration);
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [jrChildNavController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    //DLog(@"toOrientation: %i duration: %f", toInterfaceOrientation, duration);
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [jrChildNavController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //DLog(@"fromOrientation: %i", fromInterfaceOrientation);
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [jrChildNavController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view sizeToFit];
    [self.view setNeedsLayout];
    [jrChildNavController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [jrChildNavController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [jrChildNavController viewDidDisappear:animated];
}

- (void)dealloc
{
    [jrChildNavController release];
    [super dealloc];
}

@end

@interface UINavigationController(IOS6Autorotation)
@end

@implementation UINavigationController(IOS6Autorotation)
- (BOOL)shouldAutorotate
{
    BOOL b = [[self visibleViewController] shouldAutorotate];
    DLog(@"should: %i with %@", b, [[self visibleViewController] description]);
    return b;
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger i = [[self visibleViewController] supportedInterfaceOrientations];
    DLog(@"supported: %i", i);
    return i;
}

@end
