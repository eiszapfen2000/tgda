#import "Core/NPObject/NPObject.h"

@interface NPURLDownload : NPObject
{
    NSURL * fileToDownload;
    NSString * destinationFileName;
}

- (id) init;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NSURL *) fileToDownload;
- (void) setFileToDownload:(NSURL *)newFileToDownload;

- (NSString *) destinationFileName;
- (void) setDestinationFileName:(NSString *)newDestinationFileName;

- (void) startDownloading;

@end
