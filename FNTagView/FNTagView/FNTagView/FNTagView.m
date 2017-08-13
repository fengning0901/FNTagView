//
//  FNTagView.m
//  FNTagView
//
//  Created by 冯宁 on 2017/8/13.
//  Copyright © 2017年 demo. All rights reserved.
//

#import "FNTagView.h"

@interface FNTagView () <UIGestureRecognizerDelegate, FNTagTextViewDelegate, FNTagModelDelegate>
@property (nonatomic, strong) FNTagPointView* point;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, strong) FNTagTextView* textView;
@property (nonatomic, strong) FNTagAdditionView* catView;
@property (nonatomic, strong) NSLayoutConstraint* catCon;
@property (nonatomic, strong) NSLayoutConstraint* dirCon;
@property (nonatomic, assign) BOOL isJustForDisplay;
@property (nonatomic, strong) NSLayoutConstraint* textCon;
@property (nonatomic, strong) NSTimer* editingAnimationTimer;
@property (nonatomic, assign) BOOL showTextAnimating;
@end

static CGFloat height;

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenRate (screenWidth  / 375.0)
#define fitScr(...) (ceil((__VA_ARGS__)*screenRate))

@implementation FNTagView

- (instancetype)initWithModel:(FNTagModel*)model justForDisplay:(BOOL)justForDisplay{
    if (self = [super init]) {
        self.showTextAnimating = NO;
        self.isJustForDisplay = justForDisplay;
        height = 26*screenRate;
        _model = model;
        [self setUpSubviews];
        [self tagSingleModelChanged:_model];
        self.isEditing = NO;
        [self tagSingleModelChanged:self.model];
        self.model.delegate = self;
        if (!self.isJustForDisplay) {
            [self setGestureRecognizers];
        }
        
    }
    return self;
}

- (BOOL)textHadShown{
    return _point.alpha;
}

#pragma mark - model delegate
- (void)tagModel:(FNTagModel*)model leftForwardDidChange:(NSNumber*)leftForward {
    [self directionChanged];
}
- (void)tagModel:(FNTagModel*)model titleDidChange:(NSString*)title {
    [self tagSingleModelChanged:self.model];
}
- (void)tagModel:(FNTagModel*)model showAddtionDidChange:(NSNumber*)showAddtion {
    [self tagSingleModelChanged:self.model];
}


#pragma mark - 相应方法
- (void)setIsEditing:(BOOL)isEditing{
    if (_isEditing != isEditing) {
        _isEditing = isEditing;
        _dirCon.constant = _isEditing ? height : 0;
        [self.superview setNeedsUpdateConstraints];
        if ([self.delegate respondsToSelector:@selector(tagNeedAdjustPostion:)]) {
            [self.delegate tagNeedAdjustPostion:self];
        }
        if (isEditing && !self.editingAnimationTimer) {
            __weak typeof(self) weakSelf = self;
            self.editingAnimationTimer = [NSTimer timerWithTimeInterval:4.0 target:weakSelf selector:@selector(editingAnimation) userInfo:nil repeats:YES];
            [self.editingAnimationTimer fire];
            [[NSRunLoop currentRunLoop] addTimer:self.editingAnimationTimer forMode:NSRunLoopCommonModes];
        }
        if (!isEditing) {
            [self.editingAnimationTimer invalidate];
            self.editingAnimationTimer = nil;
        }
    }
}

- (void)editingAnimation{
    [self animationStepTwoWithCallBack:^(BOOL finished) {
        [self animationStepThreeWithCallBack:^(BOOL finished) {
            
        }];
    }];
}

- (void)removeFromSuperview{
    [_textView removeFromSuperview];
    [_catView removeFromSuperview];
    [super removeFromSuperview];
}

- (void)changeDirectionSwitcherClick{
    self.model.leftForward = [NSNumber numberWithBool:!self.model.leftForward.boolValue];
}

