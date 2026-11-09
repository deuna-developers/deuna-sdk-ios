//
//  HybridAppSupport.h
//  TMXProfiling
//
//  Created by Samin Pour on 30/1/2024.
//  Copyright © 2024 ThreatMetrix. All rights reserved.
//

#ifndef _TMXHYBRIDAPPSUPPORT_H
#define _TMXHYBRIDAPPSUPPORT_H

#import <Foundation/Foundation.h>

#define TMX_NAME_PASTE2( a, b) a##b
#define TMX_NAME_PASTE( a, b) TMX_NAME_PASTE2( a, b)

#ifndef TMX_PREFIX_NAME
#define NO_COMPAT_CLASS_NAME
#define TMX_PREFIX_NAME
#endif

#define TMXHybridAppSupport TMX_NAME_PASTE(TMX_PREFIX_NAME, TMXHybridAppSupport)
#define TMXHybridAppWithNTFSupport TMX_NAME_PASTE(TMX_PREFIX_NAME, TMXHybridAppWithNTFSupport)

#define ReactNativeSupport TMX_NAME_PASTE(TMX_PREFIX_NAME, ReactNativeSupport)
#define SwiftUISupport TMX_NAME_PASTE(TMX_PREFIX_NAME, SwiftUISupport)
#define FlutterSupport TMX_NAME_PASTE(TMX_PREFIX_NAME, FlutterSupport)
#define CordovaSupport TMX_NAME_PASTE(TMX_PREFIX_NAME, CordovaSupport)

NS_ASSUME_NONNULL_BEGIN

/*!
 * This class should only be used when application is developed using SwiftUI or
 * hybrid applications like ReactNative.
 */
@interface TMXHybridAppSupport : NSObject

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
 * hybrid applications like Flutter. It adds additional Ntf (Non Text Field) support
 */
@interface TMXHybridAppWithNTFSupport : TMXHybridAppSupport

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

// expose Ntf methods
- (void)registerKeyboardTargetNTF:(NSObject *)target withName:(NSString *)name isMasked:(BOOL)masked NS_SWIFT_NAME(registerKeyboadTargetNTF(target:name:isMasked:));
- (void)keyboardTargetTextChangedNTF:(NSObject *)target to:(NSString *)newText NS_SWIFT_NAME(keyboardTargetTextChangedNTF(target:newtText:));
- (void)setCurrentKeyboardTargetNTF:(NSObject *)target withText:(NSString *)text NS_SWIFT_NAME(setCurrentKeyboardTargetNTF(target:text:));
- (void)clearCurrentKeyboardTargetNTF:(NSObject *)target NS_SWIFT_NAME(clearCurrentKeyboardTargetNTF(target:));

@end

@interface ReactNativeSupport : TMXHybridAppSupport
@end

@interface SwiftUISupport : TMXHybridAppSupport
@end

@interface FlutterSupport : TMXHybridAppWithNTFSupport
@end

@interface CordovaSupport : TMXHybridAppWithNTFSupport
@end

NS_ASSUME_NONNULL_END

#endif /* HybridAppSupport_h */
