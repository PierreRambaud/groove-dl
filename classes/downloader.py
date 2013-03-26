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

import os
import subprocess
import threading
import random
import time

class downloader:
    #Current directory
    currentDirectory = None
    #Groove
    groove = None
    #song in queue
    queue = []
    #Time between download
    sleepTime = 10

    def __init__(self, groove):
        self.currentDirectory = os.getcwd()
        self.groove = groove

    def downloadPlaylist(self, name, songs):
        playlistDirectory = self.currentDirectory + '/playlists/' + name
        if (os.path.exists(playlistDirectory) != True):
            os.mkdir(playlistDirectory)

        for idx, song in enumerate(songs):
            filename = '%s/%s - %s.mp3' % (playlistDirectory, song["ArtistName"], song["Name"])
            if (os.path.exists(filename) != True):
                self.downloadSong(song, filename)
                self.waitForNext(idx, songs)

    def downloadSong(self, song, filename):
        print ('Download %s' % (filename))
        #Get the StreamKey for the selected song
        stream = self.groove.getStreamKeyFromSongIDEx(song["SongID"])
        if stream == []:
            print "Failed"
            return
        #Run wget to download the song
        wget = "wget --progress=dot --post-data=streamKey=%s -O \"%s\" \"http://%s/stream.php\"" % (stream["streamKey"], filename, stream["ip"])
        cmd = wget + " 2>&1 | grep --line-buffered \"%\" | sed -u -e \"s,\.,,g\" | awk '{printf(\"\b\b\b\b%4s\", $2)}'"
        process = subprocess.Popen(cmd, shell=True)
        #Starts a timer that reports the song as being played for over 30-35 seconds. May not be needed.
        markTimer = threading.Timer(30 + random.randint(0,5), self.groove.markStreamKeyOver30Seconds, [song["SongID"], self.getQueueID(), stream["ip"], stream["streamKey"]]) 
        markTimer.start()
        try:
            #Wait for wget to finish
            process.wait()
        #If we are interrupted by the user
        except KeyboardInterrupt:
            os.remove(filename) #Delete the song
            print "\nDownload cancelled. File deleted."
            markTimer.cancel()
            exit()

    def getQueueID(self):
        return str(random.randint(10000000000000000000000,99999999999999999999999))

    def prepareSongs(self, query, type):
        songs = self.groove.getResultsFromSearch(query, type)
        for idx, song in enumerate(songs):
            result = None
            songName = ('%d - Album: %sSong: %s - %s' % (idx, song['AlbumName'].ljust(40), song['ArtistName'], song['SongName']))
            print songName
            if ((idx != 0 and idx % 10 == 0) or idx == len(songs) - 1):
                while (result not in ["n", "q"]):
                    result = raw_input('Press "n" for next, "Number" for song id, "q" for quit and download songs: ')
                    if (result.isdigit()):
                        if (int(result) >= 0 and int(result) <= len(songs)):
                            self.queue.append(songs[int(result)])
                            print "Song added"

            if (result == "q"):
                break;
            elif (result == "n"):
                continue

    def preparePlaylist(self, query, type):
        playlists = self.groove.getResultsFromSearch(query, type)
        for idx, playlist in enumerate(playlists):
            result = None
            playlistName = ('%d - Playlist: %sAuthor: %s' % (idx, playlist['Name'].ljust(40), playlist['FName']))
            print playlistName
            if ((idx != 0 and idx % 10 == 0) or idx == len(playlists) - 1):
                while (result not in ["n", "q"]):
                    result = raw_input('Press "n" for next, "Number" for playlist id: ')
                    if (result.isdigit()):
                        if (int(result) >= 0 and int(result) <= len(playlists)):
                            self.queue.append(playlists[int(result)])
                            print "Playlist will be downloaded"
                            break;
            elif (result == "n"):
                continue

    def downloadQueue(self):
        if (self.queue != []):
            for idx, song in enumerate(self.queue):
                filename = '%s/%s - %s.mp3' % (self.currentDirectory + '/songs', song["ArtistName"], song["SongName"])
                if (os.path.exists(filename) != True):
                    self.downloadSong(song, filename)
                    self.waitForNext(idx, self.queue)

    def waitForNext(self, idx, songs):
        if (idx + 1 < len(songs)):
            #Wait for next download
            print "Wait for next download"
            time.sleep(self.sleepTime)

