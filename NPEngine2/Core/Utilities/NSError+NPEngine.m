#import <Foundation/NSDictionary.h>
#import "Core/NPObject/NPObject.h"
#import "NSError+NPEngine.h"

@implementation NSError (NPEngine)

+ (id) errorWithCode:(NSInteger)code 
         description:(NSString *)description
{
    NSMutableDictionary * userInfo = [ NSMutableDictionary dictionary ];
    [ userInfo setValue:description forKey:NSLocalizedDescriptionKey ];

    return [ NSError errorWithDomain:NPEngineErrorDomain
                                code:code
                            userInfo:userInfo ];                
}

+ (id) errorWithDomain:(NSString *)domain 
                  code:(NSInteger)code
           description:(NSString *)description
{
    NSMutableDictionary * userInfo = [ NSMutableDictionary dictionary ];
    [ userInfo setValue:description forKey:NSLocalizedDescriptionKey ];

    return [ NSError errorWithDomain:domain
                                code:code
                            userInfo:userInfo ]; 
}

@end

