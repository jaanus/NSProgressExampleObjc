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
}

- (IBAction)doLotsOfWork:(NSButton *)sender {
    
    self.progress = [NSProgress progressWithTotalUnitCount:1];
    __weak WindowController *weakSelf = self;
    self.progress.cancellationHandler = ^{
        [weakSelf teardownProgressUi];
    };
    
    [self.progress addObserver:self
               forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                  options:NSKeyValueObservingOptionInitial
                  context:ProgressObserverContext];

    /* First, show the worker windows.
     It is important to show the windows before the progress object becomes current
     because showing the viewcontroller loads its NIB, and NIB loading
     reports progress because it internally calls [NSData dataWithContentsOfURL:]
     */
    
    self.worker1.taskDuration = self.duration1.floatValue;
    [self.worker1 showWindow:self];

    self.worker2.taskDuration = self.duration2.floatValue;
    [self.worker2 showWindow:self];
    
    /* Now that the UI is set up and we hope nothing else would run that would report unwanted progress,
     can finally become current ourselves and show the sheet. */
    
    [self.window beginSheet:self.progressSheet completionHandler:nil];
    [self.progress becomeCurrentWithPendingUnitCount:1];
    
    [self.worker1 doWork];
    [self.worker2 doWork];
    
    [self.progress resignCurrent];
}

- (IBAction)cancel:(id)sender {
    [self.progress cancel];
}



#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == ProgressObserverContext)
    {
        NSProgress *progress = object;
        
//        NSLog(@"fraction completed: %f", progress.fractionCompleted);
        
        if (progress.fractionCompleted == 1) {
            [self teardownProgressUi];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}



#pragma mark - Utilities

- (void)teardownProgressUi
{
    // Don’t really know which queue is calling us. Progress cancellation, KVO, …
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progress removeObserver:self
                      forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                         context:ProgressObserverContext];
        [self.window endSheet:self.progressSheet];
    });
}

@end
