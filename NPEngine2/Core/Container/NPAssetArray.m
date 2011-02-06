#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/File/NPLocalPathManager.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "NSPointerArray+NPEngine.h"
#import "NSPointerArray+NPPObject.h"
#import "NSPointerArray+NPPPersistentObject.h"
#import "NPAssetArray.h"

@implementation NPAssetArray

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
         assetClass:(Class)newAssetClass
{
    self = [ super initWithName:newName parent:newParent ];

    assetClass = newAssetClass;

    BOOL conformstoNPPObject
        = [ assetClass conformsToProtocol:@protocol(NPPObject) ];

    BOOL conformsToNPPPersistentObject
        = [ assetClass conformsToProtocol:@protocol(NPPPersistentObject) ];

    if ( conformstoNPPObject == NO || conformsToNPPPersistentObject == NO)
    {
        //raise exception
        DESTROY(self);
        return nil;
    }

    NSPointerFunctionsOptions options
        = NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality;
    assets = [[ NSPointerArray alloc ] initWithOptions:options ];

    return self;
}

- (void) dealloc
{
    DESTROY(assets);
    [ super dealloc ];
}

- (void) registerAsset:(id <NPPPersistentObject>)asset
{
    NSAssert(asset != nil, @"Invalid asset");

    [ assets addPointer:asset ];
}

- (void) unregisterAsset:(id <NPPPersistentObject>)asset
{
    [ assets removePointerIdenticalTo:asset ];
}

- (id <NPPObject>) getAssetWithName:(NSString *)assetName
{
    if ( assetName == nil )
    {
        return nil;
    }

    return [ assets pointerWithName:assetName ];
}

- (id <NPPPersistentObject>) getAssetWithFileName:(NSString *)fileName
{
    NSString * absoluteFileName
        = [[[ NPEngineCore instance ] 
                localPathManager ] getAbsolutePath:fileName ];

    if ( absoluteFileName == nil )
    {
        NPLOG_ERROR([ NSError fileNotFoundError:fileName ]);
        return nil;
    }

    id <NPPPersistentObject> asset = [ assets pointerWithFileName:fileName ];
    if ( asset != nil )
    {
        return asset;
    }

    asset = [[ assetClass alloc ] init ];

    NSError * error = nil;
    if ( [ asset loadFromFile:absoluteFileName error:&error ] == NO )
    {
        NPLOG_ERROR(error);
        DESTROY(asset);
        return nil;
    }

    return AUTORELEASE(asset);
}

@end

