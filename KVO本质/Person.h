//
//  Person.h
//  KVO本质
//
//  Created by 刘光强 on 2020/2/3.
//  Copyright © 2020 guangqiang.liu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject{
    @public
    int _age;
}

@property (nonatomic, assign) int age;
@end

NS_ASSUME_NONNULL_END
