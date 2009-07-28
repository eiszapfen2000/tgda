#import "NP.h"
#import "ODScene.h"
#import "ODSceneManager.h"
#import "ODOceanEntity.h"
#import "ODOceanTile.h"
#import "ODOceanAnimatedTile.h"
#import "ODCore.h"

@implementation ODOceanEntity

- (id) init
{
    return [ self initWithName:@"ODOceanEntity" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    staticTiles = [[ NSMutableArray alloc ] init ];
    animatedTiles = [[ NSMutableArray alloc ] init ];

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"ocean.cgfx" ];
    projectorIMVP = [ effect parameterWithName:@"projectorIMVP" ];
    NSAssert(projectorIMVP != NULL, @"Parameter \"projectorIMVP\" not found");

    renderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTC" parent:self ];

    id tempRenderTexture = [ NPRenderTexture renderTextureWithName:@"RT"
                                                              type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                             width:256
                                                            height:256
                                                        dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                       pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                     textureFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                       textureWrap:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    [ renderTargetConfiguration setColorRenderTarget:tempRenderTexture atIndex:0 ];

    r2vbConfiguration = [[ NPR2VBConfiguration alloc ] initWithName:@"R2VB" parent:self ];

    return self;
}

- (void) dealloc
{
    [ staticTiles removeAllObjects ];
    [ staticTiles release ];

    [ animatedTiles removeAllObjects ];
    [ animatedTiles release ];

    [ r2vbConfiguration release ];

    [ renderTargetConfiguration clear ];
    [ renderTargetConfiguration release ];

    TEST_RELEASE(nearPlaneGrid);
    TEST_RELEASE(projectedGrid);

    [ super dealloc ];
}

- (id) renderTexture
{
    return [ renderTargetConfiguration renderTextureAtIndex:0 ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
{
    NSString * entityName = [ config objectForKey:@"Name" ];
    NSArray  * dataSetFiles = [ config objectForKey:@"DataSets" ];

    if ( entityName == nil || dataSetFiles == nil )
    {
        NPLOG_ERROR(@"Scene config is incomplete");
        return NO;
    }

    [ self setName:entityName ];

    NSEnumerator * dataSetFilesEnumerator = [ dataSetFiles objectEnumerator ];
    id dataSetFileName;

    while ( (dataSetFileName = [ dataSetFilesEnumerator nextObject ]) )
    {
        NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:dataSetFileName ];

        if ( [ absolutePath isEqual:@"" ] == NO )
        {
            NPFile * file = [[ NPFile alloc ] initWithName:absolutePath parent:self fileName:absolutePath ];

            NSString * header = [ file readSUXString ];
            if ( [ header isEqual:@"OceanSurface" ] == YES )
            {
                BOOL animated;
                [ file readBool:&animated ];

                if ( animated == NO )
                {
                    ODOceanTile * staticTile = [[ ODOceanTile alloc ] initWithName:absolutePath ];
                    BOOL result = [ staticTile loadFromFile:file ];

                    if ( result == YES )
                    {
                        [ staticTiles addObject:staticTile ];
                    }

                    [ staticTile release ];
                }
                else
                {
                    ODOceanAnimatedTile * animatedTile = [[ ODOceanAnimatedTile alloc ] initWithName:absolutePath ];
                    BOOL result = [ animatedTile loadFromFile:file ];

                    if ( result == YES )
                    {
                        [ animatedTiles addObject:animatedTile ];
                    }

                    [ animatedTile release ];
                }
            }

            [ file release ];
        }
    }

    return YES;
}

- (void) update:(Float)frameTime
{

}

- (void) render
{

}

@end
