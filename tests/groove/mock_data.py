def response_token():
    return {
        "header": {
            "session": "0af20ed02098635de4ffa3b62b36d02a",
            "prefetchEnabled": True,
            "serviceVersion": "20100903"
        },
        "result": "429897a7b29bcf01ac0b0483ffe7a7b3b2a49023"
    }


def response_get_playlist():
    return {
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


def response_search():
    return {
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
                    "SongID": "1337",
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
                    "SongID": "1337",
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
                    "SongID": "1337",
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


def response_search_playlist():
    return {
        "header": {
            "session": "98b040dffe126a40354e0469572746f3",
            "serviceVersion": "20100903",
            "prefetchEnabled": True
        },
        "result": [
            {
                'About': '',
                'Username': '',
                'Artists': '',
                'Name': 'CruciAGoT  ',
                'LName': '',
                'Picture': '9279288.jpg',
                'FName': 'RAMBAUD PIERRE  ',
                'Score': 205442.35021064,
                'NumSongs': '41',
                'SphinxSortExpr': 0,
                'PlaylistID': '91786079',
                'IsDeleted': '0',
                'NumArtists': '1',
                'UserID': '6696298',
                'TSAdded': '0'
            }
        ]
    }


def response_get_stream_key():
    return {
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
