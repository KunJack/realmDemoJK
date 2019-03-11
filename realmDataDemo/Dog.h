//
//  Dog.h
//  realmDataDemo
//
//  Created by 姜昆 on 2019/3/7.
//  Copyright © 2019年 richeditor. All rights reserved.
//

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface Dog : RLMObject

@property NSString *name;
//@property NSData   *picture;
@property int type;
@property NSInteger age;

@end

RLM_ARRAY_TYPE(Dog)

NS_ASSUME_NONNULL_END
