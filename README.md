#Grooveshark song downloader

[![Build Status](https://travis-ci.org/PierreRambaud/groove-dl.png?branch=master)](https://travis-ci.org/PierreRambaud/groove-dl)

##Requirements

 * Ruby 1.9.3 or newer

##Installation

From RubyGems

```
$ gem install groove-dl
```

From Github

```
$ git clone https://github.com/PierreRambaud/groove-dl.git
$ cd groove-dl
$ bundle install
$ bundle exec rake install
```

## Usage

Run `groove-dl` and a gtk app will be displayed, you can:

* search for playlist or song
* add them to queue
* choose download directory
* download concurrently


In CLI mode:

```bash
$ groove-dl-cli --help
Usage: groove-dl [COMMAND] [OPTIONS]

Options:

    -v, --version       Shows the current version
    -p, --playlist      Playlist
    -s, --song          Song
    -o, --output        Output directory
    -h, --help          Display this help message.

Available commands:

  search   Search for something on GrooveShark

See `<command> --help` for more information on a specific command.
```

Search for song:
```bash
$ groove-dl-cli search --help
Usage: groove-dl search [OPTIONS]

Options:

    -p, --playlist      Playlist
    -s, --song          Song
    -h, --help          Display this help message.
```

## Running tests

To run unit tests:
`$ bundle exec rake spec`

To check code style:
`$ bundle exec rake rubocop`

To run all tests:
`$ bundle exec rake`

##Disclamer

You must have paid the song before download it, thus I'm not responsible for any violations this script does to Grooveshark's Terms Of Use.
This is just a project for learning how to create gtk app in ruby.


## License
See [LICENSE](LICENSE) file
