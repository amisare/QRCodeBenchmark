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
            UIImage *imageOrigin = [UIImage imageWithContentsOfFile:imagePath];
            __block UIImage *image = imageOrigin;
            __block CGFloat scale = 1.0;
            // scale size
            [imageOrigin bm_imageScaleWithMaxSize:CGSizeMake(768, 1008) complete:^(UIImage *_image, CGFloat _scale) {
                image = _image;
                scale = _scale;
            }];
            
            ZBarImageScanner *scanner = [ZBarImageScanner new];
            // disable all
            [scanner setSymbology:ZBAR_NONE config:ZBAR_CFG_ENABLE to:0];
            // enable qr
            [scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];
            
            NSTimeInterval tick = [[NSDate date] timeIntervalSince1970];
            ZBarImage *zbar_image = [[ZBarImage alloc] initWithCGImage:image.CGImage];
            NSInteger result = [scanner scanImage:zbar_image];
            NSTimeInterval tock = [[NSDate date] timeIntervalSince1970];
            
            NSMutableArray *beachmark = [NSMutableArray new];
            [beachmark addObject:[@"# ZBar " stringByAppendingString:imageName]];
            [beachmark addObject:[@"milliseconds = " stringByAppendingString:@((tock - tick) * 1000).stringValue]];
            
            if (result > 0) {
                for (ZBarSymbol *result in scanner.results) {
                    // skip incorrect result
                    if (zbar_symbol_get_loc_size(result.zbarSymbol) != 4) {
                        continue;
                    }
                    NSString *message = [@"message = " stringByAppendingString:result.data];
                    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                    [beachmark addObject:message];
                    
                    NSMutableArray *bboxArray = [NSMutableArray new];
                    for( int i = 0; i < zbar_symbol_get_loc_size(result.zbarSymbol); i ++ ) {
                        [bboxArray addObject:@(zbar_symbol_get_loc_x(result.zbarSymbol, i) / scale).stringValue];
                        [bboxArray addObject:@(zbar_symbol_get_loc_y(result.zbarSymbol, i) / scale).stringValue];
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
