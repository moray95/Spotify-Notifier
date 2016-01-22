//
//  AppDelegate.m
//
//  Created by Moray Baruh
//  Code based on https://gist.github.com/kwylez/5337918
//

#import "AppDelegate.h"
#import "SpotifyClient.h"

@interface AppDelegate()
- (void)updateTrackInfoFromSpotify:(NSNotification *)notification;
@end

@implementation AppDelegate

- (void)handleSpotifyTermination
{
  SpotifyClientApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];

  if (!spotify.isRunning)
  {
    [[NSApplication sharedApplication] terminate:nil];
  }
}

- (void)setup
{
  SpotifyClientApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];

  if (spotify.isRunning)
  {
    NSLog(@"Spotify Launched");
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];

    [dnc addObserver:self
            selector:@selector(updateTrackInfoFromSpotify:)
                name:@"com.spotify.client.PlaybackStateChanged"
              object:nil];
  }
  else
  {
    [self startTimer];
  }

  statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusBarItem setTitle:@"No song playing"];

}

- (void)startTimer
{
  NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(setup) userInfo:nil repeats:NO];
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  if(![[NSWorkspace sharedWorkspace] launchApplication:@"Spotify"])
  {
    NSUserNotification *notif = [[NSUserNotification alloc] init];

    [notif setTitle:@"Error launching Spotify"];
    [notif setInformativeText:@"Spotify couldn't be launched. Try to launch it manually and reopen Spotify Notifier."];
    [notif setDeliveryDate:[NSDate date]];

    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center setDelegate:self];
    [center scheduleNotification:notif];
    return;
  }
  [self setup];

  NSTimer *timer = [NSTimer timerWithTimeInterval:10
                                           target:self
                                         selector:@selector(handleSpotifyTermination)
                                         userInfo:nil repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)updateTrackInfoFromSpotify:(NSNotification *)notification
{

  SpotifyClientApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
  SpotifyClientTrack *spotifyTrack  = [spotify currentTrack];
  NSLog(@"notification payload: %@", notification.userInfo);
  NSLog(@"Track: %@", [spotifyTrack debugDescription]);
  if (![[notification.userInfo valueForKey:@"Player State"] isEqualToString:@"Playing"])
  {
    [statusBarItem setTitle:@"No song playing"];
    return;
  }

  NSUserNotification *notif = [[NSUserNotification alloc] init];

  [notif setTitle:[spotifyTrack name]];
  [notif setInformativeText:[NSString stringWithFormat:@"%@ - %@",
                             [spotifyTrack artist], [spotifyTrack album]]];
  [notif setDeliveryDate:[NSDate date]];
  [notif setContentImage:[spotifyTrack artwork]];
  NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
  [center setDelegate:self];
  [center scheduleNotification:notif];

  [statusBarItem setTitle:[NSString stringWithFormat:@"%@ - %@",
                           [spotifyTrack name], [spotifyTrack artist]]];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification
{
  [[NSWorkspace sharedWorkspace] launchApplication:@"Spotify"];
}

@end