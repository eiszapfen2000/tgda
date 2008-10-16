#import "NPURLDownloadManager.h"
#import "NPURLDownload.h"

@implementation NPURLDownloadManager

- (id) init
{
    return [ self initWithName:@"NPEngine URL Download Manager" parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    urlDownloads = [ [ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ urlDownloads release ];

    [ super dealloc ];
}

- (void)addDownloadFrom:(NSURL *)url toFileAtPath:(NSString *)path
{
    if ( [ urlDownloads objectForKey:url ] == nil )
    {
        NPURLDownload * download = [ [ NPURLDownload alloc ] initWithName:[ url absoluteString ] parent:self ];
        [ download setFileToDownload:url ];
        [ download setDestinationFileName:path ];

        [ urlDownloads setObject:download forKey:url ];

        [ download startDownloading ];
        [ download release ];
    }
}

@end
