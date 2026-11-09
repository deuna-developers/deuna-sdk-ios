//
//  InMobileVersion.h
//  InMobileMME
//
//  Created on 8/30/23.
//  Copyright © 2023 Accertify, Inc. All rights reserved.
//  

#ifndef InMobileVersion_h
#define InMobileVersion_h

#import <Foundation/Foundation.h>
/**
  The version of the SDK as a NSString.
  The format is iOS-MME-<Build Flavor-><Bitcode Enabled-><Version Number>.
  Build Flavor can be FULL, STL (Stripped with Location) or ST (Stripped).
  If the build doesn’t have bitcode enabled it will not have “BITCODE” as part of the version.
*/
__attribute__((visibility("default"))) FOUNDATION_EXPORT NSString *const MME_SDK_VERSION;

#endif /* InMobileVersion_h */
