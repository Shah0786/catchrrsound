#import "SoundcodePlugin.h"
#if __has_include(<soundcode/soundcode-Swift.h>)
#import <soundcode/soundcode-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "soundcode-Swift.h"
#endif

@implementation SoundcodePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSoundcodePlugin registerWithRegistrar:registrar];
}
@end
