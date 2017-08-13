//
//  FNTaggedImageView.m
//  FNTagView
//
//  Created by 冯宁 on 2017/8/13.
//  Copyright © 2017年 demo. All rights reserved.
//

#import "FNTaggedImageView.h"

@interface FNTaggedImageView () <FNTagViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL isJustForDisplay;
@property (nonatomic, strong) UIImageView* labelsDisplaySwitcherImg;
@property (nonatomic, strong) UIButton* labelsDisplaySwitcher;

@end

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenRate (screenWidth  / 375.0)
#define fitScr(...) (ceil((__VA_ARGS__)*screenRate))

@implementation FNTaggedImageView

- (instancetype)initWithImage:(UIImage *)image justForDisplay:(BOOL)justForDisplay {
    if (self = [super initWithImage:image]) {
        self.isJustForDisplay = justForDisplay;
        UITapGestureRecognizer* tapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blankAreaClick:)];
        tapOne.cancelsTouchesInView = NO;
        tapOne.delegate = self;
        [self addGestureRecognizer:tapOne];
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
    return self;
}
- (void)setTags:(NSArray<FNTagModel *> *)tags{
    _tags = tags;
    [self setUpSubviews];
}
- (void)refreshView{
    [self setUpSubviews];
}

// 文字出现动画入口1
- (void)startTextAnimation{
    if (self.window) {
        CGRect frame = [self convertRect:self.frame toView:self.window];
        if (frame.origin.y > 0 && frame.origin.y + frame.size.height < screenHeight) {
            if (self.subviews.count < self.tags.count) {
                [self setUpSubviews];
            }
            BOOL isOn = NO;
            for (FNTagView* tag in self.subviews) {
                if ([tag isKindOfClass:[FNTagView class]]) {
                    [tag showText];
                    if (!tag.point.alpha) {
                        isOn = NO;
                    }else{
                        isOn = YES;
                    }
                }
            }
            [self labelSwitcherAnimateWithIsOn:isOn];
        }
    }
}

// 文字出现动画入口2
- (void)showAllText:(UIButton*)btn{
    [self showTexts];
}

- (void)labelSwitcherAnimateWithIsOn:(BOOL)isON{
    if (isON) {
        if (self.labelsDisplaySwitcherImg.alpha == 1.0) {
            return;
        }
    }else{
        if (self.labelsDisplaySwitcherImg.alpha != 1.0) {
            return;
        }
    }
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelsDisplaySwitcherImg.transform = CGAffineTransformMakeScale(0.6, 0.6);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.labelsDisplaySwitcherImg.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            self.labelsDisplaySwitcherImg.transform = CGAffineTransformIdentity;
        }];
    }];
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelsDisplaySwitcherImg.alpha = isON ? 1.0 : (4.0 / 7.0);
    } completion:^(BOOL finished) {
    }];
}

- (void)showTexts{
    BOOL isOn = NO;
    for (FNTagView* tag in self.subviews) {
        if ([tag isKindOfClass:[FNTagView class]]) {
            [tag showText];
            if (!tag.point.alpha) {
                isOn = NO;
            }else{
                isOn = YES;
            }
        }
    }
    [self labelSwitcherAnimateWithIsOn:isOn];
}

- (void)layoutSubviews{
    for (FNTagView* tag in self.subviews) {
        if ([tag isMemberOfClass:[FNTagView class]]) {
            FNTagModel* model = tag.model;
            CGFloat x = self.frame.size.width * model.xRate.floatValue;
            CGFloat y = self.frame.size.height * model.yRate.floatValue;
            tag.xCon.constant = x;
            tag.yCon.constant = y;
            //            [self adjustPosition:tag];
        }
    }
    if (self.isJustForDisplay) {
        [self addSubview:self.labelsDisplaySwitcher];
        self.labelsDisplaySwitcher.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.labelsDisplaySwitcher attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.labelsDisplaySwitcher attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-15]];
        [super layoutSubviews];
    }
}



