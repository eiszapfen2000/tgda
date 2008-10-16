#import "Core/NPObject/NPObject.h"

@class NPFile;
@class NPSUXModel;

@interface NPModelManager : NPObject
{
    NSMutableDictionary * models;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (id) loadModelFromPath:(NSString *)path;
- (id) loadModelFromAbsolutePath:(NSString *)path;
- (id) loadModelUsingFileHandle:(NPFile *)file;

- (BOOL) saveModel:(NPSUXModel *)model atAbsolutePath:(NSString *)path;

@end
