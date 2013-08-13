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

#import "UIColor+HNExtensions.h"

// Useful macro for clamping a value between MIN and MAX
#define CLAMP(x, min, max) MIN(max, MAX(min, x))

#pragma mark - 
#pragma mark C helpers

NSArray * UIColorAdjacentColorsToColor(UIColor *color);
NSArray * UIColorAdjacentColorsToColor(UIColor *color) {
    // Start by grabbing the hue, and other parameters of the color we are processing
    CGFloat hue = 0.f; CGFloat saturation = 0.f; CGFloat brightness = 1.f; CGFloat alpha = 1.f;
    
    // Grab the components, if not RGB use the default ones (as it's most likely monochrome
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        // We have what we need, adjust the hue both ways and create new colors
        CGFloat leftHue = hue - 0.08333f < 0.f ? 1.f + (hue - 0.08333f) : hue - 0.08333f;
        CGFloat rightHue = fmodf(hue + 0.08333f, 1.f);
        
        UIColor *color1 = [UIColor colorWithHue:leftHue saturation:saturation brightness:brightness alpha:alpha];
        UIColor *color2 = [UIColor colorWithHue:rightHue saturation:saturation brightness:brightness alpha:alpha];
        
        // Combine and return the array
        return [NSArray arrayWithObjects:color1, color2, nil];
    } else if ([color getWhite:&brightness alpha:&alpha]) {
        // With black/white and gray tones the analogous scheme is just the same color
        UIColor *color1 = [UIColor colorWithCGColor:color.CGColor];
        UIColor *color2 = [UIColor colorWithCGColor:color.CGColor];
        
        return [NSArray arrayWithObjects:color1, color2, nil];
    }
    
    return nil;
}

typedef CGFloat (^BlendingBlock)(CGFloat destination, CGFloat source);
BlendingBlock BlendingBlockForMode(UIColorBlendingMode blendMode);
BlendingBlock BlendingBlockForMode(UIColorBlendingMode blendMode)
{
    // Formulas are based on http://www.pegtop.net/delphi/articles/blendmodes/
    BlendingBlock resultBlock = NULL;
    switch (blendMode) {
        case kColorBlendingModeNormal:
            resultBlock = ^(CGFloat destination, CGFloat source){ return source; };
            break;
        case kColorBlendingModeMultiply:
            resultBlock = ^(CGFloat destination, CGFloat source){ return destination * source; };
            break;
        case kColorBlendingModeScreen:
            resultBlock = ^(CGFloat destination, CGFloat source){ return destination + source - (destination * source); };
            break;
        case kColorBlendingModeOverlay:
            resultBlock = ^(CGFloat destination, CGFloat source){ return destination <= 0.5f ? source * (destination / 0.5f) :
                source * ((source - destination) / 0.5f) + (destination - (source - destination)); };
            break;
        case kColorBlendingModeDarken:
            resultBlock = ^(CGFloat destination, CGFloat source){ return MIN(source, destination); };
            break;
        case kColorBlendingModeLighten:
            resultBlock = ^(CGFloat destination, CGFloat source){ return MAX(source, destination); };
            break;
        case kColorBlendingModeColorDodge:
            resultBlock = ^(CGFloat destination, CGFloat source){ return source == 1.f ? 0.f : destination / (1.f - source); };
            break;
        case kColorBlendingModeColorBurn:
            resultBlock = ^(CGFloat destination, CGFloat source){ return source == 0.f ? 1.f : 1.0f - (1.f - destination) / source; };
            break;
        case kColorBlendingModeHardLight:
            resultBlock = ^(CGFloat destination, CGFloat source){ return source >= 0.5f ? 2.f * destination * source : 1.f - 2.f * (1.f - destination) * (1.f - source); };
            break;
        case kColorBlendingModeSoftLight:
            resultBlock = ^(CGFloat destination, CGFloat source){
                return (1.f - destination) * (destination * source) + destination * (destination + source - (destination * source)); };
            break;
        case kColorBlendingModeDifference:
            resultBlock = ^(CGFloat destination, CGFloat source){ return fabsf(destination - source); };
            break;
        case kColorBlendingModeExclusion:
            resultBlock = ^(CGFloat destination, CGFloat source){ return 0.5f - 2.f * (destination - 0.5f) * (source - 0.5f); };
        default:
            break;
    }
        
    return resultBlock;
}

@implementation UIColor (Extensions)

#pragma mark -
#pragma mark Components

- (CGFloat)getAlpha {
    CGFloat alpha = 0.f;
    
    if ([self getWhite:NULL alpha:&alpha])
        return alpha;
    
    [self getRed:NULL green:NULL blue:NULL alpha:&alpha];
    return alpha;
}

- (CGFloat)getRed {
    CGFloat red = 0.f;
    [self getRed:&red green:NULL blue:NULL alpha:NULL];
    return red;
}