#pragma mark - gesture delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]] || [gestureRecognizer isMemberOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    CGPoint point = [gestureRecognizer locationInView:self];
    for (FNTagView* tag in self.subviews) {
        if ([tag isMemberOfClass:[FNTagView class]]) {
            if (CGRectContainsPoint(tag.frame, point)) {
                return NO;
            }
            for (UIView* text in tag.subviews) {
                CGRect textFrame = [text convertRect:text.frame toView:self];
                if (CGRectContainsPoint(textFrame, point)) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    for (UIView* subview in self.subviews) {
        if ([otherGestureRecognizer.view isEqual:subview]) {
            return NO;
        }
    }
    return YES;
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self];
    for (FNTagView* tag in self.subviews) {
        if ([tag isMemberOfClass:[FNTagView class]]) {
            if (CGRectContainsPoint(tag.frame, point)) {
                return NO;
            }
            for (UIView* text in tag.subviews) {
                CGRect textFrame = [text convertRect:text.frame toView:self];
                if (CGRectContainsPoint(textFrame, point)) {
                    return NO;
                }
            }
        }
    }
    return ([touch.view isEqual:self]);
    return YES;
}

// called before pressesBegan:withEvent: is called on the gesture recognizer for a new press. return NO to prevent the gesture recognizer from seeing this press
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press{
    for (UIGestureRecognizer* gesture in press.gestureRecognizers) {
        CGPoint point = [gesture locationInView:self];
        for (FNTagView* tag in self.subviews) {
            if ([tag isMemberOfClass:[FNTagView class]]) {
                if (CGRectContainsPoint(tag.frame, point)) {
                    return NO;
                }
                for (UIView* text in tag.subviews) {
                    CGRect textFrame = [text convertRect:text.frame toView:self];
                    if (CGRectContainsPoint(textFrame, point)) {
                        return NO;
                    }
                }
            }
        }
    }
    return YES;
}

#pragma mark - 响应事件
- (void)blankAreaClick:(UITapGestureRecognizer*)tap{
    if ([self.delegate respondsToSelector:@selector(displayer:canAddTagWithGesture:)]) {
        BOOL canAddTag = [self.delegate displayer:self canAddTagWithGesture:tap];
        if (canAddTag) {
            CGPoint tapPoint = [tap locationInView:self];
            CGFloat x = tapPoint.x;
            CGFloat y = tapPoint.y;
            FNTagModel* model = [[FNTagModel alloc] init];
            CGFloat xRate =  x / self.frame.size.width;
            CGFloat yRate = y / self.frame.size.height;
            model.xRate = [NSNumber numberWithFloat:xRate];
            model.yRate = [NSNumber numberWithFloat:yRate];
            if (!self.tags) {
                _tags = [NSArray array];
            }
            NSMutableArray* mArray = [NSMutableArray arrayWithArray:self.tags];
            [mArray addObject:model];
            _tags = mArray.copy;
            FNTagView* tag = [self addTagWithModel:model];
            [self setNeedsUpdateConstraints];
            for (FNTagView* tagView in self.subviews) {
                if ([tagView isKindOfClass:[FNTagView class]] && ![tagView isEqual:tag]) {
                    if (CGRectIntersectsRect([tagView unionFrame], [tag unionFrame])) {
                        tag.yCon.constant = tagView.yCon.constant + 29*screenRate;
                        model.yRate = [NSNumber numberWithFloat:tag.yCon.constant / self.frame.size.height];
                    }
                }
            }
            [self adjustPosition:tag];
            tag.model.xRate = [NSNumber numberWithFloat:(tag.xCon.constant / (self.frame.size.width ? self.frame.size.width : 1.0))];
            tag.model.yRate = [NSNumber numberWithFloat:(tag.yCon.constant / (self.frame.size.height ? self.frame.size.height : 1.0))];
            [self setNeedsUpdateConstraints];
            if ([self.delegate respondsToSelector:@selector(displayer:createdTagWithModel:tag:)]) {
                [self.delegate displayer:self createdTagWithModel:self.tags.lastObject tag:tag];
            }
        }
    }
}

#pragma mark - 代理事件
- (void)tagNeedAdjustPostion:(FNTagView *)tag{
    [self adjustPosition:tag];
}

- (BOOL)allowTagBeginEdit:(FNTagView*)tag withGesture:(UITapGestureRecognizer*)tap {
    FNTagView* editingLabel = [self isEditingLabel];
    if (editingLabel) {
        if ([editingLabel isEqual:tag]) {
            [self changeDirectionWithLabel:tag];
            return YES;
        }else{
            [self changeDirectionWithLabel:tag];
            return NO;
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(displayerAllowEditTag:whenTagClickedWithTag:gesture:)]) {
            BOOL allow = [self.delegate displayerAllowEditTag:self whenTagClickedWithTag:tag gesture:tap];
            return  allow;
        }
    }
    return NO;
}

- (void)changeDirectionWithLabel:(FNTagView*)label{
    if ([self.delegate respondsToSelector:@selector(displayer:allowLabelChangeDirection:)]) {
        BOOL allow = [self.delegate displayer:self allowLabelChangeDirection:label];
        if (allow) {
            [label changeDirectionSwitcherClick];
        }
    }
}

