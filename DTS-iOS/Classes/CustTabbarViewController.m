//
//  CustTabbarViewController.m
//  101Compaign-iOS
//
//  Created by Viktor on 14/05/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

#import "CustTabbarViewController.h"
#import "SWRevealViewController.h"

@interface CustTabbarViewController ()



@end

@implementation CustTabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.selectedIndex = self.newSelectedIndex;
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.newSelectedIndex > 0) {
        self.selectedIndex = self.newSelectedIndex;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == 0) {
        SWRevealViewController *firstController = [self.viewControllers objectAtIndex:0];
        UINavigationController *frontController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mainChildNav"];
        firstController.frontViewController = frontController;
        [firstController setFrontViewPosition:FrontViewPositionRight animated:YES];
        //firstController.setFrontViewPosition(.Right, animated: true)
    }
    else if (item.tag == 1) {
        //
        SWRevealViewController *firstController = [self.viewControllers objectAtIndex:1];
        UINavigationController *frontController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"nav3VC"];
        firstController.frontViewController = frontController;
        [firstController setFrontViewPosition:FrontViewPositionRight animated:YES];
    }
    else if (item.tag == 2) {
        //nav3VC
        SWRevealViewController *firstController = [self.viewControllers objectAtIndex:2];
        UINavigationController *frontController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"navMessageVC"];
        firstController.frontViewController = frontController;
        [firstController setFrontViewPosition:FrontViewPositionRight animated:YES];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
