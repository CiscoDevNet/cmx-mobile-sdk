//
//  CMXMenuViewController.m
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import "CMXMenuViewController.h"
#import "CMXMenuItem.h"
#import "CMXSettingsViewController.h"
#import "UIViewController+JASidePanel.h"
#import "Model.h"
#import "Network.h"
#import "CMXFeedbackViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CMXMenuViewController ()

/**
 *  Hold the name of the current floor where user is located, or nil if unknown.
 */
@property (nonatomic,strong) NSString *currentUserFloorName;

@property (strong, nonatomic) NSArray *venues;

@property (strong, nonatomic) NSDictionary *floorsByVenueId;

/**
 *  Tree view model.
 **/
@property (nonatomic,strong) NSMutableArray *treeViewModel;


@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CMXMenuViewController


////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupWithVenues:(NSArray*)venues floors:(NSDictionary*)floorsByVenueId userLocation:(CMXClientLocation*)userLocation {
    self.floorsByVenueId = floorsByVenueId;
    self.venues = venues;

    _treeViewModel = [[NSMutableArray alloc] init];

    self.currentUserFloorName = NSLocalizedString(@"CMX Not Available Location Menu Item", "");

    for(CMXVenue* venue in venues) {
        
        NSArray* floors = [floorsByVenueId objectForKey:venue.identifier];
        NSMutableArray *venueChildren = [NSMutableArray arrayWithCapacity:floors.count];
        for(CMXFloor* floor in floors) {
            CMXMenuItem *floorItem = [CMXMenuItem dataObjectWithName:floor.name children:nil];
            floorItem.floorID = floor.identifier;
            floorItem.venueID = floor.venueId;
            floorItem.level = [NSNumber numberWithInt:1];
            [venueChildren addObject:floorItem];
            
            // Define user location floor name
            if ([floor.identifier isEqualToString:userLocation.floorId]) {
                self.currentUserFloorName = floor.name;
            }
        }

        CMXMenuItem * venueItem = [CMXMenuItem dataObjectWithName:venue.name children:venueChildren];
        venueItem.venueID = venue.identifier;
        venueItem.level = [NSNumber numberWithInt:0];
        
        [_treeViewModel addObject:venueItem];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width*0.8, self.view.frame.size.height);
    self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width*0.8, self.tableView.frame.size.height);
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
        self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0);
    else self.tableView.contentInset = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0);
}

