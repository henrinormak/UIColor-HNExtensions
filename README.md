UIColor-HNExtensions
====================

A grab-bag of different UIColor related extensions. Feel free to contact me on Twitter [@henrinormak](http://twitter.com/henrinormak "@henrinormak on Twitter") 

Components
----------

There are a few methods for getting one of the components UIColor consists of, such as red, green or blue. Additionally there are a couple of methods for getting a new color by changing a component such as brightness or saturation.

Example:

    CGFloat redComponent = [[UIColor redColor] getRed];
    CGFloat blueComponent = [[UIColor redColor] getBlue];


Colour palette
--------------

Convenience methods for getting a colour palette from a colour. Different types of palettes are available, such as analogous, split complementary, triadic, square and tetradic.

Example:

    // Returns colours that are roughly blueColor and greenColor
    NSArray *triadicColours = [[UIColor redColor] triadicColors];

Accessibility
-------------

Few methods for determining the contrast between two colours according to WGAC standards. Also a simple method for getting the best text colour (black or white) for the given background color.

Example:

    // Returns whiteColor as it's most contrasting with blue
    UIColor *textColor = [[UIColor blueColor] contrastingTextColor];
    
    // Returns ~13.85 as the ratio according to WGAC standard
    CGFloat contrastRatio = [[UIColor blueColor] contrastRatioWithColor:[UIColor whiteColor]]; 

Gradients
---------

Methods for getting an interpolated colour in an array of colours, which can be seen as getting a colour at a given point in a gradient.

Example:

    // Returns a colour exactly in the middle between white and black (so 50% gray)
    UIColor *gray = [UIColor colorAtPosition:.5f fromColor:[UIColor blackColor] toColor:[UIColor whiteColor]];
    
    // Equivalent to the previous call, but allows more than two colour gradients
    UIColor *gray = [UIColor colorAtPosition:.5f withinColors:@[[UIColor whiteColor], [UIColor blackColor]]];

Blending
--------

Methods for creating new colours by blending two colours together based on blend mode. This is very useful for avoiding translucent colours when performance matters, by pre-blending the colour and using that one instead - the resulting colour is opaque (i.e alpha is 1.0).
With these methods you can also replicate layer blend modes from Photoshop.

References for blending
- Calculation is based on http://partners.adobe.com/public/developer/en/pdf/PDFReference.pdf by Adobe
- The blend modes are calculated as shown in http://www.pegtop.net/delphi/articles/blendmodes/ by Pegtop

Example:

    // Getting the same effect as if you had used a blend mode when filling a colour on top of another colour
    // For example, overlay of white on darker blue produces full blue
    UIColor *overlayBlue = [[UIColor colorForHexString:@"0000da"] colorByBlendingWithColor:[UIColor whiteColor] mode:kColorBlendingModeOverlay]
    
Miscellaneous
-------------

There are two miscellaneous methods, one for converting a CSS styled HEX string to a colour, like "#FFF" or "FF", also there is a method for getting a totally random colour

