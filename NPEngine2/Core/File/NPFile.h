#import <Foundation/NSFileHandle.h>
#import "Core/NPObject/NPObject.h"
#import "NPPStream.h"

#define NP_FILE_READING     0
#define NP_FILE_UPDATING    1
#define NP_FILE_WRITING     2

typedef enum NpFileMode
{
    NpFileRead = 0,
    NpFileUpdate = 1,
    NpFileWrite = 2
}
NpFileMode;

@interface NPFile : NPObject < NPPStream >
{
    NSString * fileName;
    NSFileHandle * fileHandle;
    NpFileMode mode;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName 
             parent:(id <NPPObject> )newParent
                   ;

- (id) initWithName:(NSString *)newName 
             parent:(id <NPPObject> )newParent
           fileName:(NSString *)newFileName
                   ;

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject>)newParent
           fileName:(NSString *)newFileName
               mode:(NpFileMode)newMode
                   ;

- (void) dealloc;

- (NSString *) fileName;
- (NpFileMode) mode;

- (void) openFile:(NSString *)newFileName
             mode:(NpFileMode)newMode
                 ;

- (void) close;

@end
