//
//  HYGDotSegcontrol.m
//  Pods
//
//  Created by 金秋实 on 1/15/16.
//
//

#import "HYGDotSegcontrol.h"

static NSString * const keyItemTitle = @"title";
static NSString * const keyItemWidth = @"width";
static NSString * const keyItemDropDownSegCtl = @"drop_down_segment_control";
static NSString * const keyItemLinkFlag = @"link_flag";
static NSString * const keyItemUserInfo = @"user_info";

@interface HYGDotSegcontrol ()

@property (nonatomic, strong) NSMutableArray *itemArray;

@property (nonatomic, strong) NSMutableArray *segmentArray;

@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, strong) UIView *topSeperatorLine;
@property (nonatomic, strong) UIView *bottomSeperatorLine;

@end

@implementation HYGDotSegcontrol

- (instancetype)initWithFrame:(CGRect)frame
                sectionTitles:(NSArray *)sectionTitles
          indexOfDropDownMenu:(NSInteger)indexOfDropDownMenu
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!sectionTitles || [sectionTitles count] == 0) {
            return nil;
        }
        
        self.selectedSegmentIndex = 0;
        self.itemArray = [NSMutableArray array];
        
        for (NSString *title in sectionTitles) {
            if ([title isKindOfClass:[NSString class]]) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:title forKey:keyItemTitle];
                [self.itemArray addObject:dict];
            }
        }
        
        if (indexOfDropDownMenu > sectionTitles.count - 1) {
            self.indexOfDropDownMenu = NSNotFound;
        } else {
            self.indexOfDropDownMenu = indexOfDropDownMenu;
        }
        
        self.segmentArray = [NSMutableArray array];
        self.underLineView = [[UIView alloc] init];
        
        _topSeperatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1.0/[UIScreen mainScreen].scale)];
        self.topSeperatorLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.topSeperatorLine.backgroundColor = [UIColor colorWithRed:0xec / 255.0 green:0xec / 255.0 blue:0xec / 255.0 alpha:1.0];
        self.topSeperatorLine.hidden = YES;
        [self addSubview:self.topSeperatorLine];
        
        _bottomSeperatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 1.0/[UIScreen mainScreen].scale, CGRectGetWidth(self.frame), 1.0/[UIScreen mainScreen].scale)];
        self.bottomSeperatorLine.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        self.bottomSeperatorLine.backgroundColor = [UIColor colorWithRed:0xec / 255.0 green:0xec / 255.0 blue:0xec / 255.0 alpha:1.0];
        self.bottomSeperatorLine.hidden = YES;
        [self addSubview:self.bottomSeperatorLine];
        
        [self setTextColor:[UIColor blackColor]];
        [self setSelectedTextColor:[UIColor blackColor]];
        [self setunderLineHeight:2.5];
        [self setUnderLineLength:CGRectGetWidth(self.bounds)/[sectionTitles count]];
        
        [self addSubview:self.underLineView];
        
        [self resetViewPool];
        
        [self setSelectedSegmentIndex:0 animated:NO];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame sectionTitles:(NSArray *)sectionTitles
{
    return [self initWithFrame:frame sectionTitles:sectionTitles indexOfDropDownMenu:NSNotFound];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([self.segmentArray count] == 0) {
        return;
    }
    CGFloat totalWidth = CGRectGetWidth(self.bounds) - self.contentInsets.left - self.contentInsets.right;
    CGFloat contentHeight = CGRectGetHeight(self.bounds) - self.contentInsets.top - self.contentInsets.bottom;
    [self.segmentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dict = self.itemArray[idx];
        HYGDotSegment *segment = (HYGDotSegment *)obj;
        [segment setTitle:dict[keyItemTitle] forState:UIControlStateNormal];
        [self addSubview:segment];
        
        self.underLineView.hidden = NO;
        CGFloat segmentWidth = totalWidth / [self.segmentArray count];
        segment.frame = CGRectMake(self.contentInsets.left + idx * segmentWidth, self.contentInsets.top, segmentWidth, contentHeight);
        if (self.selectedSegmentIndex  == idx) {
            self.underLineView.frame = CGRectMake(CGRectGetMinX(segment.frame) + segmentWidth/2.0 - CGRectGetWidth(self.underLineView.frame)/2.0, CGRectGetHeight(self.bounds) - self.underLineHeight, CGRectGetWidth(self.underLineView.frame), self.underLineHeight);
        }
    }];
}

