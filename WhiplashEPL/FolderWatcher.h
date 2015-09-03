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
//    NSString *_folderPath;
//    NSArray *_contents;
//    NSArray *_lastContents;
    NSTimer *_timer;
//    NSString *_status;
    

//    
//    NSArray *_validExtensions;
//    
//    PrintManager *_printer;
}


//
//@property (nonatomic, strong) NSString *folderPath;
//@property (nonatomic, strong) NSArray *contents;
//@property (nonatomic, strong) NSArray *lastContents;
@property (nonatomic, strong) NSTimer *timer;
//@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, readonly) NSString *nextToggleState;

//
//@property (nonatomic, strong) NSArray *validExtensions;
//
//@property (nonatomic, strong) PrintManager *printer;


+(FolderWatcher*)sharedInstance;

-(void)start;
-(void)stop;

@end
