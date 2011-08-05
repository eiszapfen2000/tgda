#import "Core/Math/FMatrix.h"
#import "Core/NPObject/NPObject.h"

@interface NPOrthographic : NPObject
{
    FMatrix4 modelBefore;
    FMatrix4 viewBefore;
    FMatrix4 projectionBefore;
}

+ (float) top;
+ (float) bottom;
+ (float) left;
+ (float) right;
+ (FVector2) topCenter;
+ (FVector2) bottomCenter;
+ (FVector2) leftCenter;
+ (FVector2) rightCenter;
+ (FVector2) alignTop:(const FVector2)vector;
+ (FVector2) alignBottom:(const FVector2)vector;
+ (FVector2) alignLeft:(const FVector2)vector;
+ (FVector2) alignRight:(const FVector2)vector;
+ (FVector2) alignTopLeft:(const FVector2)vector;
+ (FVector2) alignTopRight:(const FVector2)vector;
+ (FVector2) alignBottomLeft:(const FVector2)vector;
+ (FVector2) alignBottomRight:(const FVector2)vector;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) activate;
- (void) deactivate;

@end

/*
class ZTOPENGLAPI ZtOrthographic : ZtNamedObject
{
public:
	COUNTED(ZtOrthographic);

	ZtOrthographic();

	static float Top();
	static float Bottom();
	static float Left();
	static float Right();
	static ZtFVector2 TopCenter();
	static ZtFVector2 BottomCenter();
	static ZtFVector2 LeftCenter();
	static ZtFVector2 RightCenter();
	static ZtFVector2 AlignTop(const ZtFVector2& Vector);
	static ZtFVector2 AlignBottom(const ZtFVector2& Vector);
	static ZtFVector2 AlignLeft(const ZtFVector2& Vector);
	static ZtFVector2 AlignRight(const ZtFVector2& Vector);
	static ZtFVector2 AlignTopLeft(const ZtFVector2& Vector);
	static ZtFVector2 AlignTopRight(const ZtFVector2& Vector);
	static ZtFVector2 AlignBottomLeft(const ZtFVector2& Vector);
	static ZtFVector2 AlignBottomRight(const ZtFVector2& Vector);
	static ZtFVector2 AlignTopCenter(const ZtFVector2& Vector);
	static ZtFVector2 AlignBottomCenter(const ZtFVector2& Vector);
	static ZtFVector2 AlignLeftCenter(const ZtFVector2& Vector);
	static ZtFVector2 AlignRightCenter(const ZtFVector2& Vector);
	static ZtFBoundingRectangle AlignTop(const ZtFBoundingRectangle& Rectangle);
	static ZtFBoundingRectangle AlignBottom(const ZtFBoundingRectangle& Rectangle);	
	static ZtFBoundingRectangle AlignLeft(const ZtFBoundingRectangle& Rectangle);	
	static ZtFBoundingRectangle AlignRight(const ZtFBoundingRectangle& Rectangle);
	static ZtFBoundingRectangle AlignTopLeft(const ZtFBoundingRectangle& Rectangle);
	static ZtFBoundingRectangle AlignTopRight(const ZtFBoundingRectangle& Rectangle);
	static ZtFBoundingRectangle AlignBottomLeft(const ZtFBoundingRectangle& Rectangle);	
	static ZtFBoundingRectangle AlignBottomRight(const ZtFBoundingRectangle& Rectangle);

	void activate();
	void deactivate();

private:
	ZtFMatrix4 ModelBefore_;
	ZtFMatrix4 ViewBefore_;
	ZtFMatrix4 ProjectionBefore_;
};
*/