- (void)setSectionTitles:(NSArray<NSString *> *)sectionTitles
{
    [self.itemArray removeAllObjects];
    for (NSString *title in sectionTitles) {
        if ([title isKindOfClass:[NSString class]]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:title forKey:keyItemTitle];
            [self.itemArray addObject:dict];
        }
    }
    [self resetViewPool];
    [self setNeedsDisplay];
}

- (void)setDotIndex:(NSUInteger)dotIndex
{
    if (dotIndex > [self.segmentArray count] - 1) {
        return;
    }
    HYGDotSegment *segment = self.segmentArray[dotIndex];
    [segment showDot];
}

- (void)hideAllDotIndex
{
    for (HYGDotSegment *segment in self.segmentArray) {
        [segment hideDot];
    }
}

- (void)hideDotIndex:(NSUInteger)dotIndex
{
    if (dotIndex > [self.segmentArray count] - 1) {
        return;
    }
    HYGDotSegment *segment = self.segmentArray[dotIndex];
    [segment hideDot];
}

- (void)setDotSegmentImageUp
{
    if (self.indexOfDropDownMenu != NSNotFound) {
        HYGDotSegment *segment = self.segmentArray[self.indexOfDropDownMenu];
        [segment setRedArrowImageUp];
    }
}

- (void)setDotSegmentImageDown
{
    if (self.indexOfDropDownMenu != NSNotFound) {
        HYGDotSegment *segment = self.segmentArray[self.indexOfDropDownMenu];
        [segment setRedArrowImageDown];
    }
}

- (void)setDotSegmentImageGray
{
    if (self.indexOfDropDownMenu != NSNotFound) {
        HYGDotSegment *segment = self.segmentArray[self.indexOfDropDownMenu];
        [segment setRedArrowImageGray];
    }
}

- (void)setCurrentDotSegmentSelected
{
    [self.segmentArray[self.selectedSegmentIndex] setSelected:YES];
}

