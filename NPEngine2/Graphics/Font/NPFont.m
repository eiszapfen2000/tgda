#import <Foundation/NSArray.h>
#import "NPFont.h"

@implementation NPFont

- (id) init
{
    return [ self initWithName:@"Font" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    file = nil;
    ready = NO;

    characterPages = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ characterPages removeAllObjects ];
    DESTROY(characterPages);
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
    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    return NO;
}

@end