#pragma mark - Public
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) updateMenuItemsWithNewCurrentFloor:(CMXFloor*)floor {
    _currentUserFloorName = floor ? floor.name : NSLocalizedString(@"CMX Not Available Location Menu Item", "");
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableView delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 1;
            break;
        case 1:
            rows = [_treeViewModel count];
            break;
        case 2:
            rows = 2;
            break;

            
    }
    return rows;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 1.0f;
    
    return 25.0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    switch (section) {
        case 0:
            return nil;
            break;
        case 1:
            title = NSLocalizedString(@"CMX Venues & Floors Section Title", @"");
            break;
        case 2:
            title = NSLocalizedString(@"CMX Miscellaneous Section Title", @"");
            break;
    }
    
    return title;     
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.0f;
    }
    return [self.tableView sectionHeaderHeight];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
            cell.textLabel.font = [UIFont systemFontOfSize:10.];
        else
            cell.textLabel.font = [UIFont systemFontOfSize:12.];
    }
    
    if(indexPath.section==0) {
        cell.textLabel.text= [NSString stringWithFormat:NSLocalizedString(@"CMX Current Location Menu Item", @"") ,self.currentUserFloorName];
        cell.imageView.image = [UIImage imageNamed:@"cmx_menu_item_location.png"];
        
        
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmx_menu_item_accessory_right.png"]];
        accessoryView.contentMode = UIViewContentModeScaleAspectFill;
        accessoryView.frame = CGRectMake(0, 0, 40, 40);
        cell.accessoryView = accessoryView;

        
    }
    else if(indexPath.section==1) {
        CMXMenuItem *tmpTreeData = [self.treeViewModel objectAtIndex:indexPath.row];
        
        cell.textLabel.text= tmpTreeData.name;
        [cell setIndentationLevel:tmpTreeData.level.intValue];
        
        if (cell.indentationLevel == 0) {
            
            cell.imageView.image = tmpTreeData.image;
            UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmx_menu_item_accessory_down.png"]];
            accessoryView.contentMode = UIViewContentModeScaleAspectFill;
            accessoryView.frame = CGRectMake(0, 0, 40, 40);
            cell.accessoryView = accessoryView;

            if(!tmpTreeData.image) {
                [[CMXClient instance] loadImageOfVenue:tmpTreeData.venueID start:nil completion:^(UIImage *image) {
                    tmpTreeData.image = image;

                    // Capture the indexPath variable, not the cell variable, and use that
                    UITableViewCell *blockCell = [tableView cellForRowAtIndexPath:indexPath];
                    if (image) {
                        blockCell.imageView.image = image;
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }

                } failure:^(NSError *error) {
                    // Do nothing
                }];
            }
        }
        else {
            cell.imageView.image = nil;
            UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmx_menu_item_accessory_right.png"]];
            accessoryView.contentMode = UIViewContentModeScaleAspectFill;
            accessoryView.frame = CGRectMake(0, 0, 40, 40);
            cell.accessoryView = accessoryView;
        }
        
    }
    else {
        
        if (indexPath.row == 0){
            cell.textLabel.text = NSLocalizedString(@"CMX Settings Menu Item", @"");
            cell.imageView.image = [UIImage imageNamed:@"cmx_menu_item_settings.png"];
            UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmx_menu_item_accessory_right.png"]];
            accessoryView.contentMode = UIViewContentModeScaleAspectFill;
            accessoryView.frame = CGRectMake(0, 0, 40, 40);
            cell.accessoryView = accessoryView;
        }
        
        if (indexPath.row == 1){
            cell.textLabel.text = NSLocalizedString(@"CMX Feedback Menu Item", @"");
            cell.imageView.image = [UIImage imageNamed:@"cmx_menu_item_feedback.png"];
            UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmx_menu_item_accessory_right.png"]];
            accessoryView.contentMode = UIViewContentModeScaleAspectFill;
            accessoryView.frame = CGRectMake(0, 0, 40, 40);
            cell.accessoryView = accessoryView;

        }
        

    }
    return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    if (indexPath.section==0) {
        
        if([_delegate respondsToSelector:@selector(menuViewControllerDidSelectUserLocationMenuItem:)]) {
            [_delegate menuViewControllerDidSelectUserLocationMenuItem:self];
        }
    }
    
    if (indexPath.section==1) {
        
        CMXMenuItem *d=[self.treeViewModel objectAtIndex:indexPath.row];
        if(d.children.count != 0) {
           
            NSArray *ar=d.children;
            
            BOOL isAlreadyInserted=NO;
            
            for(CMXMenuItem *dInner in ar ){
                NSInteger index=[self.treeViewModel indexOfObjectIdenticalTo:dInner];
                isAlreadyInserted=(index>0 && index!=NSIntegerMax);
                if(isAlreadyInserted) break;
            }
            
            if(isAlreadyInserted) {
                [self miniMizeSecondsRows:ar];
                
                UITableViewCell *tmpCell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmx_menu_item_accessory_down.png"]];
                accessoryView.contentMode = UIViewContentModeScaleAspectFill;
                accessoryView.frame = CGRectMake(0, 0, 40, 40);
                tmpCell.accessoryView = accessoryView;
                tmpCell.textLabel.textColor = [UIColor darkTextColor];
            }
            else {
                
                NSUInteger count=indexPath.row+1;
                NSMutableArray *arCells=[NSMutableArray array];
                for(NSDictionary *dInner in ar ) {
                    [arCells addObject:[NSIndexPath indexPathForRow:count inSection:1]];
                    [self.treeViewModel insertObject:dInner atIndex:count++];
                }
                [tableView insertRowsAtIndexPaths:arCells withRowAnimation:UITableViewRowAnimationLeft];
                
                UITableViewCell *tmpCell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmx_menu_item_accessory_up.png"]];
                accessoryView.contentMode = UIViewContentModeScaleAspectFill;
                accessoryView.frame = CGRectMake(0, 0, 40, 40);
                tmpCell.accessoryView = accessoryView;
                tmpCell.textLabel.textColor = [UIColor blueColor];

            }
        }
        else {
           // Selected floor
            if([_delegate respondsToSelector:@selector(menuViewController:didSelectFloorMenuItem:ofVenue:)]) {
                NSDictionary *mapInformations = [self floorAndVenueForFloorID:d.floorID andVenueID:d.venueID];
                CMXFloor* floor = mapInformations[@"CMXFloor"];
                [_delegate menuViewController:self didSelectFloorMenuItem:floor.identifier ofVenue:floor.venueId];
            }
        }
    }
    
    if (indexPath.section==2) {
        
        if (indexPath.row == 0){
            // Settings item
            if([_delegate respondsToSelector:@selector(menuViewControllerDidSelectSettingsMenuItem:)]) {
                [_delegate menuViewControllerDidSelectSettingsMenuItem:self];
            }
        }
        
        if (indexPath.row == 1){
            // Feedback item
            if([_delegate respondsToSelector:@selector(menuViewControllerDidSelectFeedbackMenuItem:)]) {
                [_delegate menuViewControllerDidSelectFeedbackMenuItem:self];
            }
        }
        
    }

}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)miniMizeSecondsRows:(NSArray*)ar {
	
	for(CMXMenuItem *dInner in ar ) {
		NSUInteger indexToRemove=[self.treeViewModel indexOfObjectIdenticalTo:dInner];
		NSArray *arInner= dInner.children;
		if(arInner && [arInner count]>0){
			[self miniMizeSecondsRows:arInner];
		}
		
		if([self.treeViewModel indexOfObjectIdenticalTo:dInner]!=NSNotFound) {
			[self.treeViewModel removeObjectIdenticalTo:dInner];
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:
                                                    [NSIndexPath indexPathForRow:indexToRemove inSection:1]
                                                    ]
                                  withRowAnimation:UITableViewRowAnimationRight];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// TODO to remove
-(NSDictionary*)floorAndVenueForFloorID:(NSString*)floorID andVenueID:(NSString*)venueID {
    
    NSMutableDictionary *mutableDico = [[NSMutableDictionary alloc] init];
    
    for(CMXVenue* venue in _venues) {
        if([venue.identifier isEqualToString:venueID]) {
            [mutableDico setValue:venue forKey:@"CMXVenue"];
            break;
        }
    }
    
    NSArray* floors = [_floorsByVenueId objectForKey:venueID];
    for(CMXFloor* floor in floors) {
        if ([floor.identifier isEqualToString:floorID]) {
            [mutableDico setValue:floor forKey:@"CMXFloor"];
            break;
        }
    }
    
    return mutableDico;
}

@end
