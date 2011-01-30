#import "Core/File/NPAssetArray.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPShader.h"
#import "NPEffectTechnique.h"

@implementation NPEffectTechnique

- (id) init
{
    return [ self initWithName:@"Technique" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    vertexShader = fragmentShader = nil;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) addVertexShaderFromFile:(NSString *)fileName
{
    if ( vertexShader != nil )
    {
        [[[ NPEngineGraphics instance ] shader ] releaseAsset:vertexShader ];
        vertexShader = nil;
    }

    vertexShader
        = [[[ NPEngineGraphics instance ] shader ] getAssetWithFileName:fileName ];
}

- (void) addFragmentShaderFromFile:(NSString *)fileName
{
    if ( fragmentShader != nil )
    {
        [[[ NPEngineGraphics instance ] shader ] releaseAsset:fragmentShader ];
        fragmentShader = nil;
    }

    fragmentShader 
        = [[[ NPEngineGraphics instance ] shader ] getAssetWithFileName:fileName ];
}


@end