- (void)directionChanged{
    [_textView removeFromSuperview];
    [_catView removeFromSuperview];
    _textView = nil;
    _catView = nil;
    [self didMoveToSuperview];
    [self tagSingleModelChanged:self.model];
    [self.superview setNeedsUpdateConstraints];
    if ([self.delegate respondsToSelector:@selector(tagNeedAdjustPostion:)]) {
        [self.delegate tagNeedAdjustPostion:self];
    }
    self.model.xRate = [NSNumber numberWithFloat:(self.xCon.constant / (self.superview.frame.size.width ? self.superview.frame.size.width : 1.0))];
    self.model.yRate = [NSNumber numberWithFloat:(self.yCon.constant / (self.superview.frame.size.height ? self.superview.frame.size.height : 1.0))];
    [self.superview setNeedsUpdateConstraints];
}

- (CGRect)unionFrame{
    if (!self.model.leftForward.boolValue) {
        return CGRectMake(self.frame.origin.x, _textView.frame.origin.y, self.frame.size.width + _textView.frame.size.width + _catView.frame.size.width + 3*screenRate , _textView.frame.size.height);
    }else{
        return CGRectMake(self.frame.origin.x - (_textView.frame.size.width + _catView.frame.size.width + 3*screenRate), _textView.frame.origin.y, self.frame.size.width + _textView.frame.size.width + _catView.frame.size.width , _textView.frame.size.height);
    }
}

- (void)setGestureRecognizers{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEventInvoke:)];
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEventInvoke:)];
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEventInvoke:)];
    tap.cancelsTouchesInView = NO;
    pan.cancelsTouchesInView = NO;
    longPress.cancelsTouchesInView = NO;
    tap.delegate = self;
    pan.delegate = self;
    longPress.delegate = self;
    [self setGestureRecognizers:@[tap,pan,longPress]];
}

- (void)setUpSubviews{
    if (self.isJustForDisplay) {
        return;
    }
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.point];
    self.point.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"point":self.point,@"con":self.containerView};
    NSDictionary* metrics = @{@"pH":@(self.point.size.width)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[con(==pH)]-0-|" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[con(==pH)]-0-|" options:0 metrics:metrics views:dict]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[point(==pH)]-0-|" options:0 metrics:metrics views:dict]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[point(==pH)]-0-|" options:0 metrics:metrics views:dict]];
}

- (void)addText{
    [self addSubview:self.point];
    self.point.alpha = 0;
    self.point.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* pdict = @{@"point":self.point};
    NSDictionary* pmetrics = @{@"pH":@(self.point.size.width)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[point(==pH)]-0-|" options:0 metrics:pmetrics views:pdict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[point(==pH)]-0-|" options:0 metrics:pmetrics views:pdict]];
    [self.superview addSubview:self.textView];
    [self.superview addSubview:self.catView];
    self.textView.alpha = 0;
    self.catView.alpha = 0;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.catView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"point":self.point,@"text":self.textView,@"self":self,@"cat":self.catView};
    NSDictionary* metrics = @{@"pMg":@(5*screenRate)};
    self.catCon = [NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.model.showAddtion.boolValue ? height : 0];
    [self.superview addConstraint:self.catCon];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
    if (!self.model.leftForward.boolValue) {
        self.textCon = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:3*screenRate];
        [self.superview addConstraint:self.textCon];
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[text]-0-[cat]" options:0 metrics:metrics views:dict]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }else{
        self.textCon = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-3*screenRate];
        [self.superview addConstraint:self.textCon];
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cat]-0-[text]" options:0 metrics:metrics views:dict]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    [self.superview setNeedsUpdateConstraints];
    
}

- (void)animationStepOneWithCallBack:(void (^)(BOOL finished))callback{
    self.point.transform = CGAffineTransformRotate(self.point.transform, -M_PI / 4);
    self.point.alpha = 0;
    [UIView animateWithDuration:9.0/30.0 animations:^{
        self.point.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:6.0/30.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.point.transform = CGAffineTransformRotate(self.point.transform, M_PI / 4 + M_PI / 8);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:6.0/30.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.point.transform = CGAffineTransformRotate(self.point.transform, -M_PI / 8);
            } completion:^(BOOL finished) {
                if (callback) {
                    callback(finished);
                }
            }];
        }];
    }];
}
- (void)animationStepTwoWithCallBack:(void (^)(BOOL finished))callback{
    self.point.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:8.0/30.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.point.alpha = 1.0;
        self.point.transform = CGAffineTransformScale(self.point.transform, 1.3, 1.3);
    } completion:^(BOOL finished) {
        callback(finished);
    }];
}
- (void)animationStepThreeWithCallBack:(void (^)(BOOL finished))callback{
    [UIView animateWithDuration:8.0/30.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.point.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (callback) {
            callback(finished);
        }
    }];
}
- (void)animationStepFourWithCallBack:(void (^)(BOOL finished))callback{
    
    if (self.model.leftForward.boolValue) {
        self.textCon.constant = 30*screenRate;
    }else{
        self.textCon.constant = -30*screenRate;
    }
    [self.superview setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (self.model.leftForward.boolValue) {
            self.textCon.constant = -3*screenRate;
        }else{
            self.textCon.constant = 3*screenRate;
        }
        self.textView.alpha = 1.0;
        self.catView.alpha = 1.0;
        [self.superview setNeedsUpdateConstraints];
    } completion:^(BOOL finished) {
        if (callback) {
            callback(finished);
        }
    }];
}

