//
//  JHFlatAlertView.m
//  JHFlatAlertView
//
//  Created by Jonathan Hooper on 7/26/13.
//  Copyright (c) 2013 Jonathan Hooper. All rights reserved.
//

#import "JHFlatAlertView.h"
#import <QuartzCore/QuartzCore.h>

// Constants for use laying out elements
static const float kJHAlertBoxMinHeight;
static const float kJHAlertBoxWidth = 245.0;
static const float kJHAlertBoxPadding = 20.0;
static const float kJHAlertBoxCornerRadius = 20.0;
static const float kJHAlertBoxBorderWidth = 2.0;
static const float kJHAlertBoxItemSpacing = 7.0;
static const float kJHAlertBoxItemWidth = kJHAlertBoxWidth - kJHAlertBoxPadding * 2.0;

static const float kJHTitleLabelHeight = 30.0;
static const float kJHTitleLabelFontSize = 28.0;

static const float kJHImageViewMaxHeight = 145.0;

static const float kJHTextViewMaxHeightWithoutImage = 262.0;
static const float kJHTextViewMaxHeightWithImage = 105.0;
static const float kJHTextViewFontSize = 15.0;

static const float kJHButtonHeight = 44.0;
static const float kJHSingleButtonWidth = 140.0;
static const float kJHButtonSpacing = 10.0;
static const float kJHButtonCornerRadius = 10.0;
static const float kJHButtonBorderWidth = 1.5;

static const UIColor *defaultBackgroundColor;
static const UIColor *defaultBorderColor;

@interface JHFlatAlertView ()

@property (nonatomic, strong) void (^buttonBlock)();
@property (nonatomic, strong) void (^cancelButtonBlock)();

// View elements
@property (nonatomic, strong) UIView *alertBox;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *cancelButton;

- (void)drawAlertBox;
- (IBAction)buttonPressed:(id)sender;

@end

@implementation JHFlatAlertView

+ (void)initialize
{
    defaultBackgroundColor = [UIColor whiteColor];
    defaultBorderColor = [UIColor grayColor];
}

- (UIColor *)backgroundColor
{
    if (!_backgroundColor){
        _backgroundColor = [defaultBackgroundColor copy];
    }
    return _backgroundColor;
}

- (UIColor *)borderColor
{
    if (!_borderColor){
        _borderColor = [defaultBorderColor copy];
    }
    return _borderColor;
}

+ (void)setDefaultBackgroundColor:(UIColor *)color
{
    defaultBackgroundColor = color;
}

+ (void)setDefaultBorderColor:(UIColor *)color
{
    defaultBorderColor = color;
}

