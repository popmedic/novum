//
//  NVMMasterViewController.m
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/10/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import "NVMMasterViewController.h"
#import "NVMAtchImagesViewController.h"
#import "NVMBaseUsers.h"
#import "NVMImageZoomViewController.h"
#import "NVMMasterViewCell.h"

@interface NVMMasterViewController () {
    NSMutableArray *_objects;
    NVMBaseUsers *_baseUsers;
    NSDate* _lastChecked;
}
@end

@implementation NVMMasterViewController

@synthesize baseUsers = _baseUsers;
@synthesize lastChecked = _lastChecked;

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(checkForMessages:)];
    //[refreshButton setEnabled:NO];
    //self.navigationItem.rightBarButtonItem = refreshButton;
    //self.navigationItem.title = @"Field Reports";

    _lastChecked = [NSDate date];
    NSDate *start = [[_lastChecked copy] dateByAddingTimeInterval:(-1)*(30*/*days*/(24*(60*60)))];
   // NSLog(@"Start:%@ End:%@", start.description, _lastChecked.description);
    
    _baseUsers = [[NVMBaseUsers alloc] init];
    [_baseUsers login:^(NSURLResponse *lresp, NSData *ldata, NSError *lerror) {
        if(lresp != nil){
            NSError *ljerror;
            //NSLog(@"%@", [[NSString alloc] initWithData:ldata encoding:NSUTF8StringEncoding]);
            NSDictionary* ldres = [NSJSONSerialization JSONObjectWithData:ldata options:NSJSONReadingAllowFragments error:&ljerror];
            if(ldres != nil){
                if([[ldres valueForKey:@"error"] isKindOfClass:[NSNumber class]]){
                    [_baseUsers getMsgHeadersStart:start End:_lastChecked Handler:^(NSURLResponse *resp, NSData *data, NSError *error) {
                        NSError* jerror;
                        if(resp != nil){
                            //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                            NSDictionary* dres = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jerror];
                            if(dres != nil){
                                if([[dres valueForKey:@"error"] isKindOfClass:[NSNumber class]]){
                                    _objects = [NSMutableArray arrayWithArray:[dres valueForKey:@"rows"]];
                                    [self.tableView reloadData];
                                    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkForMessages:) userInfo:self repeats:YES];
                                }
                                else{
                                    UIAlertView* alert;
                                    alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                                       message:[NSString stringWithFormat:@"Unable to getMsgHeaders: %@", [dres valueForKey:@"error"]]
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles: nil];
                                    [alert show];
                                }
                            }
                            else{
                                UIAlertView* alert;
                                alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                                   message:[NSString stringWithFormat:@"Unable to getMsgHeaders - JSON ERROR: %@", jerror.description]
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles: nil];
                                [alert show];
                            }
                        }
                        else{
                            UIAlertView* alert;
                            alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                               message:[NSString stringWithFormat:@"Unable to getMsgHeaders: %@", error.description]
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles: nil];
                            [alert show];
                        }
                    }];
                }
                else{
                    UIAlertView* alert;
                    alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                       message:[NSString stringWithFormat:@"Unable to login: %@", [ldres valueForKey:@"error"]]
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
                    [alert show];
                }
            }
            else{
                UIAlertView* alert;
                alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                   message:[NSString stringWithFormat:@"Unable to login - JSON ERROR: %@", ljerror]
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles: nil];
                [alert show];
            }
        }
        else{
            UIAlertView* alert;
            alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                               message:[NSString stringWithFormat:@"Unable to login: %@", lerror.description]
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles: nil];
            [alert show];
        }
    }];

    self.detailViewController = (NVMAtchImagesViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)checkForMessages:(id)sender{
    NSDate* end = [NSDate date];
    [_baseUsers getMsgHeadersStart:_lastChecked End:end Handler:^(NSURLResponse *resp, NSData *data, NSError *error) {
        NSError* jerror;
        if(resp != nil){
            //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSDictionary* dres = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&jerror];
            if(dres != nil){
                if([[dres valueForKey:@"error"] isKindOfClass:[NSNumber class]]){
                    _lastChecked = end;
                    NSArray* nobjs = [dres valueForKey:@"rows"];
                    for(int i = 0; i < [nobjs count];i++){
                        NSDictionary* nobj = [nobjs objectAtIndex:i];
                        [self performSelectorOnMainThread:@selector(insertNewObject:)
                                               withObject:nobj
                                            waitUntilDone:NO];
                    }
                }
                else{
                    UIAlertView* alert;
                    alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                       message:[NSString stringWithFormat:@"Unable to getMsgHeaders: %@", [dres valueForKey:@"error"]]
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
                    [alert show];
                }
            }
            else{
                UIAlertView* alert;
                alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                   message:[NSString stringWithFormat:@"Unable to getMsgHeaders - JSON ERROR: %@", jerror.description]
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles: nil];
                [alert show];
            }
        }
        else{
            UIAlertView* alert;
            alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                               message:[NSString stringWithFormat:@"Unable to getMsgHeaders: %@", error.description]
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles: nil];
            [alert show];
        }
    }];
}


