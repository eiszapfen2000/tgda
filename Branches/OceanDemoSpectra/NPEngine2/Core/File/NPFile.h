#import <stdio.h>
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPStream.h"

@interface NPFile : NPObject < NPPStream >
{
    NSString * fileName;
    NpStreamMode mode;
    FILE * file;
}

- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
           fileName:(NSString *)newFileName
               mode:(NpStreamMode)newMode
              error:(NSError **)error
                   ;

- (void) dealloc;

- (NSString *) fileName;
- (NpStreamMode) mode;

- (BOOL) openFile:(NSString *)newFileName
             mode:(NpStreamMode)newMode
            error:(NSError **)error
                 ;

- (void) close;

@end
