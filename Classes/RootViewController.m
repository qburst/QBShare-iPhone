//
//  RootViewController.m
//  iShare
//
//  Created by midhun on 31/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "QBShareViewController.h"


@implementation RootViewController



#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSString * imageName = nil; 
    switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"FaceBook";
            imageName = @"facebook.png";
			break;
		case 1:
			cell.textLabel.text = @"LinkedIn";
            imageName = @"linkedin.png";
			break;
        case 2:
            cell.textLabel.text = @"Twitter";
            imageName = @"twitter.png";
		default:
			break;
	}
	if (imageName) {
        cell.imageView.image = [UIImage imageNamed:imageName];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	// Configure the cell.

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	 QBShareViewController *detailViewController = [[QBShareViewController alloc] initWithNibName:@"QBShareViewController" bundle:[NSBundle mainBundle]];
	 detailViewController.selectedIndex = indexPath.row;
	// ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [super dealloc];
}


@end

