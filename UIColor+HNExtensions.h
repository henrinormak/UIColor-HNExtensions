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
#import <CommonCrypto/CommonDigest.h>

@interface UIColor (HNExtensions)

#pragma mark -
#pragma mark Components

/**
 *  @return Alpha component of the color
 */
- (CGFloat)getAlpha;

/**
 *  @return Red component of the color, 0 for non RGB color
 */
- (CGFloat)getRed;

/**
 *  @return Green component of the color, 0 for non RGB color
 */
- (CGFloat)getGreen;

/**
 *  @return Blue component of the color, 0 for non RGB color
 */
- (CGFloat)getBlue;

/**
 *  @return Hue component of the color, 0 for non HSB color
 */
- (CGFloat)getHue;

/**
 *  @return Saturation component of the color, 0 for non HSB color
 */
- (CGFloat)getSaturation;

/**
 *  @return Brightness component of the color, 0 for non HSB color
 */
- (CGFloat)getBrightness;

/**
 *  @return Calculated luminance for the colour, works with both RGB and grayscale
 */
- (CGFloat)getLuminance;

/**
 *  @return YES if this colour was likely created by +colorWithPatternImage:
 */
- (BOOL)isPatternBased;

/**
 *  Comparison to another UIColor, converts both to suitable model/space beforehand
 *
 *  @param color to compare against the receiver
 *
 *  @return YES if the colors are equal (their components are equal)
 */
- (BOOL)isEqualToColor:(UIColor *)color;

/**
 *  @param hue New hue value for the color
 *
 *  @return Color with the hue component replaced
 */
- (UIColor *)colorWithHue:(CGFloat)hue;

/**
 *  @param saturation New saturation value for the color
 *
 *  @return Color with the saturation component replaced
 */
- (UIColor *)colorWithSaturation:(CGFloat)saturation;

/**
 *  @param brightness New brightness value for the color
 *
 *  @return Color with the brightness component replaced
 */
- (UIColor *)colorWithBrightness:(CGFloat)brightness;

#pragma mark -
#pragma mark Dimming

/**
 *  @return iOS 7 style dimmed version of the color, i.e what happens to tint when an alert is shown
 */
- (UIColor *)dimmedColor;

#pragma mark -
#pragma mark Color palette

/**
 *  @return Complementary color to the receiver
 */
- (UIColor *)complementaryColor;

/**
 *  @return Array of 3 UIColor objects that are analogous to the receiver
 */
- (NSArray *)analogousColors;

/**
 *  @return Array of 3 UIColor objects that make the split complementary palette for the receiver
 */
- (NSArray *)splitComplementaryColors;

/**
 *  @return Array of 3 UIColor objects that represent the triadic palette for the receiver
 */
- (NSArray *)triadicColors;

/**
 *  @return Array of 4 UIColors that form the tetradic palette with the receiver
 */
- (NSArray *)tetradicColors;

/**
 *  @return Array of 4 UIColors that form square palette with the receiver on the color wheel
 */
- (NSArray *)squareColors;

#pragma mark -
#pragma mark Accessibility

/**
 *  @return Either black or white, whichever has better contrast with the color
 */
- (UIColor *)contrastingTextColor;

/**
 *  @param color Color to compare against
 *
 *  @return Ratio according to the WGAC standard, >= 1.0
 */
- (CGFloat)contrastRatioWithColor:(UIColor *)color;

/**
 *  @param color Color to compare against
 *
 *  @return WGAC AAA standard is assumed, YES if ratio is better than 4.5
 */
- (BOOL)isAccessibleWithBackgroundColor:(UIColor *)color;

#pragma mark -
#pragma mark Gradients

/**
 *  Calculate a color in a gradient at a position between two colors
 *
 *  @param position  Unit value between 0.0 and 1.0 (enforced)
 *  @param fromColor Start color for the gradient
 *  @param toColor   End color for the gradient
 *
 *  @return Color at the given position between the two colors
 */
+ (UIColor *)colorAtPosition:(CGFloat)position fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;

/**
 *  Derives the colour in a linear gradient consisting of n colours
 *
 *  @param position Unit value between 0.0 and 1.0 (enforced)
 *  @param colors   Array of colours that form the linear uniform gradient
 *
 *  @return Color at the given position in the gradient
 */
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

/**
 *  Blend the receiver with another color to using a specified blending mode
 *
 *  @param source Colour to add (the order does matter, receiver is the destination)
 *  @param mode   Blending mode
 *
 *  @return Result from blending receiver with source
 */
- (UIColor *)colorByBlendingWithColor:(UIColor *)source mode:(UIColorBlendingMode)mode;

/**
 *  Blend the receiver with another color to using a specified blending mode at a given alpha
 *
 *  @param source Colour to add (the order does matter, receiver is the destination)
 *  @param mode   Blending mode
 *  @param alpha  Alpha to apply to the source colour (in addition to its natural alpha component)
 *
 *  @return Result from blending receiver with source
 */
- (UIColor *)colorByBlendingWithColor:(UIColor *)source mode:(UIColorBlendingMode)mode alpha:(CGFloat)alpha;

#pragma mark -
#pragma mark Misc

// Method for converting web hex color into a UIColor object, pass in a string similar to "FFFFFF" or "#FFFFFF"
// If less than six characters long, will be used as a pattern - "FFA" will result in "FFAFFA" and "FFFA" results in "FFFAFF"
// Does not take alpha into account (i.e alpha is always set to 100%)
// Additionally works with the constants used by UIColor, such as "yellow" or "orange" or "clear"
/**
 *  Convert hex string into a UIColor object
 *  If less than six characters long, will be used as a pattern - "FFA" will result in "FFAFFA" and "FFFA" results in "FFFAFF"
 *  Does not take alpha into account (i.e alpha is always set to 100%)
 *  Additionally works with the constants used by UIColor, such as "yellow" or "orange" or "clear"
 *
 *  @param colorCode Color code as a string, refer to brief for potential values
 *
 *  @return UIColor corresponding to the code
 */
+ (UIColor *)colorForHexString:(NSString *)colorCode;

/**
 *  Hex string from the color
 *
 *  @return hex color code for the receiver
 */
- (NSString *)hexString;

/**
 *  @return Random UIColor, generated using arc4random() used in RGB
 */
+ (UIColor *)randomColor;

/**
 *  Color from string, uses SHA1 of the string to get a list of colours, then picks the most saturated one
 *
 *  @param string String to seed the colour generator with
 *  @param color  Colour to match the hue against, pass nil if no preference
 *
 *  @return Color derived from the string
 */
+ (UIColor *)colorForString:(NSString *)string withIdeal:(UIColor *)color;

@end
