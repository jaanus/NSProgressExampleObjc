//
//  WorkerWindowController.h
//  NSProgressExampleObjc
//
//  Created by Jaanus Kase on 24.01.15.
//  Copyright (c) 2015 Jaanus Kase. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WorkerWindowController : NSWindowController

/// Duration of the computation task.
@property (assign, nonatomic) CGFloat taskDuration;

/// Do a long-running operation.
- (void)doWork;

@end