- (id)init
{
    CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.25f;
        [self addSubview:backgroundView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self init];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
    return [self initWithTitle:title message:message image:nil];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message imagePath:(NSString *)imagePath
{
    return [self initWithTitle:title message:message image:[[UIImage alloc] initWithContentsOfFile:imagePath]];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message imageNamed:(NSString *)imageName
{
    return [self initWithTitle:title message:message image:[UIImage imageNamed:imageName]];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image
{
    self = [self init];
    self.title = title;
    self.message = message;
    if (image.size.height > kJHImageViewMaxHeight || image.size.width > kJHAlertBoxItemWidth){
        float imageResizeScale = MIN(kJHAlertBoxItemWidth / image.size.width, kJHImageViewMaxHeight / image.size.height);
        CGSize newSize = CGSizeMake(image.size.width * imageResizeScale, image.size.height * imageResizeScale);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.image = newImage;
    } else {
        self.image = image;
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block type:(JHFlatAlertViewButtonType)buttonType{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:self.borderColor forState:UIControlStateNormal];
    [button setTitleColor:self.backgroundColor forState:UIControlStateSelected];
    button.backgroundColor = self.backgroundColor;
    button.layer.borderColor = self.borderColor.CGColor;
    button.layer.cornerRadius = kJHButtonCornerRadius;
    button.layer.borderWidth = kJHButtonBorderWidth;
    
    switch (buttonType) {
        case JHFlatAlertViewButtonTypeRegular:
            self.button = button;
            [self.button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.buttonBlock = block;
            break;
        case JHFlatAlertViewButtonTypeCancel:
            self.cancelButton = button;
            [self.cancelButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.cancelButtonBlock = block;
            break;
    }
}

- (void)removeButtonWithType:(JHFlatAlertViewButtonType)buttonType
{
    if (JHFlatAlertViewButtonTypeRegular){
        self.button = nil;
    } else if (JHFlatAlertViewButtonTypeCancel){
        self.cancelButton = nil;
    }
}

- (void)showAnimated:(BOOL)animated
{
    [self drawAlertBox];
    if (animated){
        self.hidden = NO;
        self.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [self setAlpha:1.0];
        [UIView commitAnimations];
    } else {
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self];
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    if (animated){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
        self.alpha = 0.0;
        [UIView commitAnimations];
    } else {
        [self removeFromSuperview];
    }
}

- (void)drawAlertBox
{    
    self.alertBox = [[UIView alloc] init];
    
    //Layout title
    float altitude = kJHAlertBoxPadding;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kJHAlertBoxPadding, altitude, kJHAlertBoxItemWidth, kJHTitleLabelHeight)];
    titleLabel.text = self.title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = self.borderColor;
    titleLabel.font = [UIFont boldSystemFontOfSize:kJHTitleLabelFontSize];
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.alertBox addSubview:titleLabel];
    
    altitude += titleLabel.frame.size.height;
    
    //Layout image
    UIImageView *imageView;
    if (self.image){
        altitude += kJHAlertBoxItemSpacing;
        
        imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.frame = CGRectMake(kJHAlertBoxPadding, altitude, kJHAlertBoxItemWidth, self.image.size.height);
        imageView.contentMode = UIViewContentModeCenter;
        [self.alertBox addSubview:imageView];
        
        altitude += imageView.frame.size.height;
    }
    
    // Layout message
    UITextView *messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(kJHAlertBoxPadding, altitude, kJHAlertBoxItemWidth, kJHTextViewMaxHeightWithoutImage)];
    messageTextView.text = self.message;
    messageTextView.textAlignment = NSTextAlignmentCenter;
    messageTextView.textColor = self.borderColor;
    messageTextView.backgroundColor = self.backgroundColor;
    messageTextView.font = [UIFont systemFontOfSize:kJHTextViewFontSize];
    messageTextView.editable = NO;
    messageTextView.userInteractionEnabled = NO;
    [self.alertBox addSubview:messageTextView];
    if (self.image && messageTextView.contentSize.height >= kJHTextViewMaxHeightWithImage - .0001)
    {
        messageTextView.frame = CGRectMake(kJHAlertBoxPadding, altitude - 5.0, kJHAlertBoxItemWidth, kJHTextViewMaxHeightWithImage);
        messageTextView.userInteractionEnabled = YES;
        messageTextView.scrollEnabled = YES;
        altitude += kJHAlertBoxItemSpacing + kJHTextViewMaxHeightWithImage;
    } else if (!self.image && messageTextView.contentSize.height >= kJHTextViewMaxHeightWithoutImage){
        messageTextView.frame = CGRectMake(kJHAlertBoxPadding, altitude - 5.0, kJHAlertBoxItemWidth, kJHTextViewMaxHeightWithoutImage);
        messageTextView.userInteractionEnabled = YES;
        messageTextView.scrollEnabled = YES;
        altitude += kJHAlertBoxItemSpacing + kJHTextViewMaxHeightWithoutImage;
    } else {
        messageTextView.frame = CGRectMake(kJHAlertBoxPadding, altitude -5.0, kJHAlertBoxItemWidth, messageTextView.contentSize.height);
        messageTextView.scrollEnabled = NO;
        altitude += messageTextView.contentSize.height;
    }
    
    //Layout buttons
    if (self.button && self.cancelButton){
        self.button.frame = CGRectMake(kJHAlertBoxPadding, altitude, kJHAlertBoxItemWidth / 2.0 - kJHButtonSpacing / 2.0, kJHButtonHeight);
        self.cancelButton.frame = CGRectMake(kJHAlertBoxPadding + kJHAlertBoxItemWidth / 2.0 + kJHButtonSpacing, altitude, kJHAlertBoxItemWidth / 2.0 - kJHButtonSpacing / 2.0, kJHButtonHeight);
        [self.alertBox addSubview:self.button];
        [self.alertBox addSubview:self.cancelButton];
    } else if (self.button){
        self.button.frame = CGRectMake((kJHAlertBoxWidth - kJHSingleButtonWidth) / 2.0, altitude, kJHSingleButtonWidth, kJHButtonHeight);
        [self.alertBox addSubview:self.button];
    } else if (self.cancelButton){
        self.cancelButton.frame = CGRectMake((kJHAlertBoxWidth - kJHSingleButtonWidth) / 2.0, altitude, kJHSingleButtonWidth, kJHButtonHeight);
        [self.alertBox addSubview:self.cancelButton];
    }
    altitude += kJHButtonHeight + kJHAlertBoxPadding;
    
    //Layout alert box
    self.alertBox.frame = CGRectMake(self.frame.size.width / 2.0 - kJHAlertBoxWidth / 2.0, (self.frame.size.height / 2.0 - altitude / 2.0) * 0.85, kJHAlertBoxWidth, altitude);
    self.alertBox.backgroundColor = self.backgroundColor;
    self.alertBox.layer.cornerRadius = kJHAlertBoxCornerRadius;
    self.alertBox.layer.borderColor = self.borderColor.CGColor;
    self.alertBox.layer.borderWidth = kJHAlertBoxBorderWidth;
    
    self.alertBox.layer.shadowColor = [UIColor blackColor].CGColor;
    self.alertBox.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    self.alertBox.layer.shadowOpacity = 0.4;
    
        
    [self addSubview:self.alertBox];
}

- (IBAction)buttonPressed:(id)sender
{
    [self dismissAnimated:YES];
    if (sender == self.button){
        self.button.selected = YES;
        self.button.backgroundColor = self.borderColor;
        self.button.layer.borderColor = self.backgroundColor.CGColor;
        [self dismissAnimated:YES];
        if (self.buttonBlock != nil) self.buttonBlock();
    } else if (sender == self.cancelButton){
        self.cancelButton.selected = YES;
        self.cancelButton.backgroundColor = self.borderColor;
        self.cancelButton.layer.borderColor = self.backgroundColor.CGColor;
        [self dismissAnimated:YES];
        if (self.cancelButtonBlock != nil) self.cancelButtonBlock();
    }
}

@end
