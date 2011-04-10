#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"
#import "GL/glew.h"

@class NSData;
@class NSError;

@interface NPBufferObject : NPObject
{
    GLuint glID;
    GLenum glTarget;
    NpBufferObjectType type;
    NpBufferDataUpdateRate updateRate;
    NpBufferDataUsage dataUsage;

}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (GLuint) glID;

- (BOOL) generate:(NpBufferObjectType)newType
       updateRate:(NpBufferDataUpdateRate)newUpdateRate
        dataUsage:(NpBufferDataUsage)newDataUsage
             data:(NSData *)newData
            error:(NSError **)error
                 ;

- (void) activate;
- (void) deactivate;

@end

