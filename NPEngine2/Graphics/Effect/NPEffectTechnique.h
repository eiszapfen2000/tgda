#import "Core/NPObject/NPObject.h"

@class NPShader;

@interface NPEffectTechnique : NPObject
{
    NPShader * vertexShader;
    NPShader * fragmentShader;

    NSMutableArray * techniqueVariables;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
                   ;
- (void) dealloc;

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
                           ;

@end