- (void)showText{
    if (self.isJustForDisplay) {
        if (self.showTextAnimating) {
            return;
        }
        if (_textView.alpha == 0) {
            self.showTextAnimating = YES;
            NSLog(@"%s",__FUNCTION__);
            if (_point == nil || _textView == nil || _catView == nil) {
                [self addText];
                [self tagSingleModelChanged:self.model];
                if ([self.delegate respondsToSelector:@selector(tagNeedAdjustPostion:)]) {
                    [self.delegate tagNeedAdjustPostion:self];
                }
            }
            self.point.transform = CGAffineTransformIdentity;
            self.point.alpha = 0;
            [UIView animateWithDuration:8.0/30.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.point.alpha = 1.0;
                self.point.transform = CGAffineTransformScale(self.point.transform, 1.3, 1.3);
            } completion:^(BOOL finished) {
                [self animationStepThreeWithCallBack:^(BOOL finished) {
                    
                }];
                [self animationStepFourWithCallBack:^(BOOL finished) {
                    self.showTextAnimating = NO;
                    NSLog(@"%s end show text",__FUNCTION__);
                }];
            }];
        }else{
            self.showTextAnimating = YES;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                if (self.model.leftForward.boolValue) {
                    self.textView.transform = CGAffineTransformTranslate(self.textView.transform, 30, 0);
                    self.catView.transform = CGAffineTransformTranslate(self.textView.transform, 30, 0);
                }else{
                    self.textView.transform = CGAffineTransformTranslate(self.textView.transform, -30, 0);
                    self.catView.transform = CGAffineTransformTranslate(self.textView.transform, -30, 0);
                }
                self.textView.alpha = 0;
                self.catView.alpha = 0;
                self.point.alpha = 0;
            } completion:^(BOOL finished) {
                self.showTextAnimating = NO;
                [self.point removeFromSuperview];
                [self.textView removeFromSuperview];
                [self.catView removeFromSuperview];
                self.point = nil;
                self.textView = nil;
                self.catView = nil;
            }];
        }
    }
}

- (void)wavePointAnimationWithCallBack:(void (^)(BOOL finished))callback{
    if (_isAnimating) {
        return;
    }
    FNTagPointView* point = [[FNTagPointView alloc] init];
    point.image = _point.image;
    point.frame = self.bounds;
    _isAnimating = YES;
    [self addSubview:point];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:point attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:point attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [UIView animateWithDuration:1.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        point.transform = CGAffineTransformScale(point.transform, 4.0, 4.0);
        point.alpha = 0.0;
    } completion:^(BOOL finished) {
        [point removeFromSuperview];
        _isAnimating = NO;
        if (callback) {
            callback(finished);
        }
    }];
}

