#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Executes `block` inside an ObjC @try/@catch.
/// Returns YES on success, NO if an NSException was raised.
/// On failure, `outError` is set to the exception reason string.
FOUNDATION_EXPORT BOOL DeunaPerformSafely(void (^block)(void),
                                          NSString * _Nullable * _Nullable outError);

NS_ASSUME_NONNULL_END
