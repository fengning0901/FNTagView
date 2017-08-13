//
//  FNTaggedImageView.h
//  FNTagView
//
//  Created by 冯宁 on 2017/8/13.
//  Copyright © 2017年 demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTagModel.h"
#import "FNTagView.h"

@class FNTaggedImageView;

/**
 *  三个代理方法 如果是编辑器那么就必须全部实现，如果是仅仅展现，那么仅仅实现需要的就可以
 */
@protocol FNTaggedImageViewDelegate <NSObject>

@optional
// 关于tag
- (BOOL)displayerAllowEditTag:(FNTaggedImageView*)displayer whenTagClickedWithTag:(FNTagView*)tag gesture:(UITapGestureRecognizer*)gesture;
- (BOOL)displayer:(FNTaggedImageView*)displayer canMoveTag:(FNTagView*)tag;
- (BOOL)displayerAllowDeleteTag:(FNTaggedImageView*)displayer longPressedWithTag:(FNTagView*)tag gesture:(UILongPressGestureRecognizer*)gesture;
- (BOOL)displayer:(FNTaggedImageView*)displayer allowLabelChangeDirection:(FNTagView*)tag;
- (void)displayer:(FNTaggedImageView*)displayer createdTagWithModel:(FNTagModel*)model tag:(FNTagView*)tag;

// 关于空白区域点击
- (BOOL)displayer:(FNTaggedImageView*)displayer canAddTagWithGesture:(UITapGestureRecognizer*)tap;
@end

/**
 tag的显示视图 可以用于创建之后的feed显示
 */

@interface FNTaggedImageView : UIImageView

- (instancetype)initWithImage:(UIImage *)image justForDisplay:(BOOL)justForDisplay;

@property (nonatomic, strong) NSArray<FNTagModel*>* tags;

@property (nonatomic, weak) id<FNTaggedImageViewDelegate> delegate;

// 用于重新定位labels
- (void)refreshView;
- (void)startTextAnimation;

@end
