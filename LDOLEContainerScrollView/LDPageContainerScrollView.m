//
//  LDPageContainerScrollView.m
//  LDHYG
//
//  Created by asshole on 16/4/18.
//  Copyright © 2016年 caipiao. All rights reserved.
//

#import "LDPageContainerScrollView.h"
#import "HMSegmentedControl.h"
#import "OLEMessageInterceptor.h"
#import "LDPageContainerScrollView_Private.h"

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)

@interface LDPageContainerScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) OLEMessageInterceptor *delegate_interceptor;
@property (nonatomic, strong) NSMutableArray <__kindof UIScrollView *> *inner_childTableViews;
@property (nonatomic, assign) NSUInteger oldIndex;
@property (nonatomic, strong, readwrite) HMSegmentedControl *segControl;

@end

@implementation LDPageContainerScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame sectionTitles:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
                sectionTitles:(NSArray<NSString *> *)sectionTitles
{
    if (self = [super initWithFrame:frame]) {
        _delegate_interceptor = [[OLEMessageInterceptor alloc] init];
        [_delegate_interceptor setMiddleMan:self];
        [super setDelegate:(id)self.delegate_interceptor];

        _inner_childTableViews = [NSMutableArray array];
        _currentIndex = 0;
        _segControlFloatingTopMargin = 0;
        self.delegate = self;
        if (sectionTitles && sectionTitles.count) {
            self.segControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 35)];
            self.segControl.sectionTitles = sectionTitles;
            self.segControl.backgroundColor = [UIColor whiteColor];
//            self.segControl.font = [UIFont fontWithName:@"STHeitiSC-Light" size:15.0f];
//            self.segControl.textColor = [UIColor cp_colorWithHex:0x808080];
//            self.segControl.selectedTextColor = [UIColor cp_colorWithHex:0xd91d37];
            self.segControl.selectionIndicatorColor = [UIColor colorWithRed:0xd9 / 255.0f green:0x1d / 255.0f blue:0x37 / 255.0f alpha:1.0f];
            self.segControl.selectionIndicatorHeight = 2;
            self.segControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
            self.segControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
//            [self.segControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
            
            __weak typeof(self) weakSelf = self;
            self.segControl.IndexChangeBlock = ^(NSInteger index) {
                NSUInteger oldIndex = weakSelf.currentIndex;
                weakSelf.oldIndex = oldIndex;
                weakSelf.currentIndex = index;
                UITableView *tableView = weakSelf.inner_childTableViews[weakSelf.currentIndex];
                
                [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [weakSelf setContentOffset:CGPointMake(weakSelf.currentIndex * CGRectGetWidth(weakSelf.bounds), 0)];
                } completion:^(BOOL finished) {
                }];
                
                tableView.scrollsToTop = YES;
                for (UITableView *enumTableView in weakSelf.inner_childTableViews) {
                    if (![enumTableView isEqual:tableView]) {
                        enumTableView.scrollsToTop = NO;
                    } else {
                        [enumTableView setContentOffset:CGPointMake(0, 0)];
                    }
                }

                [weakSelf adjustContentHeight];

                if (oldIndex != index && weakSelf.containerScrollViewInternalDelegate &&
                    [weakSelf.containerScrollViewInternalDelegate respondsToSelector:@selector(internal_containerScrollView:hygDotSegcontrol:selectSegmentedControlIndex:oldIndex:)]) {
                    [weakSelf.containerScrollViewInternalDelegate
                     internal_containerScrollView:weakSelf
                     hygDotSegcontrol:weakSelf.segControl
                     selectSegmentedControlIndex:index
                     oldIndex:oldIndex];
                }
                
                if (weakSelf.pageContainerScrollViewdelegate &&
                    [weakSelf.pageContainerScrollViewdelegate respondsToSelector:@selector(containerScrollView:hygDotSegcontrol: selectSegmentedControlIndex:)]) {
                    [weakSelf.pageContainerScrollViewdelegate containerScrollView:weakSelf selectSegmentedControlIndex:index];
                }
                if (oldIndex != index && weakSelf.pageContainerScrollViewdelegate &&
                    [weakSelf.pageContainerScrollViewdelegate respondsToSelector:@selector(containerScrollView:selectedIndexChangedNewIndex:oldIndex:)]) {
                    [weakSelf.pageContainerScrollViewdelegate containerScrollView:weakSelf
                                                     selectedIndexChangedNewIndex:index
                                                                         oldIndex:oldIndex];
                }
            };
        }
    }
    return self;
}

#pragma mark getter & setter

- (id)delegate
{
    return _delegate_interceptor.receiver;
}