- (void)didMoveToSuperview{
    if (self.isJustForDisplay) {
        
    }else{
        [super didMoveToSuperview];
        [self.superview addSubview:self.textView];
        [self.superview addSubview:self.catView];
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        self.catView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary* dict = @{@"point":self.point,@"text":self.textView,@"self":self,@"cat":self.catView};
        NSDictionary* metrics = @{@"pMg":@(3*screenRate)};
        self.catCon = [NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.model.showAddtion.boolValue ? height : 0];
        [self.superview addConstraint:self.catCon];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
        if (!self.model.leftForward.boolValue) {
            [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[self]-pMg-[text]-0-[cat]" options:0 metrics:metrics views:dict]];
            [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
            [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        }else{
            [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cat]-0-[text]-pMg-[self]" options:0 metrics:metrics views:dict]];
            [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
            [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        }
        [self.superview setNeedsUpdateConstraints];
        [self tagSingleModelChanged:self.model];
    }
    
}



#pragma mark - model delegate
- (void)tagSingleModelChanged:(FNTagModel*)model{
    if (self.model.title.length) {
        _textView.title = self.model.title;
    }else{
        _textView.title = @"添加标签";
    }
    if (self.model.showAddtion.boolValue) {
        _catView.hidden = NO;
        _catCon.constant = height;
        
    }else{
        _catView.hidden = YES;
        _catCon.constant = 0;
        
    }
    _point.image = [[UIImage imageNamed:@"point"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if ([self.delegate respondsToSelector:@selector(tagNeedAdjustPostion:)]) {
        [self.delegate tagNeedAdjustPostion:self];
    }
    [self.superview setNeedsUpdateConstraints];
}

#pragma mark - text delegte
- (void)text:(FNTagTextView *)text tapedWithGesture:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(allowTagBeginEdit:withGesture:)]) {
        BOOL canEdit = [self.delegate allowTagBeginEdit:self withGesture:tap];
        if (canEdit) {
            self.isEditing = YES;
        }
    }
}

- (void)text:(FNTagTextView *)text pannedWithGesture:(UIPanGestureRecognizer *)pan{
    if ([self.delegate respondsToSelector:@selector(tag:panedWithGesture:)]) {
        [self.delegate tag:self panedWithGesture:pan];
    }
}

- (void)text:(FNTagTextView *)text longPressedWithGesture:(UILongPressGestureRecognizer *)longPress{
    if ([self.delegate respondsToSelector:@selector(tag:longPressWithGesture:)]) {
        [self.delegate tag:self longPressWithGesture:longPress];
    }
}

#pragma mark - 响应事件
- (void)tapEventInvoke:(UITapGestureRecognizer*)tap{
    if ([self.delegate respondsToSelector:@selector(allowTagBeginEdit:withGesture:)]) {
        BOOL canEdit = [self.delegate allowTagBeginEdit:self withGesture:tap];
        if (canEdit) {
            self.isEditing = YES;
        }else{
            self.isEditing = NO;
        }
    }
}
- (void)panEventInvoke:(UIPanGestureRecognizer*)pan{
    if ([self.delegate respondsToSelector:@selector(tag:panedWithGesture:)]) {
        [self.delegate tag:self panedWithGesture:pan];
    }
}
- (void)longPressEventInvoke:(UILongPressGestureRecognizer*)longPress{
    if ([self.delegate respondsToSelector:@selector(tag:longPressWithGesture:)]) {
        [self.delegate tag:self longPressWithGesture:longPress];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return  (![touch.view isEqual:self]);
}
- (void)startEditing{
    self.isEditing = YES;
}

- (void)endEditing{
    self.isEditing = NO;
}

- (FNTagTextView *)textView{
    if (_textView == nil) {
        _textView = [[FNTagTextView alloc] initWithLeftForward:self.model.leftForward.boolValue];
        _textView.delegate = self;
    }
    return _textView;
}

- (FNTagPointView *)point{
    if (_point == nil) {
        _point = [[FNTagPointView alloc] init];
        _point.image = [[UIImage imageNamed:@"point"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _point.tintColor = [UIColor redColor];
    }
    return _point;
}

- (FNTagAdditionView *)catView{
    if (_catView == nil) {
        _catView = [[FNTagAdditionView alloc] init];
        _catView.image = [UIImage imageNamed:@"addtion"];
        _catView.contentMode = UIViewContentModeScaleToFill;
        _catView.clipsToBounds = YES;
        _catView.userInteractionEnabled = YES;
        [_catView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEventInvoke:)]];
        _catView.hidden = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEventInvoke:)];
        UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEventInvoke:)];
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEventInvoke:)];
        [_catView addGestureRecognizer:tap];
        [_catView addGestureRecognizer:pan];
        [_catView addGestureRecognizer:longPress];
    }
    return _catView;
}


@end

@implementation FNTagPointView

