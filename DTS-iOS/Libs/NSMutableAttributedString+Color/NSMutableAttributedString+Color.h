//
//  NSMutableAttributedString+Color.h
//  testTextView
//
//  Created by anoopm on 30/09/15.
//  Copyright (c) 2015 anoopm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (Color)
-(void)setColorForText:(NSString*) textToFind withColor:(UIColor*) color;
-(void)setFontForText:(NSString*)textToFind withFont:(UIFont*)font;
-(void)setAlignmentForText:(NSString*)textToFind withAlignment:(NSTextAlignment)textAlignment;
@end
