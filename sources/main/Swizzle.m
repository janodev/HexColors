
#import "Swizzle.h"
#import "HexColors-Swift.h"
@import AppKit;
@import ObjectiveC.runtime;

@implementation Swizzle

-(void)swizzle
{
    [self replaceFixAttributesInRangeForClass: NSClassFromString(@"DVTTextStorage")];
}

/// Returns true if this attributed string is being printed in the Xcode console.
+(BOOL)isConsole:(id)instance
{
    SEL selector = NSSelectorFromString(@"_associatedTextViews");
    IMP imp = [instance methodForSelector:selector];
    NSMutableArray* (*_associatedTextViews)(id, SEL) = (void *)imp;
    NSMutableArray* array = _associatedTextViews(instance, selector);
    return ([array count] > 0 && [[array[0] className] isEqual: @"IDEConsoleTextView"]);
}

-(void)replaceFixAttributesInRangeForClass:(Class)clazz
{
    SEL selector = @selector(fixAttributesInRange:);
    Method m = class_getInstanceMethod(clazz, selector);
    IMP oldImplementation = method_getImplementation(m);
    IMP newImplementation = imp_implementationWithBlock(^(id self, NSRange range) {
        ((void(*)(id, SEL, NSRange))oldImplementation)(self, selector, range);
        if ([Swizzle isConsole: self]){
            [HexColors colorize: self];
        }
    });
    method_setImplementation(m, newImplementation);
}

@end
