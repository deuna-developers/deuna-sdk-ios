/*!
 @header HybridAppSupport.h

 @copyright ThreatMetrix. All rights reserved.
 */

#ifndef _TMXHYBRIDAPPSUPPORT_H
#define _TMXHYBRIDAPPSUPPORT_H

#import <Foundation/Foundation.h>


#ifndef TMX_PREFIX_NAME
#define NO_COMPAT_CLASS_NAME
#endif



NS_ASSUME_NONNULL_BEGIN

/*!
 * This class should only be used when application is developed using SwiftUI or
 * hybrid applications like ReactNative.
 */
@interface RLTMXHybridAppSupport : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone * _Nullable)zone NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*!
 * @abstract Changes the page (View Controller) name used by TMXBehavioSec module.
 * @discussion Use this method to pass the name of ViewController (component) when
 * application is developed using SwiftUI or hybrid applications like ReactNative.
 *
 * @param pageName Name of ViewController
 */
- (void)changePageName:(NSString *)pageName NS_SWIFT_NAME(changePageName(pageName:));

/*!
 * @abstract Clears TMXBehavioSec registration.
 * @discussion Use this method to clear UI registrations when navigating out of a page
 * developed using SwiftUI or hybrid applications like ReactNative.
 */
- (void)clearRegistrations NS_SWIFT_NAME(clearRegistrations());



@end

/*!
 * This class should only be used when application is developed using
 * hybrid applications like Flutter. It adds additional Ntf (Non-Text Field) support
 */
@interface RLTMXHybridAppWithNTFSupport : RLTMXHybridAppSupport

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

// expose Ntf methods
- (void)registerKeyboardTargetNTF:(NSObject *)target withName:(NSString *)name isMasked:(BOOL)masked NS_SWIFT_NAME(registerKeyboadTargetNTF(target:name:isMasked:));
- (void)keyboardTargetTextChangedNTF:(NSObject *)target to:(NSString *)newText NS_SWIFT_NAME(keyboardTargetTextChangedNTF(target:newtText:));
- (void)setCurrentKeyboardTargetNTF:(NSObject *)target withText:(NSString *)text NS_SWIFT_NAME(setCurrentKeyboardTargetNTF(target:text:));
- (void)clearCurrentKeyboardTargetNTF:(NSObject *)target NS_SWIFT_NAME(clearCurrentKeyboardTargetNTF(target:));

@end

@interface RLReactNativeSupport : RLTMXHybridAppSupport
@end

@interface RLSwiftUISupport : RLTMXHybridAppSupport
@end

@interface RLFlutterSupport : RLTMXHybridAppWithNTFSupport
@end

@interface RLCordovaSupport : RLTMXHybridAppWithNTFSupport
@end

NS_ASSUME_NONNULL_END

#endif /* HybridAppSupport_h */
