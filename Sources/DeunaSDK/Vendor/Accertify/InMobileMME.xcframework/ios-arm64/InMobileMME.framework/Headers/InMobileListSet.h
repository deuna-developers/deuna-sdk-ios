//
//  InMobileListSet.h
//  InMobileMME
//
//  Created on 9/20/23.
//  Copyright © 2023 Accertify, Inc. All rights reserved.
//  

#ifndef InMobileListSet_h
#define InMobileListSet_h

/**
 Specifies which types of lists should be updated.
 */
typedef NS_OPTIONS(UInt16, InMobileListSet) {
    InMobileListSetEmpty           = 0,
    InMobileListSetRoot            = (1u << 1),
    InMobileListSetMalware         = (1u << 2),
    InMobileListSetLogConfig       = (1u << 3),
    InMobileListSetRemoteRoot      = (1u << 4),
    InMobileListSetRemoteMalware   = (1u << 5),
    InMobileListSetRemoteLogConfig = (1u << 6),
    InMobileListSetLocalModel      = (1u << 7),
    InMobileListSetRemoteModel      = (1u << 8),
    InMobileListSetAll             = InMobileListSetRoot | InMobileListSetMalware | InMobileListSetLogConfig | InMobileListSetRemoteRoot | InMobileListSetRemoteMalware | InMobileListSetRemoteLogConfig | InMobileListSetLocalModel | InMobileListSetRemoteModel
};

#endif /* InMobileListSet_h */
