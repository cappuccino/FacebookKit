
@import "CPRemoteObject.j"

@import "FBAlbum.j"

@implementation FBUser : CPRemoteObject
{
    CPString    m_ID @accessors(readonly, property=ID);
    CPArray     m_albums @accessors(property=albums);
}

- (id)initWithID:(CPString)anID
{
    self = [super init];

    if (self)
    {
        m_ID = anID;
        
        [self unresolveValueForKey:@"albums"];
    }

    return self;
}

- (void)requestValuesForKeys:(CPMutableSet)keys
{
    if ([keys containsObject:@"albums"])
    {
        [keys removeObject:@"albums"];

        [[FBConnectController sharedConnectController]
            query:"SELECT aid, cover_pid, owner, name, created, modified, description, location, link, size, visible FROM album WHERE owner=" + m_ID
            callback:function(/*Object*/ aResponse)
            {
                var albums = [],
                    albumObject = nil,
                    albumObjectEnumerator = [aResponse objectEnumerator];

                while (albumObject = [albumObjectEnumerator nextObject])
                    [albums addObject:[[FBAlbum alloc] initWithAlbumObject:albumObject]];

                [self setValue:albums forKey:@"albums"];
            }];
    }

    [super requestValuesForKeys:keys];
}

@end
