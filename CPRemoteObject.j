
@import <Foundation/CPObject.j>


@implementation CPRemoteObject : CPObject
{
    CPSet           _resolvingKeys;
    CPSet           _unresolvedKeys;

    CPDictionary    _keyCallbacks;
}

- (id)init
{
    self = [super init];

    if (self)
    {
        _resolvingKeys = [CPSet set];
        _unresolvedKeys = [CPSet set];
    }

    return self;
}

- (void)unresolveValueForKey:(CPString)aKey
{
    [self setValue:nil forKey:aKey];
    [_unresolvedKeys addObject:aKey];
/*
    var keyPath = nil,
        keyPathEnumerator = [self keyPathsForValuesAffectingValueForKey:aKey];

    while (keyPath = [keyPathEnumerator nextObject])
        [self unresolveValueForKey:aKey];
*/
}

- (BOOL)isValueResolvedForKey:(CPString)aKey
{
    return [_unresolvedKeys containsObject:aKey]; 
}

- (BOOL)isResolvingValueForKey:(CPString)aKey
{
    return [_resolvingKeys containsObject:aKey];
}

- (void)resolveValuesForKeys:(id)keys
{
    return [self resolveValuesForKeys:keys callback:NULL];
}

- (void)resolveValuesForKeys:(id)keys callback:(Function)aFunction
{
    var key = nil,
        keyEnumerator = [keys objectEnumerator],
        callback = [_CPRemoteObjectKeyCallback keyCallbackWithFunction:aFunction keys:keys],
        keysToRequest = [];

    while (key = [keyEnumerator nextObject])
    {
        [[self _callbacksForKey:key create:YES] addObject:callback];

        if ([self isResolvingValueForKey:key] || ![self isValueResolvedForKey:key])
            continue;

        [_resolvingKeys addObject:key];
        [keysToRequest addObject:key];
    }

    if ([keysToRequest count])
        [self requestValuesForKeys:keysToRequest];
}

- (void)requestValuesForKeys:(CPArray)keys
{

}

- (CPArray)_callbacksForKey:(CPString)aKey create:(BOOL)shouldCreate
{
    var callbacks = [_keyCallbacks objectForKey:aKey];

    if (!callbacks && shouldCreate)
    {
        callbacks = [];
        [_keyCallbacks addObject:callbacks forKey:aKey];
    }

    return callbacks;
}

- (id)valueForKey:(CPString)aKey
{
    var value = [super valueForKey:aKey];

    if ([self isValueResolvedForKey:aKey] && ![self isResolvingValueForKey:aKey])
        [self resolveValuesForKeys:[aKey]];

    return value;
}

- (void)didChangeValueForKey:(CPString)aKey
{
    [_unresolvedKeys removeObject:aKey];
    [_resolvingKeys removeObject:aKey];

    [super didChangeValueForKey:aKey];

    var callback = nil,
        callbacks = [self _callbacksForKey:aKey create:NO],
        callbackEnumerator = [callbacks objectEnumerator],
        callbacksToRemove = [];

    while (callback = [callbackEnumerator nextObject])
        if ([callback satisfyKey:aKey])
            [callbacksToRemove addObject:callback];

    [callbacks removeObjectsFromArray:callbacksToRemove];
}

@end

@implementation _CPRemoteObjectKeyCallback : CPObject
{
    Function    _function;
    CPArray     _keys;
    CPArray     _unsatisfiedKeys;
}

+ (id)keyCallbackWithFunction:(Function)aFunction keys:(CPArray)keys
{
    return [[self alloc] initWithFunction:aFunction keys:keys];
}

- (id)initWithFunction:(Function)aFunction keys:(CPArray)keys
{
    self = [super init];

    if (self)
    {
        _function = aFunction;
        _keys = keys;
        _unsatisfiedKeys = [keys copy];
    }

    return self;
}

- (void)satisfyKey:(CPString)aKey
{
    [_unsatisfiedKeys removeObject:aKey];
    
    if ([_unsatisfiedKeys count] <= 0)
        _function(_keys);
}

@end
