#import <Foundation/NSError.h>

NSString * const NPEngineErrorDomain;

@interface NSError (NPEngine)

+ (id) fileNotFoundError:(NSString *)fileName;

+ (id) errorWithCode:(NSInteger)code 
         description:(NSString *)description
                    ;

+ (id) errorWithDomain:(NSString *)domain 
                  code:(NSInteger)code
           description:(NSString *)description
                      ;

@end
