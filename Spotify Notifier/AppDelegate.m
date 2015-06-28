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
}

- (void)startTimer
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(setup) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSWorkspace sharedWorkspace] launchApplication:@"Spotify"];
    [self setup];

    NSTimer *timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(handleSpotifyTermination) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

}

- (void)updateTrackInfoFromSpotify:(NSNotification *)notification
{

    SpotifyClientApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    SpotifyClientTrack *spotifyTrack  = [spotify currentTrack];

    NSLog(@"notification payload: %@", notification.userInfo);

    if (![[notification.userInfo valueForKey:@"Player State"] isEqualToString:@"Playing"])
    {
        return;
    }

    if ([[spotifyTrack album] hasPrefix:@"http"])
    {
        NSLog(@"Album prefix = http (%@)", [spotifyTrack album]);
    }

    NSUserNotification *notif = [[NSUserNotification alloc] init];

    [notif setTitle:[spotifyTrack name]];
    [notif setInformativeText:[NSString stringWithFormat:@"%@ - %@", [spotifyTrack artist], [spotifyTrack album]]];
    [notif setDeliveryDate:[NSDate date]];

    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    
    [center scheduleNotification:notif];
}

@end