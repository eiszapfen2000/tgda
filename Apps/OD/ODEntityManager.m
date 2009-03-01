#import "ODEntityManager.h"
#import "ODEntity.h"
#import "ODOceanEntity.h"
#import "NP.h"

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
    extensionToEntityClass = [[ NSMutableDictionary alloc ] init ];

    Class entity = [ ODEntity      class ];
    Class ocean  = [ ODOceanEntity class ];
    [ extensionToEntityClass setObject:entity forKey:@"entity" ];
    [ extensionToEntityClass setObject:ocean  forKey:@"odata" ];

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
    NPLOG(@"");
    NPLOG(([NSString stringWithFormat:@"%@: loading %@", name, path]));

    if ( [ path isEqual:@"" ] == NO )
    {
        id entity = [ entities objectForKey:path ];

        if ( entity == nil )
        {
            Class entityClass = [ extensionToEntityClass objectForKey:[ path pathExtension ]];

            if ( entityClass == Nil )
            {
                NPLOG_ERROR(@"%@: Unknown entity type, skipping", name);
                return nil;
            }

            entity = [[ entityClass alloc ] initWithName:@"" parent:self ];

            if ( [ entity loadFromPath:path ] == YES )
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

        return entity;
    }

    return nil;
}

@end
