//
//  ViewController.m
//  realmDataDemo
//
//  Created by 姜昆 on 2019/3/7.
//  Copyright © 2019年 richeditor. All rights reserved.
//

// module
#import <Realm/Realm.h>
// helper
#import "JKRealmDataManager.h"
// vc
#import "ViewController.h"
// model
#import "Dog.h"
#import "Person.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic)  RLMResults<Person *> *tableData;
@property (weak, nonatomic) IBOutlet UITextField *textField;


@end



@implementation ViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tableData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"dbdbdbdb";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:cellID];
    }
    cell.textLabel.text = self.tableData[indexPath.row].firstName;
    cell.detailTextLabel.text = self.tableData[indexPath.row].secondName;
    return cell;
}


- (IBAction)addAction:(id)sender {
    
    Person *pppp = [[Person alloc] init];
    pppp.firstName = [self randomString];
    pppp.secondName = [self randomString];
    pppp.thirdName = [self randomString];
    
    for (int i = 0; i < 8; i++) {
        Dog *mydog = [[Dog alloc] init];
        mydog.name = [self randomString];
        mydog.age = arc4random()%10;
        mydog.type = arc4random()%10;
        [pppp.dogs addObject:mydog];
    }
    
    RLMResults<Person *> *mama = [Person objectsWhere:@"firstName ==  'mama' "];
    if (mama.count > 0) {
        [pppp.parents addObject:mama.firstObject];
    }else{
        Person *mama1 = [[Person alloc] init];
        mama1.firstName = @"mama";
        mama1.secondName = @"35";
        mama1.thirdName = @"666";
        [pppp.parents addObject:mama1];
    }
    
    [[JKRealmDataManager shareManager] insertObject:pppp];
    [self getTableDatas];
    return;
}
- (IBAction)deleteAc:(id)sender {
    if (self.textField.text.length <= 0) {
        [[JKRealmDataManager shareManager] deleteAllObject];
        [self getTableDatas];
        return;
    }else{
        RLMResults<Person *> *hunmanbeings = [Person objectsWhere:self.textField.text];
        if (hunmanbeings.count <= 0) {
            return;
        }
        [[JKRealmDataManager shareManager] deleteObjects:hunmanbeings];
        [self getTableDatas];
    }
    
}
- (IBAction)changeAc:(id)sender {
    
    if (self.textField.text.length <= 0) {
        return;
    }else{
        RLMResults<Person *> *hunmanbeings = [Person objectsWhere:self.textField.text];
        if (hunmanbeings.count <= 0) {
            return;
        }
        Person *humen = [[Person objectsWhere:self.textField.text] firstObject];
        [[JKRealmDataManager shareManager].realm beginWriteTransaction];
        humen.firstName = @"realFirst";
        [[JKRealmDataManager shareManager].realm commitWriteTransaction];
    }
    
    [self getTableDatas];
    
}
- (IBAction)getAcs:(id)sender {
    
    if (self.textField.text.length <= 0) {
        _tableData = [Person allObjects];
    }else{
        
    }
    [self.tableView reloadData];
}

- (NSString *)randomString{
    return [NSUUID.UUID.UUIDString substringToIndex:6];
}
- (void)getTableDatas{
    _tableData = [Person allObjects];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [JKRealmDataManager shareManager];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

}


@end
