@class NSString;
@class NSError;

@protocol NPPLogger

- (void) logMessage:(NSString *)message;
- (void) logWarning:(NSString *)warning;
- (void) logError:(NSError *)error;

@end
