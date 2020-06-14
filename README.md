# 03-KVO本质

**什么是KVO？**

> KVO:`Key-Value Observing`，用来监听类的某个对象的某个属性的值发生变化，简称键值观察

我们先来看下KVO的基本用法：

```
// 创建一个Person类
@interface Person : NSObject

@property (nonatomic, assign) int age;
@end


@implementation Person

- (void)setAge:(int)age {
    _age = age;
    NSLog(@"setAge:");
}

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
    NSLog(@"willChangeValueForKey:");
}

- (void)didChangeValueForKey:(NSString *)key {
    NSLog(@"didChangeValueForKey:begin");
    [super didChangeValueForKey:key];
    NSLog(@"didChangeValueForKey:end");
}
@end


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
    self.person1.age = 10;
    self.person2.age = 11;
    
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
    [self.person1 setAge:20];
    [self.person2 setAge:22];
}

- (void)dealloc {
    [self.person1 removeObserver:self forKeyPath:@"age"];
}
@end
```

我们创建了一个`Person`类，并且给`Person`类添加了一个`Int age`属性，注意：我们在控制器`ViewController`中监听了`preson1`实例对象的`age`属性值的变化，并没有监听`person2`实例对象的age属性值的变化

接下来我们打印下`person1`和`person2`实例对象的isa指针，打印结果如下：

```
(lldb) p self.person1->isa
(Class) $0 = NSKVONotifying_Person
(lldb) p self.person2->isa
(Class) $1 = Person
```

这时我们就发现，`person1`实例对象添加了`age`属性的监听，其isa指向`NSKVONotifying_Person`，`person2`实例对象没有添加`age`属性监听，其isa指向`Person`

我们从上篇章节中知道一个结论：`实例对象的isa指向的是类对象`

也就是说`person1`实例对象的类对象是`NSKVONotifying_Person`，`person2`实例对象的类对象是`Person`

> NSKVONotifying_Person
>> 这个类是runtime运行时动态为我们创建的一个全新的类，它是`Person`类的子类

*实例对象未使用KVO监听的内存结构图如下：*

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200204-103950@2x.png)


*实例对象使用了KVO监听的内存结构图如下：*

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200204-104108@2x.png)

我们创建一个`NSKVONotifying_Person`类的伪代码如下：

```
@interface NSKVONotifying_Person : NSObject

@end

@implementation NSKVONotifying_Person

// 重新setAge：函数
- (void)setAge:(int)age {
	// 这`setAge:`方法中调用了`_NSSetIntValueAndNotify()`这个C语言函数
    _NSSetIntValueAndNotify();
}

// _NSSetIntValueAndNotify() 函数的伪代码实现
void _NSSetIntValueAndNotify() {

	 // 1. 调用willChangeValueForKey:
    [self willChangeValueForKey:@"age"];
    
    // 2.调用父类的`setAge:`函数
    [super setAge:age];
    
    // 3. 调用didChangeValueForKey:
    [self didChangeValueForKey:@"age"];
}

// didChangeValueForKey: 函数的伪代码实现
- (void)didChangeValueForKey:(NSString *)key {
    // 调用监听器的监听方法，通知监听器某一个对象的属性值发生了改变
    [observer observeValueForKeyPath:key ofObject:self change:nil context:nil];
}

// 实现`class`方法，用来屏蔽内部实现，苹果不希望开发者知道`NSKVONotifying_Person`这个类的存在
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
```

通过`NSKVONotifying_Person`类中的伪代码实现，我们可以知道KVO底层的实现逻辑

我们都知道当我们设置了一个对象属性的KVO，当这个属性的值发生变化，就会自动触发KVO监听，那么我们如何实现手动来触发一个KVO？

手动触发一个对象的KVO很简单，我们只需要调用下面两个方法即可：

```
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.person1.age = 20;
//    self.person2.age = 22;
//    [self.person1 setAge:20];
//    [self.person2 setAge:22];
    
    // 手动触发KVO
    [self.person1 willChangeValueForKey:@"age"];
    [self.person1 didChangeValueForKey:@"age"];
}
```

那么修改成员变量的值会触发KVO吗？，怎么实现修改成员变量的值也能触发KVO？

直接修改成员变量的值是不能触发KVO的，因为成员变量没有对应的`set:`方法，KVO的本质就是重写属性的`set:`方法

要想实现修改成员变量的值，也能触发KVO，我们可以使用手动触发KVO如下：

```
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.person1.age = 20;
//    self.person2.age = 22;
//    [self.person1 setAge:20];
//    [self.person2 setAge:22];
    
    [self.person1 willChangeValueForKey:@"age"];
    self.person1 -> _age = 33;
    [self.person1 didChangeValueForKey:@"age"];
}
```

## 更多文章
* ReactNative开源项目OneM(1200+star)：**[https://github.com/guangqiang-liu/OneM](https://github.com/guangqiang-liu/OneM)**：欢迎小伙伴们 **star**
* 简书主页：包含多篇iOS和RN开发相关的技术文章[http://www.jianshu.com/u/023338566ca5](http://www.jianshu.com/u/023338566ca5) 欢迎小伙伴们：**多多关注，点赞**
* ReactNative QQ技术交流群(2000人)：**620792950** 欢迎小伙伴进群交流学习
* iOS QQ技术交流群：**678441305** 欢迎小伙伴进群交流学习