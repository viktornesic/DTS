//
//  KeyboardBar.m
//  KeyboardInputView
//
//  Created by Viktor on 10/4/14.
//  Copyright (c) 2014 Mac. All rights reserved.
//

#import "KeyboardBar.h"

@implementation KeyboardBar

- (id)initWithDelegate:(id<KeyboardBarDelegate>)delegate {
    self = [self init];
    self.delegate = delegate;
    return self;
}

- (id)init {
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0,0, CGRectGetWidth(screen), 55);
    self = [self initWithFrame:frame];
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeZero;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
        
    
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(5, 5, frame.size.width - 70, frame.size.height - 10)];
        self.textView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
        self.textView.delegate = self;
        self.textView.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.textView];
        
        self.actionButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 60, 5, 55, frame.size.height - 10)];
        self.actionButton.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        self.actionButton.layer.cornerRadius = 2.0;
        self.actionButton.layer.borderWidth = 1.0;
        self.actionButton.layer.borderColor = [[UIColor colorWithWhite:0.45 alpha:1.0f] CGColor];
        [self.actionButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.actionButton addTarget:self action:@selector(didTouchAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.textView.backgroundColor = [UIColor whiteColor];
        
        [self.textView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5].active = YES;
        [self.textView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-70].active = YES;
        [self.textView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
        [self.textView.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor constant:-8].active = YES;
        [self.textView.heightAnchor constraintEqualToConstant:frame.size.height - 10].active = YES;
        
        [self addSubview:self.actionButton];
        
    }
    return self;
}

- (BOOL)isAcceptableTextLength:(NSUInteger)length {
    return length <= 80;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    return [self isAcceptableTextLength:textView.text.length + string.length - range.length];
}

- (void) didTouchAction
{
    [self.delegate keyboardBar:self sendText:self.textView.text];
}

@end
