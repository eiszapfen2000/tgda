#import "NPPStream.h"

@class NSError;
@class NSString;

@protocol NPPPersistentObject

- (NSString *) fileName;
- (BOOL) ready;

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
                       ;

- (BOOL) loadFromFile:(NSString *)fileName
                error:(NSError **)error
                     ;

@end
