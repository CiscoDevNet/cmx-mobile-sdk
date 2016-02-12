//
//  CMXPoiListViewController.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXSearchViewController.h"
#import "CMXClient.h"
#import "CMXPoi.h"
#import "CMXVenue.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXSearchViewController ()

@property (nonatomic, strong) NSArray* pois;

/**
 *  Tableview listing Pois
 **/
@property (nonatomic,strong) UITableView *tableView;

/**
 *  Search text field
 **/
@property (nonatomic,strong) UITextField *searchTextField;

/**
 *  Venue identifier
 **/
@property (nonatomic,strong) NSString *venueId;

/**
 *  Venue name
 **/
@property (nonatomic,strong) NSString *venueName;

/**
 *  Direction image (accessory view)
 **/
@property (nonatomic,strong) UIImage *accessoryImage;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXSearchViewController

////////////////////////////////////////////////////////////////////////////////////////////////////
-(id) initWithVenue:(CMXVenue*)venue {
    if(self = [super initWithStyle:UITableViewStylePlain]) {
        self.venueId = venue.identifier;
        self.venueName = venue.name;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) viewDidLoad {
    
    self.accessoryImage = [UIImage imageNamed:@"cmx_action_target_destination.png"];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(37,7,246,31)];
    _searchTextField.placeholder = [NSString stringWithFormat:NSLocalizedString(@"CMX Search Placeholder", @""), _venueName];
    _searchTextField.clearButtonMode = UITextFieldViewModeAlways;
    [_searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _searchTextField.delegate = self;
    _searchTextField.returnKeyType = UIReturnKeySearch;
    _searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchTextField.textColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1.0];
    _searchTextField.textAlignment = UITextAlignmentLeft;
    _searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    _searchTextField.font = [UIFont fontWithName:@"Helvetica" size:15];
    _searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.navigationItem setTitleView:_searchTextField];
    
    [self adjustSizeForCurrentOrientation];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) viewDidAppear:(BOOL)animated {
    if ([_searchTextField.text isEqualToString:@""]) {
        [_searchTextField becomeFirstResponder];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) viewDidDisappear:(BOOL)animated {
    [_searchTextField resignFirstResponder];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) viewWillDisappear:(BOOL)animated {
    [_searchTextField resignFirstResponder];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) adjustSizeForCurrentOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGFloat latteralViewVisiblePercentage = 0.;

    if (orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            latteralViewVisiblePercentage = 0.47;
        }else{
            latteralViewVisiblePercentage = 1;
        }
    
        
    }else{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            latteralViewVisiblePercentage = 0.35;
        }else{
            latteralViewVisiblePercentage = 0.85;
        }

    }
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width*latteralViewVisiblePercentage, self.view.frame.size.height);
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.tableView.frame.size.height);
}


#pragma mark TableView delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];

        UIImageView* accessoryView = [[UIImageView alloc] initWithImage:_accessoryImage];
        CGRect f = accessoryView.frame;
        f.size.width = cell.frame.size.height - 2 * 3;
        f.size.height = f.size.width;
        accessoryView.frame = f;
        accessoryView.contentMode = UIViewContentModeScaleAspectFit;
        accessoryView.userInteractionEnabled = YES;
        accessoryView.tag = indexPath.row;

        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAccessoryTap:)];
        singleTapGestureRecognizer.numberOfTapsRequired = 1;

        [accessoryView addGestureRecognizer:singleTapGestureRecognizer];
        cell.accessoryView = accessoryView;
    }
    
    CMXPoi* poi = [_pois objectAtIndex:indexPath.row];
    cell.textLabel.text = poi.name;
    return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _pois ? [_pois count] : 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_searchTextField resignFirstResponder];

    CMXPoi* poi = [_pois objectAtIndex:indexPath.row];

    if([_delegate respondsToSelector:@selector(searchViewController:didSelectPoi:)]) {
        [_delegate searchViewController:self didSelectPoi:poi];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

    [_searchTextField resignFirstResponder];

    CMXPoi* poi = [_pois objectAtIndex:indexPath.row];

    if([_delegate respondsToSelector:@selector(searchViewController:accessoryButtonTappedForPoi:)]) {
        [_delegate searchViewController:self accessoryButtonTappedForPoi:poi];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_searchTextField isFirstResponder]) {
        [_searchTextField resignFirstResponder];
    }
}

#pragma mark - TextField Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return TRUE;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    NSString* keywords = [textField.text isEqualToString:@""] ? nil : textField.text;
    
    if(keywords) {
        [self searchQuery:keywords];
    }
    
    [textField resignFirstResponder];
    return TRUE;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) textFieldShouldClear:(UITextField *)textField {
    self.pois = nil;
    [self.tableView reloadData];
    return YES;
}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) searchQuery:(NSString*)keywords {
    [[CMXClient instance] loadQueryForKeywords:keywords
                                      ofVenue:_venueId
                                         start:nil
                                    completion:^(NSMutableArray *POIs) {
                                        self.pois = POIs;
                                        [self.tableView reloadData];
                                    }
                                       failure:^(NSError *error) {
                                           UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Error Alert Title", @"")
                                                                                               message: error.localizedDescription
                                                                                              delegate: self
                                                                                     cancelButtonTitle: nil
                                                                                     otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                           [alertView show];
                                       }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) handleAccessoryTap:(UIGestureRecognizer *)gestureRecognizer {

    [_searchTextField resignFirstResponder];

    CMXPoi* poi = [_pois objectAtIndex:gestureRecognizer.view.tag];

    if([_delegate respondsToSelector:@selector(searchViewController:accessoryButtonTappedForPoi:)]) {
        [_delegate searchViewController:self accessoryButtonTappedForPoi:poi];
    }
}

@end
