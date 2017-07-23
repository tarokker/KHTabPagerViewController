//
//  KHTabPagerViewController.m
//  KHTabPagerViewControllerExample
//
//  Created by Kareem Hewady on 9/3/15.
//  Copyright (c) 2015 K H. All rights reserved.
//


#import "KHTabPagerViewController.h"
#import "KHTabScrollView.h"
#import <objc/runtime.h>

@interface KHTabPagerViewController () <KHTabScrollDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>
{
    BOOL tapped;
}

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIScrollView *pageScrollView;
@property (strong, nonatomic) KHTabScrollView *header;
@property (assign, nonatomic) NSInteger selectedIndex;

@property (strong, nonatomic) UIColor *headerColor;
@property (strong, nonatomic) UIColor *tabBackgroundColor;
@property (assign, nonatomic) CGFloat headerHeight;
@property (assign, nonatomic) BOOL isTransitionInProgress;
@property (assign, nonatomic) CGFloat headerPadding;
@property (strong, nonatomic) UIView *headerTopView;

- (void)_refreshTabColorsAfterAppearing;
- (UIViewController *)_requestViewControllerForIndex:(NSInteger)i;

@end

@implementation KHTabPagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self setPageViewController:[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                              options:nil]];
    
    for (UIView *view in [[[self pageViewController] view] subviews]) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView = (UIScrollView *)view;
            [self.pageScrollView setCanCancelContentTouches:YES];
            [self.pageScrollView setDelaysContentTouches:NO];
            [self.pageScrollView setBounces:NO]; // Maio
            [self.pageScrollView setDelegate:self];
        }
    }
    
    tapped = false;
    
    [[self pageViewController] setDataSource:self];
    [[self pageViewController] setDelegate:self];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self reloadTabs];
    [self selectTabbarIndex:self.selectedIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

# pragma mark - Private Methods

// Maio - chiamato dopo che ci siamo spostati su un tab
- (void)_refreshTabColorsAfterAppearing
{
    for ( NSInteger c = 0; c < [[_header tabViews] count]; c++ )
    {
        [[_header tabViews][c] setAlpha:c == _selectedIndex ? 1.0 : 0.4];
    }
}

- (UIViewController *)_requestViewControllerForIndex:(NSInteger)i
{
    // chiediamo controllr
    UIViewController *viewController = nil;
    
    if ((viewController = [[self dataSource] viewControllerForIndex:i]) != nil)
    {
        // Maio - injectiamo l'indice del controller
        objc_setAssociatedObject(viewController, @"__KHTabPagerViewController_index__", @(i), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return viewController;
}

#pragma mark - Page View Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger pageIndex = [objc_getAssociatedObject(viewController, @"__KHTabPagerViewController_index__") integerValue];
    return pageIndex > 0 ? [self _requestViewControllerForIndex:pageIndex - 1] : nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger pageIndex = [objc_getAssociatedObject(viewController, @"__KHTabPagerViewController_index__") integerValue];
    return pageIndex < [[self dataSource] numberOfViewControllers] - 1 ? [self _requestViewControllerForIndex:pageIndex + 1] : nil;
}

#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    self.isTransitionInProgress = YES;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [self setSelectedIndex:[objc_getAssociatedObject([[self pageViewController] viewControllers][0], @"__KHTabPagerViewController_index__") integerValue]];
    [[self header] animateToTabAtIndex:[self selectedIndex]];
    self.isTransitionInProgress = NO;

    // maio
    [self _refreshTabColorsAfterAppearing];
}

- (void)reloadData
{
    [self reloadTabs];
    
    CGRect frame = [[self view] frame];
    frame.origin.y = [self headerHeight] + [self headerPadding];
    frame.size.height -= [self headerHeight] + [self headerPadding];
    
    [[[self pageViewController] view] setFrame:frame];
    
    [self.pageViewController setViewControllers:@[[self _requestViewControllerForIndex:_selectedIndex]]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:NO
                                     completion:nil];
}

- (void)reloadTabs {
    if ([[self dataSource] numberOfViewControllers] == 0)
        return;
    
    if ([[self dataSource] respondsToSelector:@selector(tabHeight)]) {
        [self setHeaderHeight:[[self dataSource] tabHeight]];
    } else {
        [self setHeaderHeight:48.0];
    }
    
    if ([[self dataSource] respondsToSelector:@selector(tabColor)]) {
        [self setHeaderColor:[[self dataSource] tabColor]];
    } else {
        [self setHeaderColor:[UIColor whiteColor]];
    }
    
    if ([[self dataSource] respondsToSelector:@selector(tabBackgroundColor)]) {
        [self setTabBackgroundColor:[[self dataSource] tabBackgroundColor]];
    } else {
        [self setTabBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    }
    
    if ([[self dataSource] respondsToSelector:@selector(tabBarTopViewHeight)]) {
        [self setHeaderPadding:[[self dataSource] tabBarTopViewHeight]];
    } else {
        [self setHeaderPadding:0];
    }
    
    if ([[self dataSource] respondsToSelector:@selector(tabBarTopView)]) {
        UIView *view = [[self dataSource] tabBarTopView];
        view.tag = 666; //Dirty way to remove the view later on. Please change
        [self setHeaderTopView:view];
    } else {
        [self setHeaderTopView:nil];
    }
    
    NSMutableArray *tabViews = [NSMutableArray array];
    
    if ([[self dataSource] respondsToSelector:@selector(viewForTabAtIndex:)]) {
        for (int i = 0; i < [[self dataSource] numberOfViewControllers]; i++) {
            UIView *view;
            if ((view = [[self dataSource] viewForTabAtIndex:i]) != nil) {
                [tabViews addObject:view];
            }
        }
    } else {
        UIFont *font;
        if ([[self dataSource] respondsToSelector:@selector(titleFont)]) {
            font = [[self dataSource] titleFont];
        } else {
            font = [UIFont boldSystemFontOfSize:16.0];
        }
        
        UIColor *color;
        if ([[self dataSource] respondsToSelector:@selector(titleColor)]) {
            color = [[self dataSource] titleColor];
        } else {
            color = [UIColor whiteColor];
        }
        
        // Maio: cambiato il loop per rileggere in tempo reale il titolo dei tabs
        for (int i = 0; i < [[self dataSource] numberOfViewControllers]; i++) {
            if ([[self dataSource] respondsToSelector:@selector(titleForTabAtIndex:)]) {
                NSString *title;
                if ((title = [[self dataSource] titleForTabAtIndex:i]) != nil) {
                    UILabel *label = [UILabel new];
                    [label setText:title];
                    [label setTextAlignment:NSTextAlignmentCenter];
                    [label setFont:font];
                    [label setTextColor:color];
                    [label sizeToFit];
                    
                    CGRect frame = [label frame];
                    frame.size.width = MAX(frame.size.width + 20, 85);
                    [label setFrame:frame];
                    [tabViews addObject:label];
                }
            }
        }
    }
    
    if ([self header]) {
        [[self header] removeFromSuperview];
    }
    
    if ([self headerTopView]) {
        for (UIView *view in self.view.subviews) {
            if (view.tag == 666) {
                [view removeFromSuperview];
            }
        }
    }
    
    CGRect frame = self.view.frame;
    frame.origin.y = [self headerPadding];
    frame.size.height = [self headerHeight];
    [self setHeader:[[KHTabScrollView alloc] initWithFrame:frame tabViews:tabViews tabBarHeight:[self headerHeight] tabBarTopViewHeight:[self headerPadding] tabColor:[self headerColor] backgroundColor:[self tabBackgroundColor] selectedTabIndex:self.selectedIndex]];
    [[self header] setTabScrollDelegate:self];
    
    [[self view] addSubview:[self header]];
    [[self view] addSubview:[self headerTopView]];
    
    // Maio
    [self _refreshTabColorsAfterAppearing];
}

#pragma mark - Tab Scroll View Delegate

-(BOOL)shouldAllowTapOnScrollView:(KHTabScrollView *)tabScrollView {
    return (!self.isTransitionInProgress && !self.pageScrollView.isTracking && !self.pageScrollView.isDragging && !self.pageScrollView.isDecelerating);
}

- (void)tabScrollView:(KHTabScrollView *)tabScrollView didSelectTabAtIndex:(NSInteger)index
{
    if (index != [self selectedIndex] && !self.isTransitionInProgress)
    {
        __weak KHTabPagerViewController *weakSelf = self;
        self.pageScrollView.scrollEnabled = NO;
        tapped = true;
        UIPageViewControllerNavigationDirection direction = (index > [self selectedIndex]) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
        [[self pageViewController] setViewControllers:@[[self _requestViewControllerForIndex:index]]
                                             direction:direction
                                              animated:YES
                                            completion:^(BOOL finished) {
                                                [weakSelf setSelectedIndex:index];
                                                
                                                // maio
                                                [weakSelf _refreshTabColorsAfterAppearing];

                                                weakSelf.pageScrollView.scrollEnabled = YES;
                                            }];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    float progress = 0;
    NSInteger fromIndex = self.selectedIndex;
    NSInteger toIndex = -1;
    progress = (offset.x - self.view.bounds.size.width) / self.view.bounds.size.width;

    if (progress > 0)
    {
        if (fromIndex < [[self dataSource] numberOfViewControllers] - 1)
        {
            toIndex = fromIndex + 1;
        }
    }
    else
    {
        if (fromIndex > 0)
        {
            toIndex = fromIndex - 1;
        }
    }
    if (!tapped)
    {
        [[self header] animateFromTabAtIndex:fromIndex toTabAtIndex:toIndex withProgress:progress];
    }
    else if (fabs(progress) >= 0.999999 || fabs(progress) <= 0.000001)
        tapped = false;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isTransitionInProgress = YES;
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.isTransitionInProgress = NO;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.isTransitionInProgress = NO;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isTransitionInProgress = NO;
}

#pragma mark - Public Methods

- (void)selectTabbarIndex:(NSInteger)index {
    [self selectTabbarIndex:index animation:NO];
}

- (void)selectTabbarIndex:(NSInteger)index animation:(BOOL)animation
{
    [self.pageViewController setViewControllers:@[[self _requestViewControllerForIndex:index]]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:animation
                                     completion:nil];
    [[self header] animateToTabAtIndex:index animated:animation];
    [self setSelectedIndex:index];
    // Maio
    [self _refreshTabColorsAfterAppearing];
}

@end
