//
//  iTermEditSnippetWindowController.m
//  iTerm2SharedARC
//
//  Created by George Nachman on 8/14/20.
//

#import "iTermEditSnippetWindowController.h"
#import "NSStringITerm.h"

@interface iTermEditSnippetWindowController ()

@end

@implementation iTermEditSnippetWindowController {
    IBOutlet NSTextField *_titleView;
    IBOutlet NSTextView *_valueView;
    IBOutlet NSPopUpButton *_escapingButton;
    NSString *_title;
    NSString *_value;
    NSString *_guid;
    iTermSendTextEscaping _escaping;
    BOOL _canceled;
}

- (instancetype)initWithSnippet:(iTermSnippet *)snippet
                     completion:(void (^)(iTermSnippet * _Nullable snippet))completion {
    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    if (self) {
        if (snippet) {
            _title = snippet.title;
            _value = snippet.value;
            _guid = snippet.guid;
            _escaping = snippet.escaping;
        } else {
            NSString *pasteboardString = [NSString stringFromPasteboard];
            if (pasteboardString) {
                _title = [pasteboardString ellipsizedDescriptionNoLongerThan:40];
                _value = pasteboardString;
            } else {
                _title = @"Untitled";
                _value = @"";
            }
            _guid = [[NSUUID UUID] UUIDString];
            _escaping = iTermSendTextEscapingCommon;
        }
        _completion = [completion copy];
    }
    return self;
}

- (iTermSnippet *)snippet {
    if (_canceled) {
        return nil;
    }
    return [[iTermSnippet alloc] initWithTitle:_title
                                         value:_value
                                          guid:_guid
                                      escaping:_escaping
                                       version:[iTermSnippet currentVersion]];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    _titleView.stringValue = _title;
    _valueView.string  = _value;
    [_escapingButton selectItemWithTag:_escaping];
}

- (IBAction)ok:(id)sender {
    _canceled = NO;
    _title = _titleView.stringValue.copy ?: @"";
    _value = _valueView.string.copy ?: @"";
    _escaping = _escapingButton.selectedTag;

    self.completion(self.snippet);
    [self.window.sheetParent endSheet:self.window];
}

- (IBAction)cancel:(id)sender {
    _canceled = YES;
    self.completion(nil);
    [self.window.sheetParent endSheet:self.window];
}

- (IBAction)help:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Escaping";
    alert.informativeText =
    @"C-Style Backslash Escaping supports: \\a (bell), \\b (backspace), \\e (escape), \\n (newline), \\r (carriage return), \\t (tab), \\\\ (backslash), and \\x followed by two hex digits giving a single byte of UTF-8.\n\n"
    @"Unescaped Literal Text does not have any special characters.\n\n"
    @"Backward Compatibility Escaping, which is not recommended for new snippets, supports: \\n (newline), \\e (escape), \\a (bell), and \\t (tab).\n\n";
    [alert runModal];
}

@end
