"""
    Downloader class.
"""
import os
import sys


class Downloader:
    output_directory = None
    connector = None
    subprocess = None
    songs_queue = None
    max_per_list = 10

    def __init__(self, connector, subprocess, output_directory):
        """
            Initiliaze Downloader

            Parameters:
                connector: connector to Grooveshark api
                subprocess: spawn new processes
                output_directory: where files will be downloaded
        """
        self.output_directory = output_directory
        self.connector = connector
        self.subprocess = subprocess
        self.songs_queue = []

    def download_song(self, filename, song):
        """
            Download song

            Parameters:
                filename: the filename
                song: dictionary with song informations
        """
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

    def prepare(self, query, type=None):
        """
            Prepare downloads

            Parameters:
                query: the search query
                type: the search type
                    (types are 'Songs', 'Artists', 'Albums' or 'Playlists')
        """
        result = self.connector.search(query, type)
        self.__display_raw_input__(
            result,
            type,
            "Press \"n\" for next, "
            "\"Number\" for song id, "
            "\"q\" for quit and download songs: "
        )

    def __display_raw_input__(self, result, type, input_text):
        """
            Display prompt to choose songs, playlist, etc...

            Parameters:
                result: the result from the connector
                type: the search type
                    (types are 'Songs', 'Artists', 'Albums' or 'Playlists')
                input_text: texte for the raw input
        """
        try:
            for idx, data in enumerate(result):
                key = None
                if (type == "Songs"):
                    print(
                        "%d - Album: %sSong: %s - %s" % (
                            idx,
                            data["AlbumName"].ljust(40),
                            data["ArtistName"],
                            data["SongName"]
                        )
                    )

                is_last = (idx == (len(result) - 1))
                if ((idx != 0 and idx % self.max_per_list == 0) or is_last):
                    while (key is not False):
                        key = input(input_text)
                        if (key == "q"):
                            raise StopIteration
                        elif (key == "n" and is_last is False):
                            key = False
                        elif (key.isdigit()):
                            key = int(key)
                            if (key >= 0 and key <= len(result)):
                                added_song = result[key]
                                self.songs_queue.append(added_song)
                                print("Song %s added" % added_song["SongName"])
                                continue
        except StopIteration:
            pass
        except Exception as inst:
            print("Unexpected error:", sys.exc_info()[0])
            raise inst
