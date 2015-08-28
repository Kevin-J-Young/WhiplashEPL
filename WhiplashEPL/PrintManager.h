//
//  PrintManager.h
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrintManager : NSObject

@property (nonatomic, strong) NSString *currentPrinterName;
//@property (nonatomic, strong) NSString *printerName;

-(NSArray*)printersAvailable;

-(void)shellPrint:(NSString*)fullPath;

@end
