//
//  ViewController.m
//  KVO本质
//
//  Created by 刘光强 on 2020/2/3.
//  Copyright © 2020 guangqiang.liu. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@property (nonatomic, strong) Person *person1;
@property (nonatomic, strong) Person *person2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.person1 = [[Person alloc] init];
    self.person2 = [[Person alloc] init];
//    self.person1.age = 10;
//    self.person2.age = 11;
    
    [self.person1 addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:@"111"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"keyPath = %@ object = %@ change = %@ context = %@",keyPath, object, change, context);
    /**
     keyPath = age object = <Person: 0x600001ec4810> change = {
         kind = 1;
         new = 20;
         old = 10;
     } context = 111
     */
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.person1.age = 20;
//    self.person2.age = 22;
//    [self.person1 setAge:20];
//    [self.person2 setAge:22];
    
    [self.person1 willChangeValueForKey:@"age"];
    self.person1 -> _age = 33;
    [self.person1 didChangeValueForKey:@"age"];
}

- (void)dealloc {
    [self.person1 removeObserver:self forKeyPath:@"age"];
}
@end
