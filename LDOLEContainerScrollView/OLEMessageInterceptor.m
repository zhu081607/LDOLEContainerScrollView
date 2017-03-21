//
//  MessageInterceptor.m
//  Pods
//
//  Created by asshole on 16/8/22.
//
//

#import "OLEMessageInterceptor.h"

@implementation OLEMessageInterceptor

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.middleMan respondsToSelector:aSelector]) { return self.middleMan; }
    if ([self.receiver respondsToSelector:aSelector]) { return self.receiver; }
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.middleMan respondsToSelector:aSelector]) { return YES; }
    if ([self.receiver respondsToSelector:aSelector]) { return YES; }
    return [super respondsToSelector:aSelector];
}

@end