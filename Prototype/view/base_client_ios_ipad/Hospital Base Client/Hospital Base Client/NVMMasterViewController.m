//
//  NVMMasterViewController.m
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/10/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import "NVMMasterViewController.h"
#import "NVMDetailViewController.h"
#import "NVMBaseUsers.h"
#import "NVMImageZoomViewController.h"
#import "NVMMasterViewCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

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
    /*self.pollingInterval = [[NSUserDefaults standardUserDefaults] valueForKey:@"pollingIntervalInSecs"];
    if(![self.pollingInterval isKindOfClass:[NSNumber class]]){*/
        self.pollingInterval = [NSNumber numberWithFloat:15.0];
        
    //}
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
                    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ - %@",
                                                                        _baseUsers.user, self.navigationItem.title]];
                    [_baseUsers getMsgHeadersStart:start End:_lastChecked Handler:^(NSURLResponse *resp, NSData *data, NSError *error) {
                        NSError* jerror;
                        if(resp != nil){
                            //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                            NSDictionary* dres = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jerror];
                            if(dres != nil){
                                if([[dres valueForKey:@"error"] isKindOfClass:[NSNumber class]]){
                                    _objects = [NSMutableArray arrayWithArray:[dres valueForKey:@"rows"]];
                                    [self.tableView reloadData];
                                    [NSTimer scheduledTimerWithTimeInterval:self.pollingInterval.floatValue target:self selector:@selector(checkForMessages:) userInfo:self repeats:YES];
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

    self.detailViewController = (NVMDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)checkForMessages:(id)sender{
    NSDate* end = [NSDate date];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [_baseUsers getMsgHeadersStart:_lastChecked End:end Handler:^(NSURLResponse *resp, NSData *data, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
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
            //[alert show];
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
    
    NSString *soundFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/siren.mp3"];
    if([[NSFileManager defaultManager] fileExistsAtPath:soundFilePath]){
        NSURL* soundFileURL = [NSURL fileURLWithPath:soundFilePath isDirectory:NO];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
     
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [object valueForKey:@"fagency"], [object valueForKey:@"funit"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)",
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
    UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.frame = CGRectMake(0.0, 0.0, 120.0, 120.0);
    activityIndicatorView.center = self.detailViewController.view.center;
    [self.detailViewController.view addSubview:activityIndicatorView];
    [self.detailViewController.view bringSubviewToFront:activityIndicatorView];
    [activityIndicatorView startAnimating];
    tableView.userInteractionEnabled = FALSE;
    
    self.detailViewController.complaintLabel.text = @"";
    self.detailViewController.descriptionLabel1.text = @"";
    self.detailViewController.descriptionLabel2.text = @"";
    self.detailViewController.descriptionLabel3.text = @"";
    self.detailViewController.descriptionLabel4.text = @"";
    self.detailViewController.atchImages = [NSArray array];
    [self.detailViewController.atchCollectionView reloadData];
    CATransition *detailViewClearAnimation = [CATransition animation];
    [detailViewClearAnimation setType:kCATransitionPush];
    [detailViewClearAnimation setSubtype:kCATransitionFade];
    [detailViewClearAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [detailViewClearAnimation setFillMode:kCAFillModeBoth];
    [detailViewClearAnimation setDuration:.5];
    [[self.detailViewController.view layer] addAnimation:detailViewClearAnimation forKey:@"UITableViewReloadDataAnimationKey"];
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [_baseUsers getAtchHeaders:msgId
                       Handler:^(NSURLResponse *resp, NSData *data, NSError *error) {
                           
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        if(data.length > 0){
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
                       
                       [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
                       [_baseUsers readMessage:msgId Handler:^(NSURLResponse *resp, NSData *data, NSError *error) {
                           [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                           if(data != nil){
                               NSError *j2error;
                               NSDictionary *dmsg = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:NSJSONReadingAllowFragments
                                                                                      error:&j2error];
                               if(dmsg != nil){
                                   NSArray* rows =[dmsg valueForKey:@"rows"];
                                   NSDictionary* dm =[rows objectAtIndex:0];
                                   NVMDetailViewController* advc = self.detailViewController;
                                   NSError* jerr2;
                                   NSDictionary* jsonMessage = [NSJSONSerialization JSONObjectWithData:[[dm valueForKey:@"message"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                                               options:NSJSONReadingAllowFragments
                                                                                                 error:&jerr2];
                                   if(jsonMessage != nil){
                                        [advc.complaintLabel setText:[jsonMessage valueForKey:@"complaint"]];
                                        [advc.descriptionLabel1 setText:[NSString stringWithFormat:@"Age: %@", (NSString*)[jsonMessage valueForKey:@"age"]]];
                                        [advc.descriptionLabel2 setText:[NSString stringWithFormat:@"Gender: %@", [jsonMessage valueForKey:@"gender"]]];
                                        /*[advc.descriptionLabel3 setText:[NSString stringWithFormat:@"Blood Pressure: %@", [jsonMessage valueForKey:@"blood_pressure"]]];
                                        [advc.descriptionLabel4 setText:[NSString stringWithFormat:@"Respitory Rate: %@", [jsonMessage valueForKey:@"respiration"]]];*/
                                   }
                                   else{
                                        [advc.complaintLabel setText:[dm valueForKey:@"message"]];
                                   }
                                   advc.navigationItem.title = [dm valueForKey:@"sentts"];
                                   /*[NSString stringWithFormat:@"%@ - %@ | %@ (%@) - %@", [dm valueForKey:@"fagency"], [dm valueForKey:@"fname"],
                                                                [dm valueForKey:@"funit"], [dm valueForKey:@"fphone_number"], [dm valueForKey:@"fip_addr"]];*/
                                   NSMutableDictionary* md = [[_objects objectAtIndex:indexPath.row] mutableCopy];
                                   if([[md valueForKey:@"read"] isKindOfClass:[NSNull class]]){
                                       [md setObject:@"true" forKey:@"read"];
                                       [_objects replaceObjectAtIndex:indexPath.row withObject:md];
                                       [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
                                       [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                                   }
                                   else{
                                       NSLog(@"Unable to set read");
                                       [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                                       [activityIndicatorView stopAnimating];
                                   }
                               }
                           }
                           else{
                               UIAlertView* alert;
                               alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                                  message:[NSString stringWithFormat:@"Unable to read message: %@", error.description]
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
                               [alert show];
                           }
                       }];
                       [activityIndicatorView stopAnimating];
                       tableView.userInteractionEnabled = TRUE;
                       
                       [self.detailViewController.atchCollectionView reloadData];
                       CATransition *detailViewAnimation = [CATransition animation];
                       [detailViewAnimation setType:kCATransitionPush];
                       [detailViewAnimation setSubtype:kCATransitionFade];
                       [detailViewAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                       [detailViewAnimation setFillMode:kCAFillModeBoth];
                       [detailViewAnimation setDuration:.5];
                       [[self.detailViewController.view layer] addAnimation:detailViewAnimation forKey:@"UITableViewReloadDataAnimationKey"];
                   }
                   else{
                       [activityIndicatorView stopAnimating];
                       tableView.userInteractionEnabled = TRUE;
                       
                       UIAlertView* alert;
                       alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                          message:[NSString stringWithFormat:@"Unable to getAtchHeaders (RCP ERROR): %@", [dres valueForKey:@"error"]]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
                       [alert show];
                   }
               }
               else{
                   [activityIndicatorView stopAnimating];
                   tableView.userInteractionEnabled = TRUE;

                   UIAlertView* alert;
                   alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                      message:[NSString stringWithFormat:@"Unable to getAtchHeaders (JSON ERROR): %@", jerror.description]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles: nil];
                   [alert show];
               }
            }
            else{
                [activityIndicatorView stopAnimating];
                tableView.userInteractionEnabled = TRUE;

               UIAlertView* alert;
               alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                  message:[NSString stringWithFormat:@"Unable to getAtchHeaders (NETWORK ERROR): %@", error.description]
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles: nil];
               [alert show];
            }
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
