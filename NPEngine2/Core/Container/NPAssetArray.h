#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSPointerArray;

@interface NPAssetArray : NPObject
{
    Class assetClass;
    NSPointerArray * assets;
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
         assetClass:(Class)newAssetClass
                   ;

- (void) dealloc;

- (void) registerAsset:(id <NPPPersistentObject>)asset;
- (void) unregisterAsset:(id <NPPPersistentObject>)asset;

- (id <NPPObject>) getAssetWithName:(NSString *)assetName;
- (id <NPPPersistentObject>) getAssetWithFileName:(NSString *)fileName;

@end

