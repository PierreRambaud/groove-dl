import unittest
import json
import http.client

from .mock_data import response_token
from .mock_data import response_get_playlist
from .mock_data import response_search
from .mock_data import response_get_stream_key
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
        self.mock_client(client_response=response_token())

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
        self.mock_client(client_response=response_get_playlist())
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
        self.mock_client(client_response=response_search())
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
        self.mock_client(client_response=response_get_stream_key())
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
