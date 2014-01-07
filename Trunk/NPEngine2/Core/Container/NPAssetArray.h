#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSPointerArray;
@class NSDictionary;

@interface NPAssetArray : NPObject
{
    Class assetClass;
    NSPointerArray * assets;
}

- (id) initWithName:(NSString *)newName
         assetClass:(Class)newAssetClass
                   ;

- (void) dealloc;

- (void) registerAsset:(id <NPPPersistentObject>)asset;
- (void) unregisterAsset:(id <NPPPersistentObject>)asset;

- (id <NPPObject>) getAssetWithName:(NSString *)assetName;
- (id <NPPPersistentObject>) getAssetWithFileName:(NSString *)fileName;
- (id <NPPPersistentObject>) getAssetWithFileName:(NSString *)fileName
                                        arguments:(NSDictionary *)arguments;

@end

