/*
 OLEContainerScrollView
 
 Copyright (c) 2014 Ole Begemann.
 https://github.com/ole/OLEContainerScrollView
 */

@import QuartzCore;

#import "OLEContainerScrollView.h"
#import "OLEContainerScrollView_Private.h"
#import "OLEContainerScrollViewContentView.h"
#import "OLEContainerScrollView+Swizzling.h"
#import "LDPageContainerScrollView.h"
#import "HMSegmentedControl.h"
#import "MJRefresh.h"
#import "HYGDotSegcontrol.h"
#import "OLEMessageInterceptor.h"
#import "LDPageContainerScrollView_Private.h"

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)

@interface OLEContainerScrollView () <UIScrollViewDelegate, LDPageContainerScrollViewInternalDelegate>

@property (nonatomic, readonly) NSMutableArray *subviewsInLayoutOrder;
@property (nonatomic, strong) LDPageContainerScrollView *pageContainerScrollView;
@property (nonatomic, strong) OLEMessageInterceptor *delegate_interceptor;

@property (nonatomic, assign) BOOL checkForRefresh;
@property (nonatomic, strong) MJRefreshHeader* refreshHeader;
@property (nonatomic, assign) BOOL pullDownToReload;

@property (nonatomic, assign) NSInteger oldIndex;//oldIndex会冲突

@end


@implementation OLEContainerScrollView

+ (void)initialize
{
    // +initialize can be called multiple times if subclasses don't implement it.
    // Protect against multiple calls
    if (self == [OLEContainerScrollView self]) {
        swizzleUICollectionViewLayoutFinalizeCollectionViewUpdates();
        swizzleUITableView();
    }
}

- (void)dealloc
{
    // Removing the subviews will unregister KVO observers
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
}

- (id)delegate
{
    return _delegate_interceptor.receiver;
}

- (void)setDelegate:(id)newDelegate
{
    if (newDelegate) {
        [super setDelegate:nil];
        [self.delegate_interceptor setReceiver:newDelegate];
        [super setDelegate:(id)self.delegate_interceptor];
    }
}

- (void)setIsNeedRefresh:(BOOL)isNeedRefresh
{
    if (isNeedRefresh) {
        if (!self.mj_header) {
            self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                [self pullDownToReloadAction];  //self
                //Call this Block When enter the refresh status automatically
            }];
//            self.mj_header.backgroundColor = [UIColor redColor];
        }
    } else {
        if (self.mj_header) {
            self.mj_header = nil;
        }
    }
    _isNeedRefresh = isNeedRefresh;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _delegate_interceptor = [[OLEMessageInterceptor alloc] init];
        [_delegate_interceptor setMiddleMan:self];
        [super setDelegate:(id)self.delegate_interceptor];
        _oldIndex = 0;
        _segControlFloatingTopMargin = 0.0f;
        
        [self commonInitForOLEContainerScrollView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInitForOLEContainerScrollView];
}

- (void)commonInitForOLEContainerScrollView
{
    _contentView = [[OLEContainerScrollViewContentView alloc] initWithFrame:CGRectZero];
    [self addSubview:_contentView];
    _subviewsInLayoutOrder = [NSMutableArray arrayWithCapacity:4];
}

#pragma mark - Adding and removing subviews

- (void)didAddSubviewToContainer:(UIView *)subview
{
    NSParameterAssert(subview != nil);

    subview.autoresizingMask = UIViewAutoresizingNone;
//    subview.translatesAutoresizingMaskIntoConstraints = NO;

    [self.subviewsInLayoutOrder addObject:subview];

    if ([subview isKindOfClass:[LDPageContainerScrollView class]]) {
        LDPageContainerScrollView *scrollView = (LDPageContainerScrollView *)subview;
        scrollView.delegate = self;
        scrollView.containerScrollViewInternalDelegate = self;
        scrollView.segControlFloatingTopMargin = self.segControlFloatingTopMargin;
        self.pageContainerScrollView = scrollView;
        
        if (scrollView.segControl) {
            // insert segControl at the second last place
            [self.subviewsInLayoutOrder removeLastObject];
            [self.contentView addSubview:scrollView.segControl];
            [self.subviewsInLayoutOrder addObject:subview];
        }
        [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld context:KVOContext];
        [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentHeight)) options:NSKeyValueObservingOptionOld context:KVOContext];
    } else if ([subview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)subview;
        scrollView.scrollEnabled = NO;
        [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld context:KVOContext];
    } else {
        [subview addObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionOld context:KVOContext];
        [subview addObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) options:NSKeyValueObservingOptionOld context:KVOContext];
    }
    
    [self setNeedsLayout];
}

