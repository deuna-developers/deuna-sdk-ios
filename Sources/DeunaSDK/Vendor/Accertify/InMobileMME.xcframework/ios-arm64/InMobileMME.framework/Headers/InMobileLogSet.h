//
//  InMobileLogSet.h
//  InMobileMME
//
//  Created on 9/20/23.
//  Copyright © 2023 Accertify, Inc. All rights reserved.
//  

#ifndef InMobileLogSet_h
#define InMobileLogSet_h

/**
A set of logs to be gathered by the SDK.
 */
typedef NS_OPTIONS(UInt64, InMobileLogSet) {
    InMobileLogSetEmpty           = 0ull,
    InMobileLogSetAccelerometer   = (1ull << 0),
    InMobileLogSetAnomalies       = (1ull << 25),
    InMobileLogSetApplicationInfo = (1ull << 13),
    InMobileLogSetBattery         = (1ull << 1),
    InMobileLogSetBluetooth       = (1ull << 26),
    InMobileLogSetCamera          = (1ull << 32),
    InMobileLogSetDataUsage       = (1ull << 3),
    InMobileLogSetDevice          = (1ull << 4),
    InMobileLogSetDeviceAccess    = (1ull << 24),
    InMobileLogSetGPS             = (1ull << 5),
    InMobileLogSetHardware        = (1ull << 6),
    InMobileLogSetLocale          = (1ull << 30),
    InMobileLogSetMalware         = (1ull << 7),
    InMobileLogSetPermissions     = (1ull << 27),
    InMobileLogSetRoot            = (1ull << 10),
    InMobileLogSetScreen          = (1ull << 29),
    InMobileLogSetWifi            = (1ull << 12),
    InMobileLogSetFont            = (1ull << 33),
    InMobileLogSetAppStore        = (1ull << 34),
    InMobileLogSetPollingGPS      = (1ull << 35),
    InMobileLogSetAppAttest       = (1ull << 36),
    InMobileLogSetSensor          = (1ull << 37),
    InMobileLogSetServerLog       = 0xFFFFFFFFFFFFFFFF,
    InMobileLogSetAll             = InMobileLogSetAccelerometer | InMobileLogSetAnomalies | InMobileLogSetApplicationInfo | InMobileLogSetBattery | InMobileLogSetBluetooth | InMobileLogSetCamera | InMobileLogSetDataUsage | InMobileLogSetDevice | InMobileLogSetDeviceAccess | InMobileLogSetGPS | InMobileLogSetHardware | InMobileLogSetLocale | InMobileLogSetMalware | InMobileLogSetPermissions | InMobileLogSetRoot | InMobileLogSetScreen | InMobileLogSetWifi | InMobileLogSetFont | InMobileLogSetAppStore | InMobileLogSetPollingGPS | InMobileLogSetAppAttest | InMobileLogSetSensor
};

#endif /* InMobileLogSet_h */
