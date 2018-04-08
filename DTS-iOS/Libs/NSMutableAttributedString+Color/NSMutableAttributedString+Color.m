//
//  NSMutableAttributedString+Color.m
//  testTextView
//
//  Created by anoopm on 30/09/15.
//  Copyright (c) 2015 anoopm. All rights reserved.
//

#import "NSMutableAttributedString+Color.h"


@implementation NSMutableAttributedString (Color)

-(void)setColorForText:(NSString*)textToFind withColor:(UIColor*)color
{
    NSRange searchRange = NSMakeRange(0,self.length);
    NSRange foundRange;
    while (searchRange.location < self.length) {
        searchRange.length = self.length-searchRange.location;
        foundRange = [self.mutableString rangeOfString:textToFind options:NSCaseInsensitiveSearch range:searchRange];
        if (foundRange.location != NSNotFound) {
            searchRange.location = foundRange.location+foundRange.length;
            if(searchRange.location != NSNotFound)
                [self addAttribute:NSForegroundColorAttributeName value:color range:foundRange];
        } else {
            // no more substring to find
            break;
        }
    }
//    NSRange range = [self.mutableString rangeOfString:textToFind options:NSCaseInsensitiveSearch];
//    
//    if (range.location != NSNotFound) {
//        [self addAttribute:NSForegroundColorAttributeName value:color range:range];
//    }
}

-(void)setFontForText:(NSString*)textToFind withFont:(UIFont*)font
{
    NSRange searchRange = NSMakeRange(0,self.length);
    NSRange foundRange;
    while (searchRange.location < self.length) {
        searchRange.length = self.length-searchRange.location;
        foundRange = [self.mutableString rangeOfString:textToFind options:NSCaseInsensitiveSearch range:searchRange];
        if (foundRange.location != NSNotFound) {
            searchRange.location = foundRange.location+foundRange.length;
            if(searchRange.location != NSNotFound)
                [self addAttribute:NSFontAttributeName value:font range:foundRange];
        } else {
            // no more substring to find
            break;
        }
    }
//    NSRange range = [self.mutableString rangeOfString:textToFind options:NSCaseInsensitiveSearch];
//    
//    if (range.location != NSNotFound) {
//        [self addAttribute:NSFontAttributeName value:font range:range];
//    }
}

-(void)setAlignmentForText:(NSString*)textToFind withAlignment:(NSTextAlignment)textAlignment {
    
    NSRange range = [self.mutableString rangeOfString:textToFind options:NSCaseInsensitiveSearch];
    
    if (range.location != NSNotFound) {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:textAlignment];
        
        [self addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    }
}

@end
