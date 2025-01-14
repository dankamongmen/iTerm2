//
//  iTermOpenQuicklyView.m
//  iTerm
//
//  Created by George Nachman on 7/13/14.
//
//

#import "iTermOpenQuicklyView.h"
#import "NSView+iTerm.h"

@interface iTermVibrantVisualEffectView : NSVisualEffectView
@end

// This class is based on a misunderstanding of vibrancy that I discovered in macOS 12 because it
// added a warning. Since it seems to work in older versions I'm keeping it around but don't use
// it in the future. The subtlety is that -allowsVibrancy should be enabled in leaf views *under*
// NSVisualEffectView, not in NSVisualEffectView itself.
@implementation iTermVibrantVisualEffectView
- (BOOL)allowsVibrancy {
    if (@available(macOS 10.12, *)) {
        return NO;
    }
    return YES;
}
@end

@implementation iTermOpenQuicklyView {
    NSVisualEffectView *_visualEffectView;
    NSView *_container;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)awakeFromNib {
    // Flip subviews
    NSArray *subviews = [self subviews];
    CGFloat height = self.bounds.size.height;
    for (NSView *view in subviews) {
        NSRect frame = view.frame;
        frame.origin.y = height - NSMaxY(frame);
        view.frame = frame;
    }

    _container = [[NSView alloc] initWithFrame:self.bounds];
    [self insertSubview:_container atIndex:0];

    _visualEffectView = [[iTermVibrantVisualEffectView alloc] initWithFrame:self.bounds];
    _visualEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    if (@available(macOS 10.16, *)) {
        _visualEffectView.material = NSVisualEffectMaterialMenu;
    } else {
        _visualEffectView.material = NSVisualEffectMaterialSheet;
    }
    _visualEffectView.state = NSVisualEffectStateActive;
    [_container addSubview:_visualEffectView];

    // Even though this is set in IB, we have to set it manually.
    self.autoresizesSubviews = NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    return;
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    _container.frame = self.bounds;
    _visualEffectView.frame = _container.bounds;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize {
    [super resizeWithOldSuperviewSize:oldSize];
    _container.frame = self.bounds;
    _visualEffectView.frame = _container.bounds;
}

@end
