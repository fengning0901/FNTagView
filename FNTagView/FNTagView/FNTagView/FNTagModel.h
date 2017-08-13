//
//  FNTagModel.h
//  FNTagView
//
//  Created by 冯宁 on 2017/8/13.
//  Copyright © 2017年 demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FNTagModel;

@protocol FNTagModelDelegate <NSObject>

- (void)tagModel:(FNTagModel*)model leftForwardDidChange:(NSNumber*)leftForward;
- (void)tagModel:(FNTagModel*)model titleDidChange:(NSString*)title;
- (void)tagModel:(FNTagModel*)model showAddtionDidChange:(NSNumber*)showAddtion;

@end

@interface FNTagModel : NSObject

@property (nonatomic, weak) id <FNTagModelDelegate> delegate;

@property (nonatomic, strong) NSNumber* leftForward;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) NSNumber* showAddtion;
@property (nonatomic, strong) NSNumber* xRate;
@property (nonatomic, strong) NSNumber* yRate;

@end
