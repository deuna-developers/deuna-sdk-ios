#import "include/DeunaObjCBridge.h"

BOOL DeunaPerformSafely(void (^block)(void), NSString **outError) {
    @try {
        block();
        return YES;
    } @catch (NSException *exception) {
        if (outError) {
            *outError = exception.reason ?: exception.name;
        }
        return NO;
    }
}
