//
//  FNTagView.h
//  FNTagView
//
//  Created by 冯宁 on 2017/8/13.
//  Copyright © 2017年 demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTagModel.h"

@class FNTagView;
@protocol FNTagViewDelegate <NSObject>

@optional
- (BOOL)allowTagBeginEdit:(FNTagView*)tag withGesture:(UITapGestureRecognizer*)tap;
- (void)tag:(FNTagView*)tag panedWithGesture:(UIPanGestureRecognizer*)pan;
- (void)tag:(FNTagView*)tag longPressWithGesture:(UILongPressGestureRecognizer*)longPress;
- (void)tagNeedAdjustPostion:(FNTagView*)tag;

@end

@class FNTagTextView;
@protocol FNTagTextViewDelegate <NSObject>

- (void)text:(FNTagTextView*)text tapedWithGesture:(UITapGestureRecognizer*)tap;
- (void)text:(FNTagTextView*)text pannedWithGesture:(UIPanGestureRecognizer*)pan;
- (void)text:(FNTagTextView*)text longPressedWithGesture:(UILongPressGestureRecognizer*)longPress;

@end

@interface FNTagPointView : UIImageView
@property (nonatomic, assign,readonly) CGSize size;
@end

@interface FNTagTextView : UIView

@property (nonatomic, copy) NSString* title;
@property (nonatomic, weak) id <FNTagTextViewDelegate> delegate;
- (instancetype)initWithLeftForward:(BOOL)leftForward;

@end

@interface FNTagView : UIView

- (void)changeDirectionSwitcherClick;
- (void)showText;
- (instancetype)initWithModel:(FNTagModel*)model justForDisplay:(BOOL)justForDisplay;
- (void)startEditing;
- (void)endEditing;
@property (nonatomic, assign, readonly) BOOL isEditing;

@property (nonatomic, weak) NSLayoutConstraint* xCon;
@property (nonatomic, weak) NSLayoutConstraint* yCon;
@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, assign) BOOL textHadShown;
@property (nonatomic, strong, readonly) FNTagPointView* point;
@property (nonatomic, strong) NSValue* originPoint;
@property (nonatomic, strong) NSValue* originCon;
@property (nonatomic, strong) NSValue* startPoint;
@property (nonatomic, assign, readonly) BOOL isAnimating;
@property (nonatomic, strong, readonly) FNTagTextView* textView;
@property (nonatomic, assign) CGRect unionFrame;
@property (nonatomic, readonly) FNTagModel* model;
@property (nonatomic, weak) id<FNTagViewDelegate> delegate;

@end

@interface FNTagAdditionView : UIImageView

@end
