//
//  JKRealmDataManager.h
//  realmDataDemo
//
//  Created by 姜昆 on 2019/3/8.
//  Copyright © 2019年 richeditor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKRealmDataManager : NSObject

+ (instancetype)shareManager;

@property (nonatomic, strong, readonly) RLMRealm *realm;

#pragma mark - insert


/**
 非主键型model的插入方式

 @param object rlmobject
 */
- (void)insertObject:(RLMObject *)object;
- (void)insertObjects:(id<NSFastEnumeration>)objects;

#pragma mark - delete

- (void)deleteObject:(RLMObject *)object;
- (void)deleteObjects:(id<NSFastEnumeration>)objects;
- (void)deleteAllObject;

#pragma mark - update

/*
 
 单个属性的更新，请使用
 
 [[JKRealmDataManager shareManager].realm beginWriteTransaction];
 author.name = @"Thomas Pynchon";
 [[JKRealmDataManager shareManager].realm commitWriteTransaction];
 */

/**
 主键型object的插入与更新,如果有该主键的对象就更新，如果没有就传入
 传入的数组中的元素必须设置了主键，

 @param objects 继承与 RLMObject 对象的数组
 */
- (void)updateObjects:(id<NSFastEnumeration>)objects;


#pragma mark - select

// ~

#pragma mark - operation

/**
 数据库迁移方法，该方法应于 [AppDelegate didFinishLaunchingWithOptions:] 中，处理数据逻辑之前进行，否则Realm会抛出异常

 @param versionCode 新数据库的版本号,新的版本号必须大于老的版本号才能继续
 @param migra 迁移回调，在该闭包中进行配置
 */
- (void)migrationDataWithNewVersionCode:(uint64_t)versionCode migration:(void(^)(RLMMigration *migration, uint64_t oldSchemaVersion))migra;


/**
 清理数据库，但是注意这样并不会显著的减少Realm的文件的大小，只会删除所有数据，并清除表主键
 */
- (void)clearData;


/**
 移除数据库，该操作会直接将数据库及其辅助文件移除,并且一并移除数据对应关系,一定要慎用；
 */
- (void)removeRealm;

@end

NS_ASSUME_NONNULL_END
