#import <Foundation/Foundation.h>
#import "FPGMImage.h"
#import "NP.h"

@implementation FPGMImage

- (id) init
{
    return [ self initWithName:@"PGMImage" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    width = height = -1;

    return self;
}

- (void) dealloc
{
    SAFE_FREE(imageData);

    [ super dealloc ];
}

- (Long) width
{
    return width;
}

- (Long) height
{
    return height;
}

- (Byte *) imageData
{
    return imageData;
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSData * data = [ NSData dataWithContentsOfFile:path ];

    const char * bytes = [ data bytes ];
    const char * offset = bytes;

    // Check header
    if ( offset[0] != 'P' || offset[1] != '5' )
    {
        NPLOG_ERROR(@"%@: invalid header", path);
        return NO;
    }

    // Skip newlines
    UInt index = 0;
    for ( UInt i = 0; i < [ data length ]; i++ )
    {
        if ( bytes[i] == '\r' || bytes[i] == '\n' )
        {
            offset = &(bytes[i+1]);
            index = i+1;
            break;
        }
    }

    //NSLog(@"%c %d",bytes[index], index);

    // Skip comments
    while ( bytes[index] == '#' )
    {
        for ( UInt i = index; i < [ data length ]; i++ )
        {
            if ( bytes[i] == '\r' || bytes[i] == '\n' )
            {
                offset = &(bytes[i+1]);
                index = i+1;
                break;
            }
        }
    }

    char * tail;
    char * tmp;

    width = strtol(offset, &tail, 0);
    height = strtol(tail, &tmp, 0);
    long int max = strtol(tmp, &tail, 0);

    //NSLog(@"%d %d", (int)width, (int)height);

    if ( max > 255 )
    {
        NPLOG_ERROR(@"RFPGMImage does not support 16Bit images");
        return NO;
    }

    ptrdiff_t d = tail - offset;
    offset = tail;
    index = index + (int)d;

    //NSLog(@"%d",d);

    // Skip newlines
    for ( UInt i = index; i < [ data length ]; i++ )
    {
        if ( bytes[i] == '\r' || bytes[i] == '\n' )
        {
            offset = &(bytes[i+1]);
            index = i+1;
            break;
        }
    }

    /*for ( int j = 0; j < width*height; j++ )
    {
        NSLog(@"%d %x",j,(int)offset[j]);
    }*/

    imageData = ALLOC_ARRAY(Byte, width*height);
    memcpy(imageData, offset, width*height);

    return YES;
}

@end