- (CGFloat)getGreen {
    CGFloat green = 0.f;
    [self getRed:NULL green:&green blue:NULL alpha:NULL];
    return green;
}

- (CGFloat)getBlue {
    CGFloat blue = 0.f;
    [self getRed:NULL green:NULL blue:&blue alpha:NULL];
    return blue;
}

- (CGFloat)getLuminance {
    CGFloat r, g, b;
    
    // If RGB, grab values, if not then use the white value (gray-scale)
    if (![self getRed:&r green:&g blue:&b alpha:NULL]) {
        [self getWhite:&r alpha:NULL];
        g = r;
        b = r;
    }
    
    // Adjust the components
    if (r <= 0.03928)
        r = r / 12.92f;
    else
        r = powf(((r + 0.055f) / 1.055f), 2.4f);
    
    if (g <= 0.03928f)
        g = g / 12.92f;
    else
        g = powf(((g + 0.055f) / 1.055f), 2.4f);
    
    if (b <= 0.03928f)
        b = b / 12.92f;
    else
        b = powf(((b + 0.055f) / 1.055f), 2.4f);
    
    return 0.2126f * r + 0.7152f * g + 0.0722f * b;
}

- (UIColor *)colorWithSaturation:(CGFloat)saturation {
    // Convert the color to HSB values
    CGFloat hue;
    CGFloat brightness;
    CGFloat alpha;
    
    [self getHue:&hue saturation:NULL brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:CLAMP(saturation, 0.f, 1.f) brightness:brightness alpha:alpha];
}

- (UIColor *)colorWithBrightness:(CGFloat)brightness {
    // Convert the color to HSB values
    CGFloat hue;
    CGFloat saturation;
    CGFloat alpha;
    
    [self getHue:&hue saturation:&saturation brightness:NULL alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation brightness:CLAMP(brightness, 0.f, 1.f) alpha:alpha];
}

#pragma mark -
#pragma mark Color palette

- (UIColor *)complementaryColor {    
    CGFloat hue = 0.0; CGFloat saturation = 0.f; CGFloat brightness = 1.f; CGFloat alpha = 1.f;
    
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        CGFloat oppositeHue = fmodf(hue + 0.5f, 1.f);
        return [UIColor colorWithHue:oppositeHue saturation:saturation brightness:brightness alpha:alpha];
    } else if ([self getWhite:&brightness alpha:&alpha]) {
        brightness = 1.f - brightness;
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }
    
    // Error, colour was in unknown colour space
    return nil;
}

- (NSArray *)analogousColors {
    return @[[self copy], UIColorAdjacentColorsToColor(self)];
}

- (NSArray *)splitComplementaryColors {
    UIColor *complementary = [self complementaryColor];
    if (complementary)
        return @[[self copy], UIColorAdjacentColorsToColor(complementary)];
    
    // Error, likely due to colour space issues
    return nil;
}

- (NSArray *)triadicColors {
    CGFloat hue = 0.f; CGFloat saturation = 0.f; CGFloat brightness = 1.f; CGFloat alpha = 1.f;
    
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        CGFloat leftHue = hue - 0.33333f < 0.f ? 1.f + (hue - 0.33333f) : hue - 0.33333f;
        CGFloat rightHue = fmodf(hue + 0.33333f, 1.f);
                
        UIColor *color1 = [UIColor colorWithHue:leftHue saturation:saturation brightness:brightness alpha:alpha];
        UIColor *color2 = [UIColor colorWithHue:rightHue saturation:saturation brightness:brightness alpha:alpha];
        
        return @[[self copy], color1, color2];
    } else if ([self getWhite:&brightness alpha:&alpha]) {
        // With black/white and gray tones the analogous scheme is just the same color
        UIColor *color1 = [UIColor colorWithCGColor:self.CGColor];
        UIColor *color2 = [UIColor colorWithCGColor:self.CGColor];
        
        return @[[self copy], color1, color2];
    }
    
    return nil;
}

- (NSArray *)tetradicColors {
    UIColor *complementary = [self complementaryColor];
    
    if (complementary) {
        CGFloat hue = 0.f; CGFloat saturation = 0.f; CGFloat brightness = 1.f; CGFloat alpha = 1.f;
        
        if ([complementary getHue: &hue saturation: &saturation brightness: &brightness alpha: &alpha]) {
            UIColor *left = [UIColor colorWithHue:fmodf(hue + 0.16666f, 1.f) saturation:saturation brightness:brightness alpha:alpha];
            
            if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
                UIColor *right = [UIColor colorWithHue:fmodf(hue + 0.16666f, 1.f) saturation:saturation brightness:brightness alpha:alpha];
                return @[[self copy], left, complementary, right];
            }
        }
    }
    
    return nil;
}

