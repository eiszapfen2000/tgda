#import "ODOceanEntity.h"

@implementation ODOceanEntity

- (id) init
{
    return [ self initWithName:@"ODOceanEntity" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(stateset);

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    return NO;
}

- (void) update:(const float)frameTime
{
}

- (void) render
{
}

@end

