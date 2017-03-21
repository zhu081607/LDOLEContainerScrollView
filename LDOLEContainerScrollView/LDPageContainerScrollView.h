//
//  LDPageContainerScrollView.h
//  LDHYG
//
//  Created by asshole on 16/4/18.
//  Copyright © 2016年 caipiao. All rights reserved.
//

/**************************************************************
**  Use this scrollView to hold the tableViews
**  deal with scroll logic for this container in the contentView
***************************************************************/

@import UIKit;

@class HMSegmentedControl, LDPageContainerScrollView;
@protocol LDPageContainerScrollViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface LDPageContainerScrollView : UIScrollView

@property (nonatomic, strong, readonly) NSArray <__kindof UIScrollView *> *childTableViews;
@property (nonatomic, assign, readonly) NSUInteger currentIndex;
@property (nonatomic, strong, readonly) HMSegmentedControl *segControl;
@property (nonatomic, weak) id <LDPageContainerScrollViewDelegate> pageContainerScrollViewdelegate;
/**
 TopMargin of the floating position
 */
@property (nonatomic, assign) CGFloat segControlFloatingTopMargin;

- (instancetype)initWithFrame:(CGRect)frame
                sectionTitles:(NSArray<NSString *> *)sectionTitles NS_DESIGNATED_INITIALIZER;

/**
 Scroll to a tableView.
 
 @param index the index of the tableView
 @param animated with or without animation
 */
- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 Set the tableViews in the containerScrollView.
 
 @param childTableViews the scrollViews in the containerScrollView
 */
- (void)setTableViews:(NSArray <__kindof UIScrollView *> *)childTableViews;

/**
 Sets titles of the segControl.
 
 @param sectionTitles
 */
- (void)setSegcontrolTitles:(NSArray<NSString *> *)sectionTitles;

@end


@protocol LDPageContainerScrollViewDelegate <NSObject>

@optional
/**
 This delegate method will be called when segmentcontrol is selected.
 
 @param scrollView self
 @param index      the selected index
 */
- (void)containerScrollView:(LDPageContainerScrollView *)scrollView
selectSegmentedControlIndex:(NSUInteger)index;

/**
 This delegate method will be called when the selected index of segmentcontrol changed.
 
 @param scrollView self
 @param newIndex      the selected index
 @param oldIndex      the previous selected index
 */
- (void)containerScrollView:(LDPageContainerScrollView *)scrollView
selectedIndexChangedNewIndex:(NSUInteger)newIndex
                    oldIndex:(NSUInteger)oldIndex;

@end

NS_ASSUME_NONNULL_END
