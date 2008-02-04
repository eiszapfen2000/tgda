#import "NPModelManager.h"
#import "NPSUXModel.h"
#import "Core/File/NPFile.h"
#import "Core/NPEngineCore.h"

@implementation NPModelManager

- (id) init
{
    return [ self initWithName:@"NPEngine Pathmanager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    models = [ [ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ models release ];

    [ super dealloc ];
}

- (id) loadModelFromPath:(NSString *)path
{
    NSString * absolutePath = [ [ [ NPEngineCore instance ] pathManager ] getAbsoluteFilePath:path ];

    if ( [ absolutePath isEqual:path ] == NO )
    {
        NPFile * file = [ [ NPFile alloc ] initWithName:path parent:self fileName:absolutePath ];
        NPSUXModel * model = [ [ NPSUXModel alloc ] initWithName:@"" parent:self ];

        if ( [ model loadFromFile:file ] == YES )
        {
            [ models setObject:model forKey:absolutePath ];
            [ models release ];

            return model;
        }
    }

    return nil;
}

@end