static NSInteger width = 18;
- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleToFill;
        self.image = [[UIImage imageNamed:@"point"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.tintColor = [UIColor redColor];
        width = 18 * screenRate;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.size.width]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.size.height]];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (CGSize)size{
    return CGSizeMake(width, width);
}

@end

@interface FNTagTextView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) NSLayoutConstraint* leftCon;
@property (nonatomic, strong) NSLayoutConstraint* wCon;
@property (nonatomic, assign) BOOL leftForward;

@end

@implementation FNTagTextView

- (instancetype)initWithLeftForward:(BOOL)leftForward{
    if (self = [super init]) {
        self.leftForward = leftForward;
        [self setUpSuviews];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEventInvoke:)];
        UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEventInvoke:)];
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEventInvoke:)];
        tap.cancelsTouchesInView = NO;
        pan.cancelsTouchesInView = NO;
        longPress.cancelsTouchesInView = NO;
        tap.delegate = self;
        pan.delegate = self;
        longPress.delegate = self;
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:pan];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)layoutSubviews{
    if (!self.leftForward) {
        self.leftCon.constant = self.frame.size.height / 3 + 5*screenRate;
    }else{
        self.leftCon.constant = -(self.frame.size.height / 3 + 5*screenRate);
    }
}

- (void)drawRect:(CGRect)rect{
    CGFloat w = self.frame.size.width;
    CGFloat h = height;
    
    if (!self.leftForward) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextMoveToPoint(context, 0, h / 2);
        CGContextAddLineToPoint(context, h / 3, 0);
        CGContextAddLineToPoint(context, w, 0);
        CGContextAddLineToPoint(context, w, h);
        CGContextAddLineToPoint(context, h / 3, h);
        CGContextClosePath(context);
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetAlpha(context, 0.9);
        CGContextFillPath(context);
    }else{
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextMoveToPoint(context, w, h / 2);
        CGContextAddLineToPoint(context, w - h / 3, 0);
        CGContextAddLineToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, 0, h);
        CGContextAddLineToPoint(context, w - h / 3, h);
        CGContextClosePath(context);
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetAlpha(context, 0.9);
        CGContextFillPath(context);
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer.view isEqual:self.superview]) {
        return NO;
    }else{
        return YES;
    }
}

- (void)tapEventInvoke:(UITapGestureRecognizer*)tap{
    if ([self.delegate respondsToSelector:@selector(text:tapedWithGesture:)]) {
        [self.delegate text:self tapedWithGesture:tap];
    }
}
- (void)panEventInvoke:(UIPanGestureRecognizer*)pan{
    if ([self.delegate respondsToSelector:@selector(text:pannedWithGesture:)]) {
        [self.delegate text:self pannedWithGesture:pan];
    }
}
- (void)longPressEventInvoke:(UILongPressGestureRecognizer*)longPress{
    if ([self.delegate respondsToSelector:@selector(text:longPressedWithGesture:)]) {
        [self.delegate text:self longPressedWithGesture:longPress];
    }
}

- (void)setUpSuviews{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.wCon = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
    [self addConstraint:self.wCon];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:150*screenRate - height / 3 - 10*screenRate]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
    if (!self.leftForward) {
        self.leftCon = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:height / 3 + 5*screenRate];
        [self addConstraint:self.leftCon];
    }else{
        self.leftCon = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-(height / 3 + 5*screenRate)];
        [self addConstraint:self.leftCon];
    }
}

- (UILabel *)label{
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont fontWithName:@"Avenir-HeavyOblique" size:12*screenRate];
        _label.textColor = [UIColor whiteColor];
        _label.numberOfLines = 1;
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _label;
}

- (void)setTitle:(NSString *)title{
    _title = title.copy;
    self.label.text = _title;
    CGSize size = [_title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:self.label.font} context:nil].size;
    self.wCon.constant = height / 3 + 5*screenRate + size.width + 8*screenRate > 150*screenRate ? 150*screenRate : height / 3 + 5*screenRate + size.width + 8*screenRate;
    self.frame = CGRectMake(0, 0, self.wCon.constant, 26*screenRate);
    [self setNeedsUpdateConstraints];
    [self setNeedsDisplay];
}

@end

@implementation FNTagAdditionView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return self;
}

@end