- (void)setDelegate:(id)newDelegate
{
    [super setDelegate:nil];
    [self.delegate_interceptor setReceiver:newDelegate];
    [super setDelegate:(id)self.delegate_interceptor];
}

- (void)setCurrentIndex:(NSUInteger)newIndex
{
    _currentIndex = newIndex;
//    self.contentHeight = self.inner_childTableViews[_currentIndex].contentSize.height;
}

- (NSArray <__kindof UIScrollView *> *)childTableViews
{
    return [NSArray arrayWithArray:self.inner_childTableViews];
}

- (void)setProductSegmentControlHeight:(CGFloat)segmentControlHeight
{
//    _productSegmentControlHeight = segmentControlHeight;
    self.segControl.frame = CGRectMake(self.segControl.frame.origin.x, self.segControl.frame.origin.y, self.segControl.frame.size.width, segmentControlHeight);
}

#pragma mark public methods

- (void)setSegcontrolTitles:(NSArray<NSString *> *)sectionTitles
{
    if (self.segControl) {
        [self.segControl setSectionTitles:sectionTitles];
    }
}

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index == self.currentIndex) {
        return;
    }
    NSUInteger oldIndex = self.currentIndex;
    self.currentIndex = index;
    if (animated) {
        [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setContentOffset:CGPointMake(index * CGRectGetWidth(self.bounds), 0)];
        } completion:^(BOOL finished) {
        }];
    } else {
        [self setContentOffset:CGPointMake(index * CGRectGetWidth(self.bounds), 0)];
    }
    
    [self.segControl setSelectedSegmentIndex:index animated:YES];
    
    if (self.pageContainerScrollViewdelegate &&
        [self.pageContainerScrollViewdelegate respondsToSelector:@selector(containerScrollView:selectedIndexChangedNewIndex:oldIndex:)]) {
        [self.pageContainerScrollViewdelegate containerScrollView:self
                                     selectedIndexChangedNewIndex:self.currentIndex
                                                         oldIndex:oldIndex];
    }
}

- (void)setTableViews:(NSArray <__kindof UIScrollView *> *)childTableViewsArray
{
    NSUInteger count = childTableViewsArray.count;
    self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * count, CGRectGetHeight(self.bounds));
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    for (int idx = 0; idx < childTableViewsArray.count ; idx++) {
        UITableView *childTableView = childTableViewsArray[idx];
        childTableView.frame = CGRectMake(idx * CGRectGetWidth(self.bounds), 0, CGRectGetWidth(self.bounds), CGRectGetHeight(childTableView.frame));
        [self addSubview:childTableView];
    }
}

#pragma mark layout obeserver

- (void)didAddSubview:(__kindof UIView *)view
{
    [super didAddSubview:view];
    [self.inner_childTableViews addObject:view];
    
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        scrollView.scrollEnabled = NO;
        [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld context:KVOContext];
    } else {
        [view addObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionOld context:KVOContext];
        [view addObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) options:NSKeyValueObservingOptionOld context:KVOContext];
    }
    
    [self setNeedsLayout];
}

- (void)willRemoveSubview:(__kindof UIView *)subview
{
    [super willRemoveSubview:subview];
    [self.inner_childTableViews removeObject:subview];

    if ([subview isKindOfClass:[UIScrollView class]]) {
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:KVOContext];
    } else {
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) context:KVOContext];
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) context:KVOContext];
    }
    [self setNeedsLayout];
}

