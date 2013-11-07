import unittest
import json
import http.client

from groove import Connector
from mock import Mock
from mock import MagicMock


class TestConnector(unittest.TestCase):
    client = None
    default_token = "429897a7b29bcf01ac0b0483ffe7a7b3b2a49023"

    def setUp(self):
        self.client = Mock()
        self.connector = Connector(self.client)

    def tearDown(self):
        self.client = None
        self.connector = None

    def test_init_without_params(self):
        connector = Connector()
        assert connector is not None
        self.assertIsInstance(connector.client, http.client.HTTPSConnection)

    def test_headers_should_contains_some_values(self):
        headers = {
            "country": {
                "CC1": 72057594037927940,
                "CC2": 0,
                "CC3": 0,
                "CC4": 0,
                "ID": 57,
                "IPR": 0,
            },
            "privacy": 0,
        }

        for k, v in headers.items():
            self.assertEquals(self.connector.headers[k], v)

        self.assertTrue("session" in self.connector.headers)
        self.assertTrue("uuid" in self.connector.headers)
        self.assertEquals(4, len(self.connector.js_queue))
        html_client = (
            "htmlshark",
            "20130520",
            "nuggetsOfBaller",
            {
                "User-Agent": ("Mozilla/5.0 (X11; Linux x86_64; rv:17) "
                               "Gecko/20130917 Firefox/17 Iceweasel/17.0.29"),
                "Content-Type": "applicaiton/json"
            }
        )

        self.assertEquals(self.connector.html_client, html_client)

    def test_get_token_should_return_string(self):
        response = {
            "header": {
                "session": "0af20ed02098635de4ffa3b62b36d02a",
                "prefetchEnabled": True,
                "serviceVersion": "20100903"
            },
            "result": "429897a7b29bcf01ac0b0483ffe7a7b3b2a49023"
        }
        self.mock_client(client_response=response)

        result = self.connector.get_token()
        assert result is not None
        self.assertEquals("429897a7b29bcf01ac0b0483ffe7a7b3b2a49023", result)
        self.__assert_request_called__(
            "getCommunicationToken",
            ignore_token=True
        )

    def test_get_token_with_error_should_raise(self):
        self.mock_client(side_effect=Exception('foo'))
        self.assertRaises(Exception, lambda: self.connector.get_token())

    def test_get_playlist_from_id(self):
        self.connector.token = self.default_token
        response = {
            "header": {
                "session": "98b040dffe126a40354e0469572746f3",
                "serviceVersion": "20100903",
                "prefetchEnabled": True
            },
            "result": {
                "UUID": "52695089046d676a4e000000",
                "TSAdded": "2013-10-24 12:53:28",
                "About": "",
                "Picture": "9279288.jpg",
                "LastModifiedBy": 6696298,
                "TSModified": 1382633734,
                "Name": "CruciAGoT",
                "PlaylistID": 91786079,
                "SongCount": 1,
                "UserID": 6696298,
                "AlbumFiles": ["9279288.jpg"],
                "Songs": [{
                    "SongID": "37745712",
                    "Name": "Good Riddance",
                    "SongNameID": "4666",
                    "AlbumID": "1933324",
                    "AlbumName": "Nexus",
                    "ArtistID": "2543947",
                    "ArtistName": "CruciA",
                    "AvgRating": None,
                    "IsVerified": "0",
                    "CoverArtFilename": None,
                    "Year": None,
                    "EstimateDuration": None,
                    "Popularity": "1326600003",
                    "TrackNum": "0",
                    "IsLowBitrateAvailable": "1",
                    "Flags": "0"
                }],
                "FName": "RAMBAUD PIERRE",
                "LName": "",
                "Username": "RAMBAUD PIERRE"
            }
        }
        self.mock_client(client_response=response)
        result = self.connector.get_playlist_from_id(91786079)
        assert result is not None
        self.assertEquals("CruciAGoT", result["Name"])
        self.assertEquals(1382633734, result["TSModified"])
        self.assertEquals(91786079, result["PlaylistID"])
        self.__assert_request_called__(
            "getPlaylistByID",
            {"playlistID": 91786079}
        )

    def test_get_playlist_from_id_with_error_should_raise(self):
        self.connector.token = self.default_token
        self.mock_client(side_effect=Exception('foo'))
        self.assertRaises(
            Exception,
            lambda: self.connector.get_playlist_from_id(91786079)
        )

    def test_search(self):
        response = {
            "header": {
                "session": "98b040dffe126a40354e0469572746f3",
                "serviceVersion": "20100903",
                "prefetchEnabled": True
            },
            "result": {
                "assignedVersion": "HTP4PopArtist",
                "version": "HTP4PopArtist",
                "askForSuggestion": False,
                "result": [
                    {
                        "ArtistName": "crucia",
                        "Popularity": 1324200092,
                        "ArtistCoverArtFilename": "",
                        "Year": "1901",
                        "PopularityIndex": 92,
                        "AlbumName": "x",
                        "RawScore": 0,
                        "SongName": "shadow battle",
                        "TrackNum": "0",
                        "Flags": 0,
                        "ArtistID": "2538215",
                        "IsVerified": "0",
                        "AvgRating": "0.000000",
                        "CoverArtFilename": "",
                        "Score": 145249.67579683,
                        "Name": "crucia",
                        "AvgDuration": "0.000000",
                        "TSAdded": "1347696501",
                        "AlbumID": "8269643",
                        "EstimateDuration": "0.000000",
                        "IsLowBitrateAvailable": "1"
                    },
                    {
                        "ArtistName": "CruicA",
                        "Popularity": 1324200092,
                        "ArtistCoverArtFilename": "",
                        "Year": "2012",
                        "PopularityIndex": 92,
                        "AlbumName": "CruciA",
                        "RawScore": 0,
                        "SongName": "Air Raid",
                        "TrackNum": "0",
                        "Flags": 0,
                        "ArtistID": "2798613",
                        "IsVerified": "0",
                        "AvgRating": "0.000000",
                        "CoverArtFilename": "",
                        "Score": 30149.696062082,
                        "Name": "CruicA",
                        "AvgDuration": "0.000000",
                        "TSAdded": "1373768806",
                        "AlbumID": "9105345",
                        "EstimateDuration": "0.000000",
                        "IsLowBitrateAvailable": "0"
                    },
                    {
                        "ArtistName": "CruciA",
                        "Popularity": 1324200066,
                        "ArtistCoverArtFilename": "",
                        "Year": "1901",
                        "PopularityIndex": 66,
                        "AlbumName": "youtube",
                        "RawScore": 0,
                        "SongName": "Lie 2 Me",
                        "TrackNum": "0",
                        "Flags": 0,
                        "ArtistID": "2543947",
                        "IsVerified": "0",
                        "AvgRating": "0.000000",
                        "CoverArtFilename": "",
                        "Score": 145667.01263264,
                        "Name": "CruciA",
                        "AvgDuration": "0.000000",
                        "TSAdded": "1370870082",
                        "AlbumID": "9011717",
                        "EstimateDuration": "0.000000",
                        "IsLowBitrateAvailable": "0"
                    }
                ]
            }
        }
        self.mock_client(client_response=response)
        self.connector.token = self.default_token
        assert self.connector.search("CruciA", "Artists") is not None
        self.__assert_request_called__(
            "getResultsFromSearch",
            {"type": "Artists", "query": "CruciA"}
        )
        """
            Test method with wrong type
        """
        assert self.connector.search("CruciA", "Fake") is not None
        self.__assert_request_called__(
            "getResultsFromSearch",
            {"type": "Songs", "query": "CruciA"}
        )

    def test_search_with_error_should_raise(self):
        self.connector.token = self.default_token
        self.mock_client(side_effect=Exception('foo'))
        self.assertRaises(
            Exception,
            lambda: self.connector.search("CruciA", "Fake")
        )

    def test_get_stream_key(self):
        response = {
            "result": {
                "ts": 1383778597,
                "streamKey": "f168a9015788077db5b16913fb18d10ae3f"
                             "1603d_527ad02d_21b641b_2846ffc_0_9_8",
                "FileID": "42233852",
                "uSecs": "221000000",
                "ip": "stream79b.grooveshark.com",
                "FileToken": "4BOTr9",
                "Expires": 1383780397,
                "SongID": 35349531,
                "streamServerID": 1,
                "isMobile": False
            },
            "header": {
                "serviceVersion": "20100903",
                "prefetchEnabled": True,
                "session": "f562b1e5f438026eb35032d870d53901"
            }
        }

        self.mock_client(client_response=response)
        self.connector.token = self.default_token
        assert self.connector.get_stream_key_from_song_id(1337) is not None
        self.__assert_request_called__(
            "getStreamKeyFromSongIDEx",
            {
                "type": 8,
                "mobile": False,
                "prefetch": False,
                "songID": 1337,
                "country": ",".join(self.connector.headers["country"])
            },
            {
                "client": self.connector.js_queue[0],
                "clientRevision": self.connector.js_queue[1]
            }
        )

    def test_get_stream_key_with_error_should_raise(self):
        self.connector.token = self.default_token
        self.mock_client(side_effect=Exception('foo'))
        self.assertRaises(
            Exception,
            lambda: self.connector.get_stream_key_from_song_id(1337)
        )

    def mock_client(
        self,
        client_response={},
        status=200,
        side_effect=None,
        **kwargs
    ):
        response = Mock(side_effect=side_effect)
        response.status.return_value = status
        read = Mock()
        read.decode.return_value = json.dumps(client_response)
        response.read.return_value = read

        self.client.reset_mock()
        self.client.request.return_value = None
        self.client.getresponse.return_value = response

        return self.client

    def __assert_request_called__(
        self,
        method,
        other_parameters=(),
        other_headers=(),
        ignore_token=False,
        **kwargs
    ):
        self.client.request.assert_called_once()
        args = self.client.request.call_args[0]
        self.assertEquals("POST", args[0])
        self.assertEquals("/more.php", args[1])

        options = json.loads(args[2])
        self.assertTrue("parameters" in options)
        self.assertTrue("header" in options)
        self.assertTrue("client" in options["header"])
        self.assertTrue("clientRevision" in options["header"])
        if (ignore_token is False):
            self.assertTrue("token" in options["header"])

        self.assertEquals("text/html", options["header"]["Accept"])
        self.assertEquals(method, options["method"])

        for key in other_parameters:
            self.assertEquals(
                other_parameters[key],
                options["parameters"][key]
            )

        for key in other_headers:
            self.assertEquals(
                other_headers[key],
                options["header"][key]
            )
