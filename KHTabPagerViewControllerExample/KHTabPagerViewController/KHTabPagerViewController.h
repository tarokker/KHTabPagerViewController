//
//  KHTabPagerViewController.h
//  KHTabPagerViewControllerExample
//
//  Created by Kareem Hewady on 9/3/15.
//  Copyright (c) 2015 K H. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KHTabPagerDataSource;

@interface KHTabPagerViewController : UIViewController

@property (weak, nonatomic) id<KHTabPagerDataSource> dataSource;

- (void)reloadData;
- (void)reloadTabs;
- (NSInteger)selectedIndex;

- (void)selectTabbarIndex:(NSInteger)index animation:(BOOL)animation;

@property (assign, nonatomic) BOOL enableTapClickAnimation;

@end

@protocol KHTabPagerDataSource <NSObject>

@required
- (NSInteger)numberOfViewControllers;
- (UIViewController *)viewControllerForIndex:(NSInteger)index;

@optional
- (UIView *)viewForTabAtIndex:(NSInteger)index;
- (NSString *)titleForTabAtIndex:(NSInteger)index;
- (CGFloat)tabHeight;
- (UIColor *)tabColor;
- (UIColor *)tabBackgroundColor;
- (UIFont *)titleFont;
- (UIColor *)titleColor;
- (CGFloat)tabBarTopViewHeight;
- (UIView *)tabBarTopView;

@end

