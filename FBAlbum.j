
@import "CPRemoteObject.j"
@import "FBPhoto.j"


@implementation FBAlbum : CPRemoteObject
{
    CPString    m_ID;
    CPString    m_ownerID;

    CPString    m_name @accessors(property=name);
    CPString    m_description;

    unsigned    m_size;
    CPArray     m_photos @accessors(property=photos);
    
    BOOL        m_loadingStatus;
}

- (id)initWithAlbumObject:(Object)anAlbumObject
{
    self = [super init];

    if (self)
    {
        m_ID = anAlbumObject.aid;

        m_name = anAlbumObject.name;
        m_description = anAlbumObject.description;

        m_size = anAlbumObject.size;
        
        [self unresolveValueForKey:@"photos"];
    }

    return self;
}

- (void)requestValuesForKeys:(CPMutableSet)keys
{
    if ([keys containsObject:@"photos"])
    {
        [keys removeObject:@"photos"];

    [[FBConnectController sharedConnectController]
        query:"SELECT pid, aid, owner, src, src_big, src_small, link, caption, created FROM photo WHERE aid=" + m_ID
        callback:function(/*Object*/ aResponse)
        {
            var photos = [],
                photoObject = nil,
                photoObjectEnumerator = [aResponse objectEnumerator];

            while (photoObject = [photoObjectEnumerator nextObject])
                [photos addObject:[[FBPhoto alloc] initWithPhotoObject:photoObject]];

            [self setValue:photos forKey:@"photos"];
        }];
    }

    [super requestValuesForKeys:keys];
}

@end
