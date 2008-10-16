#import "NPURLDownload.h"
#import "Core/NPEngineCore.h"

@implementation NPURLDownload

- (id) init
{
    return [ self initWithName:@"NPEngine URL Download" parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    return self;
}

- (void) dealloc
{
    [ fileToDownload release ];
    [ destinationFileName release ];

    [ super dealloc ];
}

- (NSURL *) fileToDownload
{
    return fileToDownload;
}

- (void) setFileToDownload:(NSURL *)newFileToDownload
{
    if ( fileToDownload != newFileToDownload )
    {
        [ fileToDownload release ];

        fileToDownload = newFileToDownload;
    }
}

- (NSString *) destinationFileName
{
    return destinationFileName;
}

- (void) setDestinationFileName:(NSString *)newDestinationFileName
{
    if ( destinationFileName != newDestinationFileName )
    {
        [ destinationFileName release ];

        destinationFileName = [ newDestinationFileName retain ];
    }
}

- (void) startDownloading
{
    NPLOG([@"Downloading " stringByAppendingString:[ fileToDownload description ] ]);

    [ fileToDownload loadResourceDataNotifyingClient:self usingCache:YES ];
}

- (void)URLResourceDidFinishLoading:(NSURL *)sender
{
    NPLOG([@"Done downloading " stringByAppendingString:[ sender description ] ]);

    NSData * urlData = [ sender resourceDataUsingCache:YES ];

    if ( [ urlData writeToFile:destinationFileName atomically:YES ] == NO )
    {
        NPLOG([@"Failed to write to disk " stringByAppendingString:[ sender description ] ]);        
    }
}

- (void)URLResourceDidCancelLoading:(NSURL *)sender
{
   NPLOG([@"Download canceled " stringByAppendingString:[ sender description ] ]);
}

- (void)URL:(NSURL *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{
    NSString * message = [ NSString stringWithFormat:@"%@ failed to download with reason %@",[ sender description ],reason ];
    NPLOG(message);
}

- (void)URL:(NSURL *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes
{

}

@end
