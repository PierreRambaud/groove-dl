import os
import subprocess
import threading
import random

class downloader:
    #Current directory
    currentDirectory = None
    #Groove
    groove = None

    def __init__(self, groove):
        self.currentDirectory = os.getcwd()
        self.groove = groove

    def downloadPlaylist(self, name, songs):
        playlistDirectory = self.currentDirectory + '/songs/playlists/' + name
        if (os.path.exists(playlistDirectory) != True):
            os.mkdir(playlistDirectory)

        for song in songs:
            filename = '%s/%s - %s.mp3' % (playlistDirectory, song["ArtistName"], song["Name"])
            print ('Download %s' % (filename))
            if (os.path.exists(filename) != True):
                self.downloadSong(song, playlistDirectory, filename)

    def downloadSong(self, song, playlistDirectory, filename):
        #Get the StreamKey for the selected song
        stream = self.groove.getStreamKeyFromSongIDEx(song["SongID"])
        if stream == []:
            print "Failed"
            return
        #Run wget to download the song
        cmd = 'wget --progress=bar:force --post-data=streamKey=%s -O "%s" "http://%s/stream.php"' % (stream["streamKey"], filename, stream["ip"]) 
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
