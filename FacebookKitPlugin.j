
@import <AtlasKit/AKPlugin.j>


@implementation FacebookKitPlugin : AKPlugin
{
}

- (CPArray)libraryCibNames
{
    return [@"FacebookKitLibrary.cib"];
}

- (void)init
{
    self = [super init];

    if (self)
    {
        [_classDescriptions setObject:[CPDictionary dictionaryWithJSObject:{
            "ClassName"  : "FBPhotoBrowser",
            "SuperClass" : "CPSplitView"
        } recursively:YES] forKey:@"FBPhotoBrowser"];
    }

    return self;
}

@end
