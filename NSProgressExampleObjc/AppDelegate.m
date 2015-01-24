//
//  AppDelegate.m
//  NSProgressExampleObjc
//
//  Created by Jaanus Kase on 24.01.15.
//  Copyright (c) 2015 Jaanus Kase. All rights reserved.
//

#import "AppDelegate.h"
#import "WindowController.h"



@interface AppDelegate ()

@property (strong, nonatomic) WindowController *windowController;

@end



@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.windowController = [[WindowController alloc] initWithWindowNibName:@"WindowController"];
    [self.windowController showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    [self.windowController showWindow:self];
    return NO;
}

@end
