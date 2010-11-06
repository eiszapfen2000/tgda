#import <Foundation/NSString.h>
#import "NPPStream.h"

@class NSError;

@protocol NPPPersistentObject

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
                       ;

- (BOOL) loadFromFile:(NSString *)fileName
                error:(NSError **)error
                     ;

@end
