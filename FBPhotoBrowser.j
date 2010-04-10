
@import <AppKit/CPOutlineView.j>


@implementation FBPhotoBrowser : CPView
{
    CPView      m_loginView;
    CPButton    m_loginButton;
    
    CPView      m_albumsView;
    CPView      m_photosView;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
        [self common_init];

    return self;
}

- (void)common_init
{
    [[FBConnectController sharedConnectController]
        addObserver:self
         forKeyPath:@"user"
            options:0
            context:NULL];

    [[FBConnectController sharedConnectController]
        addObserver:self
         forKeyPath:@"user.albums"
            options:0
            context:NULL];

    var bounds = [self bounds],
        bundle = [CPBundle bundleForClass:[FBPhotoBrowser class]],
        splitView = [[CPSplitView alloc] initWithFrame:bounds];

    [splitView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    // Albums View
    m_albumsView = [[CPTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, CGRectGetWidth(bounds))];

    var tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"Title"];
    
    [tableColumn setWidth:150.0];
    [tableColumn setResizingMask:CPTableColumnAutoresizingMask];
    [m_albumsView addTableColumn:tableColumn];

    [m_albumsView setHeaderView:nil];
    [m_albumsView setBackgroundColor:[CPColor colorWithHexString:@"dde8f7"]];
    [m_albumsView setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleSourceList];
    [m_albumsView sizeLastColumnToFit];
    [m_albumsView setDataSource:self];
    [m_albumsView setDelegate:self];
    [m_albumsView setColumnAutoresizingStyle:CPTableViewLastColumnOnlyAutoresizingStyle];
    [m_albumsView setCornerView:nil];

    var albumsScrollView = [[CPScrollView alloc] initWithFrame:[m_albumsView frame]];

    [albumsScrollView setAutohidesScrollers:YES];
    [albumsScrollView setHasHorizontalScroller:NO];
    [albumsScrollView setDocumentView:m_albumsView];

    [splitView addSubview:albumsScrollView];

    // Photos Collection View

    m_photosView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(bounds) - 150.0, 10.0)];

    var imageView = [CPImageView new];

    [imageView setImageScaling:CPScaleProportionally];
    [imageView setHasShadow:YES];

    var itemPrototype = [[CPCollectionViewItem alloc] init];

    [itemPrototype setView:imageView];

    [m_photosView setMinItemSize:CGSizeMake(130, 130)];
    [m_photosView setMaxItemSize:CGSizeMake(130, 130)];
    [m_photosView setItemPrototype:itemPrototype];
    [m_photosView setSelectable:YES];
    [m_photosView setAutoresizingMask:CPViewWidthSizable];

    [m_photosView setDelegate:self];

    var photosScrollView = [[CPScrollView alloc] initWithFrame:[m_photosView frame]];        

    [photosScrollView setAutohidesScrollers:YES];
    [photosScrollView setDocumentView:m_photosView];
    [photosScrollView setBackgroundColor:[CPColor whiteColor]];

    [splitView addSubview:photosScrollView];

    [self addSubview:splitView];

    // Login View
    m_loginView = [[CPView alloc] initWithFrame:bounds];

    [m_loginView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [m_loginView setBackgroundColor:[CPColor whiteColor]];

    var iconView = [[CPImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 96.0, 96.0)];

    [iconView setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [iconView setImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"FacebookPhotos.png"]
size:CGSizeMake(96.0, 96.0)]];

    m_loginButton = [CPButton buttonWithTitle:@"Connect with Facebook"];

    [m_loginButton setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [m_loginButton setImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"FacebookConnectButtonIcon.png"] size:CGSizeMake(16.0, 15.0)]];

    var frame = [m_loginButton frame];

    [m_loginButton setFrameSize:CGSizeMake(CGRectGetWidth(frame) + 16.0 + 5.0, CGRectGetHeight(frame))];
    [m_loginButton setTarget:[FBConnectController sharedConnectController]];
    [m_loginButton setAction:@selector(login:)];

    var combinedHeight = 96.0 + 5.0 + CGRectGetHeight(frame);

    [iconView setFrameOrigin:CGPointMake((CGRectGetWidth(bounds) - 96.0) / 2.0, (CGRectGetHeight(bounds) - combinedHeight) / 2.0)];

    [m_loginView addSubview:iconView];

    [m_loginButton setFrameOrigin:CGPointMake((CGRectGetWidth(bounds) - CGRectGetWidth(frame)) / 2.0, (CGRectGetHeight(bounds) - combinedHeight) / 2.0 + 96.0 + 5.0)];

    [m_loginView addSubview:m_loginButton];

    [self addSubview:m_loginView];
    
    [m_loginView setHidden:!![[FBConnectController sharedConnectController] user]];
}

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    if (self)
    {
        [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self common_init];
    }

    return self;
}

@end

@implementation FBPhotoBrowser (CPTableViewDataSource)

- (CPData)collectionView:(CPCollectionView)collectionView dataForItemsAtIndexes:(CPIndexSet)anIndexSet forType:(CPString)aType
{
    return [CPKeyedArchiver archivedDataWithRootObject:[[self largeImages] objectsAtIndexes:anIndexSet]];
}

- (CPArray)collectionView:(CPCollectionView)collectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
    return [CPImagesPboardType];
}

- (void)largeImages
{
    var albums = [[FBConnectController sharedConnectController] valueForKeyPath:@"user.albums"],
        images = nil;

    if (albums)
    {
        var selectedIndex = [[m_albumsView selectedRowIndexes] firstIndex],
            album = albums[selectedIndex];

        [album
            addObserver:self
             forKeyPath:@"photos"
                options:0
                context:NULL];

        images = [albums[selectedIndex] valueForKeyPath:@"photos.largeImage"];
    }

    return images;
}

- (CPArray)synchronizePhotosViewWithAlbumsView
{
    var albums = [[FBConnectController sharedConnectController] valueForKeyPath:@"user.albums"],
        images = nil;

    if (albums)
    {
        var selectedIndex = [[m_albumsView selectedRowIndexes] firstIndex],
            album = albums[selectedIndex];

        [album
            addObserver:self
             forKeyPath:@"photos"
                options:0
                context:NULL];

        images = [albums[selectedIndex] valueForKeyPath:@"photos.image"];
    }

    [m_photosView setContent:images];
}

- (void)hideOrShowMainInterface
{
    [m_loginView setHidden:!![[FBConnectController sharedConnectController] user]];
}

- (void)observeValueForKeyPath:(CPString)aKeyPath ofObject:(id)anObject change:(CPDictionary)aChangeDictionary context:(id)aContext
{
    if (aKeyPath === "user.albums" || aKeyPath === "user")
    {
        [m_loginView setHidden:!![[FBConnectController sharedConnectController] user]];
        [m_albumsView reloadData];
        
        if ([m_albumsView numberOfRows] > 1)
            [m_albumsView selectRowIndexes:[CPIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }

    else if (aKeyPath === "photos")
        [self synchronizePhotosViewWithAlbumsView];
}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    [self synchronizePhotosViewWithAlbumsView];
}

- (int)numberOfRowsInTableView:(CPTableView)tableView
{
    return [[FBConnectController sharedConnectController] valueForKeyPath:@"user.albums.@count"];
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(int)aRowIndex
{
    return [[[FBConnectController sharedConnectController] valueForKeyPath:@"user.albums"][aRowIndex] name];
}

@end

@implementation CPImageView (x)

- (void)setRepresentedObject:(id)anObject
{
    [self setImage:anObject];
}

@end
