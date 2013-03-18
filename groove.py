#!/usr/bin/env python

import argparse

from classes.groove import groove
from classes.downloader import downloader

descriptionString = \
"""A Grooveshark song downloader
by Pierre Rambaud <http://rambaudpierre.fr>
"""
parser = argparse.ArgumentParser(description=descriptionString)
parser.add_argument("-p", "--playlist-id", help="Playlist id", type=int)
parser.add_argument("-s", "--search", help="Search song", type=int)

args = parser.parse_args()

groove = groove()
downloader = downloader(groove)

if(args.playlist_id != None):
    #Initiliaze token
    groove.getToken()
    playlist = groove.getPlaylistByID(args.playlist_id)
    downloader.downloadPlaylist(playlist["result"]["Name"], playlist["result"]["Songs"])
elif (args.search != None):
    #Initiliaze token
    groove.getToken()
    print "@TODO"
else:
    print "Nothing to do"