#pragma mark Setter
- (void)setFont:(UIFont *)font
{
    if (font) {
        _font = font;
        for (HYGDotSegment *segment in self.segmentArray) {
            [segment setTextFont:font];
        }
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    if (textColor) {
        _textColor = textColor;
        for (HYGDotSegment *segment in self.segmentArray) {
            [segment setTitleColor:self.textColor forState:UIControlStateNormal];
            [segment setTitleColor:self.textColor forState:UIControlStateHighlighted];
        }
    }
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor
{
    if (selectedTextColor) {
        _selectedTextColor = selectedTextColor;
        for (HYGDotSegment *segment in self.segmentArray) {
            [segment setTitleColor:self.selectedTextColor forState:UIControlStateSelected];
            [segment setTitleColor:self.selectedTextColor forState:UIControlStateSelected|UIControlStateHighlighted];
        }
    }
}

- (void)setunderLineHeight:(CGFloat)underLineHeight
{
    if (_underLineHeight != underLineHeight) {
        CGFloat oldHeight = _underLineHeight;
        _underLineHeight = underLineHeight;
            CGRect frame = self.underLineView.frame;
            frame.size.height = underLineHeight;
            frame.origin.y = frame.origin.y + oldHeight - underLineHeight;
            self.underLineView.frame = frame;
    }
}

- (void)setUnderLineLength:(CGFloat)underLineLength
{
    if (_underLineLength != underLineLength) {
        _underLineLength = underLineLength;
            CGRect frame = self.underLineView.frame;
            CGFloat xCentor = CGRectGetMidX(frame);
            frame.origin.x = xCentor - underLineLength/2.0;
            frame.size.width = underLineLength;
            self.underLineView.frame = frame;
    }
}

- (void)setUnderLineColor:(UIColor *)underLineColor
{
    if (underLineColor) {
        _underLineColor = underLineColor;
        [self.underLineView setBackgroundColor:_underLineColor];
    }
}

- (void)setShowTopSeperatorLine:(BOOL)showTopSeperatorLine
{
    if (_showTopSeperatorLine ^ showTopSeperatorLine) {
        _showTopSeperatorLine = showTopSeperatorLine;
        self.topSeperatorLine.hidden = !showTopSeperatorLine;
    }
}

- (void)setShowBottomSeperatorLine:(BOOL)showBottomSeperatorLine
{
    if (_showBottomSeperatorLine ^ showBottomSeperatorLine) {
        _showBottomSeperatorLine = showBottomSeperatorLine;
        self.bottomSeperatorLine.hidden = !showBottomSeperatorLine;
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    [self setSelectedSegmentIndex:selectedSegmentIndex animated:YES];
}

- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self setSelectedSegmentIndex:index animated:animated notify:NO];
}

- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated notify:(BOOL)notify
{
    if ( index >= [self.segmentArray count]) {
        return;
    }
    
    if (self.indexOfDropDownMenu != NSNotFound) {
        // 下拉菜单按钮变灰
        if (index != self.indexOfDropDownMenu) {
            [self setDotSegmentImageGray];
        } else {
            [self setDotSegmentImageUp];
        }
    }
    
    HYGDotSegment *segment = self.segmentArray[index];
    for (HYGDotSegment *aSeg in self.segmentArray) {
        [aSeg setSelected:(segment == aSeg)];
    }
    if (animated) {
        [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.underLineView.frame = CGRectMake(CGRectGetMinX(segment.frame) + CGRectGetWidth(segment.frame)/2.0 - CGRectGetWidth(self.underLineView.bounds)/2.0, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.underLineView.bounds), CGRectGetWidth(self.underLineView.bounds), CGRectGetHeight(self.underLineView.bounds));
        } completion:^(BOOL finished) {
        }];
    } else {
        self.underLineView.frame = CGRectMake(CGRectGetMinX(segment.frame) + CGRectGetWidth(segment.frame)/2.0 - CGRectGetWidth(self.underLineView.bounds)/2.0, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.underLineView.bounds), CGRectGetWidth(self.underLineView.bounds), CGRectGetHeight(self.underLineView.bounds));
    }
    _selectedSegmentIndex = index;
    if (notify) {
        if ([self.delegate respondsToSelector:@selector(hygDotSegcontrol:selectSegmentedControlIndex:)]) {
            [self.delegate hygDotSegcontrol:self selectSegmentedControlIndex:_selectedSegmentIndex];
        }
    }
}

- (void)showDropDownMenuWithIndex:(NSUInteger)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hygShowDropDownMenuViewWithIndex:)]) {
        [self.delegate hygShowDropDownMenuViewWithIndex:index];
    }
}

#pragma mark Private

- (void)handleSelectSegment:(HYGDotSegment *)sender
{
    NSInteger index = [self.segmentArray indexOfObject:sender];
    if (index != self.selectedSegmentIndex) {
        [self setSelectedSegmentIndex:index animated:YES notify:YES];
    } else {
        if (self.indexOfDropDownMenu == index) {
            // 如果有下拉菜单，重复点击,弹出下拉菜单，不收起
            [self showDropDownMenuWithIndex:index];
        }
    }
}

