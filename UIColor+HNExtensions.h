//
//  UIColor+HNExtensions.h
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Henri Normak
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIColor (HNExtensions)

#pragma mark -
#pragma mark Components

- (CGFloat)getAlpha;
- (CGFloat)getRed;
- (CGFloat)getGreen;
- (CGFloat)getBlue;

// Following methods take value from 0-1 and replace the receiver's corresponding value
- (UIColor *)colorWithSaturation:(CGFloat)saturation;
- (UIColor *)colorWithBrightness:(CGFloat)brightness;

#pragma mark -
#pragma mark Color palette

// Complementary color
- (UIColor *)complementaryColor;

// Following methods return an array of 3 UIColor objects (first of which is the receiver)
- (NSArray *)analogousColors;
- (NSArray *)splitComplementaryColors;
- (NSArray *)triadicColors;

// Following methods return an array of 4 UIColor objects (first of which is the receiver)
- (NSArray *)tetradicColors;
- (NSArray *)squareColors;

#pragma mark -
#pragma mark Accessibility

// Returns either black or white, whichever has better contrast with the color
- (UIColor *)contrastingTextColor;

// Measured according to the WGAC standard, returns a ratio >= 1.0
- (CGFloat)contrastRatioWithColor:(UIColor *)color;

// WGAC AAA standard is assumed, the ratio has to be better than 4.5
- (BOOL)isAccessibleWithBackgroundColor:(UIColor *)color;

#pragma mark -
#pragma mark Gradients

// Position is a unit value between 0.0 and 1.0
+ (UIColor *)colorAtPosition:(CGFloat)position fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;

// Wrapper around the previous call, useful for multicolor gradients
+ (UIColor *)colorAtPosition:(CGFloat)position withinColors:(NSArray *)colors;

#pragma mark -
#pragma mark Blending

typedef enum {
    kColorBlendingModeNormal,
    kColorBlendingModeMultiply,
    kColorBlendingModeScreen,
    kColorBlendingModeOverlay,
    kColorBlendingModeDarken,
    kColorBlendingModeLighten,
    kColorBlendingModeColorDodge,
    kColorBlendingModeColorBurn,
    kColorBlendingModeHardLight,
    kColorBlendingModeSoftLight,
    kColorBlendingModeDifference,
    kColorBlendingModeExclusion,
} UIColorBlendingMode;

// Blending two colors based on a rule
- (UIColor *)colorByBlendingWithColor:(UIColor *)source mode:(UIColorBlendingMode)mode;
- (UIColor *)colorByBlendingWithColor:(UIColor *)source mode:(UIColorBlendingMode)mode alpha:(CGFloat)alpha;

#pragma mark -
#pragma mark Misc

// Method for converting web hex color into a UIColor object, pass in a string similar to "FFFFFF" or "#FFFFFF"
// If less than six characters long, will be used as a pattern - "FFA" will result in "FFAFFA" and "FFFA" results in "FFFAFF"
// Does not take alpha into account (i.e alpha is always set to 100%)
// Additionally works with the constants used by UIColor, such as "yellow" or "orange" or "clear"
+ (UIColor *)colorForWebColor:(NSString *)colorCode;

// Random color generator
+ (UIColor *)randomColor;

@end
