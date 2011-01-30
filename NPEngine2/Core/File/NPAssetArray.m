#import <Foundation/NSArray.h>
#import "Log/NPLog.h"
#import "Core/NPEngineCore.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "NPLocalPathManager.h"
#import "NPAssetArray.h"

/*
@interface NSPointerArray (NPEngine)

- (BOOL) containsPointer:(void *)pointer;
- (NSUInteger) indexOfPointerIdenticalTo:(void *)pointer;

@end

@implementation NSPointerArray (NPEngine)

- (BOOL) containsPointer:(void *)pointer
{
    NSUInteger numberOfPointers = [ self count ];
    for ( NSUInteger i = 0; i < numberOfPointers; i++ )
    {
        if ( [ self pointerAtIndex:i ] == pointer )
        {
            return YES;
        }
    }

    return NO;
}

- (NSUInteger) indexOfPointerIdenticalTo:(void *)pointer
{
    NSUInteger numberOfPointers = [ self count ];
    for ( NSUInteger i = 0; i < numberOfPointers; i++ )
    {
        if ( [ self pointerAtIndex:i ] == pointer )
        {
            return i;
        }
    }

    return NSNotFound;
}

@end
*/

@implementation NPAssetArray

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
         assetClass:(Class)newAssetClass
{
    self = [ super initWithName:newName parent:newParent ];

    assetClass = newAssetClass;
    assets = [[ NSMutableArray alloc ] init ];

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

    return self;
}

- (void) dealloc
{
    DESTROY(assets);
    [ super dealloc ];
}

- (id <NPPPersistentObject>) getAssetWithName:(NSString *)assetName
{
    if ( assetName == nil )
    {
        return nil;
    }

    NSUInteger numberOfAssets = [ assets count ];

    for ( NSUInteger i = 0; i < numberOfAssets; i++ )
    {
        id <NPPPersistentObject> o = [ assets objectAtIndex:i ];
        if ( [[ o name ] isEqual:assetName ] == YES )
        {
            return o;
        }
    }
    
    return nil;
}

- (id <NPPPersistentObject>) getAssetWithFileName:(NSString *)fileName
{
    if ( fileName == nil )
    {
        return nil;
    }

    NSString * absoluteFileName
        = [[[ NPEngineCore instance ] 
                localPathManager ] getAbsolutePath:fileName ];

    if ( absoluteFileName == nil )
    {
        NPLOG_ERROR([ NSError fileNotFoundError:fileName ]);
        return nil;
    }

    NSUInteger numberOfAssets = [ assets count ];
    for ( NSUInteger i = 0; i < numberOfAssets; i++ )
    {
        id <NPPPersistentObject> o = [ assets objectAtIndex:i ];
        if ( [[ o fileName ] isEqual:absoluteFileName ] == YES )
        {
            return o;
        }
    }

    id <NPPPersistentObject> asset = [[ assetClass alloc ] init ];

    NSError * error = nil;
    if ( [ asset loadFromFile:absoluteFileName error:&error ] == NO )
    {
        NPLOG_ERROR(error);
        DESTROY(asset);
        return nil;
    }

    [ assets addObject:asset ];

    return AUTORELEASE(asset);
}

- (void) releaseAsset:(id <NPPPersistentObject>)asset
{
    NSUInteger index = [ assets indexOfObjectIdenticalTo:asset ];

    if ( index != NSNotFound )
    {
        RELEASE(asset);

        // if the retain counter is at 1, then we
        // are the only ones left owning the asset,
        // so we can release it
        if ( [ asset retainCount ] == 1 )
        {
            [ assets removeObjectAtIndex:index ];
        }
    }   
}

@end

