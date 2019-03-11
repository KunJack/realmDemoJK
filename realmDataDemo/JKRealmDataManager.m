//
//  JKRealmDataManager.m
//  realmDataDemo
//
//  Created by 姜昆 on 2019/3/8.
//  Copyright © 2019年 richeditor. All rights reserved.
//



#import "JKRealmDataManager.h"



@interface JKRealmDataManager ()


@end



@implementation JKRealmDataManager

+ (instancetype)shareManager{
    static JKRealmDataManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //第一步，配置默认的 RLMRealmConfiguration
        [self setupRealmConfig];
    }
    return self;
}

- (void)setupRealmConfig{
    // 获取默认 config
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    // 设置realm的版本号，用于将来的数据库迁移，如果不设置会默认为0；
    config.schemaVersion = 0;
    
    // 这里使用App名称作为数据库名字
    NSString *realmname = @"database";
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (appName.length > 0) {
        realmname = appName;
    }
    // 修改默认配置
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:appName] URLByAppendingPathExtension:@"realm"];
    NSLog(@"config.fileUrl = %@",config.fileURL.absoluteString);
    // 将该配置设置为默认 Realm 配置
    [RLMRealmConfiguration setDefaultConfiguration:config];
}

- (RLMRealm *)realm{
    return [RLMRealm defaultRealm];
}


#pragma mark - insert

- (void)insertObject:(RLMObject *)object{
    @autoreleasepool {
        [[RLMRealm defaultRealm] beginWriteTransaction];
        [[RLMRealm defaultRealm] addObject:object];
        [[RLMRealm defaultRealm] commitWriteTransaction];
    }
}
- (void)insertObjects:(NSArray<RLMObject *> *)objects{
    @autoreleasepool {
        [[RLMRealm defaultRealm] beginWriteTransaction];
        [[RLMRealm defaultRealm] addObjects:objects];
        [[RLMRealm defaultRealm] commitWriteTransaction];
    }
}

#pragma mark - delete

- (void)deleteObject:(RLMObject *)object{
    @autoreleasepool {
        [[RLMRealm defaultRealm] beginWriteTransaction];
        [[RLMRealm defaultRealm] deleteObject:object];
        [[RLMRealm defaultRealm] commitWriteTransaction];
    }
}
- (void)deleteObjects:(NSArray<RLMObject *> *)objects{
    @autoreleasepool {
        [[RLMRealm defaultRealm] beginWriteTransaction];
        [[RLMRealm defaultRealm] deleteObjects:objects];
        [[RLMRealm defaultRealm] commitWriteTransaction];
    }
}
- (void)deleteAllObject{
     @autoreleasepool {
         [[RLMRealm defaultRealm] beginWriteTransaction];
         [[RLMRealm defaultRealm] deleteAllObjects];
         [[RLMRealm defaultRealm] commitWriteTransaction];
     }
}

#pragma mark - update

/*
 
 单个属性的更新，请使用
 
 [[JKRealmDataManager shareManager].realm beginWriteTransaction];
 author.name = @"Thomas Pynchon";
 [[JKRealmDataManager shareManager].realm commitWriteTransaction];
 */

/**
 批量更新，传入的数组中的元素必须设置了主键，
 
 @param objects 继承与 RLMObject 对象的数组
 */
- (void)updateObjects:(NSArray<RLMObject *> *)objects{
    @autoreleasepool {
        [[RLMRealm defaultRealm] beginWriteTransaction];
        [[RLMRealm defaultRealm] addOrUpdateObjects:objects];
        [[RLMRealm defaultRealm] commitWriteTransaction];
    }
}

#pragma mark - select

#pragma mark - 其他

// 数据库迁移
- (void)migrationDataWithNewVersionCode:(uint64_t)versionCode migration:(void(^)(RLMMigration *migration, uint64_t oldSchemaVersion))migra{
     RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    if (versionCode <= config.schemaVersion) {
        return;
    }
   
    // 设置新的架构版本。必须大于之前所使用的版本
    // 建议改数字和APP的数字版本号同步起来，这样就能保证迁移的成功率
    config.schemaVersion = versionCode;
    
    // 设置模块，如果 Realm 的架构版本低于上面所定义的版本,那么这段代码就会自动调用
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // 我们目前还未执行过迁移，因此 oldSchemaVersion == 0
        // 回调闭包,这样只是更新了,如果想要进行值更新过着属性重命名，请参见 https://realm.io/docs/objc/latest/#migrations
        migra(migration,oldSchemaVersion);
        /*
        if (oldSchemaVersion < 1) {
            // 没有什么要做的！
            // Realm 会自行检测新增和被移除的属性
            // 然后会自动更新磁盘上的架构
        }
         // 值更新
         [migration enumerateObjects:Object.className
                               block:^(RLMObject *oldObject, RLMObject *newObject) {
         
             // 在这里写上值迁移的关系
             newObject[@"fullName"] = [NSString stringWithFormat:@"%@ %@",
             oldObject[@"firstName"],
             oldObject[@"lastName"]];
         }];
         
         // 属性重命名
          [migration renamePropertyForClass:Object.className oldName:@"oldName" newName:@"newName"];
         
         */
    };
    
    // 通知 Realm 为默认的 Realm 数据库使用这个新的配置对象
    [RLMRealmConfiguration setDefaultConfiguration:config];
}


/**
 清理数据库，但是注意这样并不会减少Realm的文件的大小，只会删除所有数据
 */
- (void)clearData{
    @autoreleasepool {
        [[RLMRealm defaultRealm] beginWriteTransaction];
        [[RLMRealm defaultRealm] deleteAllObjects];
        [[RLMRealm defaultRealm] commitWriteTransaction];
    }
}


/**
 移除数据库，该操作会直接将数据库及其辅助文件移除，一定要慎用；
 */
- (void)removeRealm{

    NSFileManager *manager = [NSFileManager defaultManager];
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    NSArray<NSURL *> *realmFileURLs =
  @[
    config.fileURL,
    [config.fileURL URLByAppendingPathExtension:@"lock"],
    [config.fileURL URLByAppendingPathExtension:@"note"],
    [config.fileURL URLByAppendingPathExtension:@"management"]];
    for (NSURL *URL in realmFileURLs) {
        NSError *error = nil;
        [manager removeItemAtURL:URL error:&error];
        if (error) {
            // 错误处理
        }
    }
}



@end
