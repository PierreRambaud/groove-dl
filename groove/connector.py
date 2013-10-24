# This source file is part of groove-dl.
#
# groove-dl is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# groove-dl is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General
# Public License along
# with groove-dl. If not, see <http://www.gnu.org/licenses/lgpl-3.0.html>.
#
# @author   Pierre Rambaud (GoT) http://pierrerambaud.com
# @license  GNU/LGPL http://www.gnu.org/licenses/lgpl-3.0.html

import re
import io
import uuid
import random
import http.client
import string
import hashlib
import json
import gzip
import os
import sys


class Connector:
    #Grooveshark url
    url = "grooveshark.com"
    #Static headers
    headers = {}
    #Contains all the information posted with the htmlshark client
    htmlClient = (
        "htmlshark",
        "20130520",
        "nuggetsOfBaller",
        {
            "User-Agent": ("Mozilla/5.0 (X11; Linux x86_64; rv:10.0.12) "
                           "Gecko/20100101 Firefox/10.0.12 Iceweasel/10.0.12"),
            "Content-Type": "application/json"
        }
    )
    #Js queue
    jsqueue = ["jsqueue", "20130520", "chickenFingers"]
    #Token
    token = None

    encoding = "utf-8"

    def __init__(self):
        #Setting the static header (country, session and uuid)
        self.headers["country"] = {}
        self.headers["country"]["CC1"] = 72057594037927940
        self.headers["country"]["CC2"] = 0
        self.headers["country"]["CC3"] = 0
        self.headers["country"]["CC4"] = 0
        self.headers["country"]["ID"] = 57
        self.headers["country"]["IPR"] = 0
        self.headers["privacy"] = 0
        self.headers["session"] = ("".join(
            random.choice(
                string.digits + string.ascii_letters[:6]
            ) for x in range(32)
        )).lower()
        self.headers["uuid"] = str.upper(str(uuid.uuid4()))
        #Contains all the information specific to jsqueue
        self.jsqueue.append(
            {
                "User-Agent": self.htmlClient[3]["User-Agent"],
                "Referer": "http://%s/JSQueue.swf?%s" % (
                    self.url, self.jsqueue[1]
                ),
                "Content-Type": "application/json"
            }
        )

    """
    Retrieve the local token for the session which is used
    to generate tokens for each request.
    """
    def getToken(self):
        if (self.token is None):
            parameters = self.getRequestParameters()
            parameters["method"] = "getCommunicationToken"
            response = self.executeQuery(
                "/more.php",
                parameters,
                self.htmlClient[3]
            )
            self.token = response["result"]

        return self.token

    """
    Gets songs of a playlist
    """
    def getPlaylistByID(self, playlistID):
        parameters = self.getRequestParameters()
        parameters["method"] = "getPlaylistByID"
        parameters["parameters"]["playlistID"] = playlistID
        parameters["header"]["token"] = self.prepareToken(
            parameters["method"],
            self.htmlClient[2]
        )
        return self.executeQuery(
            "/more.php?" + parameters["method"],
            parameters,
            self.htmlClient[3]
        )["result"]

    """
    Prepare request parameters
    """
    def getRequestParameters(self):
        parameters = {}
        parameters["parameters"] = {}
        parameters["parameters"]["secretKey"] = hashlib.md5(
            self.headers["session"].encode(self.encoding)
        ).hexdigest()
        parameters["header"] = self.headers
        parameters["header"]["client"] = self.htmlClient[0]
        parameters["header"]["clientRevision"] = self.htmlClient[1]
        parameters["header"]["Accept"] = "text/html"
        return parameters

    """
    Execute query
    """
    def executeQuery(self, url, parameters, userAgent):
        try:
            conn = http.client.HTTPSConnection(self.url)
            conn.request(
                "POST",
                url,
                json.JSONEncoder().encode(parameters),
                userAgent
            )
            response = conn.getresponse().read()
            return json.JSONDecoder().decode(response.decode(self.encoding))
        except:
            print("Unexpected error:", sys.exc_info()[0])
            raise

    """
    Prepare token
    """
    def prepareToken(self, method, secret):
        rnd = ("".join(
            random.choice(string.hexdigits) for x in range(6)
        )).lower()
        s = "%s:%s:%s:%s" % (method, self.getToken(), secret, rnd)
        return rnd + hashlib.sha1(s.encode("utf-8")).hexdigest()

    """
    Get the streamKey needed to request the download link to the MP3
    """
    def getStreamKeyFromSongIDEx(self, songID):
        parameters = self.getRequestParameters()
        parameters["parameters"]["type"] = 8
        parameters["parameters"]["mobile"] = False
        parameters["parameters"]["prefetch"] = False
        parameters["parameters"]["songID"] = songID
        parameters["parameters"]["country"] = ",".join(self.headers["country"])
        parameters["header"]["client"] = self.jsqueue[0]
        parameters["header"]["clientRevision"] = self.jsqueue[1]
        parameters["method"] = "getStreamKeyFromSongIDEx"
        parameters["header"]["token"] = self.prepareToken(
            parameters["method"],
            self.jsqueue[2]
        )
        return self.executeQuery(
            "/more.php?" + parameters["method"],
            parameters,
            self.jsqueue[3]
        )["result"]

    """
    Tell Grooveshark that the client has played at
    least 30 seconds of the song.
    """
    def markStreamKeyOver30Seconds(
        self,
        songID,
        songQueueID,
        streamServer,
        streamKey
    ):
        parameters = self.getRequestParameters()
        parameters["parameters"]["songQueueID"] = songQueueID
        parameters["parameters"]["streamServerID"] = streamServer
        parameters["parameters"]["songID"] = songID
        parameters["parameters"]["streamKey"] = streamKey
        parameters["parameters"]["songQueueSongID"] = 1
        parameters["header"]["client"] = self.jsqueue[0]
        parameters["header"]["clientRevision"] = self.jsqueue[1]
        parameters["method"] = "markStreamKeyOver30Seconds"
        parameters["header"]["token"] = self.prepareToken(
            parameters["method"],
            self.jsqueue[2]
        )
        return self.executeQuery(
            "/more.php?" + parameters["method"],
            parameters,
            self.jsqueue[3]
        )["result"]

    def getResultsFromSearch(self, query, type):
        haystack = ["Songs", "Artists", "Albums", "Playlists"]
        if (type not in haystack):
            type = "Songs"

        parameters = self.getRequestParameters()
        parameters["method"] = "getResultsFromSearch"
        parameters["parameters"]["query"] = query
        parameters["parameters"]["type"] = type
        parameters["header"]["token"] = self.prepareToken(
            parameters["method"],
            self.htmlClient[2]
        )
        return self.executeQuery(
            "/more.php?" + parameters["method"],
            parameters,
            self.htmlClient[3]
        )["result"]["result"]
