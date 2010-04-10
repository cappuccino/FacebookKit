
@import <Foundation/CPObject.j>

@import "FBUser.j"


var FacebookConnectURLString    = @"http://static.ak.fbcdn.net/connect/en_US/core.js",
    SharedConnectController     = nil;

var ConnectStatusUnconnected    = 0,
    ConnectStatusConnecting     = 1,
    ConnectStatusConnected      = 2;

var Uninitialized               = 0,
    Loading                     = 1,
    Loaded                      = 2;

@implementation FBConnectController : CPObject
{
    State       loadStatus;
    State       connectionStatus;
    State       loggedInStatus;

    CPString    APIKey @accessors(readonly);
    DOMElement  m_fbRoot;
    
    
    FBUser      m_user @accessors(readonly, property=user);
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    [CPJSONPConnection sendRequest:[CPURLRequest requestWithURL:FacebookConnectURLString]
                          callback:"callback"
                          delegate:nil];
}

+ (id)sharedConnectController
{
    return SharedConnectController || [[self alloc] init];
}

- (id)init
{
    if (SharedConnectController)
        return SharedConnectController;

    SharedConnectController = self;

    self = [super init];

    m_fbRoot = document.createElement("div");
    m_fbRoot.id = "fb-root";
    m_fbRoot.className = "cpdontremove";
    m_fbRoot.style.position = "absolute";
    m_fbRoot.style.top = "-1000px";
    m_fbRoot.style.width = "1px";
    m_fbRoot.style.height = "1px";

    [CPPlatform mainBodyElement].appendChild(m_fbRoot);

    [[CPNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(applicationDidFinishLaunching:)
               name:CPApplicationDidFinishLaunchingNotification
             object:nil];
    
    window.fbAsyncInit = function()
    {
        FB.Event.subscribe("auth.sessionChange", function(aResponse)
        {
            var user = nil;

            if (aResponse.session)
                user = [[FBUser alloc] initWithID:aResponse.session.uid];

            if (m_user !== user)
            {
                [self willChangeValueForKey:@"user"];

                self.m_user = user;

                [self didChangeValueForKey:@"user"];
            }

            [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
        });

        [[FBConnectController sharedConnectController] connect];

        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
    };

    SharedConnectController = self;

    return self;
}

- (void)connect
{
    FB.init(
    {
      apiKey : "cc28f8d5ce1962b3537b8f1a59782e37",//"f9ffbd6b9696f5cf5f8ab908bf8fcb02",
      status : true, // check login status
      cookie : true // enable cookies to allow the server to access the session
    });
}

- (void)login:(id)aSender
{
    FB.login();
}

- (void)logout:(id)aSender
{
    FB.logout();
}

- (void)query:(CPString)aQuery callback:(Function)aCallback
{
    FB.Data.query(aQuery).wait(function()
    {
        aCallback.apply(this, arguments);
        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
    });
}

@end

@implementation FBConnectController (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    return [FBConnectController sharedConnectController];
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
}

@end

[FBConnectController sharedConnectController];
