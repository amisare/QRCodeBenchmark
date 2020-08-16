//
//  ViewController.m
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/16.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import "ViewController.h"
#import "BMFileUtils.h"
#import "BMOpenCV.h"
#import "BMZBar.h"
#import "BMZXing.h"
#import "BMCIDetector.h"
#import "BMMLKit.h"
#import "BMCoreML.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *OpenCVCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *ZBarCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *ZXingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *CIDetectorCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *MLKitCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *CoreMLCountLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
}

- (void)start {
    self.startButton.enabled = false;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[BMOpenCV new] benchmark:^(int total, int count, NSString *imagePath, NSString *beachmarkPath) {
            NSLog(@"%@", imagePath);
            NSLog(@"%@", beachmarkPath);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.OpenCVCountLabel.text = [NSString stringWithFormat:@"%d/%d", count, total];
            });
        }];

        [[BMZBar new] benchmark:^(int total, int count, NSString *imagePath, NSString *beachmarkPath) {
            NSLog(@"%@", imagePath);
            NSLog(@"%@", beachmarkPath);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.ZBarCountLabel.text = [NSString stringWithFormat:@"%d/%d", count, total];
            });
        }];

        [[BMZXing new] benchmark:^(int total, int count, NSString *imagePath, NSString *beachmarkPath) {
            NSLog(@"%@", imagePath);
            NSLog(@"%@", beachmarkPath);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.ZXingCountLabel.text = [NSString stringWithFormat:@"%d/%d", count, total];
            });
        }];

        [[BMCIDetector new] benchmark:^(int total, int count, NSString *imagePath, NSString *beachmarkPath) {
            NSLog(@"%@", imagePath);
            NSLog(@"%@", beachmarkPath);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.CIDetectorCountLabel.text = [NSString stringWithFormat:@"%d/%d", count, total];
            });
        }];

        [[BMMLKit new] benchmark:^(int total, int count, NSString *imagePath, NSString *beachmarkPath) {
            NSLog(@"%@", imagePath);
            NSLog(@"%@", beachmarkPath);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.MLKitCountLabel.text = [NSString stringWithFormat:@"%d/%d", count, total];
            });
        }];

        [[BMCoreML new] benchmark:^(int total, int count, NSString *imagePath, NSString *beachmarkPath) {
            NSLog(@"%@", imagePath);
            NSLog(@"%@", beachmarkPath);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.CoreMLCountLabel.text = [NSString stringWithFormat:@"%d/%d", count, total];
            });
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.startButton.enabled = true;
        });
    });
}

@end
