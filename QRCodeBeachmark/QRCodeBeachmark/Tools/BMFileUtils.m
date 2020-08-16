//
//  BMFileUtils.m
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/16.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import "BMFileUtils.h"
#import <NNMacros/NNMacros.h>

@implementation BMFileUtils

+ (NSString *)resultsPath {
    return [NN_pathDocuments stringByAppendingPathComponent:@"results"];
}

+ (NSString *)resultsOpenCVPath {
    return [[self resultsPath] stringByAppendingPathComponent:@"opencv"];
}

+ (NSString *)resultsZBarPath {
    return [[self resultsPath] stringByAppendingPathComponent:@"zbar"];
}

+ (NSString *)resultsZXingPath {
    return [[self resultsPath] stringByAppendingPathComponent:@"zxing"];
}

+ (NSString *)resultsCIDetectorPath {
    return [[self resultsPath] stringByAppendingPathComponent:@"cidetector"];
}

+ (NSString *)resultsMLKitPath {
    return [[self resultsPath] stringByAppendingPathComponent:@"mlkit"];
}

+ (NSString *)resultsCoreMLPath {
    return [[self resultsPath] stringByAppendingPathComponent:@"coreml"];
}

+ (NSString *)saveBeachmarkFileWithResultPath:(NSString *)resultPath
                                imageCategory:(NSString *)imageCategory
                            beachmarkFileName:(NSString *)beachmarkFileName
                               beanchmarkData:(NSString *)beanchmarkData {
    
    NSFileManager *fmgr = [NSFileManager defaultManager];
    NSString *beachmarkFileDir = [resultPath stringByAppendingPathComponent:imageCategory];
    NSString *beachmarkFilePath = [beachmarkFileDir stringByAppendingPathComponent:beachmarkFileName];
    if ([fmgr fileExistsAtPath:beachmarkFilePath]) {
        [fmgr removeItemAtPath:beachmarkFilePath error:nil];
    }
    [fmgr createDirectoryAtPath:beachmarkFileDir withIntermediateDirectories:true attributes:nil error:nil];
    [beanchmarkData writeToFile:beachmarkFilePath atomically:true encoding:NSUTF8StringEncoding error:nil];
    return beachmarkFilePath;
}

+ (NSString *)sourcePath {
    NSString *path = [NSBundle mainBundle].bundlePath;
    path = [path stringByAppendingPathComponent:@"qrcodes"];
    return path;
}

+ (NSString *)detectionSourcePath {
    NSString *path = [[self sourcePath] stringByAppendingPathComponent:@"detection"];
    return path;
}

+ (int)totalImagesCount {
    int count = 0;
    NSFileManager *fmgr = [NSFileManager defaultManager];
    NSString *detectionSourcePath = [self detectionSourcePath];
    NSArray<NSString *> *imageCategories = [fmgr contentsOfDirectoryAtPath:detectionSourcePath error:nil];
    for (NSString *_imageCategory in imageCategories) {
        NSString *imagesPath = [detectionSourcePath stringByAppendingPathComponent:_imageCategory];
        NSArray<NSString*> *imagePaths = [fmgr contentsOfDirectoryAtPath:imagesPath error:nil];
        for (NSString *_imagePath in imagePaths) {
            if ([_imagePath hasSuffix:@".jpg"] || [_imagePath hasSuffix:@".png"]) {
                count++;
            }
        }
    }
    return count;
}

+ (void)enumerateAllImagesUsingBlock:(void (^)(NSString *imagePath, NSString *imageCategory, NSString *imageName))block {
    
    NSFileManager *fmgr = [NSFileManager defaultManager];
    NSString *detectionSourcePath = [self detectionSourcePath];
    NSArray<NSString *> *imageCategories = [fmgr contentsOfDirectoryAtPath:detectionSourcePath error:nil];
    for (NSString *_imageCategory in imageCategories) {
        NSString *imagesPath = [detectionSourcePath stringByAppendingPathComponent:_imageCategory];
        NSArray<NSString*> *imagePaths = [fmgr contentsOfDirectoryAtPath:imagesPath error:nil];
        for (NSString *_imagePath in imagePaths) {
            if ([_imagePath hasSuffix:@".jpg"] || [_imagePath hasSuffix:@".png"]) {
                block([imagesPath stringByAppendingPathComponent:_imagePath], _imageCategory, _imagePath);
            }
        }
    }
}


@end
