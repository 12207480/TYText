//
//  TYTextRender.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTextRender.h"
#import <pthread.h>

#define TYAssertMainThread() NSAssert(0 != pthread_main_np(), @"This method must be called on the main thread!")

@interface TYTextRender () {
    CGRect _textBound;
    NSArray *_attachmentViews;
    NSSet *_attachmentViewSet;
    BOOL _ownsTextKitStack;
}

@property (nonatomic, strong) NSTextContentStorage *contentStorage;
@property (nonatomic, strong) NSTextLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

@property (nonatomic, strong, nullable) TYTextHighlight *activeHighlight;
@property (nonatomic, assign) NSRange activeHighlightRange;

@property (nonatomic, assign) CGRect textRectOnRender;
@property (nonatomic, assign) NSRange visibleCharacterRangeOnRender;
@property (nonatomic, assign) NSRange truncatedCharacterRangeOnRender;

@end

@implementation TYTextRender

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _onlySetTextStorageWillGetAttachViews = YES;
        _activeHighlightRange = NSMakeRange(NSNotFound, 0);
        _ownsTextKitStack = YES;
        [self buildOwnedTextKitStack];
        [self configureRender];
    }
    return self;
}

- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText {
    if (self = [self initWithTextStorage:[[NSTextStorage alloc] initWithAttributedString:attributedText ?: [[NSAttributedString alloc] init]]]) {
    }
    return self;
}

- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage {
    if (self = [self init]) {
        self.textStorage = textStorage;
    }
    return self;
}

- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer {
    return [self initWithTextContainer:textContainer editable:NO];
}

- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer editable:(BOOL)editable {
    if (self = [super init]) {
        NSParameterAssert(textContainer.textLayoutManager);
        _onlySetTextStorageWillGetAttachViews = YES;
        _activeHighlightRange = NSMakeRange(NSNotFound, 0);
        _editable = editable;
        _ownsTextKitStack = NO;
        _textContainer = textContainer;
        _layoutManager = textContainer.textLayoutManager;
        NSTextContentManager *contentManager = _layoutManager.textContentManager;
        NSAssert([contentManager isKindOfClass:[NSTextContentStorage class]], @"TYTextRender requires NSTextContentStorage.");
        _contentStorage = (NSTextContentStorage *)contentManager;
        _textStorage = _contentStorage.textStorage;
        [self configureRender];
    }
    return self;
}

- (void)buildOwnedTextKitStack {
    _contentStorage = [[NSTextContentStorage alloc] init];
    _layoutManager = [[NSTextLayoutManager alloc] init];
    _textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    _textContainer.lineFragmentPadding = 0;
    _layoutManager.textContainer = _textContainer;
    [_contentStorage addTextLayoutManager:_layoutManager];
}

- (void)configureRender {
    _highlightBackgroudRadius = 4;
    _highlightBackgroudInset = UIEdgeInsetsZero;
    _verticalAlignment = TYTextVerticalAlignmentCenter;
}

#pragma mark - Getter && Setter

- (void)setTextStorage:(NSTextStorage *)textStorage {
    _textStorage = textStorage;
    if (_onlySetTextStorageWillGetAttachViews && !_editable) {
        self.attachmentViews = textStorage.attachmentViews;
    }
    if (_ownsTextKitStack) {
        // editable=NO 场景：在私有 content storage 上 set attributedString 副本；不把调用方的 NSTextStorage 暴露给外部编辑。
        NSAttributedString *snapshot = _editable ? textStorage : [textStorage copy];
        _contentStorage.attributedString = snapshot;
    }
    [self invalidateLayoutCache];
}

- (void)setEditable:(BOOL)editable {
    if (_editable == editable) {
        return;
    }
    _editable = editable;
    if (_ownsTextKitStack && _textStorage) {
        _contentStorage.attributedString = _editable ? _textStorage : [_textStorage copy];
        [self invalidateLayoutCache];
    }
}

