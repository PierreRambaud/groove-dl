"""
    Downloader class.
"""
import os
import sys


class Downloader:
    output_directory = None
    connector = None
    subprocess = None
    download_queue = None
    download_count = None
    max_per_list = 10

    def __init__(self, connector, output_directory, subprocess=None):
        """
            Initiliaze Downloader

            Parameters:
                connector: connector to Grooveshark api
                subprocess: spawn new processes
                output_directory: where files will be downloaded
        """
        if subprocess is not None:
            self.subprocess = subprocess
        else:
            import subprocess
            self.subprocess = subprocess

        self.output_directory = output_directory
        self.connector = connector
        self.download_queue = []
        self.download_count = 0

    def download_playlist(self, playlist_id = None):
        """
            Download Playlist
        """
        songs = []
        if (playlist_id is not None):
            plist = self.connector.get_playlist_from_id(playlist_id)
            if ("Songs" in plist):
                songs = plist["Songs"]
        else:
            for playlist in self.download_queue:
                plist = self.connector.get_playlist_from_id(playlist['PlaylistID'])
                songs = songs + plist["Songs"]

        self.download_queue = songs
        self.download()

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
            " -O \"%s\" \"http://%s/stream.php\"" % (
                stream_key["streamKey"], filename, stream_key["ip"]
            )
        cmd = wget + " 2>&1 | grep --line-buffered \"%\" |" \
            "sed -u -e \"s,\.,,g\" | awk '{printf(\"\b\b\b\b%4s\", $2)}'"
        process = self.subprocess.Popen(cmd, shell=True)

        try:
            process.wait()
            self.download_count += 1
        except BaseException:
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
            "Press \"n\" for next page, "
            "\"Number id\" to add element in queue, "
            "\"q\" for quit and download: "
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
                if (type != "Playlists"):
                    print(
                        "%d - Album: %sSong: %s - %s" % (
                            idx,
                            data["AlbumName"].ljust(40),
                            data["ArtistName"],
                            data["SongName"]
                            if "SongName" in data else data["Name"]
                        )
                    )
                else:
                    print(
                        "%d - Playlist: %sAuthor: %s with %s songs" % (
                            idx,
                            data["Name"].ljust(40),
                            data["FName"],
                            data["NumSongs"]
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
                                added_data = result[key]
                                self.download_queue.append(added_data)
                                print(
                                    "%s added" %
                                    added_data["SongName"]
                                    if "SongName" in added_data
                                    else added_data["Name"]
                                )
                                continue
        except StopIteration:
            pass
        except Exception as inst:
            print("Unexpected error:", sys.exc_info()[0])
            raise inst

    def download(self):
        """
            Download files
        """
        if (self.download_queue != []):
            for file in self.download_queue:
                filename = (
                    "%s/%s - %s.mp3" %
                    (
                        self.output_directory,
                        file["ArtistName"],
                        file["SongName"]
                        if "SongName" in file else file["Name"]
                    )
                )

                if (os.path.exists(filename) is not True):
                    self.download_song(filename, file)
            return True
        return False

    def has_downloaded(self):
        return False if self.download_count == 0 else True
