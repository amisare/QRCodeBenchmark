//
//  BMFileUtils.h
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/16.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMFileUtils : NSObject

+ (NSString *)resultsOpenCVPath;
+ (NSString *)resultsZBarPath;
+ (NSString *)resultsZXingPath;
+ (NSString *)resultsCIDetectorPath;
+ (NSString *)resultsMLKitPath;
+ (NSString *)resultsCoreMLPath;

+ (NSString *)saveBeachmarkFileWithResultPath:(NSString *)resultPath
                                imageCategory:(NSString *)imageCategory
                            beachmarkFileName:(NSString *)beachmarkFileName
                               beanchmarkData:(NSString *)beanchmarkData;

+ (int)totalImagesCount;
+ (void)enumerateAllImagesUsingBlock:(void (^)(NSString *imagePath,
                                               NSString *imageCategory,
                                               NSString *imageName))block;

@end
