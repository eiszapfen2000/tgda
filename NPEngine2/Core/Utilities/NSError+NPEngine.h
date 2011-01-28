#import <Foundation/NSError.h>

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