- (FNTagView*)isEditingLabel{
    for (UIView* subview in self.subviews) {
        if ([subview isKindOfClass:[FNTagView class]]) {
            if (((FNTagView*)subview).isEditing) {
                return (FNTagView*)subview;
            }
        }
    }
    return nil;
}
- (void)tag:(FNTagView*)tag panedWithGesture:(UIPanGestureRecognizer*)pan{
    if ([self.delegate respondsToSelector:@selector(displayer:canMoveTag:)]) {
        BOOL canMove = [self.delegate displayer:self canMoveTag:tag];
        if (canMove) {
            
            UIGestureRecognizerState state = pan.state;
            if (state == UIGestureRecognizerStateBegan) {
                tag.startPoint = [NSValue valueWithCGPoint:tag.unionFrame.origin];
                tag.originPoint = [NSValue valueWithCGPoint:[pan translationInView:tag]];
                tag.originCon = [NSValue valueWithCGPoint:CGPointMake(tag.xCon.constant, tag.yCon.constant)];
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    tag.containerView.transform = CGAffineTransformScale(tag.containerView.transform, 1.5, 1.5);
                } completion:nil];
                return;
            }
            if (state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateEnded) {
                CGPoint location = [pan translationInView:tag];
                CGPoint originPoint = tag.originPoint.CGPointValue;
                CGPoint originCon = tag.originCon.CGPointValue;
                CGPoint startPoint = tag.startPoint.CGPointValue;
                CGFloat disX = (location.x - originPoint.x);
                CGFloat disY = (location.y - originPoint.y);
                for (FNTagView* tagView in self.subviews) {
                    if (![tagView isMemberOfClass:[FNTagView class]]) {
                        continue;
                    }
                    if ([tagView isEqual:tag]) {
                        continue;
                    }
                    CGRect judgeFrame = tagView.unionFrame;
                    CGRect changedFrame = CGRectMake(startPoint.x + disX, startPoint.y + disY, tag.unionFrame.size.width, tag.unionFrame.size.height);
                    
                    if (CGRectIntersectsRect(changedFrame, judgeFrame)) {
                        CGFloat changedY = startPoint.y + disY;
                        if (judgeFrame.origin.y - changedY > - judgeFrame.size.height / 2) {
                            disY = (judgeFrame.origin.y - [tag unionFrame].size.height) - startPoint.y;
                        }else{
                            disY = (judgeFrame.origin.y + [tag unionFrame].size.height) - startPoint.y;
                        }
                    }
                }
                CGFloat nX = originCon.x + disX;
                CGFloat nY = originCon.y + disY;
                tag.xCon.constant = nX;
                tag.yCon.constant = nY;
                CGFloat xRate = tag.xCon.constant / tag.superview.frame.size.width ? tag.superview.frame.size.width : 1;
                CGFloat yRate = tag.yCon.constant / tag.superview.frame.size.height ? tag.superview.frame.size.height : 1;
                tag.model.xRate = [NSNumber numberWithFloat:xRate];
                tag.model.yRate = [NSNumber numberWithFloat:yRate];
                [self adjustPosition:tag];
                tag.model.xRate = [NSNumber numberWithFloat:(tag.xCon.constant / (self.frame.size.width ? self.frame.size.width : 1.0))];
                tag.model.yRate = [NSNumber numberWithFloat:(tag.yCon.constant / (self.frame.size.height ? self.frame.size.height : 1.0))];
                [self setNeedsUpdateConstraints];
                if (state != UIGestureRecognizerStateChanged) {
                    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        tag.containerView.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }
            }
            
        }
    }
}

- (void)adjustPosition:(FNTagView*)tagView{
    if (!self.window) {
        return;
    }
    if (!self.frame.size.width || !self.frame.size.height) {
        return;
    }
    CGRect unionFrame = [tagView unionFrame];
    BOOL haveChanged = NO;
    if (!tagView.model.leftForward.boolValue) {
        if (tagView.xCon.constant < 0) {
            tagView.xCon.constant = 0;
            haveChanged = YES;
        }
        if (tagView.yCon.constant - (tagView.textView.frame.size.height - tagView.frame.size.height) / 2 < 0) {
            tagView.yCon.constant = (tagView.textView.frame.size.height - tagView.frame.size.height) / 2;
            haveChanged = YES;
        }
        if (tagView.xCon.constant + unionFrame.size.width > tagView.superview.frame.size.width) {
            tagView.xCon.constant = tagView.superview.frame.size.width - unionFrame.size.width;
            haveChanged = YES;
        }
        if (tagView.yCon.constant + (tagView.textView.frame.size.height - tagView.frame.size.height) / 2 + tagView.frame.size.height > tagView.superview.frame.size.height ) {
            tagView.yCon.constant = tagView.superview.frame.size.height - ((tagView.textView.frame.size.height - tagView.frame.size.height) / 2 + tagView.frame.size.height);
            haveChanged = YES;
        }
    }else{
        if (tagView.xCon.constant - (tagView.unionFrame.size.width - tagView.frame.size.width) < 0) {
            tagView.xCon.constant = (tagView.unionFrame.size.width - tagView.frame.size.width);
            haveChanged = YES;
        }
        if (tagView.yCon.constant - (tagView.textView.frame.size.height - tagView.frame.size.height) / 2 < 0) {
            tagView.yCon.constant = (tagView.textView.frame.size.height - tagView.frame.size.height) / 2;
            haveChanged = YES;
        }
        if (tagView.xCon.constant + tagView.frame.size.width > tagView.superview.frame.size.width) {
            tagView.xCon.constant = tagView.superview.frame.size.width - tagView.frame.size.width;
            haveChanged = YES;
        }
        if (tagView.yCon.constant + (tagView.textView.frame.size.height - tagView.frame.size.height) / 2 + tagView.frame.size.height > tagView.superview.frame.size.height ) {
            tagView.yCon.constant = tagView.superview.frame.size.height - ((tagView.textView.frame.size.height - tagView.frame.size.height) / 2 + tagView.frame.size.height);
            haveChanged = YES;
        }
    }
    if (haveChanged) {
        tagView.model.xRate = @(tagView.xCon.constant / (self.frame.size.width ? self.frame.size.width : 1.0));
        tagView.model.yRate = @(tagView.yCon.constant / (self.frame.size.height ? self.frame.size.height : 1.0));
    }
}


