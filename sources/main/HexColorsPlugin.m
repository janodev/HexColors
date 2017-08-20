
#import "HexColorsPlugin.h"
#import "Swizzle.h"

@implementation HexColorsPlugin

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[Swizzle new] swizzle];
    });
}

@end
