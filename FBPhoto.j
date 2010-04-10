
//pid, aid, owner, src, src_big, src_small, link, caption, created

@implementation FBPhoto : CPRemoteObject
{
    FBUID       m_FBUID;

    FBUser      m_owner;
    FBAlbum     m_album;

    CPURL       m_imageURL @accessors(property=imageURL);
    CPURL       m_smallImageURL @accessors(property=smallImageURL);
    CPURL       m_largeImageURL @accessors(property=largeImageURL);

    CPImage     m_image;
    CPImage     m_smallImage;
    CPImage     m_largeImage;

    CPURL       m_linkURL @accessors(property=linkURL);

    CPString    m_caption @accessors(property=caption);
    CPDate      m_creationDate @accessors(property=creationDate);
}

+ (CPSet)keyPathsForValuesAffectingImage
{
    return [CPSet setWithObjects:@"imageURL"];
}

+ (CPSet)keyPathsForValuesAffectingSmallImage
{
    return [CPSet setWithObjects:@"smallImageURL"];
}

+ (CPSet)keyPathsForValuesAffectingLargeImage
{
    return [CPSet setWithObjects:@"largeImageURL"];
}

- (id)initWithPhotoObject:(id)anObject
{
    self = [super init]
    
    if (self)
    {
        var URLString = anObject.src;

        if (URLString)
            m_imageURL = [CPURL URLWithString:URLString];
        else
            [self unresolveValueForKey:@"imageURL"];

        URLString = anObject.src_small;

        if (URLString)
            m_smallImageURL = [CPURL URLWithString:URLString];
        else
            [self unresolveValueForKey:@"smallImageURL"];

        URLString = anObject.src_big;

        if (URLString)
            m_largeImageURL = [CPURL URLWithString:URLString];
        else
            [self unresolveValueForKey:@"largeImageURL"];

        m_largeURL = URLString ? [CPURL URLWithString:URLString] : CPUnresolvedObject;

        URLString = anObject.link;

        if (URLString)
            m_linkURL = [CPURL URLWithString:URLString];
        else
            [self unresolveValueForKey:@"linkURL"];

        var caption = anObject.caption;

        if (caption)
            m_caption = caption;
        else
            [self unresolveValueForKey:@"caption"];

        var creationDate = anObject.created;

        if (creationDate)
            m_creationDate = new Date(creationDate);
        else
            [self unresolveValueForKey:@"creationDate"];
    }

    return self;
}

- (CPImage)image
{
    if (!m_image)
        m_image = [[CPImage alloc] initWithContentsOfFile:[self valueForKey:"imageURL"]];

    return m_image;
}

- (CPImage)smallImage
{
    if (!m_smallImage)
        m_smallImage = [[CPImage alloc] initWithContentsOfFile:[self valueForKey:"smallImageURL"]];

    return m_smallImage;
}

- (CPImage)largeImage
{
    if (!m_largeImage)
        m_largeImage = [[CPImage alloc] initWithContentsOfFile:[self valueForKey:"largeImageURL"]];

    return m_largeImage;
}

@end
