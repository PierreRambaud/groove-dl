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
parser.add_argument("-ss", "--search-song", help="Search songs", type=str)
parser.add_argument("-sa", "--search-artist", help="Search artists", type=str)
parser.add_argument("-sA", "--search-album", help="Search albums", type=str)
parser.add_argument("-sp", "--search-playlist", help="Search playlists", type=str)

args = parser.parse_args()

groove = groove()
downloader = downloader(groove)

if (args.playlist_id != None):
    #Initiliaze token
    groove.getToken()
    playlist = groove.getPlaylistByID(args.playlist_id)
    downloader.downloadPlaylist(playlist["result"]["Name"], playlist["result"]["Songs"])
else:
    type = None
    query = None
    if (args.search_song != None):
        type = 'Songs'
        query = args.search_song
    elif (args.search_artist != None):
        type = 'Artists'
        query = args.search_artist
    elif (args.search_album != None):
        type = 'Albums'
        query = args.search_album
    elif (args.search_playlist != None):
        type = 'Playlists'
        query = args.search_playlist

    if (type != None and query != None):
        #Initiliaze token
        groove.getToken()
        print groove.getResultsFromSearch(query, type)
    else:
        print "Nothing to do"

