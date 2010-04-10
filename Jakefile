
var FILE = require("file"),
    ENV  = require("system").env,
    Jake = require("jake"),
    task = Jake.task,
    FileList = Jake.FileList,
    bundle = require("objective-j/jake").bundle,
    framework = require("objective-j/jake").framework,
    environment = require("objective-j/jake/environment");

$CONFIGURATION = ENV['CONFIG'] || "Release";

$BUILD_DIR = ENV['CAPP_BUILD'] || ENV['STEAM_BUILD'];

facebookKitTask = bundle ("FacebookKit", function(facebookKitTask)
{
    facebookKitTask.setBuildIntermediatesPath(FILE.join($BUILD_DIR, "FacebookKit.build", $CONFIGURATION))
    facebookKitTask.setBuildPath(FILE.join($BUILD_DIR, $CONFIGURATION));

    facebookKitTask.setAuthor("280 North, Inc.");
    facebookKitTask.setEmail("feedback @nospam@ 280north.com");
    facebookKitTask.setSummary("Plugin framework for Atlas");
    facebookKitTask.setIdentifier("com.280n.FacebookKit");
    facebookKitTask.setSources(new FileList("*.j").exclude("FacebookKitPlugin.j"), [environment.Browser, environment.CommonJS]);
    facebookKitTask.setResources(new FileList("Resources/*").exclude("Resources/FacebookKitLibrary.xib"));
    facebookKitTask.setFlattensSources(true);

    if ($CONFIGURATION === "Release")
        facebookKitTask.setCompilerFlags("-O");
    else
        facebookKitTask.setCompilerFlags("-DDEBUG -g");
});

facebookKitPluginTask = framework ("FacebookKit.atlasplugin", function(facebookKitPluginTask)
{
    facebookKitPluginTask.setBuildIntermediatesPath(FILE.join($BUILD_DIR, "FacebookKit.atlasplugin.build", $CONFIGURATION))
    facebookKitPluginTask.setBuildPath(FILE.join($BUILD_DIR, $CONFIGURATION));

    facebookKitPluginTask.setAuthor("280 North, Inc.");
    facebookKitPluginTask.setEmail("feedback @nospam@ 280north.com");
    facebookKitPluginTask.setSummary("FacebookKit Plugin for Atlas");
    facebookKitPluginTask.setIdentifier("com.280n.FacebookKit");
    facebookKitPluginTask.setInfoPlistPath("PluginInfo.plist");
    facebookKitPluginTask.setSources(new FileList("*.j"), [environment.Browser, environment.CommonJS]);
    facebookKitPluginTask.setResources(new FileList("Resources/*"));
    facebookKitPluginTask.setNib2CibFlags("-F " + FILE.join(FILE.join($BUILD_DIR, $CONFIGURATION), "AtlasKit") + " -R Resources");
    facebookKitPluginTask.setPrincipalClass("FacebookKitPlugin");
    facebookKitPluginTask.setFlattensSources(true);

    if ($CONFIGURATION === "Release")
        facebookKitPluginTask.setCompilerFlags("-O");
    else
        facebookKitPluginTask.setCompilerFlags("-DDEBUG -g");
});

task ("build", ["FacebookKit", "FacebookKit.atlasplugin"]);
task ("default", ["build"]);
