#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"

@class NPStateConfiguration;

#define NP_FRONT_FACE               0
#define NP_BACK_FACE                1
#define NP_FRONT_AND_BACK_FACE      2

#define NP_POLYGON_FILL_POINT       0
#define NP_POLYGON_FILL_LINE        1
#define NP_POLYGON_FILL_FACE        2

#define NP_COMPARISON_NEVER         0
#define NP_COMPARISON_ALWAYS        1
#define NP_COMPARISON_LESS          2
#define NP_COMPARISON_LESS_EQUAL    3
#define NP_COMPARISON_EQUAL         4
#define NP_COMPARISON_GREATER       5
#define NP_COMPARISON_GREATER_EQUAL 6

#define NP_BLENDING_ADDITIVE        0
#define NP_BLENDING_AVERAGE         1
#define NP_BLENDING_NEGATIVE        2
#define NP_BLENDING_MIN             3
#define NP_BLENDING_MAX             4

@interface NPState : NPObject
{
    NPStateConfiguration * configuration;
    BOOL locked;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent configuration:(NPStateConfiguration *)newConfiguration;
- (void) dealloc;

- (BOOL) locked;
- (void) setLocked:(BOOL)newLocked;

- (BOOL) changeable;

@end
