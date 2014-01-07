#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPStream.h"
#import "fftw3.h"

@class NSError;

@interface OBOceanSurfaceSlice : NPObject
{
    double time;
    size_t numberOfHeightElements;
    double * heights;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) setTime:(double)newTime;
- (void) setHeights:(double *)newHeights
   numberOfElements:(size_t)numberOfElements
                   ;

- (BOOL) writeToStream:(id <NPPStream>)stream
                 error:(NSError **)error
                      ;

@end
