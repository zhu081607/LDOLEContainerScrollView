//
//  LDPageContainerScrollView_Private.h
//  Pods
//
//  Created by asshole on 16/8/22.
//
/**
 *  this is a priavate class to expose some variables to OLEContainerScrollView
 **/

#import "LDPageContainerScrollView.h"

@protocol LDPageContainerScrollViewInternalDelegate <NSObject>

- (void)internal_containerScrollView:(LDPageContainerScrollView *)scrollView
                    hygDotSegcontrol:(HMSegmentedControl *)dotSegcontrol
         selectSegmentedControlIndex:(NSUInteger)index
                            oldIndex:(NSUInteger)oldIndex;

@end

@interface LDPageContainerScrollView ()

@property (nonatomic, weak) id <LDPageContainerScrollViewInternalDelegate> containerScrollViewInternalDelegate;

@property (nonatomic, assign) CGFloat contentHeight;

@end
