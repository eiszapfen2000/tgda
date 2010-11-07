#import <Foundation/NSFileManager.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>

@interface NSFileManager ( NPEngine )

- (BOOL) isFile:(NSString *)path;
- (BOOL) isDirectory:(NSString *)path;
- (BOOL) isURL:(NSString *)path;

- (BOOL) createEmptyFileAtPath:(NSString *)path;

@end

