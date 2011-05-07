#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/String/NPStringList.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "NPSUX2MaterialInstance.h"

@implementation NPSUX2MaterialInstance

- (id) init
{
    return [ self initWithName:@"SUX2 Material Instance" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    file = nil;
    ready = NO;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) ready
{
    return ready;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    NSString * materialInstanceName;
    NSString * materialScriptFileName;

    [ stream readSUXString:&materialInstanceName ];
    [ stream readSUXString:&materialScriptFileName ];

    NPStringList * materialInstanceScript
        = [[ NPStringList alloc ] initWithName:@""
                               allowDuplicates:YES
                             allowEmptyStrings:NO ];

    BOOL read
        = [ materialInstanceScript
              loadFromStream:stream
                       error:NULL ];

    if ( read == NO )
    {
        NPLOG(@"Failed to read material instance script");
    }

    NPLOG(materialInstanceName);
    NPLOG(materialScriptFileName);
    NPLOG([ materialInstanceScript description ]);

    DESTROY(materialInstanceScript);

    return read;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    return NO;
}

@end
