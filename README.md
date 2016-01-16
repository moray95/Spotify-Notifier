# Spotify Notifier

Spotify Notifier is a Mac OS X application that lets you receive notifications when the current song changes on Spotify.

You can directly launch Spotify Notifier without launching Spotify, it will launch Spotify for you and close itself when you close Spotify so you don't have to it manually.

Since it is a daemon app, you won't even be aware of it's existence. However, if you want to close it without quitting Spotify, you can always do it from Activity Monitor (Applications -> Utilities -> Application Monitor) or by running

`sudo killall Spotify\ Notifier`

from Terminal (Applications -> Utilities -> Terminal).

Spotify should be installed in Applications -> Spotify.app for this application to work properly.
