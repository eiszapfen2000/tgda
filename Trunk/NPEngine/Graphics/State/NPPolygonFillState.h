#import "NPState.h"

@interface NPPolygonFillState : NPState
{
    NpState frontFaceFill;
    NpState defaultFrontFaceFill;
    NpState currentFrontFaceFill;

    NpState backFaceFill;
    NpState defaultBackFaceFill;
    NpState currentBackFaceFill;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent configuration:(NPStateConfiguration *)newConfiguration;
- (void) dealloc;

- (NpState) frontFaceFill;
- (void)    setFrontFaceFill:(NpState)newFrontFaceFill;

- (NpState) defaultFrontFaceFill;
- (void)    setDefaultFrontFaceFill:(NpState)newDefaultFrontFaceFill;

- (NpState) backFaceFill;
- (void)    setBackFaceFill:(NpState)newBackFaceFill;

- (NpState) defaultBackFaceFill;
- (void)    setDefaultBackFaceFill:(NpState)newDefaultBackFaceFill;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