- (NSArray<TYTextAttachment *> *)attachmentViews {
    if (_onlySetTextStorageWillGetAttachViews) {
        return _attachmentViews;
    }
    return _contentStorage.attributedString.attachmentViews;
}

- (NSSet<TYTextAttachment *> *)attachmentViewSet {
    if (_onlySetTextStorageWillGetAttachViews) {
        return _attachmentViewSet;
    }
    NSArray *views = _contentStorage.attributedString.attachmentViews;
    return views.count > 0 ? [NSSet setWithArray:views] : nil;
}

- (void)setAttachmentViews:(NSArray *)attachmentViews {
    _attachmentViews = attachmentViews;
    _attachmentViewSet = attachmentViews.count > 0 ? [NSSet setWithArray:attachmentViews] : nil;
}

- (void)setSize:(CGSize)size {
    if (CGSizeEqualToSize(_size, size)) {
        return;
    }
    _size = size;
    [self applyContainerSize:size];
    if (_onlySetRenderSizeWillGetTextBounds && !_editable) {
        [self ensureLayout];
        _textBound = [self textBoundForCurrentLayout];
    }
}

- (CGRect)textBound {
    if (_onlySetRenderSizeWillGetTextBounds && !_editable) {
        return _textBound;
    }
    [self ensureLayout];
    return [self textBoundForCurrentLayout];
}

- (void)setLineFragmentPadding:(CGFloat)lineFragmentPadding {
    _lineFragmentPadding = lineFragmentPadding;
    _textContainer.lineFragmentPadding = lineFragmentPadding;
    [self invalidateLayoutCache];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
    _textContainer.lineBreakMode = lineBreakMode;
    [self invalidateLayoutCache];
}

- (void)setMaximumNumberOfLines:(NSUInteger)maximumNumberOfLines {
    _maximumNumberOfLines = maximumNumberOfLines;
    _textContainer.maximumNumberOfLines = maximumNumberOfLines;
    [self invalidateLayoutCache];
}

- (void)setTruncationToken:(NSAttributedString *)truncationToken {
    _truncationToken = [truncationToken copy];
}

#pragma mark - Layout

- (void)applyContainerSize:(CGSize)size {
    CGFloat w = size.width > 0 ? size.width : CGFLOAT_MAX;
    CGFloat h = size.height > 0 ? size.height : CGFLOAT_MAX;
    _textContainer.size = CGSizeMake(w, h);
}

- (void)invalidateLayoutCache {
    _textBound = CGRectZero;
}

- (void)ensureLayout {
    NSTextRange *documentRange = _contentStorage.documentRange;
    if (documentRange) {
        [_layoutManager ensureLayoutForRange:documentRange];
    }
}

- (CGRect)textBoundForCurrentLayout {
    __block CGRect unionRect = CGRectNull;
    [_layoutManager enumerateTextLayoutFragmentsFromLocation:_contentStorage.documentRange.location
                                                     options:NSTextLayoutFragmentEnumerationOptionsEnsuresLayout
                                                  usingBlock:^BOOL(NSTextLayoutFragment *fragment) {
        CGRect frame = fragment.layoutFragmentFrame;
        unionRect = CGRectIsNull(unionRect) ? frame : CGRectUnion(unionRect, frame);
        return YES;
    }];
    return CGRectIsNull(unionRect) ? CGRectZero : unionRect;
}

- (CGSize)textSizeWithRenderWidth:(CGFloat)renderWidth {
    CGSize previous = _textContainer.size;
    _textContainer.size = CGSizeMake(renderWidth > 0 ? renderWidth : CGFLOAT_MAX, CGFLOAT_MAX);
    [self ensureLayout];
    CGRect bound = [self textBoundForCurrentLayout];
    _textContainer.size = previous;
    return CGSizeMake(ceil(bound.size.width), ceil(bound.size.height));
}

