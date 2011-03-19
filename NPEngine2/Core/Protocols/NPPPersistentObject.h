#import "NPPObject.h"
#import "NPPStream.h"

@class NSError;
@class NSString;
@class NSDictionary;

@protocol NPPPersistentObject < NPPObject >

- (NSString *) fileName;
- (BOOL) ready;

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
                       ;

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
                     ;

@end
