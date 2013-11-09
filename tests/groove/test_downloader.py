import unittest
import os
import sys

from .mock_data import response_search
from groove import Downloader
from mock import Mock
from mock import MagicMock
from mock import patch


class testDownloader(unittest.TestCase):
    downloader = None
    connector = None
    subprocess = None
    path = None

    def setUp(self):
        self.connector = Mock()
        self.subprocess = Mock()
        self.path = os.path.dirname(os.path.realpath(__file__))
        self.downloader = Downloader(
            self.connector,
            self.subprocess,
            self.path
        )

    def tearDown(self):
        self.client = None
        self.connector = None

    def test_init_should_defined_config(self):
        self.assertIsInstance(self.downloader.connector, Mock)
        self.assertIsInstance(self.downloader.subprocess, Mock)
        self.assertEquals(self.path, self.downloader.output_directory)
        self.assertEquals([], self.downloader.songs_queue)
        self.assertEquals(10, self.downloader.max_per_list)

    def test_download_song_without_stream_key(self):
        self.connector.get_stream_key_from_song_id.return_value = []
        result = self.downloader.download_song("filename.mp3", {"SongID": 1})
        self.assertEquals(
            sys.stdout.getvalue().strip(),
            "Downloading: filename.mp3\n"
            "Failed to retrieve stream key!"
        )
        self.connector.get_stream_key_from_song_id.assert_called_once_with(1)
        self.assertFalse(result)

    def test_download_song(self):
        self.connector.get_stream_key_from_song_id.return_value = {
            "ip": "127.0.0.1",
            "streamKey": "DatKey"
        }
        process = Mock()
        process.wait.return_value = True
        self.subprocess.Popen.return_value = process

        result = self.downloader.download_song("filename.mp3", {"SongID": 1})
        self.assertEquals(
            sys.stdout.getvalue().strip(),
            "Downloading: filename.mp3"
        )
        self.connector.get_stream_key_from_song_id.assert_called_once_with(1)
        self.subprocess.Popen.assert_called_once_with(
            "wget --progress=dot --post-data=streamKey=DatKey "
            "-0 \"filename.mp3\" \"http://127.0.0.1/stream.php\" "
            "2>&1 | grep --line-buffered \"%\" | "
            "sed -u -e \"s,\.,,g\" | awk '{printf(\"\b\b\b\b%4s\", $2)}'",
            shell=True
        )

        process.wait.assert_called_once_with()
        self.assertTrue(result)

    @patch("os.remove", Mock(return_value=None))
    def test_download_song_with_error_should_exit(self):
        self.connector.get_stream_key_from_song_id.return_value = {
            "ip": "127.0.0.1",
            "streamKey": "DatKey"
        }

        process = Mock()
        process.wait.side_effect = KeyboardInterrupt("foo")
        self.subprocess.Popen.return_value = process
        result = self.downloader.download_song("filename.mp3", {"SongID": 1})
        process.wait.assert_called_once_with()
        self.assertEquals(
            sys.stdout.getvalue().strip(),
            "Downloading: filename.mp3\n"
            "Download cancelled. File deleted."
        )
        os.remove.assert_called_once_with("filename.mp3")
        self.assertFalse(result)

    @patch("builtins.input",
           Mock(side_effect=["0", "n", "n", "200", "2", "q"]))
    def test_prepare_songs(self):
        query = "CruciA"
        type = "Songs"
        response = response_search()
        self.connector.search.return_value = response["result"]["result"]
        self.downloader.max_per_list = 1
        self.downloader.prepare(query, type)
        self.connector.search.assert_called_once_with(query, type)

        self.assertEquals(
            sys.stdout.getvalue().strip(),
            "0 - Album: x                                 "
            "      Song: crucia - shadow battle\n"
            "1 - Album: CruciA                            "
            "      Song: CruicA - Air Raid\n"
            "Song shadow battle added\n"
            "2 - Album: youtube                           "
            "      Song: CruciA - Lie 2 Me\n"
            "Song Lie 2 Me added"
        )
        input.assert_called_with(
            "Press \"n\" for next, "
            "\"Number\" for song id, "
            "\"q\" for quit and download songs: "
        )

    @patch("builtins.input", Mock(side_effect=["0", "n", "2", "q"]))
    def test_prepare_songs_with_error_should_raise(self):
        query = "CruciA"
        type = "Songs"
        response = response_search()
        self.connector.search.return_value = response["result"]["result"]
        input.side_effect = Exception('foo')
        self.assertRaises(
            Exception,
            lambda: self.downloader.prepare(query, type)
        )