static void *KVOContext = &KVOContext;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KVOContext) {
        // Initiate a layout recalculation only when a subviewʼs frame or contentSize has changed
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            UITableView *scrollView = object;
            if (scrollView != self.inner_childTableViews[self.currentIndex]) {
                return;
            }
            CGSize oldContentSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = scrollView.contentSize;
            if (!CGSizeEqualToSize(newContentSize, oldContentSize) || newContentSize.height != self.contentHeight) {                
                if (newContentSize.height != self.contentHeight) {
                    // 这里之所以用这种调整逻辑是因为第一次初始化时有可能高度不对
                    CGFloat headHeight = (self.frame.origin.y  - self.childTableViews[self.oldIndex].contentOffset.y - self.segControl.frame.size.height) - self.segControlFloatingTopMargin;
                    CGFloat height = scrollView.contentSize.height < self.superview.frame.size.height - headHeight ? self.superview.frame.size.height - headHeight : scrollView.contentSize.height;
                    self.contentHeight = height;
//                    self.contentHeight = scrollView.contentSize.height;
                }
                [self setNeedsLayout];
                [self layoutIfNeeded];
            }
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(frame))] ||
                   [keyPath isEqualToString:NSStringFromSelector(@selector(bounds))]) {
            UIView *subview = object;
            CGRect oldFrame = [change[NSKeyValueChangeOldKey] CGRectValue];
            CGRect newFrame = subview.frame;
            if (!CGRectEqualToRect(newFrame, oldFrame)) {
                [self setNeedsLayout];
                [self layoutIfNeeded];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.oldIndex = self.currentIndex;
    
    UITableView *currentTableView = [self shownTableView];
    for (UITableView *tableView in self.inner_childTableViews) {
        if (![tableView isEqual:currentTableView]) {
            //设置offset
            if (fequal(CGRectGetMinY(self.segControl.frame), CGRectGetMinY(self.frame) + self.segControlFloatingTopMargin)) {
                //segmentcontrol 悬浮时的计算
                /* 这里要判断tableView.contentOffs3et.y小于等于0， 当你处在contentOffset.y为0时
                 * 有一种情况是可能向空的一侧滑，这时做了调整导致其它的tableView的位移为负值
                 * 这时再向有内容的一侧滑动时由于contentOffset.y为负值
                 * PS:如果你不知道我说的是啥那就当我啥都没说。。。
                 */
                CGFloat tableViewYOffset = -(self.segControl.frame.size.height + self.segControlFloatingTopMargin);
                
//                if (fabs(self.segControl.frame.size.height - (CGRectGetMinY(self.frame) - CGRectGetMinY(self.segControl.frame))) < 0.5 ) {
//                    tableViewYOffset = 0;
//                } else
//                if (tableView.contentOffset.y <= 0) {
//                    tableViewYOffset = (CGRectGetMinY(self.frame) - CGRectGetMaxY(self.segControl.frame));
//                }
                
                [tableView setContentOffset:CGPointMake(0, tableViewYOffset)];
            } else if (CGRectGetMinY(self.segControl.frame) < CGRectGetMinY(self.frame) + self.segControlFloatingTopMargin && CGRectGetMinY(self.frame) < CGRectGetMaxY(self.segControl.frame)) {
                // 在临界点位移在segmentcontrol高度之间的时候
                // 其实两种情况可以合并，都用下面的逻辑
                CGFloat tableViewYOffset = - (CGRectGetMaxY(self.segControl.frame) - CGRectGetMinY(self.frame));
                [tableView setContentOffset:CGPointMake(0, tableViewYOffset)];
                
            } else {
                [tableView setContentOffset:CGPointMake(0, 0)];
            }
        }
    }
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.currentIndex != [self calculateCurrentViewIndex]) {
        self.currentIndex = [self calculateCurrentViewIndex];
        [self.segControl setSelectedSegmentIndex:self.currentIndex animated:YES];
    }
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.currentIndex != self.oldIndex) {
        UITableView *tableView = self.inner_childTableViews[self.currentIndex];

        for (UITableView *enumTableView in self.inner_childTableViews) {
            if (![enumTableView isEqual:tableView]) {
                enumTableView.scrollsToTop = NO;
            }
        }
        // 会导致刷新
        if (self.pageContainerScrollViewdelegate &&
            [self.pageContainerScrollViewdelegate respondsToSelector:@selector(containerScrollView:selectedIndexChangedNewIndex:oldIndex:)]) {
            [self.pageContainerScrollViewdelegate containerScrollView:self
                                         selectedIndexChangedNewIndex:self.currentIndex
                                                             oldIndex:self.oldIndex];
        }
        
        [self adjustContentHeight];
        
        if (self.delegate &&
                 [self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
            [self.delegate scrollViewDidEndDecelerating:self];
        }
    } else {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
            [self.delegate scrollViewDidEndDecelerating:self];
        }
    }
}

#pragma mark - helper methods

- (void)adjustContentHeight
{
    CGFloat headHeight = (self.frame.origin.y  - self.childTableViews[self.oldIndex].contentOffset.y - self.segControl.frame.size.height) - self.segControlFloatingTopMargin;
    CGFloat minContentHeight = self.superview.frame.size.height - headHeight;
    CGFloat height = self.inner_childTableViews[_currentIndex].contentSize.height < minContentHeight ? minContentHeight : self.inner_childTableViews[_currentIndex].contentSize.height;
    self.contentHeight = height;
}

- (UITableView *)shownTableView
{
    NSUInteger index = self.currentIndex;
    if (index < [self.inner_childTableViews count]) {
        return self.inner_childTableViews[index];
    } else {
        return nil;
    }
}

- (NSInteger)calculateCurrentViewIndex
{
    CGRect visibleBounds = self.bounds;
    NSInteger index = floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds));
    if (index < 0) {
        index = 0;
    } else if(index >= [self.inner_childTableViews count]){
        index = self.inner_childTableViews.count - 1;
    }
    return index;
}

@end
