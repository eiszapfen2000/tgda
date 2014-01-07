#import "Core/NPObject/NPObject.h"

@interface NPURLDownloadManager : NPObject
{
    NSMutableDictionary * urlDownloads;
}

- (id) init;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void)addDownloadFrom:(NSURL *)url toFileAtPath:(NSString *)path;

@end

