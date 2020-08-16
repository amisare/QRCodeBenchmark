//
//  BMZBar.m
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/16.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import "BMZBar.h"
#import <UIKit/UIKit.h>
#import "BMFileUtils.h"
#import <ZBarSDK/ZBarSDK.h>
#import "UIImage+scale.h"

@implementation BMZBar

- (void)benchmark:(void (^)(int total, int count, NSString *imagePath, NSString *beachmarkPath))block {
    
    int total = [BMFileUtils totalImagesCount];
    __block int count = 0;
    [BMFileUtils enumerateAllImagesUsingBlock:^(NSString *imagePath, NSString *imageCategory, NSString *imageName) {
        
        @autoreleasepool {
            ZBarImageScanner *scanner = [ZBarImageScanner new];
            [scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];
            
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            // scale size
            CGFloat cgImageWidth = CGImageGetWidth(image.CGImage);
            CGFloat cgImageHeight = CGImageGetHeight(image.CGImage);
            if (cgImageWidth > 756 || cgImageHeight > 1008) {
                float scale = 1.0;
                if (cgImageWidth > 756) {
                    scale = 756.0 / cgImageWidth;
                }
                else {
                    scale = 1008.0 / cgImageHeight;
                }
                image = [image bm_imageScale:scale];
            }
            
            NSTimeInterval tick = [[NSDate date] timeIntervalSince1970];
            ZBarImage *zbar_image = [[ZBarImage alloc] initWithCGImage:image.CGImage];
            NSInteger result = [scanner scanImage:zbar_image];
            NSTimeInterval tock = [[NSDate date] timeIntervalSince1970];
            
            NSMutableArray *beachmark = [NSMutableArray new];
            [beachmark addObject:[@"# ZBar " stringByAppendingString:imageName]];
            [beachmark addObject:[@"milliseconds = " stringByAppendingString:@(tock - tick).stringValue]];
            
            if (result > 0) {
                for (ZBarSymbol *symbol in scanner.results) {
                    NSString *message = [@"message = " stringByAppendingString:symbol.data];
                    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                    [beachmark addObject:message];
                    NSMutableArray *bboxArray = [NSMutableArray new];
                    for( int i = 0; i < zbar_symbol_get_loc_size(symbol.zbarSymbol); i ++ ) {
                        [bboxArray addObject:@(zbar_symbol_get_loc_x(symbol.zbarSymbol, i)).stringValue];
                        [bboxArray addObject:@(zbar_symbol_get_loc_y(symbol.zbarSymbol, i)).stringValue];
                    }
                    NSString *bboxString = [bboxArray componentsJoinedByString:@" "];
                    [beachmark addObject:bboxString];
                }
            }
            
            NSString *beachmarkString = [beachmark componentsJoinedByString:@"\n"];
            NSString *beachmarkFileName = [[imageName componentsSeparatedByString:@"."][0] stringByAppendingString:@".txt"];
            NSString *beachmarkFilePath = [BMFileUtils saveBeachmarkFileWithResultPath:[BMFileUtils resultsZBarPath] imageCategory:imageCategory beachmarkFileName:beachmarkFileName beanchmarkData:beachmarkString];
            
            count += 1;
            block(total, count, imagePath, beachmarkFilePath);
        }
    }];
}

@end
