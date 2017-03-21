//
//  HYGDotSegcontrol.h
//  Pods
//
//  Created by 金秋实 on 1/15/16.
//
//

#import <UIKit/UIKit.h>

@class HYGDotSegcontrol;
@class HYGHallTabIndexItem;

@protocol HYGDotSegcontrolDelegate <NSObject>

- (void)hygDotSegcontrol:(HYGDotSegcontrol *)dotSegcontrol selectSegmentedControlIndex:(NSUInteger)index;

- (void)hygShowDropDownMenuViewWithIndex:(NSUInteger)index;

@end

@interface HYGDotSegcontrol : UIView

@property (nonatomic, weak) id<HYGDotSegcontrolDelegate> delegate;

/**
 *  人气推荐tab的index number
 */
@property (nonatomic, assign) NSInteger indexOfDropDownMenu;

@property (nonatomic, assign) UIEdgeInsets contentInsets;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIColor *selectedTextColor;

@property (nonatomic, assign) CGFloat underLineHeight;

@property (nonatomic, assign) CGFloat underLineLength;

@property (nonatomic, strong) UIColor *underLineColor;

@property (nonatomic, assign) BOOL showTopSeperatorLine;

@property (nonatomic, assign) BOOL showBottomSeperatorLine;

@property (nonatomic, assign) NSInteger selectedSegmentIndex;

- (instancetype)initWithFrame:(CGRect)frame sectionTitles:(NSArray *)sectionTitles;

- (instancetype)initWithFrame:(CGRect)frame
                sectionTitles:(NSArray *)sectionTitles
          indexOfDropDownMenu:(NSInteger)indexOfDropDownMenu;

- (void)setSectionTitles:(NSArray<NSString *> *)sectionTitles;

- (void)setDotIndex:(NSUInteger)dotIndex;

- (void)hideAllDotIndex;

- (void)hideDotIndex:(NSUInteger)dotIndex;

- (void)setDotSegmentImageUp;

- (void)setDotSegmentImageDown;

- (void)setCurrentDotSegmentSelected;

- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 *通过代码方式设置index时,模拟用户主动设置动作,调用回调方法
 *@param notify 是否调用回调方法,默认为NO
 */
- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated notify:(BOOL)notify;

@end

@interface HYGDotSegment : UIButton

@property (nonatomic, assign) BOOL isDropDownButton;

- (void)showDot;

- (void)hideDot;

- (void)setTextFont:(UIFont *)font;

- (void)setRedArrowImageDown;
- (void)setRedArrowImageUp;
- (void)setRedArrowImageGray;

@end
