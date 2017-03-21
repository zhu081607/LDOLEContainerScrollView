//
//  MessageInterceptor.h
//  Pods
//
//  Created by asshole on 16/8/22.
//
//  http://stackoverflow.com/questions/3498158/intercept-objective-c-delegate-messages-within-a-subclass

@interface OLEMessageInterceptor : NSObject

@property (nonatomic, assign) id receiver;
@property (nonatomic, assign) id middleMan;

@end
