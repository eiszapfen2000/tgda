#import "Core/NPObject/NPObject.h"

@interface NPViewport : NPObject
{
	uint32_t left;
	uint32_t right;
	uint32_t bottom;
	uint32_t top;
	float   aspectRatio;
	uint32_t widgetWidth;
	uint32_t widgetHeight;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (uint32_t) left;
- (uint32_t) right;
- (uint32_t) bottom;
- (uint32_t) top;
- (uint32_t) width;
- (uint32_t) height;
- (float) aspectRatio;
- (uint32_t) widgetWidth;
- (uint32_t) widgetHeight;
- (void) setWidgetWidth:(uint32_t)newWidgetWidth;
- (void) setWidgetHeight:(uint32_t)newWidgetHeight;

- (void) reset;

- (void) setWidth:(uint32_t)newWidth
           height:(uint32_t)newHeight
                 ;

- (void) setLeft:(uint32_t)newLeft
           right:(uint32_t)newRight
          bottom:(uint32_t)newBottom
             top:(uint32_t)newTop
                ;
    

@end
