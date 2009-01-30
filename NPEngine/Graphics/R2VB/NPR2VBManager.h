#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"

@class NPR2VBConfiguration;

@interface NPR2VBManager : NPObject
{
    NSMutableArray * configurations;
    NPR2VBConfiguration * currentConfiguration;
    NSSet * bufferKeys;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NSSet *) bufferKeys;
- (BOOL) isValidBufferKey:(NSString *)bufferKey;
- (NPR2VBConfiguration *) currentConfiguration;
- (void) setCurrentConfiguration:(NPR2VBConfiguration *)newCurrentConfiguration;

- (GLenum) glBufferIdentifierFromNPBufferIdentifier:(NSNumber *)bufferIdentifier;

@end
