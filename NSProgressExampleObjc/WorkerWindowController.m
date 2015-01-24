//
//  WorkerWindowController.m
//  NSProgressExampleObjc
//
//  Created by Jaanus Kase on 24.01.15.
//  Copyright (c) 2015 Jaanus Kase. All rights reserved.
//

#import "WorkerWindowController.h"



@interface WorkerWindowController ()

@property (weak) IBOutlet NSTextField *statusLabel;
@property (strong) IBOutlet NSWindow *progressSheet;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@end



@implementation WorkerWindowController

- (instancetype)init
{
    if (self = [super initWithWindowNibName:@"WorkerWindowController"]) {
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)doWork
{
    self.statusLabel.stringValue = @"Doing something…";

    // Present the indeterminate progress sheet
    [self.window beginSheet:self.progressSheet completionHandler:nil];
    [self.progressIndicator startAnimation:self];
    
    // Run the task
    [self longComputationTask];
}

- (void)longComputationTask
{
    /// One iteration length in seconds
    CGFloat iterationLength = 0.25f;
    
    NSInteger iterationCount = self.taskDuration / iterationLength;
    
    NSProgress *taskProgress = [NSProgress progressWithTotalUnitCount:iterationCount];
    taskProgress.cancellationHandler = ^{
        [self longTaskIsDone:NO];
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < iterationCount; i++) {
            [NSThread sleepForTimeInterval:iterationLength];
            taskProgress.completedUnitCount++;

//            Log some info in the console if you want to be fancy.
//            NSLog(@"worker %@, iteration %ld of %ld", self, (long)i, (long)iterationCount);
        }

        // If we are cancelled when the task is done, we no longer want the handler to be called
        taskProgress.cancellationHandler = nil;
        
        [self longTaskIsDone:YES];
    });
}

- (void)longTaskIsDone:(BOOL)completed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressIndicator stopAnimation:self];
        [self.window endSheet:self.progressSheet];
        if (completed) {
            self.statusLabel.stringValue = @"The answer is 42.";
        } else {
            self.statusLabel.stringValue = @"The task was cancelled.";
        }
    });
}

@end
