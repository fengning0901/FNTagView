//
//  ViewController.m
//  FNTagView
//
//  Created by 冯宁 on 2017/8/13.
//  Copyright © 2017年 demo. All rights reserved.
//

#import "ViewController.h"
#import "FNTaggedImageView.h"

@interface ViewController () <FNTaggedImageViewDelegate, UITextViewDelegate>

@end

@implementation ViewController {
    FNTaggedImageView* _taggedImage;
    UITextView* _textView;
    UISwitch* _directionSwitch;
    UISwitch* _addtionSwith;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _taggedImage = [[FNTaggedImageView alloc] initWithImage:[UIImage imageNamed:@"example.jpg"] justForDisplay:NO];
    _taggedImage.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    _taggedImage.delegate = self;
    [self.view addSubview:_taggedImage];
    
    _textView = [UITextView new];
    _textView.delegate = self;
    _textView.frame = CGRectMake(20, CGRectGetMaxY(_taggedImage.frame) + 20, [UIScreen mainScreen].bounds.size.width - 40, 35);
    _textView.layer.borderColor = [UIColor grayColor].CGColor;
    _textView.layer.borderWidth = 1;
    [self.view addSubview:_textView];
    
    UILabel* al = [UILabel new];
    al.text = @"额外按钮开关";
    al.font = [UIFont systemFontOfSize:12];
    al.frame = CGRectMake(20, CGRectGetMaxY(_textView.frame) + 20, 100, 35);
    [self.view addSubview:al];
    
    _addtionSwith = [UISwitch new];
    _addtionSwith.frame = CGRectMake(CGRectGetMaxX(al.frame), CGRectGetMinY(al.frame), 200, 35);
    [self.view addSubview:_addtionSwith];
}

#pragma mark - delegate 
// 关于tag
- (void)displayer:(FNTaggedImageView*)displayer whenTagDeleteBtnClickedWithTag:(FNTagView*)tag btn:(UIButton*)btn {
    
}
- (BOOL)displayerAllowEditTag:(FNTaggedImageView*)displayer whenTagClickedWithTag:(FNTagView*)tag gesture:(UITapGestureRecognizer*)gesture {
    return YES;
}
- (BOOL)displayer:(FNTaggedImageView*)displayer canMoveTag:(FNTagView*)tag {
    return YES;
}
- (BOOL)displayerAllowDeleteTag:(FNTaggedImageView*)displayer longPressedWithTag:(FNTagView*)tag gesture:(UILongPressGestureRecognizer*)gesture; {
    return YES;
}
- (BOOL)displayer:(FNTaggedImageView*)displayer allowLabelChangeDirection:(FNTagView*)tag {
    return YES;
}
- (void)displayer:(FNTaggedImageView*)displayer createdTagWithModel:(FNTagModel*)model tag:(FNTagView*)tag {
    model.title = _textView.text;
    model.showAddtion = @(_addtionSwith.on);
}
- (BOOL)displayer:(FNTaggedImageView*)displayer canAddTagWithGesture:(UITapGestureRecognizer*)tap {
    return YES;
}


@end
