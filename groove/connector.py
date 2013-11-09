"""
    Connector class to communicate with
    grooveshark API.
"""
import random
import string
import uuid
import hashlib
import json
import sys
import http.client


class Connector:
    token = None
    client = None
    js_queue = None
    url = "grooveshark.com"
    request_url = "/more.php"
    encoding = "utf-8"
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

    def __init__(self, client=None):
        """
            Initiliaze Connector

            Parameters:
                client: the http client
        """
        if client is not None:
            self.client = client
        else:
            self.client = http.client.HTTPSConnection(self.url)

        self.headers["session"] = ("".join(
            random.choice(
                string.digits + string.ascii_letters[:6]
            ) for x in range(32)
        )).lower()

        self.headers["uuid"] = str.upper(str(uuid.uuid4()))

        self.js_queue = [
            "jsqueue",
            "20130520",
            "chickenFingers"
        ]
        self.js_queue.append(
            {
                "User-Agent": self.html_client[3]["User-Agent"],
                "Referer": "http://%s/JSQueue.swf?%s" % (
                    self.url, self.js_queue[1]
                ),
                "Content-Type": "application/json"
            }
        )

    def get_token(self):
        """
            This method retrieves the local token for the session
            which is used to generate tokens for each request.
        """
        if (self.token is None):
            options = self.__get_request_options__()
            options["method"] = "getCommunicationToken"
            try:
                response = self.__execute_query__(
                    self.request_url,
                    options,
                    self.html_client[3]
                )
                self.token = response["result"]
            except Exception as inst:
                print("Unexpected error:", sys.exc_info()[0])
                raise inst

        return self.token

    def get_playlist_from_id(self, playlist_id):
        """
            Get playlist songs from playlist id

            Parameters:
                playlist_id: the playlist id
        """
        options = self.__get_request_options__()
        options["method"] = "getPlaylistByID"
        options["parameters"]["playlistID"] = playlist_id
        options["header"]["token"] = self.__prepare_token__(
            options["method"],
            self.html_client[2]
        )

        try:
            response = self.__execute_query__(
                self.request_url,
                options,
                self.html_client[3]
            )
            return response["result"]
        except Exception as inst:
            print("Unexpected error:", sys.exc_info()[0])
            raise inst

    def search(self, query, type="Songs"):
        """
            This method searches for a song using a provided search term

            Parameters:
                query: the search query
                type: the search type
                    (types are 'Songs', 'Artists', 'Albums' or 'Playlists')
        """
        haystack = ["Songs", "Artists", "Albums", "Playlists"]
        if (type not in haystack):
            type = "Songs"

        options = self.__get_request_options__()
        options["method"] = "getResultsFromSearch"
        options["parameters"]["query"] = query
        options["parameters"]["type"] = type
        options["header"]["token"] = self.__prepare_token__(
            options["method"],
            self.html_client[2]
        )

        try:
            response = self.__execute_query__(
                self.request_url,
                options,
                self.html_client[3]
            )
            return response["result"]["result"]
        except Exception as inst:
            print("Unexpected error:", sys.exc_info()[0])
            raise inst

    def get_stream_key_from_song_id(self, song_id):
        """
            Get the streamKey needed to request the download link to the MP3

            Parameters:
                song_id: the songID of the song you want to download.
        """
        options = self.__get_request_options__()
        options["parameters"]["type"] = 8
        options["parameters"]["mobile"] = False
        options["parameters"]["prefetch"] = False
        options["parameters"]["songID"] = song_id
        options["parameters"]["country"] = ",".join(self.headers["country"])
        options["header"]["client"] = self.js_queue[0]
        options["header"]["clientRevision"] = self.js_queue[1]
        options["method"] = "getStreamKeyFromSongIDEx"
        options["header"]["token"] = self.__prepare_token__(
            options["method"],
            self.js_queue[2]
        )

        try:
            response = self.__execute_query__(
                self.request_url,
                options,
                self.js_queue[3]
            )
            return response["result"]
        except Exception as inst:
            print("Unexpected error:", sys.exc_info()[0])
            raise inst

    def __get_request_options__(self):
        """
            Return request default options
        """
        options = {}
        options["parameters"] = {}
        options["parameters"]["secretKey"] = hashlib.md5(
            self.headers["session"].encode(self.encoding)
        ).hexdigest()
        options["header"] = self.headers.copy()
        options["header"]["client"] = self.html_client[0]
        options["header"]["clientRevision"] = self.html_client[1]
        options["header"]["Accept"] = "text/html"

        return options

    def __execute_query__(self, url, parameters, userAgent):
        """
            Execute query
            Parameters:
                url: Request url
                parameters: All requests parameters (headers, raw data, etc...)
                userAgent: the user agent
        """
        self.client.request(
            "POST",
            url,
            json.JSONEncoder().encode(parameters),
            userAgent
        )
        response = self.client.getresponse().read()
        return json.JSONDecoder().decode(response.decode(self.encoding))

    def __prepare_token__(self, method, secret):
        """
            Prepare token
            Parameters:
                method: Method name.
                secret: the secret key
        """
        rnd = ("".join(
            random.choice(string.hexdigits) for x in range(6)
        )).lower()
        s = "%s:%s:%s:%s" % (method, self.get_token(), secret, rnd)
        return rnd + hashlib.sha1(s.encode("utf-8")).hexdigest()
