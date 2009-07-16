#import "NPStateSetManager.h"
#import "NP.h"

@implementation NPStateSetManager

- (id) init
{
    return [ self initWithName:@"NP State Set" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    keywordMappings = [[ NSMutableDictionary alloc ] init ];

    [ keywordMappings setObject:[ NSNumber numberWithInt:0] forKey:@"Never" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:1] forKey:@"Always" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:2] forKey:@"Less" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:3] forKey:@"LessEqual" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:4] forKey:@"Equal" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:5] forKey:@"Greater" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:6] forKey:@"GreaterEqual" ];

    [ keywordMappings setObject:[ NSNumber numberWithInt:0] forKey:@"Additive" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:1] forKey:@"Average" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:2] forKey:@"Negative" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:3] forKey:@"Min" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:4] forKey:@"Max" ];

    [ keywordMappings setObject:[ NSNumber numberWithInt:0] forKey:@"Point" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:1] forKey:@"Line" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:2] forKey:@"Face" ];

    [ keywordMappings setObject:[ NSNumber numberWithInt:0] forKey:@"Front" ];
    [ keywordMappings setObject:[ NSNumber numberWithInt:1] forKey:@"Back" ];

    stateSets = [[ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ keywordMappings removeAllObjects ];
    [ keywordMappings release ];

    [ stateSets removeAllObjects ];
    [ stateSets release ];

    [ super dealloc ];
}

- (NSDictionary *) keywordMappings
{
    return keywordMappings;
}

- (id) valueForKeyword:(NSString *)keyword
{
    return [ keywordMappings objectForKey:keyword ];
}

- (id) loadStateSetFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadStateSetFromAbsolutePath:absolutePath ];
}

- (id) loadStateSetFromAbsolutePath:(NSString *)path
{
    if ( [ path isEqual:@"" ] == NO )
    {
        NPStateSet * stateSet = [ stateSets objectForKey:path ];

        if ( stateSet == nil )
        {
            NPLOG(@"%@: loading %@", name, path);

            stateSet = [[ NPStateSet alloc ] initWithName:path parent:self ];
            [ stateSet loadFromFile:path ];
            [ stateSets setObject:stateSet forKey:path ];
            [ stateSet release ];
        }

        return stateSet;
    }

    return nil;
}

@end