- (NSArray *)squareColors {
    UIColor *complementary = [self complementaryColor];
    
    if (complementary) {
        CGFloat hue = 0.f; CGFloat saturation = 0.f; CGFloat brightness = 1.f; CGFloat alpha = 1.f;
        
        if ([complementary getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
            UIColor *left = [UIColor colorWithHue:fmodf(hue + 0.25f, 1.f) saturation:saturation brightness:brightness alpha:alpha];
            
            if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
                UIColor *right = [UIColor colorWithHue:fmodf(hue + 0.25f, 1.f) saturation:saturation brightness:brightness alpha:alpha];
                return @[[self copy], left, complementary, right];
            }
        }
    }
    
    return nil;
}

#pragma mark -
#pragma mark Accessibility

- (UIColor *)contrastingTextColor {
    CGFloat luminance = [self getLuminance];
    return luminance > 0.5f ? [UIColor blackColor] : [UIColor whiteColor];
}

- (CGFloat)contrastRatioWithColor: (UIColor *)color {
    CGFloat luminance1 = [self getLuminance];
    CGFloat luminance2 = [color getLuminance];
    
    // Make sure to return the contrast ratio in correct form
    // Divide lighter colour by the darker one
    return luminance1 > luminance2 ? luminance1 / luminance2 : luminance2 / luminance1;
}

- (BOOL)isAccessibleWithBackgroundColor:(UIColor *)color {
    return [self contrastRatioWithColor:color] > 4.5f;
}

#pragma mark -
#pragma mark Gradients

+ (UIColor *)colorAtPosition:(CGFloat)position fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor {
    CGFloat fromHue, fromSaturation, fromBrightness, fromAlpha;
    CGFloat toHue, toSaturation, toBrightness, toAlpha;
    
    // Make sure the position is valid
    position = CLAMP(position, 0.f, 1.f);
    
    BOOL grayscale = NO;
    if ((grayscale = ![fromColor getHue:&fromHue saturation:&fromSaturation brightness:&fromBrightness alpha:&fromAlpha])) {
        fromSaturation = 0.f;
        fromHue = 0.f;
        [fromColor getWhite:&fromBrightness alpha:&fromAlpha];
    }
    
    if (![toColor getHue:&toHue saturation:&toSaturation brightness:&toBrightness alpha:&toAlpha]) {
        toHue = fromHue;    // In case the first colour was not grayscale (gives smoother gradient)
        toSaturation = 0.f;
        [toColor getWhite:&toBrightness alpha:&toAlpha];
    } else if (grayscale) {
        fromHue = toHue;
    }
    
    // Adjust the hues to make sure the shortest path is used
    if (toHue - fromHue > (fromHue + 1.f) - toHue) {
        // Shorter to go the other way
        // i.e not from 0.0 - 1.0, but 1.0 - 0.0
        fromHue += 1.f;
    } else if (fromHue - toHue > (toHue + 1.f) - fromHue) {
        toHue += 1.f;
    }
    
    // Calculate the interpolated value at the given point
    CGFloat inversePosition = 1.0 - position;
    CGFloat hue = fmodf((fromHue * inversePosition) + (toHue * position), 1.0);
    CGFloat saturation = (fromSaturation * inversePosition) + (toSaturation * position);
    CGFloat brightness = (fromBrightness * inversePosition) + (toBrightness * position);
    CGFloat alpha = (fromAlpha * inversePosition) + (toAlpha * position);
        
    // We don't have to worry about the values being normalised, as the input was already correct
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

+ (UIColor *)colorAtPosition:(CGFloat)position withinColors:(NSArray *)colors {
    // Check the count, if 0 return nil, if 1 return that colour
    if ([colors count] < 2)
        return [colors firstObject];
    
    // Make sure the position is valid
    position = CLAMP(position, 0.f, 1.f);
    
    // At least two colours, so a safe division
    CGFloat split = 1.f / ([colors count] - 1);
    
    NSInteger fromIndex = floorf(position / split);
    NSInteger toIndex = ceilf(position / split);
    
    CGFloat remainder = fmodf(position, split);
    return [UIColor colorAtPosition:(remainder / split) fromColor:[colors objectAtIndex:fromIndex] toColor:[colors objectAtIndex:toIndex]];
}

#pragma mark -
#pragma mark Miscellaneous

static NSUInteger const ColorRedChannel = 0;
static NSUInteger const ColorBlueChannel = 1;
static NSUInteger const ColorGreenChannel = 2;
static NSUInteger const ColorAlphaChannel = 3;

- (UIColor *)colorByBlendingWithColor:(UIColor *)source mode:(UIColorBlendingMode)mode {
    return [self colorByBlendingWithColor:source mode:mode alpha:1.f];
}

- (UIColor *)colorByBlendingWithColor:(UIColor *)sourceColor mode:(UIColorBlendingMode)mode alpha:(CGFloat)alpha {
    // Calculation is based on http://partners.adobe.com/public/developer/en/pdf/PDFReference.pdf by Adobe
    // The blend modes are calculated as shown in http://www.pegtop.net/delphi/articles/blendmodes/ by Pegtop
    // Make sure the two are in the same colorspace
    CGColorSpaceModel destinationModel = CGColorSpaceGetModel(CGColorGetColorSpace([self CGColor]));
    CGColorSpaceModel sourceModel = CGColorSpaceGetModel(CGColorGetColorSpace([sourceColor CGColor]));
    if ((destinationModel != kCGColorSpaceModelMonochrome && destinationModel != kCGColorSpaceModelRGB) ||
        (sourceModel != kCGColorSpaceModelMonochrome && sourceModel != kCGColorSpaceModelRGB)) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Both colors have to be in either RGB or monochrome color space" userInfo:nil];
        return nil;
    }
    
    CGFloat destination[4];
    CGFloat source[4];
    CGFloat result[3];

    // Get components
    if (![self getRed:&destination[ColorRedChannel] green:&destination[ColorGreenChannel] blue:&destination[ColorBlueChannel] alpha:&destination[ColorAlphaChannel]]) {
        [self getWhite:&destination[ColorRedChannel] alpha:&destination[ColorAlphaChannel]];
        destination[ColorBlueChannel] = destination[ColorRedChannel];
        destination[ColorGreenChannel] = destination[ColorRedChannel];
    }
    
    if (![sourceColor getRed:&source[ColorRedChannel] green:&source[ColorGreenChannel] blue:&source[ColorBlueChannel] alpha:&source[ColorAlphaChannel]]) {
        [sourceColor getWhite:&source[ColorRedChannel] alpha:&source[ColorAlphaChannel]];
        source[ColorGreenChannel] = source[ColorRedChannel];
        source[ColorBlueChannel] = source[ColorRedChannel];
    }
    
    // Handle the calculation
    // The alpha we received should be seen as the source alpha
    alpha = CLAMP(alpha, 0.f, 1.f);
    CGFloat alphaComplement = 1.f - alpha;
    CGFloat destinationAlphaComplement = 1.f - destination[ColorAlphaChannel];
    
    BlendingBlock formulaBlock = BlendingBlockForMode(mode);
    for (int i = 0; i < 3; i++)
        result[i] = alphaComplement * destination[i] + alpha * (destinationAlphaComplement * source[i] + destination[ColorAlphaChannel] * formulaBlock(destination[i], source[i]));
    
    // Create the color from the components
    return [UIColor colorWithRed:result[ColorRedChannel] green:result[ColorGreenChannel] blue:result[ColorBlueChannel] alpha:destination[ColorAlphaChannel]];
}

