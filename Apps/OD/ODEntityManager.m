#import "ODEntityManager.h"
#import "ODEntity.h"
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

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
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
    NPLOG(([NSString stringWithFormat:@"%@: loading %@", name, path]));

    if ( [ path isEqual:@"" ] == NO )
    {
        id entity = [ entities objectForKey:path ];

        if ( entity == nil )
        {
            entity = [[ ODEntity alloc ] initWithName:@"" parent:self ];

            if ( [ entity loadFromPath:path ] == YES )
            {
                [ entities setObject:entity forKey:path ];
                [ entity release ];

                return entity;
            }
            else
            {
                [ entity release ];

                return nil;
            }
        }

        return entity;
    }

    return nil;
}

@end
