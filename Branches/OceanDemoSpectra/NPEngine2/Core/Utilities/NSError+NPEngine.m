#import <Foundation/NSDictionary.h>
#import "Core/NPObject/NPObject.h"
#import "Core/NPEngineCoreErrors.h"
#import "NSError+NPEngine.h"

NSString* const NPEngineErrorDomain = @"NPEngineErrorDomain";

@implementation NSError (NPEngine)

+ (id) fileNotFoundError:(NSString *)fileName
{
    NSString * description
        = [ NSString stringWithFormat:@"Unable to locate file \"%@\"", fileName ];

    return [ NSError errorWithDomain:NPEngineErrorDomain
                                code:NPPathFileNotFoundError
                         description:description ];
}

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