- (void)willRemoveSubviewFromContainer:(UIView *)subview
{
    NSParameterAssert(subview != nil);
    
    if ([subview isKindOfClass:[UIScrollView class]]) {
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:KVOContext];
        if ([subview isKindOfClass:[LDPageContainerScrollView class]]) {
            [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentHeight)) context:KVOContext];
        }
    } else {
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) context:KVOContext];
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) context:KVOContext];
    }
    [self.subviewsInLayoutOrder removeObject:subview];
    [self setNeedsLayout];
}

#pragma mark - KVO

static void *KVOContext = &KVOContext;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KVOContext) {
        // Initiate a layout recalculation only when a subviewʼs frame or contentSize has changed
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            UIScrollView *scrollView = object;
            CGSize oldContentSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = scrollView.contentSize;
            if (!CGSizeEqualToSize(newContentSize, oldContentSize)) {
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
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentHeight))]) {
            LDPageContainerScrollView *scrollView = object;
            CGFloat oldContentSize = [change[NSKeyValueChangeOldKey] floatValue];
            CGFloat newContentSize = scrollView.contentHeight;
            if (newContentSize != oldContentSize) {
                [self setNeedsLayout];
                [self layoutIfNeeded];
            }

        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Translate the container view's content offset to contentView bounds.
    // This keeps the contentView always centered on the visible portion of the container view's
    // full content size, and avoids the need to make the contentView large enough to fit the
    // container view's full content size.
    self.contentView.frame = self.bounds;
    self.contentView.bounds = (CGRect){ self.contentOffset, self.contentView.bounds.size };
    
    // The logical vertical offset where the current subview (while iterating over all subviews)
    // must be positioned. Subviews are positioned below each other, in the order they were added
    // to the container. For scroll views, we reserve their entire contentSize.height as vertical
    // space. For non-scroll views, we reserve their current frame.size.height as vertical space.
    CGFloat yOffsetOfCurrentSubview = 0.0;
        
    for (UIView *subview in self.subviewsInLayoutOrder)
    {
        if ([subview isKindOfClass:[LDPageContainerScrollView class]]) {
            LDPageContainerScrollView *scrollView = (LDPageContainerScrollView *)subview;
            CGRect frame = scrollView.frame;
            CGPoint contentOffset = scrollView.childTableViews[scrollView.currentIndex].contentOffset;
            
            
            // (3) The sub-scrollview's frame should never extend beyond the bottom of the screen, even if its
            // content height is potentially much greater. When the user has scrolled so far that the remaining
            // content height is smaller than the height of the screen, adjust the frame height accordingly.
            CGFloat remainingBoundsHeight = fmax(CGRectGetMaxY(self.bounds) - CGRectGetMinY(frame), 0.0);
            CGFloat remainingContentHeight = fmax(scrollView.contentHeight - contentOffset.y, 0.0);
            frame.size.height = fmin(remainingBoundsHeight, remainingContentHeight);
            // 这里会导致layout调用多次。。。
            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, frame.size.height);
            /**
             *把这部分逻辑倒过来，因为上句触发layout之后下面的内容需要重新计算
             **/
            // Translate the logical offset into the sub-scrollview's real content offset and frame size.
            // Methodology:
            
            // (1) As long as the sub-scrollview has not yet reached the top of the screen, set its scroll position
            // to 0.0 and position it just like a normal view. Its content scrolls naturally as the container
            // scroll view scrolls.
            if (self.contentOffset.y < yOffsetOfCurrentSubview) {
                contentOffset.y = 0.0;
                frame.origin.y = yOffsetOfCurrentSubview;
            }
            // (2) If the user has scrolled far enough down so that the sub-scrollview reaches the top of the
            // screen, position its frame at 0.0 and start adjusting the sub-scrollview's content offset to
            // scroll its content.
            else {
                contentOffset.y = self.contentOffset.y - yOffsetOfCurrentSubview;
                frame.origin.y = self.contentOffset.y;
            }

            frame.size.width = self.contentView.bounds.size.width;

            scrollView.frame = frame;
            scrollView.childTableViews[scrollView.currentIndex].contentOffset = contentOffset;
            
            yOffsetOfCurrentSubview += scrollView.contentHeight + scrollView.contentInset.top + scrollView.contentInset.bottom;

        } else if ([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            CGRect frame = scrollView.frame;
            CGPoint contentOffset = scrollView.contentOffset;

            // Translate the logical offset into the sub-scrollview's real content offset and frame size.
            // Methodology:

            // (1) As long as the sub-scrollview has not yet reached the top of the screen, set its scroll position
            // to 0.0 and position it just like a normal view. Its content scrolls naturally as the container
            // scroll view scrolls.
            if (self.contentOffset.y < yOffsetOfCurrentSubview) {
                contentOffset.y = 0.0;
                frame.origin.y = yOffsetOfCurrentSubview;
            }
            // (2) If the user has scrolled far enough down so that the sub-scrollview reaches the top of the
            // screen, position its frame at 0.0 and start adjusting the sub-scrollview's content offset to
            // scroll its content.
            else {
                contentOffset.y = self.contentOffset.y - yOffsetOfCurrentSubview;
                frame.origin.y = self.contentOffset.y;
            }

            // (3) The sub-scrollview's frame should never extend beyond the bottom of the screen, even if its
            // content height is potentially much greater. When the user has scrolled so far that the remaining
            // content height is smaller than the height of the screen, adjust the frame height accordingly.
            CGFloat remainingBoundsHeight = fmax(CGRectGetMaxY(self.bounds) - CGRectGetMinY(frame), 0.0);
            CGFloat remainingContentHeight = fmax(scrollView.contentSize.height - contentOffset.y, 0.0);
            frame.size.height = fmin(remainingBoundsHeight, remainingContentHeight);
            frame.size.width = self.contentView.bounds.size.width;
            
            scrollView.frame = frame;
            scrollView.contentOffset = contentOffset;

            yOffsetOfCurrentSubview += scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom;
        }
        else {
            // Normal views are simply positioned at the current offset
            CGRect frame = subview.frame;
            frame.origin.y = yOffsetOfCurrentSubview;
            if ([subview isKindOfClass:[HMSegmentedControl class]]) {
                if (self.contentOffset.y + self.segControlFloatingTopMargin > frame.origin.y) {
                    frame.origin.y =  self.contentOffset.y + self.segControlFloatingTopMargin;
                }
            }
            
            frame.size.width = self.contentView.bounds.size.width;
            subview.frame = frame;
            
            yOffsetOfCurrentSubview += frame.size.height;
        }
    }
    
    // If our content is shorter than our bounds height, take the contentInset into account to avoid
    // scrolling when it is not needed.
    CGFloat minimumContentHeight = self.bounds.size.height - (self.contentInset.top + self.contentInset.bottom);

    CGPoint initialContentOffset = self.contentOffset;
    CGFloat contentSizeHeight = fmax(fmax(yOffsetOfCurrentSubview, minimumContentHeight), self.bounds.size.height + 1);
    self.contentSize = CGSizeMake(self.bounds.size.width, contentSizeHeight);
    
    // If contentOffset changes after contentSize change, we need to trigger layout update one more time.
    if (!CGPointEqualToPoint(initialContentOffset, self.contentOffset)) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self) {
        if (!self.refreshHeader) {
            return;
        }
        
        self.checkForRefresh = YES;  //  only check offset when dragging
        if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
            [self.delegate scrollViewWillBeginDragging:self];
        }
        
    } else if ([scrollView isKindOfClass:[LDPageContainerScrollView class]]) {
        self.oldIndex = self.pageContainerScrollView.currentIndex;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self) {
        if (!self.refreshHeader) {
            return;
        }
        if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self.delegate scrollViewDidScroll:self];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self == scrollView) {
        if (!self.refreshHeader) {
            return;
        }
        
//        [self pullDownToReloadAction];
        self.checkForRefresh = NO;
        
        if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
            [self.delegate scrollViewDidEndDragging:self willDecelerate:decelerate];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[LDPageContainerScrollView class]]) {
        LDPageContainerScrollView *pageContainerScrollView = (LDPageContainerScrollView *)scrollView;
        if (pageContainerScrollView.currentIndex != self.oldIndex) {
            UITableView *tableView = pageContainerScrollView.childTableViews[pageContainerScrollView.currentIndex];
            /**
             *   这里取头部的高度不能用headerTableViewHeight
             *   因为headerTableViewHeight基于self.scrollView.childTableViews[self.currentIndex]
             *   这个值在scrollViewWillBeginDragging中已经置0了
             **/
            CGFloat headHeight = (pageContainerScrollView.frame.origin.y  - pageContainerScrollView.childTableViews[pageContainerScrollView.currentIndex].contentOffset.y - pageContainerScrollView.segControl.frame.size.height) - self.segControlFloatingTopMargin;
            
            if (fequal(CGRectGetMinY(pageContainerScrollView.segControl.frame), self.contentOffset.y + self.segControlFloatingTopMargin)) {
                //这里增加一个判断，要是目的tableView的内容比较少不足以顶到上面的话。
                if (tableView.contentSize.height < self.bounds.size.height) {
                    //这里需要细分，如果高度不足以顶到下边的话。。
                    if (tableView.contentSize.height < tableView.bounds.size.height) {
                        //header也特别小
                        [self setContentOffset:CGPointMake(0, 0)];
                    } else {
                        [self setContentOffset:CGPointMake(0, self.contentSize.height - self.bounds.size.height)];
                    }
                } else {
                    [self setContentOffset:CGPointMake(0, headHeight)];
                }
                
            }
//            else {
//                if (self.contentOffset.y > headHeight) {
//                    self.contentOffset = CGPointMake(0, headHeight);
//                }
//                
//            }
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
            [self.delegate scrollViewDidEndDecelerating:self];
        }
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:self];
    }
}