- (NSRange)visibleCharacterRange {
    [self ensureLayout];
    __block NSInteger maxEnd = 0;
    [_layoutManager enumerateTextLayoutFragmentsFromLocation:_contentStorage.documentRange.location
                                                     options:NSTextLayoutFragmentEnumerationOptionsEnsuresLayout
                                                  usingBlock:^BOOL(NSTextLayoutFragment *fragment) {
        NSInteger end = [self->_contentStorage offsetFromLocation:self->_contentStorage.documentRange.location
                                                       toLocation:fragment.rangeInElement.endLocation];
        if (end > maxEnd) maxEnd = end;
        return YES;
    }];
    return NSMakeRange(0, MAX(maxEnd, 0));
}

- (NSInteger)numberOfLines {
    [self ensureLayout];
    __block NSInteger count = 0;
    [_layoutManager enumerateTextLayoutFragmentsFromLocation:_contentStorage.documentRange.location
                                                     options:NSTextLayoutFragmentEnumerationOptionsEnsuresLayout
                                                  usingBlock:^BOOL(NSTextLayoutFragment *fragment) {
        count += fragment.textLineFragments.count;
        return YES;
    }];
    return count;
}

- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange {
    NSTextRange *textRange = [self textRangeForCharacterRange:characterRange];
    if (!textRange) return CGRectZero;
    [self ensureLayout];

    __block CGRect unionRect = CGRectNull;
    [_layoutManager enumerateTextSegmentsInRange:textRange
                                            type:NSTextLayoutManagerSegmentTypeStandard
                                         options:NSTextLayoutManagerSegmentOptionsRangeNotRequired
                                      usingBlock:^BOOL(NSTextRange *textSegmentRange, CGRect textSegmentFrame, CGFloat baselinePosition, NSTextContainer *textContainer) {
        unionRect = CGRectIsNull(unionRect) ? textSegmentFrame : CGRectUnion(unionRect, textSegmentFrame);
        return YES;
    }];
    return CGRectIsNull(unionRect) ? CGRectZero : unionRect;
}

- (CGRect)boundingRectForGlyphRange:(NSRange)glyphRange {
    // TextKit 2 不再区分 glyph/char range
    return [self boundingRectForCharacterRange:glyphRange];
}

- (NSInteger)characterIndexForPoint:(CGPoint)point {
    if (_contentStorage.attributedString.length == 0) {
        return -1;
    }
    [self ensureLayout];

    CGPoint localPoint = CGPointMake(point.x, point.y - [self verticalOffset]);

    __block NSInteger resultIndex = -1;
    [_layoutManager enumerateTextLayoutFragmentsFromLocation:_contentStorage.documentRange.location
                                                     options:NSTextLayoutFragmentEnumerationOptionsEnsuresLayout
                                                  usingBlock:^BOOL(NSTextLayoutFragment *fragment) {
        CGRect fragmentFrame = fragment.layoutFragmentFrame;
        if (!CGRectContainsPoint(fragmentFrame, localPoint)) {
            return YES;
        }
        CGPoint pointInFragment = CGPointMake(localPoint.x - fragmentFrame.origin.x,
                                              localPoint.y - fragmentFrame.origin.y);
        NSInteger fragmentStart = [self->_contentStorage offsetFromLocation:self->_contentStorage.documentRange.location
                                                                 toLocation:fragment.rangeInElement.location];
        for (NSTextLineFragment *lineFragment in fragment.textLineFragments) {
            if (!CGRectContainsPoint(lineFragment.typographicBounds, pointInFragment)) {
                continue;
            }
            // characterIndexForPoint: 接收 line fragment 自身坐标系的点；
            // 实测它返回的索引是相对 layout fragment 整段 attributedString 的偏移，
            // 因此直接与 fragmentStart 相加即可。
            CGPoint pointInLine = CGPointMake(pointInFragment.x - lineFragment.typographicBounds.origin.x,
                                              pointInFragment.y - lineFragment.typographicBounds.origin.y);
            NSInteger idxInLine = [lineFragment characterIndexForPoint:pointInLine];
            if (idxInLine >= 0) {
                resultIndex = fragmentStart + idxInLine;
            }
            return NO;
        }
        return YES;
    }];
    return resultIndex;
}

