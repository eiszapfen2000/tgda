#import <Foundation/NSArray.h>
#import "Core/NPEngineCore.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "NPEffectCompiler.h"
#import "NPEffect.h"

@implementation NPEffect

- (id) init
{
    return [ self initWithName:@"Effect" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    file = nil;
    ready = NO;
    techniques = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ self clear ];
    DESTROY(techniques);
    [ super dealloc ];
}

- (void) clear
{
    SAFE_DESTROY(file);
    ready = NO;
    [ techniques removeAllObjects ];
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) ready
{
    return ready;
}

- (id) addTechniqueWithName:(NSString *)techniqueName
{
    NPEffectTechnique * t
        = [[ NPEffectTechnique alloc ] initWithName:techniqueName
                                             parent:self ];

    [ techniques addObject:t ];

    return AUTORELEASE(t);
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
                error:(NSError **)error
{
    [ self clear ];

    // check if file is to be found
    NSString * completeFileName
        = [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:fileName ];

    if ( completeFileName == nil )
    {
        if ( error != NULL )
        {
            *error = [ NSError fileNotFoundError:fileName ];
        }

        return NO;
    }

    [ self setName:completeFileName ];
    ASSIGNCOPY(file, completeFileName);

    NPStringList * effectScript = AUTORELEASE([[ NPStringList alloc ] init ]);
    [ effectScript setAllowDuplicates:YES ];

    if ( [ effectScript loadFromFile:completeFileName 
                               error:error ] == NO )
    {
        return NO;
    }

    NPEffectCompiler * compiler = [[ NPEffectCompiler alloc ] init ];
    [ compiler compileScript:effectScript intoEffect:self ];
    DESTROY(compiler);

    return NO;
}

@end
