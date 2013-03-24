//
//  PopupView.m
//  HWMonitor
//
//  Created by kozlek on 23.02.13.
//  Based on code by Vadim Shpanovski <https://github.com/shpakovski/Popup>
//  Popup is licensed under the BSD license.
//  Copyright (c) 2013 Vadim Shpanovski, Natan Zalkin. All rights reserved.
//

#import "PopupView.h"
#import "PopupController.h"
#import "HWMonitorDefinitions.h"

@implementation PopupView

-(void)setColorTheme:(ColorTheme*)colorTheme
{
    if (_colorTheme != colorTheme) {
        _colorTheme = colorTheme;
        _cachedImage = nil;
        [self setNeedsDisplay:YES];
    }
}

- (void)setArrowPosition:(CGFloat)arrowPosition
{
    if (_arrowPosition != arrowPosition) {
        _arrowPosition = arrowPosition + LINE_THICKNESS / 2.0;
        _cachedImage = nil;
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)rect
{
    NSRect popupBounds = NSInsetRect([self bounds], LINE_THICKNESS, LINE_THICKNESS);
    
    if (!_cachedImage || !NSEqualRects(popupBounds, _popupBounds)) {
        [[NSGraphicsContext currentContext] saveGraphicsState]; // save
        
        _popupBounds = popupBounds;
        
        _cachedImage = [[NSImage alloc] initWithSize:[self bounds].size];
        [_cachedImage lockFocus];
        
        // Toolbar and arrow path
        NSRect toolbarBounds = popupBounds;
        toolbarBounds.size.height = kHWMonitorToolbarHeight + ARROW_HEIGHT - LINE_THICKNESS * 3;
        toolbarBounds.origin.y = popupBounds.size.height - toolbarBounds.size.height;
        
        NSBezierPath *toolbarPath = [NSBezierPath bezierPath];
        [toolbarPath moveToPoint:NSMakePoint(NSMinX(toolbarBounds), NSMinY(toolbarBounds))];
        [toolbarPath lineToPoint:NSMakePoint(NSMinX(toolbarBounds), NSMaxY(toolbarBounds) - ARROW_HEIGHT - CORNER_RADIUS)];
        NSPoint topLeftCorner = NSMakePoint(NSMinX(toolbarBounds) + CORNER_RADIUS, NSMaxY(toolbarBounds) - ARROW_HEIGHT - CORNER_RADIUS);
        [toolbarPath appendBezierPathWithArcWithCenter:topLeftCorner radius:CORNER_RADIUS startAngle:180 endAngle:90 clockwise:YES];
        [toolbarPath lineToPoint:NSMakePoint(_arrowPosition - ARROW_WIDTH / 2.0f, NSMaxY(toolbarBounds) - ARROW_HEIGHT)];
        [toolbarPath lineToPoint:NSMakePoint(_arrowPosition, NSMaxY(toolbarBounds))];
        [toolbarPath lineToPoint:NSMakePoint(_arrowPosition + ARROW_WIDTH / 2.0f, NSMaxY(toolbarBounds) - ARROW_HEIGHT)];
        [toolbarPath lineToPoint:NSMakePoint(NSMaxX(toolbarBounds) - CORNER_RADIUS, NSMaxY(toolbarBounds) - ARROW_HEIGHT)];
        NSPoint topRightCorner = NSMakePoint(NSMaxX(toolbarBounds) - CORNER_RADIUS, NSMaxY(toolbarBounds) - ARROW_HEIGHT - CORNER_RADIUS);
        [toolbarPath appendBezierPathWithArcWithCenter:topRightCorner radius:CORNER_RADIUS startAngle:90 endAngle:0 clockwise:YES];
        [toolbarPath lineToPoint:NSMakePoint(NSMaxX(toolbarBounds), NSMinY(toolbarBounds))];
        
        // List path
        NSRect listBounds = NSMakeRect(popupBounds.origin.x, popupBounds.origin.y, popupBounds.size.width, popupBounds.size.height - toolbarBounds.size.height - LINE_THICKNESS);
        
        NSBezierPath *listPath = [NSBezierPath bezierPath];
        [listPath moveToPoint:NSMakePoint(NSMaxX(listBounds), NSMaxY(listBounds))];
        [listPath lineToPoint:NSMakePoint(NSMaxX(listBounds), NSMinY(listBounds) + CORNER_RADIUS)];
        NSPoint bottomRightCorner = NSMakePoint(NSMaxX(listBounds) - CORNER_RADIUS, NSMinY(listBounds) + CORNER_RADIUS);
        [listPath appendBezierPathWithArcWithCenter:bottomRightCorner radius:CORNER_RADIUS startAngle:0 endAngle:270 clockwise:YES];
        [listPath lineToPoint:NSMakePoint(NSMinX(listBounds) + CORNER_RADIUS, NSMinY(listBounds))];
        NSPoint bottomLeftCorner = NSMakePoint(NSMinX(listBounds) + CORNER_RADIUS, NSMinY(listBounds) + CORNER_RADIUS);
        [listPath appendBezierPathWithArcWithCenter:bottomLeftCorner radius:CORNER_RADIUS startAngle:270 endAngle:180 clockwise:YES];
        [listPath lineToPoint:NSMakePoint(NSMinX(listBounds), NSMaxY(listBounds))];
        [listPath closePath];

        // Setup clipping path
        NSBezierPath *clipPath = [NSBezierPath bezierPath];
        [clipPath appendBezierPath:toolbarPath];
        [clipPath appendBezierPath:listPath];
        [clipPath setLineWidth:LINE_THICKNESS];
        [clipPath addClip];

        // Fill list
        [_colorTheme.listBackgroundColor setFill];
        [listPath fill];
        
        // Fill toolbar
        [[[NSGradient alloc] initWithStartingColor:_colorTheme.toolbarStartColor endingColor:_colorTheme.toolbarEndColor] drawInBezierPath:toolbarPath angle:270];

        // Draw inner shadow
        NSBezierPath *shadowPath = [NSBezierPath bezierPath];
        topLeftCorner = NSMakePoint(NSMinX(toolbarBounds) + CORNER_RADIUS + LINE_THICKNESS, NSMaxY(toolbarBounds) - ARROW_HEIGHT - CORNER_RADIUS - SHADOW_SHIFT);
        [shadowPath appendBezierPathWithArcWithCenter:topLeftCorner radius:CORNER_RADIUS startAngle:180 endAngle:90 clockwise:YES];
        [shadowPath lineToPoint:NSMakePoint(_arrowPosition - ARROW_WIDTH / 2.0f, NSMaxY(toolbarBounds) - ARROW_HEIGHT - SHADOW_SHIFT)];
        [shadowPath lineToPoint:NSMakePoint(_arrowPosition, NSMaxY(toolbarBounds) - SHADOW_SHIFT)];
        [shadowPath lineToPoint:NSMakePoint(_arrowPosition + ARROW_WIDTH / 2.0f, NSMaxY(toolbarBounds) - ARROW_HEIGHT - SHADOW_SHIFT)];
        [shadowPath lineToPoint:NSMakePoint(NSMaxX(toolbarBounds) - CORNER_RADIUS - LINE_THICKNESS, NSMaxY(toolbarBounds) - ARROW_HEIGHT - SHADOW_SHIFT)];
        topRightCorner = NSMakePoint(NSMaxX(toolbarBounds) - CORNER_RADIUS - LINE_THICKNESS, NSMaxY(toolbarBounds) - ARROW_HEIGHT - CORNER_RADIUS - SHADOW_SHIFT);
        [shadowPath appendBezierPathWithArcWithCenter:topRightCorner radius:CORNER_RADIUS startAngle:90 endAngle:0 clockwise:YES];
        
        [NSBezierPath clipRect:NSOffsetRect(NSInsetRect(shadowPath.bounds, 0, CORNER_RADIUS * 0.3), 0, CORNER_RADIUS * 0.3)];
        
        [[NSColor colorWithCalibratedWhite:1.0 alpha:0.15] setStroke];
        
        [shadowPath setLineWidth:LINE_THICKNESS + 2];
        [shadowPath stroke];
        
        [[NSGraphicsContext currentContext] restoreGraphicsState]; // restore
        
        
        [[NSGraphicsContext currentContext] saveGraphicsState]; // save
        
        [clipPath addClip];
        
        // Stroke toolbar
        [[NSColor colorWithCalibratedWhite:0.0 alpha:0.35] setStroke];
        [toolbarPath setLineWidth:LINE_THICKNESS + 0.25];
        [toolbarPath stroke];

        // Stroke list
        [NSBezierPath clipRect:listPath.bounds];
        
        [[NSColor colorWithCalibratedWhite:0.0 alpha:0.65] setStroke];
        [listPath setLineWidth:LINE_THICKNESS + 0.25];
        [listPath stroke];
        
        [_cachedImage unlockFocus];
        
        [[NSGraphicsContext currentContext] restoreGraphicsState]; // restore
    }
    
    [_cachedImage drawInRect:rect fromRect:NSOffsetRect(rect,-self.bounds.origin.x,-self.bounds.origin.y) operation:NSCompositeSourceOver fraction:1.0];
}

@end
