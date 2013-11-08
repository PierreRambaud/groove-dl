"""
    Downloader class.
"""
import os


class Downloader:
    output_directory = None
    connector = None
    subprocess = None
    queue = None

    def __init__(self, connector, subprocess, output_directory):
        self.output_directory = output_directory
        self.connector = connector
        self.subprocess = subprocess
        self.songs_queue = []

    def download_song(self, filename, song):
        print("Downloading: %s" % (filename))
        stream_key = self.connector.get_stream_key_from_song_id(song["SongID"])
        if stream_key == []:
            print("Failed to retrieve stream key!")
            return False

        #Run wget to download the song
        wget = "wget --progress=dot --post-data=streamKey=%s" \
            " -0 \"%s\" \"http://%s/stream.php\"" % (
                stream_key["streamKey"], filename, stream_key["ip"]
            )
        cmd = wget + " 2>&1 | grep --line-buffered \"%\" | " \
            "sed -u -e \"s,\.,,g\" | awk '{printf(\"\b\b\b\b%4s\", $2)}'"
        process = self.subprocess.Popen(cmd, shell=True)

        try:
            process.wait()
        except KeyboardInterrupt:
            print("Download cancelled. File deleted.")
            os.remove(filename)
            return False

        return True