+ (UIColor *)randomColor {
    // Generate three random values
    int r = arc4random() % 256;
    int g = arc4random() % 256;
    int b = arc4random() % 256;
    
    // Create the color and return it
    return [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:1.f];
}

+ (UIColor *)colorForWebColor:(NSString *)colorCode {
    NSMutableString *string = [NSMutableString stringWithString:colorCode];
    [string replaceOccurrencesOfString:@"#" withString:@"" options:0 range:NSMakeRange(0, [string length])];
    
    // Check if named color exists
    NSString *colorName = [NSString stringWithFormat:@"%@Color", [string lowercaseString]];
    SEL selector = NSSelectorFromString(colorName);
    if ([[UIColor class] respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[UIColor class] methodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIColor class]];
        [invocation invoke];
        UIColor *result;
        [invocation getReturnValue:&result];
        
        return result;
    }
    
    // Check if size is enough
    int length = [string length];
    switch (length) {
        case 1:
            // The pattern is easy to form
            [string appendFormat:@"%@%@%@%@%@", string, string, string, string, string];
            break;
        case 2:
            // Once again, repeat the pattern
            [string appendFormat:@"%@%@", string, string];
            break;
        case 3:
            // And again, repeat the pattern
            [string appendFormat:@"%@", string];
            break;
        case 4:
            // Now it's a bit more difficult, repeat, but then cut the end off
            [string appendString:[string substringToIndex: 2]];
            break;
        case 5:
            // Same as with four, but add one less
            [string appendString:[string substringToIndex: 1]];
            break;
        default:
            break;
    }
    
    // Storage for all the values
    unsigned int color;
    
    // Now we can proceed to calculate the values, start by creating a range of the string to look at
    [[NSScanner scannerWithString:string] scanHexInt:&color]; // Grabs color value
    
    return [UIColor colorWithRed:(float)(((color >> 16) & 0xFF) / 255.f)
                           green:(float)(((color >> 8) & 0xFF) / 255.f)
                            blue:(float)((color & 0xFF) / 255.f)
                           alpha:1.f];
}

@end
