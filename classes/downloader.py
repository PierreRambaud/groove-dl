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
            self.downloadSong(song, playlistDirectory)

    def downloadSong(self, song, playlistDirectory):
        print "Retrieving stream key.."
        #Get the StreamKey for the selected song
        stream = self.groove.getStreamKeyFromSongIDEx(song["SongID"])
        if stream == []:
            print "Failed"
            return
        #Run wget to download the song
        cmd = 'wget --post-data=streamKey=%s -O "%s/%s - %s.mp3" "http://%s/stream.php"' % (stream["streamKey"], playlistDirectory, song["ArtistName"], song["Name"], stream["ip"]) 
        process = subprocess.Popen(cmd, shell=True)
        #Starts a timer that reports the song as being played for over 30-35 seconds. May not be needed.
        markTimer = threading.Timer(30 + random.randint(0,5), self.groove.markStreamKeyOver30Seconds, [song["SongID"], self.getQueueID(), stream["ip"], stream["streamKey"]]) 
        markTimer.start()
        try:
            process.wait() #Wait for wget to finish
        except KeyboardInterrupt: #If we are interrupted by the user
            os.remove('%s - %s.mp3' % (song["ArtistName"], song["SongName"])) #Delete the song
            print "\nDownload cancelled. File deleted."
        markTimer.cancel()

    def getQueueID(self):
        return str(random.randint(10000000000000000000000,99999999999999999999999))
