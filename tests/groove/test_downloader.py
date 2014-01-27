import unittest
import os
import sys

from .mock_data import response_search
from .mock_data import response_get_playlist
from .mock_data import response_search_playlist
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
            self.path,
            self.subprocess
        )

    def tearDown(self):
        self.client = None
        self.connector = None

    def test_init_without_process(self):
        self.connector = Mock()
        self.path = os.path.dirname(os.path.realpath(__file__))
        self.downloader = Downloader(
            self.connector,
            self.path
        )

    def test_init_should_defined_config(self):
        self.assertIsInstance(self.downloader.connector, Mock)
        self.assertIsInstance(self.downloader.subprocess, Mock)
        self.assertEquals(self.path, self.downloader.output_directory)
        self.assertEquals([], self.downloader.download_queue)
        self.assertEquals(10, self.downloader.max_per_list)

    def test_download_song_without_stream_key(self):
        self.connector.get_stream_key_from_song_id.return_value = []
        result = self.downloader.download_song("filename.mp3", {"SongID": 1})
        self.assertEquals(
            sys.stdout.getvalue().strip(),
            '\x1b[36mDownloading: filename.mp3\x1b'
            '[0m\nFailed to retrieve stream key!'
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
            '\x1b[36mDownloading: filename.mp3\x1b'
            '[0m\n\x1b[32m\nDownloaded\x1b[0m'
        )
        self.connector.get_stream_key_from_song_id.assert_called_once_with(1)
        self.subprocess.Popen.assert_called_once_with(
            "wget --progress=dot --post-data=streamKey=DatKey "
            "-O \"filename.mp3\" \"http://127.0.0.1/stream.php\" "
            "2>&1 | grep --line-buffered \"%\" |"
            "sed -u -e \"s,\.,,g\" | awk '{printf(\"\b\b\b\b%4s\", $2)}'",
            shell=True
        )

        process.wait.assert_called_once_with()
        self.assertTrue(result)

    def test_download_playlist(self):
        self.downloader.download_queue = [{"PlaylistID": 1}]
        self.connector.get_stream_key_from_song_id.return_value = []
        response = response_search_playlist()
        self.connector.search.return_value = response["result"]
        response = response_get_playlist()
        self.connector.get_playlist_from_id.return_value = response["result"]
        self.downloader.download_playlist()
        self.assertEquals(
            self.downloader.download_queue,
            response["result"]["Songs"]
        )

    def test_download_playlist_with_id(self):
        self.downloader.download_queue = []
        self.connector.get_stream_key_from_song_id.return_value = []
        response = response_get_playlist()
        self.connector.get_playlist_from_id.return_value = response["result"]
        self.downloader.download_playlist(1337)
        self.assertEquals(
            self.downloader.download_queue,
            response["result"]["Songs"]
        )

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
            '\x1b[36mDownloading: filename.mp3\x1b'
            '[0m\n\x1b[31mDownload cancelled. File deleted.\x1b[0m'
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
        self.assertEquals(len(self.downloader.download_queue), 2)

        self.assertEqual(
            sys.stdout.getvalue().strip(),
            """+----+-----------------------------------------\
-+--------+---------------+
| id |                  Album                   | Artist |      Song     |
+----+------------------------------------------+--------+---------------+
| 0  | x                                        | crucia | shadow battle |
| 1  | CruciA                                   | CruicA |    Air Raid   |
+----+------------------------------------------+--------+---------------+
shadow battle added
+----+------------------------------------------+--------+----------+
| id |                  Album                   | Artist |   Song   |
+----+------------------------------------------+--------+----------+
| 2  | youtube                                  | CruciA | Lie 2 Me |
+----+------------------------------------------+--------+----------+
Lie 2 Me added"""



        )
        input.assert_called_with(
            "Press \"n\" for next page, "
            "\"Number id\" to add element in queue, "
            "\"q\" for quit and download: "
        )

    @patch("builtins.input",
           Mock(side_effect=["0", "n", "q"]))
    def test_prepare_playlist(self):
        query = "CruciA"
        type = "Playlists"
        response = response_search_playlist()
        self.connector.search.return_value = response["result"]
        self.downloader.max_per_list = 1
        self.downloader.prepare(query, type)
        self.assertEquals(len(self.downloader.download_queue), 1)

        self.assertEqual(
            sys.stdout.getvalue().strip(),
            "+----+------------------------------------------"
            "+------------------+----------+\n"
            "| id |                   Name                   "
            "|      Author      | NumSongs |\n"
            "+----+------------------------------------------"
            "+------------------+----------+\n"
            "| 0  | CruciAGoT                                "
            "| RAMBAUD PIERRE   |    41    |\n"
            "+----+------------------------------------------"
            "+------------------+----------+\n"
            "CruciAGoT"
        )
        input.assert_called_with(
            "Press \"n\" for next page, "
            "\"Number id\" to add element in queue, "
            "\"q\" for quit and download: "
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

    def test_download(self):
        result = self.downloader.download()
        self.assertFalse(result)
        response = response_search()
        self.connector.get_stream_key_from_song_id.return_value = []
        self.downloader.download_queue.append(response["result"]["result"][0])
        self.downloader.download_queue.append(response["result"]["result"][1])
        with patch("os.path.exists", Mock(return_value=False)):
            result = self.downloader.download()
            os.path.exists.assert_called_any_with(
                "%s/%s-%s.mp3" %
                (
                    self.downloader.output_directory,
                    "crucia",
                    "shadow battle"
                )
            )
            os.path.exists.assert_called_any_with(
                "%s/%s-%s.mp3" %
                (
                    self.downloader.output_directory,
                    "CruciA",
                    "Air Raid"
                )
            )
            self.assertTrue(result)
        with patch("os.path.exists", Mock(return_value=True)):
            result = self.downloader.download()
            os.path.exists.assert_called_any_with(
                "%s/%s-%s.mp3" %
                (
                    self.downloader.output_directory,
                    "crucia",
                    "shadow battle"
                )
            )
            os.path.exists.assert_called_any_with(
                "%s/%s-%s.mp3" %
                (
                    self.downloader.output_directory,
                    "CruciA",
                    "Air Raid"
                )
            )
            self.assertTrue(result)

    def test_has_downloaded_songs(self):
        self.assertFalse(self.downloader.has_downloaded())
        self.test_download_song()
        self.assertTrue(self.downloader.has_downloaded())
        self.assertEquals(1, self.downloader.download_count)
