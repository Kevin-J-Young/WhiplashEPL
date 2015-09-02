//
//  PrintManager.h
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrintManager : NSObject {
    NSString *_currentPrinterName;
}

@property (nonatomic, strong) NSString *currentPrinterName;

-(NSArray*)printersAvailable;
-(void)shellPrint:(NSString*)fullPath;

@end
