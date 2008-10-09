#import "ODApplication.h"

@implementation ODApplication

- (void)sendEvent:(NSEvent *)anEvent
{
       /*NSEventType type = [anEvent type];
       BOOL handled = NO;

        switch ( type )
        {
            case NSKeyDown:{NSLog(@"Keypressed: %hu %X %@",[anEvent keyCode], [anEvent keyCode], [anEvent characters]); handled = YES; break;}
            case NSFlagsChanged:
            {
                //NSLog(@"Keypressed: %hu",[anEvent keyCode]);
                //if ( [anEvent modifierFlags] & NSShiftKeyMask )
                {
                    NSLog(@"shift %hu %X",[anEvent keyCode],[anEvent keyCode]);
                }
                handled=YES;
                break;
            }
        }*/

       //handle only the keys i need then let the other go through the regular channels
       //this stops the annoying beep
       //if( !handled )
               [super sendEvent:anEvent];
}


@end
