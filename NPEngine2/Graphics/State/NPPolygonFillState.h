#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPState.h"

@interface NPPolygonFillState : NPState
{
    NpPolygonFillMode frontFaceFill;
    NpPolygonFillMode defaultFrontFaceFill;
    NpPolygonFillMode currentFrontFaceFill;

    NpPolygonFillMode backFaceFill;
    NpPolygonFillMode defaultBackFaceFill;
    NpPolygonFillMode currentBackFaceFill;
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
      configuration:(NPStateConfiguration *)newConfiguration
                   ;
- (void) dealloc;

- (NpPolygonFillMode) frontFaceFill;
- (NpPolygonFillMode) defaultFrontFaceFill;
- (NpPolygonFillMode) backFaceFill;
- (NpPolygonFillMode) defaultBackFaceFill;

- (void) setFrontFaceFill:(NpPolygonFillMode)newFrontFaceFill;
- (void) setDefaultFrontFaceFill:(NpPolygonFillMode)newDefaultFrontFaceFill;
- (void) setBackFaceFill:(NpPolygonFillMode)newBackFaceFill;
- (void) setDefaultBackFaceFill:(NpPolygonFillMode)newDefaultBackFaceFill;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
