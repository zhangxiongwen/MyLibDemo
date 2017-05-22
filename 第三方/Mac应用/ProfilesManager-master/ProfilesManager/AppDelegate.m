//
//  AppDelegate.m
//  ProfilesTool
//
//  Created by Jakey on 15/4/30.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    tool = [[ProfilesManagerViewController alloc] initWithNibName:@"ProfilesManagerViewController" bundle:[NSBundle bundleForClass:[self class]]];
    [self.window.contentView addSubview:tool.view];
    tool.view.frame = self.window.contentView.bounds;
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (!flag)
    {
        [self.window makeKeyAndOrderFront:self];
    }
    return YES;
}

@end
