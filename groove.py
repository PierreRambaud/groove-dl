#!/usr/bin/env python
# This source file is part of groove-dl.
#
# groove-dl is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# groove-dl is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with groove-dl. If not, see <http://www.gnu.org/licenses/lgpl-3.0.html>.
#
# @author   Pierre Rambaud (GoT) http://rambaudpierre.fr
# @license  GNU/LGPL http://www.gnu.org/licenses/lgpl-3.0.html

import argparse

from classes.connector import connector
from classes.downloader import downloader

descriptionString = \
"""A Grooveshark song downloader
by Pierre Rambaud <http://pierrerambaud.com>
"""
parser = argparse.ArgumentParser(description=descriptionString)
parser.add_argument("-p", "--playlist-id", help="Playlist id", type=int)
parser.add_argument("-ss", "--search-song", help="Search songs", type=str)
parser.add_argument("-sa", "--search-artist", help="Search artists", type=str)
parser.add_argument("-sA", "--search-album", help="Search albums", type=str)
parser.add_argument("-sp", "--search-playlist", help="Search playlists", type=str)

args = parser.parse_args()

connector = connector()
downloader = downloader(connector)

if (args.playlist_id != None):
    #Initiliaze token
    connector.getToken()
    playlist = connector.getPlaylistByID(args.playlist_id)
    downloader.downloadPlaylist(playlist["Name"], playlist["Songs"])
    print "All songs have been download"
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
        connector.getToken()
        if (type =='Playlists'):
            downloader.preparePlaylists(query, type)
            for playlist in downloader.queue:
                playlist = connector.getPlaylistByID(playlist['PlaylistID'])
                downloader.downloadPlaylist(playlist["Name"], playlist["Songs"])
        else:
            #Initiliaze token
            downloader.prepareSongs(query, type)
            downloader.downloadQueue()
            print "All songs have been download"
    else:
        parser.print_help()

