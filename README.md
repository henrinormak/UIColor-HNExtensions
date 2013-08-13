UIColor-HNExtensions
====================

A grab-bag of different UIColor related extensions. Feel free to contact me on Twitter [@henrinormak](http://twitter.com/henrinormak "@henrinormak on Twitter") 

Components
----------

There are a few methods for getting one of the components UIColor consists of, such as red, green or blue. Additionally there are a couple of methods for getting a new color by changing a component such as brightness or saturation.


Colour palette
--------------

Convenience methods for getting a colour palette from a colour. Different types of palettes are available, such as analogous, split complementary, triadic, square and tetradic.


Accessibility
-------------

Few methods for determining the contrast between two colours according to WGAC standards. Also a simple method for getting the best text colour (black or white) for the given background color.


Gradients
---------

Methods for getting an interpolated colour in an array of colours, which can be seen as getting a colour at a given point in a gradient.


Blending
--------

Methods for creating new colours by blending two colours together based on blend mode. This is very useful for avoiding translucent colours when performance matters, by pre-blending the colour and using that one instead - the resulting colour is opaque (i.e alpha is 1.0).