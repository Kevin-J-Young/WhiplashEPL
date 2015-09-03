//
//  FolderWatcher.h
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import <Foundation/Foundation.h>
//@class PrintManager;

@interface FolderWatcher : NSObject {
    NSTimer *_timer;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, readonly) NSString *nextToggleState;


+(FolderWatcher*)sharedInstance;

-(void)start;
-(void)stop;

@end
