//
//  Person.h
//  realmDataDemo
//
//  Created by 姜昆 on 2019/3/7.
//  Copyright © 2019年 richeditor. All rights reserved.
//

#import <Realm/Realm.h>
#import "Dog.h"

NS_ASSUME_NONNULL_BEGIN

RLM_ARRAY_TYPE(Person)

@interface Person : RLMObject

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *secondName;
@property (nonatomic, copy) NSString *thirdName;

@property  RLMArray<Person *><Person> *parents;

@property  RLMArray<Dog *><Dog> *dogs;

@end



NS_ASSUME_NONNULL_END
