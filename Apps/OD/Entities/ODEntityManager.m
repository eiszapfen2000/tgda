#import "NP.h"

#import "ODEntityManager.h"
#import "ODCamera.h"
#import "ODProjector.h"
#import "ODEntity.h"
//#import "ODOceanEntity.h"
#import "ODPreethamSkylight.h"


@implementation ODEntityManager

- (id) init
{
    return [ self initWithName:@"OD Entity Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    entities = [[ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ entities removeAllObjects ];
    [ entities release ];

    [ super dealloc ];
}

- (id) loadEntityFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadEntityFromAbsolutePath:absolutePath ];   
}

- (id) loadEntityFromAbsolutePath:(NSString *)path
{
    if ( [ path isEqual:@"" ] == NO )
    {
        id entity = [ entities objectForKey:path ];

        if ( entity == nil )
        {
            NPLOG(@"");
            NPLOG(@"%@: loading %@", name, path);

            NSDictionary * config = [ NSDictionary dictionaryWithContentsOfFile:path ];
            NSString * typeClassString = [ config objectForKey:@"Type" ];

            if ( typeClassString != nil )
            {
                Class entityClass = NSClassFromString(typeClassString);
                if ( entityClass == Nil )
                {
                    NPLOG_ERROR(@"%@: Unknown entity type \"%@\", skipping", name, typeClassString);

                    return nil;
                }

                [[[ NP Core ] logger ] pushPrefix:@"  " ];

                entity = [[ entityClass alloc ] initWithName:@"" parent:self ];
                BOOL result = [ entity loadFromDictionary:config ];

                [[[ NP Core ] logger ] popPrefix ];

                if ( result == YES )
                {
                    [ entities setObject:entity forKey:path ];
                    [ entity release ];

                    return entity;
                }
                else
                {
                    NPLOG_ERROR(@"%@: failed to load %@", name, path);
                    [ entity release ];

                    return nil;
                }
            }
        }

        return entity;
    }

    return nil;
}

@end
