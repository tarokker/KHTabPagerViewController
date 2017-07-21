//
//  ViewController.m
//  KHTabPagerViewControllerExample
//
//  Created by Kareem Hewady on 9/3/15.
//  Copyright (c) 2015 K H. All rights reserved.
//

#import "ViewController.h"

@interface DemoCtl : UIViewController

@end

@implementation DemoCtl

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"View Will Appear");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"View DID Appear");
}

@end
@interface ViewController () <KHTabPagerDataSource, KHTabPagerDelegate>
{
@private
    NSInteger _changeLabelCount;
}
@property (assign, nonatomic) BOOL isProgressive;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _changeLabelCount = 0;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.title = NSLocalizedString(@"Tab Pager",nil);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Progressive" style:UIBarButtonItemStylePlain target:self action:@selector(switchProgressive)];
    self.navigationItem.rightBarButtonItem = button;
    
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc] initWithTitle:@"CFGLabel" style:UIBarButtonItemStylePlain target:self action:@selector(changeLabel)];
    self.navigationItem.leftBarButtonItem = button1;
    
    self.isProgressive = YES;
    
    [self setDataSource:self];
    [self setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchProgressive {
    [self.navigationItem.rightBarButtonItem setTitle: self.isProgressive ?  @"Not Progressive" : @"Progressive" ];
    self.isProgressive = !self.isProgressive;
}

- (void)changeLabel
{
    ++_changeLabelCount;
    [self reloadTabs];
}

#pragma mark - KHTabPagerDataSource
- (NSInteger)numberOfViewControllers {
    return 4;
}

- (UIViewController *)viewControllerForIndex:(NSInteger)index {
    DemoCtl *vc = [DemoCtl new];
    [[vc view] setBackgroundColor:[UIColor colorWithRed:arc4random_uniform(255) / 255.0f
                                                  green:arc4random_uniform(255) / 255.0f
                                                   blue:arc4random_uniform(255) / 255.0f alpha:1]];
    return vc;
}

// Implement either viewForTabAtIndex: or titleForTabAtIndex:
//- (UIView *)viewForTabAtIndex:(NSInteger)index {
//  return <#UIView#>;
//}

- (NSString *)titleForTabAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return NSLocalizedString(@"Tab #1",nil);
        case 1:
            return NSLocalizedString(@"Very Long Tab #2",nil);
        case 2:
            return [NSString stringWithFormat:NSLocalizedString(@"T #3 %d",nil), _changeLabelCount];
        case 3:
            return NSLocalizedString(@"Tab #4",nil);
        default:
            return nil;
    }
}

/*
- (CGFloat)tabHeight {
    // Default: 48.0f
    return 40.0f;
}
*/

- (CGFloat)tabBarTopViewHeight {
    //Default 0.0f;
    return 50.0f;
}

- (UIView *)tabBarTopView {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"tabBarTopView" owner:self options:nil] objectAtIndex:0];
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y , self.view.frame.size.width, view.frame.size.height);
    view.autoresizingMask = UIViewAutoresizingNone;
    return view;
}

- (UIColor *)tabColor {
    return [UIColor whiteColor];
}

-(UIColor *)tabBackgroundColor {
    return [UIColor colorWithRed:1.0f/255.0f green:87.0f/255.0f blue:155.0f/255.0f alpha:1];
}

-(UIColor *)titleColor {
    return [UIColor whiteColor];
}

/*
-(UIFont *)titleFont {
    return [UIFont systemFontOfSize:18];
}
*/

-(BOOL)isProgressiveTabBar{
    return self.isProgressive;
}

#pragma mark - Tab Pager Delegate

- (void)tabPager:(KHTabPagerViewController *)tabPager willTransitionToTabAtIndex:(NSInteger)index {
    NSLog(@"Will transition from tab %ld to %ld", [self selectedIndex], (long)index);
}

- (void)tabPager:(KHTabPagerViewController *)tabPager didTransitionToTabAtIndex:(NSInteger)index {
    NSLog(@"Did transition to tab %ld", (long)index);
}

@end
