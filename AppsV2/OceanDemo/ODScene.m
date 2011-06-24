#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/Container/NSArray+NPPObject.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/State/NPStateConfiguration.h"
#import "NP.h"
#import "Entities/ODPEntity.h"
#import "Entities/ODCamera.h"
#import "Entities/ODProjector.h"
#import "Entities/ODEntity.h"
#import "ODScene.h"

@interface ODScene (Private)

- (id <ODPEntity>) loadEntityFromFile:(NSString *)fileName
                                error:(NSError **)error
                                     ;

@end

@implementation ODScene (Private)

- (id <ODPEntity>) loadEntityFromFile:(NSString *)fileName
                                error:(NSError **)error
{
    NSAssert(fileName != nil, @"");

    NSString * absoluteFileName
        = [[[ NPEngineCore instance ] 
                localPathManager ] getAbsolutePath:fileName ];

    if ( absoluteFileName == nil )
    {
        NPLOG_ERROR([ NSError fileNotFoundError:fileName ]);
        return nil;
    }

    NSDictionary * entityConfig
        = [ NSDictionary dictionaryWithContentsOfFile:absoluteFileName ];

    NSString * typeClassString  = [ entityConfig objectForKey:@"Type" ];
    NSString * entityNameString = [ entityConfig objectForKey:@"Name" ];

    NSAssert(typeClassString != nil && entityNameString != nil, @"");

    id <ODPEntity> entity
        = (id <ODPEntity>)[ entities objectWithName:entityNameString ];

    if ( entity != nil )
    {
        return entity;
    }

    NPLOG(@"");
    NPLOG(@"Loading %@", absoluteFileName);

    Class entityClass = NSClassFromString(typeClassString);
    if ( entityClass == Nil )
    {
        NPLOG(@"Error: Unknown entity type \"%@\", skipping",
              typeClassString);

        return nil;
    }

    entity = [[ entityClass alloc ] initWithName:@"" ];

    BOOL result
        = [ entity loadFromDictionary:entityConfig 
                                error:NULL ];

    if ( result == YES )
    {
        AUTORELEASE(entity);
    }
    else
    {
        NPLOG(@"Error: failed to load %@", absoluteFileName);
        DESTROY(entity);
    }

    return entity;
}

@end

@implementation ODScene

- (id) init
{
    return [ self initWithName:@"ODScene" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    ready = NO;
    file = nil;
    camera = nil;
    projector = nil;

    entities = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ entities removeAllObjects ];
    DESTROY(entities);

    SAFE_DESTROY(projector);
    SAFE_DESTROY(camera);
    SAFE_DESTROY(file);

    [ super dealloc ];
}

- (BOOL) ready
{
    return ready;
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    if ( error != NULL )
    {
        *error = nil;
    }

    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    if ( error != NULL )
    {
        *error = nil;
    }

    NSString * absoluteFileName
        = [[[ NPEngineCore instance ] 
                localPathManager ] getAbsolutePath:fileName ];

    if ( absoluteFileName == nil )
    {
        if ( error != NULL )
        {
            *error = [ NSError fileNotFoundError:fileName ];
        }

        return NO;
    }

    NSDictionary * sceneContents
        = [ NSDictionary dictionaryWithContentsOfFile:absoluteFileName ];

    NSString * sceneName           = [ sceneContents objectForKey:@"Name"      ];
    NSString * skylightEntityFile  = [ sceneContents objectForKey:@"Skylight"  ];
    NSString * cameraEntityFile    = [ sceneContents objectForKey:@"Camera"    ];
    NSString * projectorEntityFile = [ sceneContents objectForKey:@"Projector" ];
    NSArray  * entityFiles         = [ sceneContents objectForKey:@"Entities"  ];

    [ self setName:sceneName ];

    camera    = [ self loadEntityFromFile:cameraEntityFile    error:NULL ];
    projector = [ self loadEntityFromFile:projectorEntityFile error:NULL ];

    ASSERT_RETAIN(camera);
    ASSERT_RETAIN(projector);

    [ projector setCamera:camera ];

    const NSUInteger numberOfEntityFiles = [ entityFiles count ];
    for ( NSUInteger i = 0; i < numberOfEntityFiles; i++ )
    {
        id <ODPEntity> entity
            = [ self loadEntityFromFile:[ entityFiles objectAtIndex:i ]
                                  error:NULL ];

        if ( entity != nil )
        {
            [ entities addObject:entity ];
        }
    }

    return YES;
}

- (ODCamera *) camera
{
    return camera;
}

- (ODProjector *) projector
{
    return projector;
}

- (void) update:(const float)frameTime
{
    [ camera    update:frameTime ];
    [ projector update:frameTime ];

    const NSUInteger numberOfEntities = [ entities count ];
    for ( NSUInteger i = 0; i < numberOfEntities; i++ )
    {
        [[ entities objectAtIndex:i ] update:frameTime ];
    }
}

- (void) renderScene
{
    // reset states, makes depth buffer writable
    [[[ NP Graphics ] stateConfiguration ] deactivate ];

    // clear color and depth buffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    // reset matrices
    [[[ NP Core ] transformationState ] reset ];

    [[[[ NPEngineGraphics instance ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NPEngineGraphics instance ] stateConfiguration ] depthTestState ] setWriteEnabled:YES ];
    [[[[ NPEngineGraphics instance ] stateConfiguration ] depthTestState ] activate ];

    // set view and projection
    [ camera render ];

    // render entities
    [ entities makeObjectsPerformSelector:@selector(render) ];

    // render projector frustum
    [ projector render ];
}

- (void) render
{
    [ self renderScene ];
}

@end
