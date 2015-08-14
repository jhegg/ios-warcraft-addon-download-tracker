//
//  SettingsViewController.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 8/10/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)keyboardDone:(id)sender;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _urlTextField.text = _url.absoluteString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender != self.saveButton) return;
    
    if (self.urlTextField.text.length > 0) {
        self.url = [NSURL URLWithString:self.urlTextField.text];
    }
}

- (IBAction)keyboardDone:(id)sender {
    [self.urlTextField becomeFirstResponder];
    [self.urlTextField resignFirstResponder];
}

@end