- (void)resetViewPool
{
    for (HYGDotSegment *segment in self.segmentArray) {
        [segment removeFromSuperview];
    }
    [self.segmentArray removeAllObjects];
    for (NSInteger i = 0; i< [[self itemArray] count]; i++) {
        HYGDotSegment *segment = [[HYGDotSegment alloc] init];
        segment.isDropDownButton = (self.indexOfDropDownMenu == i) ? YES: NO;
        [segment setTitleColor:self.textColor forState:UIControlStateNormal];
        [segment setTitleColor:self.textColor forState:UIControlStateHighlighted];
        [segment setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [segment setTitleColor:self.selectedTextColor forState:UIControlStateSelected];
        [segment setTitleColor:self.selectedTextColor forState:UIControlStateSelected|UIControlStateHighlighted];
        [segment setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected|UIControlStateDisabled];
        [segment setTextFont:self.font];
        [segment addTarget:self action:@selector(handleSelectSegment:) forControlEvents:UIControlEventTouchUpInside];
        [self.segmentArray addObject:segment];
    }
}

@end

@interface HYGDotSegment ()

@property (nonatomic, strong) UIImageView *dropDownImageView;

@property (nonatomic, strong) UIImageView *dotImageView;

@end

@implementation HYGDotSegment

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hyg_hall_redDot"]];
        self.dotImageView.frame = CGRectMake(0, 0, 2, 2);
        [self addSubview:self.dotImageView];
        self.dotImageView.hidden = YES;
        
        // set drop down arrow image
        self.isDropDownButton = NO;
        [self setImage:[UIImage imageNamed:@"HYGMyPageRedArrowDown"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"HYGMyPageRedArrowDown"] forState:UIControlStateSelected];
        
    }
    return self;
}

/**
 *  只在下拉菜单收起的时候触发
 */
- (void)setRedArrowImageUp
{
    [self setImage:[UIImage imageNamed:@"HYGMyPageRedArrowDown"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"HYGMyPageRedArrowDown"] forState:UIControlStateSelected];
}

/**
 *  只在下拉菜单弹出的时候触发
 */
- (void)setRedArrowImageDown
{
    [self setImage:[UIImage imageNamed:@"HYGMyPageRedArrowUp"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"HYGMyPageRedArrowUp"] forState:UIControlStateSelected];
}

/**
 *  切换tab时候触发
 */
- (void)setRedArrowImageGray
{
    [self setImage:[UIImage imageNamed:@"HYGMyPageGrayArrowDown"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"HYGMyPageGrayArrowDown"] forState:UIControlStateSelected];
}

- (void)setHighlighted:(BOOL)highlighted
{
    
}

- (void)setIsDropDownButton:(BOOL)isDropDownButton
{
    _isDropDownButton = isDropDownButton;
    if (isDropDownButton) {
        [self.titleLabel setTextColor:[UIColor colorWithRed:0xd9/255.0 green:0x1d/255.0 blue:0x37/255.0 alpha:1.0]];
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -self.imageView.frame.size.width - 3.0, 0.0, self.imageView.frame.size.width + 3.0);
    } else {
        [self setImage:nil forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateSelected];
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (void)setTextFont:(UIFont *)font
{
    self.titleLabel.font = font;
    [self setNeedsDisplay];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    [self setNeedsDisplay];
}
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [super setTitleColor:color forState:state];
    [self setNeedsLayout];
}

- (void)showDot
{
    self.dotImageView.hidden = NO;
}

- (void)hideDot
{
    self.dotImageView.hidden = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize sizee = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    CGFloat w = sizee.width;
    CGFloat h = sizee.height;
    CGFloat dotW =[UIImage imageNamed:@"hyg_hall_redDot"].size.width;
    CGFloat dotH = [UIImage imageNamed:@"hyg_hall_redDot"].size.height;
    CGFloat dotX = CGRectGetMidX(self.bounds) + w/2.0;
    CGFloat dotY = CGRectGetMidY(self.bounds) - h/2.0 - dotH/2.0;
    self.dotImageView.frame = CGRectMake(dotX, dotY, dotW, dotH);
    
    self.imageEdgeInsets = UIEdgeInsetsMake(0.0, self.titleLabel.frame.size.width + 3.0, 0.0, -self.titleLabel.frame.size.width - 3.0);
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -self.imageView.frame.size.width - 3.0, 0.0, self.imageView.frame.size.width + 3.0);
}
@end

