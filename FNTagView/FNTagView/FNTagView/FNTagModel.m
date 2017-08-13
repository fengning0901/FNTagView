//
//  FNTagModel.m
//  FNTagView
//
//  Created by 冯宁 on 2017/8/13.
//  Copyright © 2017年 demo. All rights reserved.
//

#import "FNTagModel.h"

@implementation FNTagModel

- (void)setTitle:(NSString *)title {
    if (_title && ([_title compare:title ? title : @""] == 0)) {
        return;
    }
    _title = title.copy;
    if ([self.delegate respondsToSelector:@selector(tagModel:titleDidChange:)]) {
        [self.delegate tagModel:self titleDidChange:_title];
    }
}

- (void)setLeftForward:(NSNumber *)leftForward {
    if (_leftForward && ([_leftForward compare:leftForward ? leftForward : @(0)] == 0)) {
        return;
    }
    _leftForward = leftForward;
    if ([self.delegate respondsToSelector:@selector(tagModel:leftForwardDidChange:)]) {
        [self.delegate tagModel:self leftForwardDidChange:_leftForward];
    }
}

- (void)setShowAddtion:(NSNumber *)showAddtion {
    if (_showAddtion && ([_showAddtion compare:showAddtion ? showAddtion : @(0)] == 0)) {
        return;
    }
    _showAddtion = showAddtion;
    if ([self.delegate respondsToSelector:@selector(tagModel:showAddtionDidChange:)]) {
        [self.delegate tagModel:self showAddtionDidChange:_showAddtion];
    }
}

@end