#pragma mark -
#pragma mark 下拉刷新
/**
 *  pullDownToReloadAction动作通过位移在内部发起
 *  pullDownToReloadActionFinished动作要等调用结束外部调回来
 **/

- (void)pullDownToReloadAction
{
    self.pullDownToReload = YES;
    
    if ([self.scrollDelegate respondsToSelector:@selector(baseViewPullDownToReloadAction)]) {
        [self.scrollDelegate baseViewPullDownToReloadAction];
    }
}

- (void)pullDownToReloadActionFinished
{
    self.pullDownToReload = NO;
    [self.mj_header endRefreshing];
}

- (UITableView *)shownTableView
{
    NSUInteger index = self.pageContainerScrollView.currentIndex;
    if (index < [self.pageContainerScrollView.childTableViews count]) {
        return self.pageContainerScrollView.childTableViews[index];
    } else {
        return nil;
    }
}

#pragma mark -
#pragma mark LDPageContainerScrollViewInternalDelegate

- (void)internal_containerScrollView:(LDPageContainerScrollView *)scrollView
                    hygDotSegcontrol:(HYGDotSegcontrol *)dotSegcontrol
         selectSegmentedControlIndex:(NSUInteger)index
                            oldIndex:(NSUInteger)oldIndex
{
    UITableView *oldTableView = self.pageContainerScrollView.childTableViews[oldIndex];
    UITableView *tableView = self.pageContainerScrollView.childTableViews[index];
    
    CGFloat headHeight = (self.pageContainerScrollView.frame.origin.y - tableView.contentOffset.y - self.pageContainerScrollView.segControl.frame.size.height - self.segControlFloatingTopMargin);
    
    //设置offset
    if (fequal(CGRectGetMinY(self.pageContainerScrollView.segControl.frame), self.contentOffset.y + self.segControlFloatingTopMargin)) {
        //这里增加一个判断，要是目的tableView的内容比较少不足以顶到上面的话。
        if (tableView.contentSize.height < self.bounds.size.height) {
            //这里需要细分，如果高度不足以顶到下边的话。。
            if (tableView.contentSize.height < tableView.bounds.size.height) {
                if (self.contentSize.height < self.bounds.size.height) {
                    //header也特别小
                    [self setContentOffset:CGPointMake(0, 0)];
                } else {
                    [self setContentOffset:CGPointMake(0, self.contentSize.height - self.bounds.size.height) animated:YES];
                }
            }
        } else {
            [self setContentOffset:CGPointMake(0, headHeight)];
        }
    } else {
        //当没有悬浮的情况下，出现内容不够的时候做调整
        if (tableView.contentSize.height + headHeight < self.bounds.size.height) {
            self.contentOffset = CGPointMake(0, 0);
        }
    }
}

@end