- (TYTextHighlight *)textHighlightAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSAttributedString *source = _contentStorage.attributedString;
    if (source.length == 0 || index >= source.length) {
        if (range) *range = NSMakeRange(NSNotFound, 0);
        return nil;
    }
    return [source textHighlightAtIndex:index effectiveRange:range];
}

#pragma mark - Vertical alignment

- (CGFloat)verticalOffset {
    CGSize containerSize = _textContainer.size;
    if (containerSize.height <= 0 || containerSize.height == CGFLOAT_MAX) {
        return 0;
    }
    [self ensureLayout];
    CGRect bound = [self textBoundForCurrentLayout];
    CGFloat remaining = containerSize.height - CGRectGetHeight(bound);
    if (remaining <= 0) return 0;
    switch (_verticalAlignment) {
        case TYTextVerticalAlignmentTop: return 0;
        case TYTextVerticalAlignmentBottom: return remaining;
        case TYTextVerticalAlignmentCenter:
        default: return floor(remaining * 0.5);
    }
}

#pragma mark - Draw

- (void)drawTextAtPoint:(CGPoint)point {
    [self drawTextAtPoint:point isCanceled:nil];
}

#pragma mark - Utility

- (nullable NSTextRange *)textRangeForCharacterRange:(NSRange)range {
    if (range.location == NSNotFound) return nil;
    NSAttributedString *source = _contentStorage.attributedString;
    if (NSMaxRange(range) > source.length) return nil;

    id<NSTextLocation> start = [_contentStorage locationFromLocation:_contentStorage.documentRange.location withOffset:(NSInteger)range.location];
    if (!start) return nil;
    id<NSTextLocation> end = [_contentStorage locationFromLocation:start withOffset:(NSInteger)range.length];
    if (!end) return nil;
    return [[NSTextRange alloc] initWithLocation:start endLocation:end];
}

@end

#pragma mark - Rendering

@implementation TYTextRender (Rendering)

- (void)setTextStorageTruncationToken {
    if (!self.truncationToken || self.maximumNumberOfLines == 0) {
        return;
    }
    if (self.textStorage.length == 0) {
        return;
    }

    CGFloat width = self.textContainer.size.width;
    if (width <= 0 || width == CGFLOAT_MAX) return;

    // 先用当前 textStorage 测量，未超行则无需截断
    TYTextRender *measure = [[TYTextRender alloc] initWithAttributedText:self.textStorage];
    measure.lineFragmentPadding = self.lineFragmentPadding;
    measure.lineBreakMode = self.lineBreakMode;
    measure.maximumNumberOfLines = 0;
    CGSize fullSize = [measure textSizeWithRenderWidth:width];
    if (fullSize.height <= 0) return;
    measure.size = CGSizeMake(width, CGFLOAT_MAX);
    if ([measure numberOfLines] <= (NSInteger)self.maximumNumberOfLines) {
        return;
    }

    NSUInteger low = 0;
    NSUInteger high = self.textStorage.length;
    NSUInteger best = 0;
    NSAttributedString *token = self.truncationToken;
    while (low <= high) {
        NSUInteger mid = (low + high) / 2;
        NSMutableAttributedString *candidate = [[self.textStorage attributedSubstringFromRange:NSMakeRange(0, mid)] mutableCopy];
        [candidate appendAttributedString:token];

        TYTextRender *probe = [[TYTextRender alloc] initWithAttributedText:candidate];
        probe.lineFragmentPadding = self.lineFragmentPadding;
        probe.lineBreakMode = self.lineBreakMode;
        probe.maximumNumberOfLines = 0;
        probe.size = CGSizeMake(width, CGFLOAT_MAX);
        NSInteger lineCount = [probe numberOfLines];
        if (lineCount <= (NSInteger)self.maximumNumberOfLines) {
            best = mid;
            low = mid + 1;
        } else if (mid == 0) {
            break;
        } else {
            high = mid - 1;
        }
    }

    NSMutableAttributedString *truncated = [[self.textStorage attributedSubstringFromRange:NSMakeRange(0, best)] mutableCopy];
    [truncated appendAttributedString:token];

    // 截断结果只写进 contentStorage（render 私有副本），保持源 textStorage 原文不变；
    // 否则下次 numberOfLines 增大后无法恢复到完整内容。
    self.contentStorage.attributedString = truncated;

    self.truncatedCharacterRangeOnRender = NSMakeRange(best, token.length);
}

