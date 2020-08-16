//
//  BMCoreML.m
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/16.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import "BMCoreML.h"
#import <UIKit/UIKit.h>
#import "BMFileUtils.h"
#import <Vision/Vision.h>
#import "UIImage+scale.h"

@implementation BMCoreML

- (void)benchmark:(void (^)(int total, int count, NSString *imagePath, NSString *beachmarkPath))block {
    
    int total = [BMFileUtils totalImagesCount];
    __block int count = 0;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [BMFileUtils enumerateAllImagesUsingBlock:^(NSString *imagePath, NSString *imageCategory, NSString *imageName) {
        
        @autoreleasepool {
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
            VNDetectBarcodesRequest *request = [[VNDetectBarcodesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                
                NSTimeInterval tock = [[NSDate date] timeIntervalSince1970];
                
                NSMutableArray *beachmark = [NSMutableArray new];
                [beachmark addObject:[@"# CoreML " stringByAppendingString:imageName]];
                [beachmark addObject:[@"milliseconds = " stringByAppendingString:@(tock - tick).stringValue]];
                
                if (error == nil && [request.results count]) {
                    for (VNBarcodeObservation * result in request.results) {
                        if ([result symbology] == VNBarcodeSymbologyQR) {
                            NSString *message = [@"message = " stringByAppendingString:[result payloadStringValue]];
                            message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                            [beachmark addObject:message];

                            NSMutableArray *bboxArray = [NSMutableArray new];
                            [bboxArray addObject:@(result.topLeft.x)];
                            [bboxArray addObject:@(result.topLeft.y)];
                            [bboxArray addObject:@(result.topRight.x)];
                            [bboxArray addObject:@(result.topRight.y)];
                            [bboxArray addObject:@(result.bottomRight.x)];
                            [bboxArray addObject:@(result.bottomRight.y)];
                            [bboxArray addObject:@(result.bottomLeft.x)];
                            [bboxArray addObject:@(result.bottomLeft.y)];
                            
                            NSString *bboxString = [bboxArray componentsJoinedByString:@" "];
                            [beachmark addObject:bboxString];
                        }
                    }
                }
                
                NSString *beachmarkString = [beachmark componentsJoinedByString:@"\n"];
                NSString *beachmarkFileName = [[imageName componentsSeparatedByString:@"."][0] stringByAppendingString:@".txt"];
                NSString *beachmarkFilePath = [BMFileUtils saveBeachmarkFileWithResultPath:[BMFileUtils resultsCoreMLPath] imageCategory:imageCategory beachmarkFileName:beachmarkFileName beanchmarkData:beachmarkString];
                
                count += 1;
                block(total, count, imagePath, beachmarkFilePath);
                
                dispatch_semaphore_signal(sema);
            }];
            
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
            [handler performRequests:@[request] error:nil];
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
    }];
}

@end