- (void)tag:(FNTagView*)tag longPressWithGesture:(UILongPressGestureRecognizer*)longPress{
    if ([self.delegate respondsToSelector:@selector(displayerAllowDeleteTag:longPressedWithTag:gesture:)]) {
        if ([self.delegate displayerAllowDeleteTag:self longPressedWithTag:tag gesture:longPress]) {
            if (!self.tags) {
                _tags = [NSArray array];
            }
            NSMutableArray* mArray = [NSMutableArray arrayWithArray:self.tags];
            for (FNTagModel* tagModel in _tags) {
                if ([tagModel isEqual:tag.model]) {
                    [mArray removeObject:tagModel];
                }
            }
            self.tags = mArray.copy;
        }
    }
}

- (UIButton *)labelsDisplaySwitcher{
    if (_labelsDisplaySwitcher == nil) {
        _labelsDisplaySwitcher = [[UIButton alloc] init];
        [_labelsDisplaySwitcher setImage:[UIImage imageNamed:@"homeLookCellShowLabelBtn"] forState:UIControlStateNormal];
        [_labelsDisplaySwitcher addTarget:self action:@selector(showAllText:) forControlEvents:UIControlEventTouchUpInside];
        [_labelsDisplaySwitcher addSubview:self.labelsDisplaySwitcherImg];
        self.labelsDisplaySwitcherImg.translatesAutoresizingMaskIntoConstraints = NO;
        [_labelsDisplaySwitcher addConstraint:[NSLayoutConstraint constraintWithItem:self.labelsDisplaySwitcherImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_labelsDisplaySwitcher attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [_labelsDisplaySwitcher addConstraint:[NSLayoutConstraint constraintWithItem:self.labelsDisplaySwitcherImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_labelsDisplaySwitcher attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    return _labelsDisplaySwitcher;
}

- (UIImageView *)labelsDisplaySwitcherImg{
    if (_labelsDisplaySwitcherImg == nil) {
        _labelsDisplaySwitcherImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taggedimagetagswitcherinner"]];
        _labelsDisplaySwitcherImg.userInteractionEnabled = NO;
    }
    return _labelsDisplaySwitcherImg;
}


- (void)setUpSubviews{
    for (UIView* view in self.subviews) {
        if ([view isMemberOfClass:[FNTagView class]]) {
            [view removeFromSuperview];
        }
    }
    BOOL hasLabel = NO;
    for (UIView* view in self.subviews) {
        if ([view isMemberOfClass:[FNTagView class]]) {
            hasLabel = YES;
        }
    }
    if (!hasLabel) {
        for (FNTagModel* model in self.tags) {
            FNTagView* tag = [self addTagWithModel:model];
            [self adjustPosition:tag];
            [self setNeedsUpdateConstraints];
        }
        [self setNeedsUpdateConstraints];
    }
}

- (FNTagView*)addTagWithModel:(FNTagModel*)model{
    FNTagView* tag = [[FNTagView alloc] initWithModel:model justForDisplay:self.isJustForDisplay];
    tag.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat x = self.frame.size.width * model.xRate.floatValue;
    CGFloat y = self.frame.size.height * model.yRate.floatValue;
    [self addSubview:tag];
    NSLayoutConstraint* yCon = [NSLayoutConstraint constraintWithItem:tag attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:y];
    NSLayoutConstraint* xCon = [NSLayoutConstraint constraintWithItem:tag attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:x];
    [self addConstraints:@[xCon,yCon]];
    tag.xCon = xCon;
    tag.yCon = yCon;
    tag.delegate = self;
    return tag;
}


@end
