#import <stdio.h>
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPStream.h"

@interface NPFile : NPObject < NPPStream >
{
    NSString * fileName;
    NpStreamMode mode;
    FILE * file;
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
