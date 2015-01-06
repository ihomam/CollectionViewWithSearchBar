//
//  CollectionViewController.m
//  collevtionViewWithSearchBar
//
//  Created by Homam on 2015-01-02.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
@interface CollectionViewController ()<UISearchBarDelegate>
    @property (nonatomic,strong) NSArray        *dataSource;
    @property (nonatomic,strong) NSArray        *dataSourceForSearchResult;
    @property (nonatomic,strong) UISearchBar    *searchBar;
    @property (nonatomic)        BOOL           searchBarActive;
    @property (nonatomic)        float          searchBarBoundsY;
@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    // datasource used when user search in collectionView
    self.dataSourceForSearchResult = [NSArray new];
    
    // normal datasource
    self.dataSource =@[@"Modesto",@"Rebecka",@"Andria",@"Sergio",@"Robby",@"Jacob",@"Lavera",@"Theola",@"Adella",@"Garry", @"Lawanda", @"Christiana", @"Billy", @"Claretta", @"Gina", @"Edna", @"Antoinette", @"Shantae", @"Jeniffer", @"Fred", @"Phylis", @"Raymon", @"Brenna", @"Gus", @"Ethan", @"Kimbery", @"Sunday", @"Darrin", @"Ruby", @"Babette", @"Latrisha", @"Dewey", @"Della", @"Dylan", @"Francina", @"Boyd", @"Willette", @"Mitsuko", @"Evan", @"Dagmar", @"Cecille", @"Doug", @"Jackeline", @"Yolanda", @"Patsy", @"Haley", @"Isaura", @"Tommye", @"Katherine", @"Vivian"];

}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // prepare the searchBar view
    [self prepareSearchBar];
    
    // prepare collection view contentInset/ContentOffset so searchBar fit at the top
    self.collectionView.contentInset    = UIEdgeInsetsMake(self.searchBar.frame.size.height, 5, 0, 5);
    self.collectionView.contentOffset   = CGPointMake(0, -self.searchBar.frame.size.height);
}
-(void)viewDidAppear:(BOOL)animated{
    // add KVO observer.. so we will be informed when user scroll colllectionView
    [self addObservers];
}
-(void)dealloc{
    // remove Our KVO observer
    [self removeObservers];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
-(void)prepareSearchBar{
    if (!self.searchBar) {
        self.searchBarBoundsY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, self.searchBarBoundsY, [UIScreen mainScreen].bounds.size.width, 44)];
        self.searchBar.searchBarStyle       = UISearchBarStyleMinimal;
        self.searchBar.showsCancelButton    = YES;
        self.searchBar.tintColor            = [UIColor whiteColor];
        self.searchBar.barTintColor         = [UIColor whiteColor];
        self.searchBar.delegate             = self;
        self.searchBar.placeholder          = @"search here";
        
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
        
        [self.view addSubview:self.searchBar];
    }
}
#pragma mark - CollectionViewDataSourc
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.searchBarActive) {
        return self.dataSourceForSearchResult.count;
    }
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    if (self.searchBarActive) {
        cell.laName.text = self.dataSourceForSearchResult[indexPath.row];
    }else{
        cell.laName.text = self.dataSource[indexPath.row];
    }
    return cell;
}


#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"self contains[c] %@", searchText];
    self.dataSourceForSearchResult  = [self.dataSource filteredArrayUsingPredicate:resultPredicate];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
    if (searchText.length>0) {
        // search and reload data source
        [self filterContentForSearchText:searchText
                                   scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                          objectAtIndex:[self.searchDisplayController.searchBar
                                                         selectedScopeButtonIndex]]];
        [self.collectionView reloadData];
    }else{
        // if text lenght == 0 ... means no text
        // display all content on user face :D
        self.dataSourceForSearchResult = self.dataSource;
        [self.collectionView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.searchBarActive = NO;
    searchBar.text       = @"";
    [searchBar resignFirstResponder];
    [self.collectionView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchBarActive = YES;
    [self.view endEditing:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.searchBarActive = YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    self.searchBarActive = NO;
}
#pragma mark - observer 
- (void)addObservers{
    [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}
- (void)removeObservers{
    [self.collectionView removeObserver:self forKeyPath:@"contentOffset" context:Nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UICollectionView *)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"] && object == self.collectionView ) {

        self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                          (-1* object.contentOffset.y)-self.searchBar.frame.size.height,
                                          self.searchBar.frame.size.width,
                                          self.searchBar.frame.size.height);
    }
}


@end