- (void)insertNewObject:(NSDictionary*)newObject
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:newObject atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NVMMasterViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idNVMMasterViewCell" forIndexPath:indexPath];

    NSDictionary *object = _objects[indexPath.row];
    cell.textLabel.text = [object valueForKey:@"fagency"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@ (%@)",
                                 [object valueForKey:@"funit"],
                                 [object valueForKey:@"fphone_number"],
                                 [object valueForKey:@"fip_addr"]];
    NSDateFormatter* utc_fmt = [[NSDateFormatter alloc] init];
    [utc_fmt setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [utc_fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter* loc_fmt = [[NSDateFormatter alloc] init];
    [loc_fmt setTimeZone:[NSTimeZone defaultTimeZone]];
    [loc_fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSLog(@"%@", [object valueForKey:@"read"]);
    if(![[object valueForKey:@"read"] isKindOfClass:[NSNull class]]){
        [cell.dateLabel setTextColor:[UIColor darkTextColor]];
    }
    else{
        [cell.dateLabel setTextColor:[UIColor blueColor]];
    }
    cell.dateLabel.text = [[loc_fmt stringFromDate:[utc_fmt dateFromString:[object valueForKey:@"sentts"]]] description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *obj = _objects[indexPath.row];
    NSString* msgId = [obj valueForKey:@"id"];
    [_baseUsers getAtchHeaders:msgId
                       Handler:^(NSURLResponse *resp, NSData *data, NSError *error) {
        NSError* jerror;
        if(resp != nil){
           //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
           NSDictionary* dres = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&jerror];
           if(dres != nil){
               if([[dres valueForKey:@"error"] isKindOfClass:[NSNumber class]]){
                   self.detailViewController.atchImages = [dres valueForKey:@"rows"];
                   if([self.detailViewController.navigationController.visibleViewController isKindOfClass:[NVMImageZoomViewController class]]){
                       [self.detailViewController.navigationController popViewControllerAnimated:YES];
                   }
                   [_baseUsers readMessage:msgId Handler:^(NSURLResponse *resp, NSData *data, NSError *error) {
                       NSError *j2error;
                       NSDictionary *dmsg = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingAllowFragments
                                                                              error:&j2error];
                       if(dmsg != nil){
                           NSArray* rows =[dmsg valueForKey:@"rows"];
                           NSDictionary* dm =[rows objectAtIndex:0];
                           NVMAtchImagesViewController* aivc = self.detailViewController;
                           aivc.navigationItem.title = [dm valueForKey:@"message"];
                           NSMutableDictionary* md = [[_objects objectAtIndex:indexPath.row] mutableCopy];
                           if([[md valueForKey:@"read"] isKindOfClass:[NSNull class]]){
                               [md setObject:@"true" forKey:@"read"];
                               [_objects replaceObjectAtIndex:indexPath.row withObject:md];
                               [self.tableView reloadData];
                               [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                           }
                       }
                   }];
                   [self.detailViewController.collectionView reloadData];
                   CATransition *animation = [CATransition animation];
                   [animation setType:kCATransitionPush];
                   [animation setSubtype:kCATransitionFade];
                   [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                   [animation setFillMode:kCAFillModeBoth];
                   [animation setDuration:.5];
                   [[self.detailViewController.collectionView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
               }
               else{
                   UIAlertView* alert;
                   alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                      message:[NSString stringWithFormat:@"Unable to getAtchHeaders: %@", [dres valueForKey:@"error"]]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles: nil];
                   [alert show];
               }
           }
           else{
               UIAlertView* alert;
               alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                  message:[NSString stringWithFormat:@"Unable to getAtchHeaders - JSON ERROR: %@", jerror.description]
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles: nil];
               [alert show];
           }
        }
        else{
           UIAlertView* alert;
           alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                              message:[NSString stringWithFormat:@"Unable to getAtchHeaders: %@", error.description]
                                             delegate:nil
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles: nil];
           [alert show];
        }
    }];
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
