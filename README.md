# Flat Alert View

## Introduction

This is a class used to show a styled flat alert view. Like the built in alert view class this alert view has a customizable message and title. There is also a button and cancel button. The titles for each can be set and the buttons can be assigned blacks to be executed when they are pressed. The special feature of this alert view is that the design involves a 2 color scheme and the colors can be set via a class method or on an object by object basis.

## Creating an alert view

There are several methods for initializing alert views with titles, messages, and an image.

- `- (id)initWithTitle:(NSString *)title message:(NSString *)message`
- `- (id)initWithTitle:(NSString *)title message:(NSString *)message imagePath:(NSString *)imagePath`
- `- (id)initWithTitle:(NSString *)title message:(NSString *)message imageNamed:(NSString *)imageName`
- `- (id)initWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image`

Buttons can be added or removed from the alert view with the following methods:

- `- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block type:(JHFlatAlertViewButtonType)buttonType`
- `- (void)removeButtonWithType:(JHFlatAlertViewButtonType)buttonType`

JHFlatAlertViewButton type describes 2 types.

- `JHFlatAlertViewButtonTypeRegular`
- `JHFlatAlertViewButtonTypeCancel`

## Showing and dismissing and alert view

The alert view is displaced over the root view controller using `- (void)showAlertViewAnimate:(BOOL)animated` and dismissed using `- (void)dismissAlertViewAnimated:(BOOL)animate`. The alert view is automatically dismissed with an animation when a button is pressed.