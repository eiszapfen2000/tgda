#import "Core/NPObject/NPObject.h"
#import "Core/Utilities/NPParser.h"

@class NPSUXMaterialInstance;

@interface NPSUXMaterialInstanceCompiler : NPParser
{
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) compileInformationFromScript:(NPStringList *)script
              intoSUXMaterialInstance:(NPSUXMaterialInstance *)materialInstance
                                     ;

@end
