//
//  ViewController.m
//  NewMingCodeLibrary
//
//  Created by Fanming on 15/12/19.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor redColor];
    _netReachabilityManager = [NetReachabilityManager sharedManager];
    [self.netReachabilityManager beginNetworkConfiguratioin:^(NetworkStatus statue, BOOL success) {
        if (success) {
            NSLog(@"***%@",[[NetReachabilityManager sharedManager].networkConfig currcentHTTPInterface]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
