# realmDemoJK

a demo for realm use

[TOC]


**本篇内容全部出于 [Realm英文文档](#https://realm.io/docs/objc/latest/) 与  [Realm中文文档](#https://realm.io/cn/docs/objc/latest)，只是为了给自己和想要快速上手的同学一个参看的范本，如有侵权，立即删除**

> Realm作为移动跨平台数据库，在github上已经有超过12K的Star了，最近学习了Realm，个人认为英文文档看起来比较费劲又啰嗦，中文文档的版本又落后好多，所以自己读完中英文文档并写完Demo后，写了个大约10分钟可以看完的Realm的使用文档，看完之后结合本文最后提供的Demo，应该是一个小时内就可以上手写自己的业务逻辑了
>
>  当然也可以直接使用Demo中我自己封装的工具类对Realm进行操作

>  [Realm英文文档](#https://realm.io/docs/objc/latest/)
>  [Realm中文文档](#https://realm.io/cn/docs/objc/latest)
>  [Realm GitHub](#https://github.com/realm/realm-cocoa)


# Realm 数据库准备工作

   > Realm 数据库可以是本地化的，也可以是可同步的。

1. clone or 下载 [Realm源码与Demo](https://github.com/realm/realm-cocoa) ，并且下载 [Realm Browser](#https://itunes.apple.com/cn/app/realm-browser/id1007457278?mt=12) 用于查看数据库，
   
2. 代码引入
    * 下载并解压源码后进入`realm-objc-3.13.1/ios/dynamic/`目录，将 Realm.framework 拖曳到 “Embedded Binaries” 部分内。请确保勾选了 Copy items if needed（除非项目中有多个平台都需要使用 Realm ），然后单击 Finish 按钮
    * 单元测试目标的 “Build Settings” 中，将 Realm.framework 的父目录添加到 “Framework Search Paths” 部分中
    * Realm Swift，请将 Swift/RLMSupport.swift 文件拖曳到 Xcode 工程的文件导航栏中，请确保选中了 Copy items if needed 选择框；
    * 目标文件中引入 `#import <Realm/Realm.h>` 或者 `import Realm`

3. 当然你以可以使用cocoapods进行导入，具体请参见 `https://realm.io/docs/objc/latest/`

4. 第一步，创建 `RLMRealmConfiguration` 对象，
    
```
   RLMRealmConfiguration *rConfig = [RLMRealmConfiguration defaultConfiguration];
    NSLog(@"config.fileUrl = %@",rConfig.fileURL.absoluteString);
    
    // 或者修改默认配置
    rConfig.fileURL = [[[config.fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"name"] URLByAppendingPathExtension:@"realm"]
    // 将该配置设置为默认 Realm 配置
    [RLMRealmConfiguration setDefaultConfiguration:config];
```
    
5. 第一步，获取 `RLMRealm` 对象

    // 使用某个配置打开 Realm 数据库
    RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:nil];
    //获取默认realm 
    RLMRealm *realm = [RLMRealm defaultRealm];
    
6. 官方建议所有realm操作放在：@autoreleasepool，所以Demo里的大部分realm操作都是：
  
        @autoreleasepool {
            // 在这里进行所有的 Realm 操作
        }

# 模型

> Realm只支持以下类型，就记住支持类型就行了，不要问不支持什么类型
> BOOL, bool, int, NSInteger, long, long long, float, double, NSString, NSDate, NSData
> 使用 NSNumber * 属性来存储可空数字,非空数字必须使用指定类型进行存储


1. 建立继承自 `RLMObject` 的类
2. RLMObject 子类的 +requiredProperties 方法以确定某些不为空的属性
    
       + (NSArray *)requiredProperties {
           return @[@"name"];
       }

3. 重写 +primaryKey 可以设置模型的主键
   

       + (NSString *)primaryKey {
        return @"id";
       }

4. 要为某个属性建立索引，那么重写 +indexedProperties 即可


       + (NSArray *)indexedProperties {
        return @[@"title"];
       }

5. 被忽略属性
    

       + (NSArray *)ignoredProperties {
        return @[@"tmpID"];
        } 

6. 重写 +defaultPropertyValues， 可以在每次创建对象时为属性提供默认值


       + (NSDictionary *)defaultPropertyValues {
         return @{@"price" : @0, @"title": @""};
       }

# 写入事务

> 写入事务中包含了传统数据库定义中的增，删，改

#### 增

1. 建立继承自 `RLMObject` 的类
2. 使用该类初始化一个实例 **所有非可空属性必须在对象添加到 Realm 数据库之前完成赋值。**

       // (1) 创建 Object 对象，然后设置其属性
       Object *myObject = [[Object alloc] init];
       myObject.name = @"Rex";
       myObject.age = 10;

       // (2) 从字典中创建 Object 对象  
       Object *myOtherObject = [[Object alloc] initWithValue:@{@"name" : @"Pluto", @"age" : @3}];

       // (3) 从数组中创建 Object 对象
       Object *myThirdObject = [[Object alloc] initWithValue:@[@"Pluto", @3]];

3. 数据库插入数据


       [realm transactionWithBlock:^{
        [realm addObject:ojc];
       }];

       // 在事务中向 Realm 数据库中添加数据
       [realm beginWriteTransaction];
       [realm addObject:myDog];
       [realm commitWriteTransaction];

4. 注意事项
    
    1. 写入操作会互相阻塞
    2. 写入事务未提交之前，读取操作是不会被阻塞的
    3. commitWriteTransaction 之前，应当把所有的写入事务写完
   
#### 删

1. 通过查询获取要删除的对象
2. 删除


       // 在事务中删除对象
       [realm beginWriteTransaction];
       [realm deleteObject:cheeseBook];
       [realm commitWriteTransaction];

       // 删除所有对象
       [realm beginWriteTransaction];
       [realm deleteAllObjects];
       [realm commitWriteTransaction]; 


#### 改

1. 对象的自更新，修改某个对象的属性，会立即影响到所有指向该对象的其他实例
    

        // 直接更新
       Object *myObject = [[Object alloc] init];
       myObject.name = @"Fido";
       myObject.age = 1;
       [realm transactionWithBlock:^{
         [realm addObject:myObject];
       }];

       Object *myPuppy = [[Object objectsWhere:@"age == 1"] firstObject];
       [realm transactionWithBlock:^{
        myPuppy.age = 2;
       }];
       myObject.age; // => 2

       // 使用主键进行更新
       Object *myObject = [[Object alloc] init];
       myObject.name = @"name";
       myObject.id = 1;
       [realm beginWriteTransaction];
       [realm addOrUpdateObject:myObject];
       [realm commitWriteTransaction];



# 查询

> 1. 查询会返回一个RLMResults实例，可以当成一个里边全是RLMObject的数组使用
> 2. 查询不是数据的拷贝
> 3. 查询结果会在当前线程每次使用时自更新
> 4. 直到使用时才去后台异步线程查询数据，因为RLMResults时刻与数据库数据保持一致

1. 返回所有对象： `RLMResults<Object *> *objects = [Object allObjects];`
2. 使用断言字符串或者 `NSPredicate` 来进行条件查询

    1. 比较操作数可以是属性名，也可以是常量。但至少要有一个操作数是属性名；
    2. 比较操作符 ==、<=、<、>=、>、!= 和 BETWEEN 支持 int、long、long long、float、double 以及 NSDate 这几种属性类型，例如 age == 45；
    3. 比较是否相同：== 和 !=，例如，[Employee objectsWhere:@"company == %@", company]；
    比较操作符 == 和 != 支持布尔属性；
    1. 对于 NSString 和 NSData 属性而言，支持使用 ==、!=、BEGINSWITH、CONTAINS 和 ENDSWITH 操作符，例如 name CONTAINS 'Ja'；
    2. 对于 NSString 属性而言，LIKE 操作符可以用来比较左端属性和右端表达式：? 和 * 可用作通配符，其中 ? 可以匹配任意一个字符，* 匹配 0 个及其以上的字符。例如：value LIKE '?bc*' 可以匹配到诸如 “abcde” 和 “cbc” 之类的字符串；
    3. 字符串的比较忽略大小写，例如 name CONTAINS[c] 'Ja'。请注意，只有 “A-Z” 和 “a-z” 之间的字符大小写会被忽略。[c] 修饰符可以与 [d] 修饰符结合使用；
    4. 字符串的比较忽略变音符号，例如 name BEGINSWITH[d] 'e' 能够匹配到 étoile。这个修饰符可以与 [c] 修饰符结合使用。（这个修饰符只能够用于 Realm 所支持的字符串子集：参见当前的限制一节来了解详细信息。）
    5.  Realm 支持以下组合操作符：“AND”、“OR” 和 “NOT”，例如 name BEGINSWITH 'J' AND age >= 32；
    6.  包含操作符：IN，例如 name IN {'Lisa', 'Spike', 'Hachi'}；
    7.  空值比较：==、!=，例如 [Company objectsWhere:@"ceo == nil"]。请注意，Realm 将 nil 视为一种特殊值，而不是某种缺失值；这与 SQL 不同，nil 等同于自身； 
    8.  ANY 比较，例如 ANY student.age < 21；
    9.  RLMArray 和 RLMResults 属性支持聚集表达式：@count、@min、@max、@sum 和 @avg，例如 [Company objectsWhere:@"employees.@count > 5"] 可用以检索所有拥有 5 名以上雇员的公司。
    10. 支持子查询，不过存在以下限制：
        * @count 是唯一一个能在 SUBQUERY 表达式当中使用的操作符；
        * SUBQUERY(…).@count 表达式只能与常量相比较；
        * 目前仍不支持关联子查询。

3. 排序Api :  `[RLMResults sortedResultsUsingKeyPath:@"age" ascending:YES];` 不支持链式排序，如果想要这么操作  `[[RLMResults sortedResultsUsingKeyPath:@"age" ascending:YES] sortedResultsUsingKeyPath:@"age" ascending:YES];`那么只有最后一个方法会生效
   
4. 链式查询,个人认为最方便的api


       RLMResults<Object *> *tanObjects = [Object objectsWhere:@"age =< 10"];
       RLMResults<Object *> *tanObjectWithBNames = [tanObjects objectsWhere:@"name BEGINSWITH 'B'"];

5. 限制查询结果，即SQLite 中的 “LIMIT” 关键字，但是Realm的特性决定了，realm不需要这种关键字，你只需要这样做：


       // 循环读取出前 5 个 Dog 对象
       // 从而限制从磁盘中读取的对象数量
       RLMResults<Dog *> *dogs = [Dog allObjects];
       for (NSInteger i = 0; i < 5; i++) {
          Dog *dog = dogs[i];
          // ...
       }

# 数据更新与迁移

> 线性版本迁移和服务器迁移同步请参见 [Realm文档](#https://realm.io/docs/objc/latest/)

#### 修改数据模型



每当将存入Realm的model进行修改时，如

将如下模型

    @interface Person : RLMObject
    @property NSString *firstName;
    @property NSString *lastName;
    @property int age;
    @end

改为如下模型

    @interface Person : RLMObject
    @property NSString *fullName;
    @property int age;
    @end

那么你就需要做迁移了，通过设置 `RLMRealmConfiguration.schemaVersion` 以及 `RLMRealmConfiguration.migrationBlock` 可以定义本地迁移，以下是属性迁移的代码：

    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    // 设置新的架构版本。必须大于之前所使用的版本
    // （如果之前从未设置过架构版本，那么当前的架构版本为 0）
    config.schemaVersion = 1;
    // 设置模块，如果 Realm 的架构版本低于上面所定义的版本，
    // 那么这段代码就会自动调用
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // 我们目前还未执行过迁移，因此 oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
            // 没有什么要做的！
            // Realm 会自行检测新增和被移除的属性
            // 然后会自动更新磁盘上的架构
            //但是如果想要直接计算好并更新好属性，那么你就需要
            // enumerateObjects:block: 方法将会遍历
            // 所有存储在 Realm 文件当中的 `Person` 对象
            [migration enumerateObjects:Person.className block:^(RLMObject *oldObject, RLMObject *newObject) {

                // 将两个 name 合并到 fullName 当中
                newObject[@"fullName"] = [NSString stringWithFormat:@"%@ %@",
                                            oldObject[@"firstName"],
                                            oldObject[@"lastName"]];
            }];
        }
    };
    // 通知 Realm 为默认的 Realm 数据库使用这个新的配置对象
    [RLMRealmConfiguration setDefaultConfiguration:config];
    // 现在我们已经通知了 Realm 如何处理架构变化，
    // 打开文件将会自动执行迁移
    [RLMRealm defaultRealm];

但是如果是直接将属性重命名（注意重名在任何地方都是肯定不能被允许的，所以不要问能不能重名的问题了），就可以像以下这样做了：

    // 如果将 `age` 这个字段改为 `old`

    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 1;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // 我们目前还未执行过迁移，因此 oldSchemaVersion == 0
         if (oldSchemaVersion < 1) {
        // 重命名操作必须要在 `enumerateObjects:` 调用之外进行
            [migration renamePropertyForClass:Person.className oldName:@"age" newName:@"old"];
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];


# 通知,线程安全与耗时操作,内存数据库

#### 通知
   
整个数据库的通知

    // 获取 Realm 通知
    token = [realm addNotificationBlock:^(NSString *notification, RLMRealm * realm) {
        [myViewController updateUI];
    }];

单个库或者数据模型的通知

    // 订阅 RLMResults 通知
    __weak typeof(self) weakSelf = self;
    self.notificationToken = [[Person objectsWhere:@"age > 5"] 
      addNotificationBlock:^(RLMResults<Person *> *results, RLMCollectionChange *changes, NSError *error) {
        
        if (error) {
            NSLog(@"Failed to open Realm on background worker: %@", error);
            return;
        }

        UITableView *tableView = weakSelf.tableView;
        // 初次运行查询的话，这个变化信息的值为 nil
        if (!changes) {
            [tableView reloadData];
            return;
        }

        // 检索结果发生改变，将其应用到 UITableView
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[changes deletionsInSection:0]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView insertRowsAtIndexPaths:[changes insertionsInSection:0]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadRowsAtIndexPaths:[changes modificationsInSection:0]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }];

    // 随后
    [token invalidate];

#### 线程安全与耗时操作的几点注意事项
   
1. 数据库迁移，压缩的操作等耗时操作，**建议使用 `asyncOpen` API**
2. 线程之间可以共享对象，但是需要 **减少** 写入事务的数量
3. 写入操作是**同步以及阻塞**进行的，它并不会异步执行,即:
        **一个线程的一个事务在对某个数据库进行写入时，其他线程的事务或者该线程的其他事务不能进行写入，否则会产生错误**
4. **但是**，当一个事务未被**提交**时，写入操作是不会被阻塞的
5. `RLMObject` 实例是底层数据的动态体现，其会**自动进行更新**,但是只反映**当前线程的状态**
6. 在使用 for...in 枚举时，它会将刚开始遍历时满足匹配条件的所有对象给遍历完，即使在遍历过程中有对象被过滤器修改或者删除

# 清除数据库，即删除Realm文件

应当注意，官网上重申，必须要在应用启动时、在打开 Realm 数据库之前完成如下操作，或者只能在`@autoreleasepool` 里进行如下操作，以打到诸如清除缓存之类的目的；所以，所有的realm操作都应当放在自动释放池中

```
NSFileManager *manager = [NSFileManager defaultManager];
RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
NSArray<NSURL *> *realmFileURLs = @[
    config.fileURL,
    [config.fileURL URLByAppendingPathExtension:@"lock"],
    [config.fileURL URLByAppendingPathExtension:@"note"],
    [config.fileURL URLByAppendingPathExtension:@"management"]
];
for (NSURL *URL in realmFileURLs) {
    NSError *error = nil;
    [manager removeItemAtURL:URL error:&error];
    if (error) {
        // 错误处理
    }
}
```

