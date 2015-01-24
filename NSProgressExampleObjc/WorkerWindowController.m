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
@property (strong, nonatomic) NSProgress *taskProgress;

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
    // Set up the UI: update status text and present the sheet.
    self.statusLabel.stringValue = @"Doing something…";
    [self.window beginSheet:self.progressSheet completionHandler:nil];
    
    // Run the task
    [self longComputationTask];
}

- (void)longComputationTask
{
    /// One iteration length in seconds. Smaller lengths seem to be more crashy.
    CGFloat iterationLength = 0.05f;
    
    NSInteger iterationCount = self.taskDuration / iterationLength;
    
    // Set up the progress reporter. There may or may not be any upstream progress objects,
    // we don’t need to care here.
    self.taskProgress = [NSProgress progressWithTotalUnitCount:iterationCount];

    // If the upstream signals cancellation, this handler is called.
    __weak typeof(self) weakSelf = self;
    self.taskProgress.cancellationHandler = ^{
        [weakSelf longComputationTaskIsDone:NO];
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < iterationCount; i++) {

            // If we happened to be cancelled from upstream, don’t do any more work,
            // break out of the block.
            if (self.taskProgress.cancelled) { return; }

            // Simulate hard work and increment the count when one unit is done.
            [NSThread sleepForTimeInterval:iterationLength];
            self.taskProgress.completedUnitCount++;

            // If you want, uncomment this to log each iteration tn the console.
            // NSLog(@"worker %@, iteration %ld of %ld", self, (long)i, (long)iterationCount);
        }

        // If we are cancelled after the task is done, we’ll ignore the cancellation
        self.taskProgress.cancellationHandler = nil;
        
        // After we’re done, signal our completion handler.
        [self longComputationTaskIsDone:YES];
    });
}

/// Completion handler. Pass NO if this was a cancellation and YES if computation completed successfully.
- (void)longComputationTaskIsDone:(BOOL)completed
{
    // Don’t know which queue called us, so schedule back to main just in case.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // No matter if we were cancelled or ended naturally,
        // we should tear down the sheet UI.
        [self.window endSheet:self.progressSheet];
        
        // Set message based on whether we completed or were cancelled.
        if (completed) {
            self.statusLabel.stringValue = @"The answer is 42.";
        } else {
            self.statusLabel.stringValue = @"The task was cancelled.";
        }
    });
}

@end
