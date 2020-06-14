//
//  NSKVONotifying_Person.m
//  KVO本质
//
//  Created by 刘光强 on 2020/2/4.
//  Copyright © 2020 guangqiang.liu. All rights reserved.
//

#import "NSKVONotifying_Person.h"

@implementation NSKVONotifying_Person

- (void)setAge:(int)age {
    _NSSetIntValueAndNotify();
}

void _NSSetIntValueAndNotify() {
    [self willChangeValueForKey:@"age"];
    
    // 调用父类的`setAge:`函数
    [super setAge:age];
    [self didChangeValueForKey:@"age"];
}

- (void)didChangeValueForKey:(NSString *)key {
    // 调用监听器的监听方法，某一个对象的属性值发生了改变
    [observer observeValueForKeyPath:key ofObject:self change:nil context:nil];
}

// 实现`class`方法，用来屏幕内部实现，苹果不希望开发者知道`NSKVONotifying_Person`这个类的存在
- (Class)class {
    return self;
}

- dealloc {
    // 收尾工作
}

- (BOOL)_isKVOA {
    return YES;
}
@end
