#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;

@interface NPAssetArray : NPObject
{
    Class assetClass;
    NSMutableArray * assets;
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
         assetClass:(Class)newAssetClass
                   ;

- (void) dealloc;

- (id <NPPPersistentObject>) getAssetWithName:(NSString *)assetName;
- (id <NPPPersistentObject>) getAssetWithFileName:(NSString *)fileName;

@end

