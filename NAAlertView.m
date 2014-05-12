//
//  NAAlertView.m
//  NAAlertView
//
//  Created by Jonathan Hooper on 7/26/13.
//  Copyright (c) 2013 NewAperio LLC. All rights reserved.
//

#import "NAAlertView.h"
#import <POP/POP.h>
#import <QuartzCore/QuartzCore.h>

static const UIColor *defaultBackgroundColor;
static const UIColor *defaultBorderColor;
static const UIFont *defaultFont;

@interface NAAlertView ()

@property (nonatomic, strong) void (^buttonBlock)();
@property (nonatomic, strong) void (^cancelButtonBlock)();

// View elements
@property (nonatomic, strong) UIView *alertBox;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *cancelButton;

- (void)drawAlertBox;
- (void)setupButton:(UIButton *)button;
- (IBAction)buttonPressed:(id)sender;

@end

@implementation NAAlertView

+ (void)initialize
{
    defaultBackgroundColor = [UIColor whiteColor];
    defaultBorderColor = [UIColor darkGrayColor];
    defaultFont = [UIFont systemFontOfSize:17.0];
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

- (UIFont *)font
{
    if (!_font){
        _font = [defaultFont copy];
    }
    return _font;
}

+ (void)setDefaultBackgroundColor:(UIColor *)color
{
    defaultBackgroundColor = [color copy];
}

+ (void)setDefaultBorderColor:(UIColor *)color
{
    defaultBorderColor = [color copy];
}

+ (void)setDefaultFont:(UIFont *)font
{
    defaultFont = [font copy];
}

- (id)init
{
    CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.50f;
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
    self.image = image;
    return self;
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block type:(NAAlertViewButtonType)buttonType{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    
    switch (buttonType) {
        default:
        case NAAlertViewButtonTypeRegular:
            self.button = button;
            [self.button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.buttonBlock = block;
            break;
        case NAAlertViewButtonTypeCancel:
            self.cancelButton = button;
            [self.cancelButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.cancelButtonBlock = block;
            break;
    }
}

- (void)removeButtonWithType:(NAAlertViewButtonType)buttonType
{
    if (NAAlertViewButtonTypeRegular){
        self.button = nil;
    } else if (NAAlertViewButtonTypeCancel){
        self.cancelButton = nil;
    }
}

- (void)showAnimated:(BOOL)animated
{
    [self drawAlertBox];
    if (animated){
        CGFloat toValue = self.alertBox.center.y;
        
        CGRect hiddenFrame = self.alertBox.frame;
        hiddenFrame.origin.y = -1.25 * hiddenFrame.size.height;
        self.alertBox.frame = hiddenFrame;
        self.alpha = 0.0;
        
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        while ([vc presentedViewController]) vc = [vc presentedViewController];
        [vc.view addSubview:self];
        
        POPBasicAnimation *fade = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fade.duration = 0.3;
        fade.fromValue = @(0.0);
        fade.toValue = @(1.0);
        
        POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        spring.toValue = @(toValue);
        spring.springSpeed = 15.0;
        spring.springBounciness = 6.0;
        
        [self.alertBox.layer pop_addAnimation:spring forKey:@"spring"];
        [self pop_addAnimation:fade forKey:@"fade"];
    } else {
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        while ([vc presentedViewController]) vc = [vc presentedViewController];
        [vc.view addSubview:self];
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    if (animated){
        POPBasicAnimation *fade = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fade.duration = 0.5;
        fade.fromValue = @(1.0);
        fade.toValue = @(0.0);
        
        POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        spring.toValue = @(self.alertBox.frame.size.height * -1.25);
        spring.springSpeed = 15.0;
        spring.springBounciness = 6.0;
        spring.completionBlock = ^(POPAnimation *a, BOOL finished) {
            if (finished) [self removeFromSuperview];
        };
        
        [self.alertBox.layer pop_addAnimation:spring forKey:@"spring"];
        [self pop_addAnimation:fade forKey:@"fade"];
    } else {
        [self removeFromSuperview];
    }
}

- (void)drawAlertBox
{    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.alertBox = [[UIView alloc] init];
    float alertBoxMargin = window.frame.size.width * 0.085;
    self.alertBox.frame = CGRectMake(0, 0, window.frame.size.width - 2 * alertBoxMargin, window.frame.size.height - 2 * alertBoxMargin);
    self.alertBox.backgroundColor = self.backgroundColor;
    self.alertBox.layer.cornerRadius = alertBoxMargin * 1.0;
    self.alertBox.layer.borderColor = self.borderColor.CGColor;
    self.alertBox.layer.borderWidth = 0.75;
    
    float contentWidth = self.alertBox.frame.size.width - 2.0 * alertBoxMargin;
    float altitude = alertBoxMargin;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 10.0)];
    titleLabel.text = self.title;
    titleLabel.font = [UIFont fontWithName:self.font.fontName size:28.0];
    titleLabel.textColor = self.borderColor;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    float titleLabelHeight = [titleLabel sizeThatFits:CGSizeMake(contentWidth, self.alertBox.frame.size.height)].height;

    titleLabel.frame = CGRectMake(alertBoxMargin, altitude, contentWidth, titleLabelHeight);
    [self.alertBox addSubview:titleLabel];
    altitude = altitude + titleLabelHeight;
    
    
    float buttonHeight = 44.0;
    float contentHeight = self.alertBox.frame.size.height - (2 * alertBoxMargin + titleLabelHeight + buttonHeight);
    UIImageView *imageView;
    if (self.image){
        contentHeight = contentHeight / 2.0;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(alertBoxMargin, altitude + 5.0, contentWidth, MIN(contentHeight, self.image.size.height))];
        altitude = altitude + MIN(contentHeight, self.image.size.height) + 5.0;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = self.image;
        [self.alertBox addSubview:imageView];
    }
    
    UITextView *messageView = [[UITextView alloc] initWithFrame:CGRectMake(alertBoxMargin, altitude, contentWidth, contentHeight)];
    messageView.text = self.message;
    messageView.font = [UIFont fontWithName:self.font.fontName size:17.0];
    messageView.textColor = self.borderColor;
    messageView.editable = NO;
    messageView.scrollEnabled = NO;
    messageView.backgroundColor = [UIColor clearColor];
    messageView.textAlignment = NSTextAlignmentCenter;
    
    float textViewHeight = [messageView sizeThatFits:messageView.frame.size].height;
    if (textViewHeight <= contentHeight){
        messageView.frame = CGRectMake(alertBoxMargin, altitude, contentWidth, textViewHeight);
        messageView.userInteractionEnabled = NO;
    } else {
        messageView.scrollEnabled = YES;
    }
    
    [self.alertBox addSubview:messageView];
    
    altitude = altitude + messageView.frame.size.height + 10.0;
    
    // Add an OK button if there is no button present
    if (!self.button && !self.cancelButton) [self addButtonWithTitle:@"OK" block:nil type:NAAlertViewButtonTypeRegular];
    
    if (self.button && self.cancelButton){
        [self setupButton:self.button]; [self setupButton:self.cancelButton];
        [self.alertBox addSubview:self.button]; [self.alertBox addSubview:self.cancelButton];
        self.cancelButton.frame = CGRectMake(alertBoxMargin, altitude, contentWidth * 0.5 - 2.5, buttonHeight);
        self.button.frame = CGRectMake(alertBoxMargin + contentWidth * 0.5 + 5.0, altitude, contentWidth * 0.5 - 2.5, buttonHeight);
    } else if (self.button) {
        [self setupButton:self.button];
        self.button.frame = CGRectMake(alertBoxMargin + .125 * contentWidth, altitude, contentWidth * .75, buttonHeight);
        [self.alertBox addSubview:self.button];
    } else if (self.cancelButton) {
        [self setupButton:self.cancelButton];
        self.cancelButton.frame = CGRectMake(alertBoxMargin + .125 * contentWidth, altitude, contentWidth * .75, buttonHeight);
        [self.alertBox addSubview:self.cancelButton];
    }
    
    CGRect alertBoxFrame = self.alertBox.frame;
    alertBoxFrame.size.height = alertBoxMargin + titleLabel.frame.size.height + messageView.frame.size.height + 5.0 + buttonHeight + alertBoxMargin;
    if (self.image){
        alertBoxFrame.size.height = alertBoxFrame.size.height + imageView.frame.size.height + 5.0;
    }
    self.alertBox.frame = alertBoxFrame;
    
    self.alertBox.center = window.center;
    
    [self addSubview:self.alertBox];
}

- (void)setupButton:(UIButton *)button;
{
    [button setTitleColor:self.borderColor forState:UIControlStateNormal];
    [button setTitleColor:self.backgroundColor forState:UIControlStateSelected];
    button.backgroundColor = self.backgroundColor;
    button.layer.borderColor = self.borderColor.CGColor;
    button.layer.cornerRadius = 10.0;
    if (self.button == button) {
        button.layer.borderWidth = 1.5;
        button.titleLabel.font = [UIFont fontWithName:self.font.fontName size:18.0];
    } else {
        button.layer.borderWidth = 1.0;
        button.titleLabel.font = [UIFont fontWithName:self.font.fontName size:17.0];
    }
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
