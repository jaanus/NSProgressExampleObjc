//
//  WindowController.m
//  NSProgressExampleObjc
//
//  Created by Jaanus Kase on 24.01.15.
//  Copyright (c) 2015 Jaanus Kase. All rights reserved.
//

#import "WindowController.h"
#import "WorkerWindowController.h"



@interface WindowController ()

@property (nonatomic, strong) WorkerWindowController *worker1;
@property (nonatomic, strong) WorkerWindowController *worker2;
@property (weak) IBOutlet NSTextField *duration1;
@property (weak) IBOutlet NSTextField *duration2;
@property (strong, nonatomic) NSProgress *progress;
@property (strong) IBOutlet NSWindow *progressSheet;

@end



static void *ProgressObserverContext = &ProgressObserverContext;



@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.worker1 = [[WorkerWindowController alloc] init];
    self.worker2 = [[WorkerWindowController alloc] init];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)doLotsOfWork:(NSButton *)sender {
    
    self.progress = [NSProgress progressWithTotalUnitCount:1];
    
    [self.progress addObserver:self
               forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                  options:NSKeyValueObservingOptionInitial
                  context:ProgressObserverContext];

    /* First, show the worker windows.
     It is important to do this before the progress object becomes current
     because showing the viewcontroller loads its NIB, and NIB loading
     reports progress because it internally calls [NSData dataWithContentsOfURL:]
     */
    
    self.worker1.taskDuration = self.duration1.floatValue;
    [self.worker1 showWindow:self];

    self.worker2.taskDuration = self.duration2.floatValue;
    [self.worker2 showWindow:self];
    
    [self.window beginSheet:self.progressSheet completionHandler:nil];
    [self.progress becomeCurrentWithPendingUnitCount:1];
    
    [self.worker1 doWork];
    [self.worker2 doWork];
    
    [self.progress resignCurrent];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == ProgressObserverContext)
    {
        NSProgress *progress = object;
        
//        NSLog(@"fraction completed: %f", progress.fractionCompleted);
        
        if (progress.fractionCompleted == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [progress removeObserver:self
                              forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                                 context:ProgressObserverContext];
                [self.window endSheet:self.progressSheet];
            });
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}

@end