- (void)setTextHighlight:(TYTextHighlight *)textHighlight range:(NSRange)range {
    self.activeHighlight = textHighlight;
    self.activeHighlightRange = textHighlight ? range : NSMakeRange(NSNotFound, 0);
}

- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^)(void))isCanceled {
    if (isCanceled && isCanceled()) return;
    [self ensureLayout];

    NSRange visibleRange = [self visibleCharacterRange];
    self.visibleCharacterRangeOnRender = visibleRange;

    CGFloat verticalOffset = [self verticalOffset];
    CGRect bound = [self textBoundForCurrentLayout];
    bound.origin.y += verticalOffset;
    self.textRectOnRender = CGRectOffset(bound, point.x, point.y);

    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;

    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y + verticalOffset);

    // 1. 自绘圆角高亮背景
    NSTextRange *highlightTextRange = self.activeHighlight ? [self textRangeForCharacterRange:self.activeHighlightRange] : nil;
    NSDictionary<NSAttributedStringKey, id> *renderingAttributes = [self.activeHighlight renderingAttributes];
    if (highlightTextRange) {
        [self drawHighlightBackgroundInRange:highlightTextRange context:context];
        if (renderingAttributes.count > 0) {
            [self.layoutManager setRenderingAttributes:renderingAttributes forTextRange:highlightTextRange];
        }
    }

    // 2. 按 fragment 绘制文本
    [self.layoutManager enumerateTextLayoutFragmentsFromLocation:self.contentStorage.documentRange.location
                                                         options:NSTextLayoutFragmentEnumerationOptionsEnsuresLayout
                                                      usingBlock:^BOOL(NSTextLayoutFragment *fragment) {
        if (isCanceled && isCanceled()) { return NO; }
        [fragment drawAtPoint:fragment.layoutFragmentFrame.origin inContext:context];
        return YES;
    }];

    if (highlightTextRange && renderingAttributes.count > 0) {
        [renderingAttributes enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey key, id obj, BOOL *stop) {
            [self.layoutManager removeRenderingAttribute:key forTextRange:highlightTextRange];
        }];
    }

    CGContextRestoreGState(context);
}

- (void)drawHighlightBackgroundInRange:(NSTextRange *)range context:(CGContextRef)context {
    TYTextHighlight *highlight = self.activeHighlight;
    UIColor *fill = highlight.backgroundColor ?: [UIColor colorWithWhite:0 alpha:0.12];
    CGFloat radius = self.highlightBackgroudRadius;
    UIEdgeInsets inset = self.highlightBackgroudInset;

    [self.layoutManager enumerateTextSegmentsInRange:range
                                                type:NSTextLayoutManagerSegmentTypeHighlight
                                             options:NSTextLayoutManagerSegmentOptionsRangeNotRequired
                                          usingBlock:^BOOL(NSTextRange *textSegmentRange, CGRect textSegmentFrame, CGFloat baselinePosition, NSTextContainer *textContainer) {
        CGRect drawRect = UIEdgeInsetsInsetRect(textSegmentFrame, UIEdgeInsetsMake(-inset.top, -inset.left, -inset.bottom, -inset.right));
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:drawRect cornerRadius:radius];
        CGContextSaveGState(context);
        [fill setFill];
        [path fill];
        CGContextRestoreGState(context);
        return YES;
    }];
}

@end
