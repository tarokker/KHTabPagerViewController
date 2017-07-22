//
//  ViewController.m
//  KHTabPagerViewControllerExample
//
//  Created by Kareem Hewady on 9/3/15.
//  Copyright (c) 2015 K H. All rights reserved.
//

#import "ViewController.h"

@interface DemoCtl : UIViewController
@property(nonatomic, strong) UILabel *lblTest;
@end

@implementation DemoCtl

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Loading controller view");
    if ( !_lblTest )
    {
        _lblTest = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
        _lblTest.text = @"prova";
        [self.view addSubview:_lblTest];
    }
}

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

#define TOT_CTLS 3

@interface ViewController () <KHTabPagerDataSource>
{
@private
    NSInteger _changeLabelCount;
    DemoCtl *democtls[TOT_CTLS];
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _changeLabelCount = 0;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.title = NSLocalizedString(@"Tab Pager",nil);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
       
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc] initWithTitle:@"CFGLabel" style:UIBarButtonItemStylePlain target:self action:@selector(changeLabel)];
    self.navigationItem.leftBarButtonItem = button1;

    
    [self setDataSource:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)changeLabel
{
    ++_changeLabelCount;
    [self reloadTabs];
}

#pragma mark - KHTabPagerDataSource
- (NSInteger)numberOfViewControllers {
    return 38;
}

- (UIViewController *)viewControllerForIndex:(NSInteger)index
{
    NSInteger real_index = index % TOT_CTLS;
    if ( !democtls[real_index] )
    {
        democtls[real_index] = [DemoCtl new];
        [[democtls[real_index] view] setBackgroundColor:[UIColor colorWithRed:arc4random_uniform(255) / 255.0f
                                                      green:arc4random_uniform(255) / 255.0f
                                                       blue:arc4random_uniform(255) / 255.0f alpha:1]];
    }
    democtls[real_index].lblTest.text = [NSString stringWithFormat:@"prova: %ld", (long)index];
    return democtls[real_index];
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
            return [NSString stringWithFormat:@"Test: %ld", (long)index];
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
/*
- (UIColor *)tabColor {
    return [UIColor whiteColor];
}
*/
-(UIColor *)tabBackgroundColor {
    return [UIColor colorWithRed:1.0f/255.0f green:87.0f/255.0f blue:155.0f/255.0f alpha:1];
}
/*
-(UIColor *)titleColor {
    return [UIColor whiteColor];
}


-(UIFont *)titleFont {
    return [UIFont systemFontOfSize:18];
}
*/


@end
