//
//  SmilePasswordContainerView.m
//  TouchID
//
//  Created by yuchen liu on 5/27/15.
//  Copyright (c) 2015 rain. All rights reserved.
//

#import "SmilePasswordContainerView.h"
#import "SmileAuthenticator.h"

@interface SmilePasswordContainerView()

@end

@implementation SmilePasswordContainerView

-(void)configureAndAddSmilePasswordView{
    
    if (self.smilePasswordView) {
        [self.smilePasswordView removeFromSuperview];
        self.smilePasswordView = nil;
    }
    
    self.backgroundColor = [UIColor clearColor];
    
    NSInteger count = [SmileAuthenticator sharedInstance].passcodeDigit;
    
    if ([SmileAuthenticator sharedInstance].tintColor) {
        self.mainColor = [SmileAuthenticator sharedInstance].tintColor;
    }
    
    self.smilePasswordView = [[SmilePasswordView alloc] initWithCircleColor:self.mainColor circleCount:count frame:self.bounds];
    
    [self addSubview:self.smilePasswordView];
    
    if (self.delegate) {
        [self.delegate smileContainerLayoutSubview];
    }
}

#if TARGET_INTERFACE_BUILDER

-(void)willMoveToSuperview:(UIView *)newSuperview{
    [self configureAndAddSmilePasswordView];
}

#else
-(void)awakeFromNib{
    [super awakeFromNib];
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    [self configureAndAddSmilePasswordView];
}

#endif

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchesEndedOnPasswordContainerView:)]) {
        [self.delegate touchesEndedOnPasswordContainerView:self];
    }
}
@end

