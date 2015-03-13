# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Download bar section
    class Download < Events
      attr_accessor :search_list, :songs, :downloader
      attr_accessor :failed, :success, :queue

      attr_reader :queue_store, :failed_store, :success_store

      RIGHT_CLICK = 3

      SUCCESS_COLUMN_PATH,
      SUCCESS_COLUMN_SIZE = *(0..1).to_a

      FAILED_COLUMN_PATH,
      FAILED_COLUMN_REASON = *(0..1).to_a

      QUEUE_COLUMN_PATH,
      QUEUE_COLUMN_PGBAR_VALUE,
      QUEUE_COLUMN_PGBAR_TEXT = *(0..2).to_a

      ##
      # Initialize download list and download button
      #
      # @param [Grooveshark::Client] client Grooveshark client
      # @param [Gtk::Builder] app Application created by Gtk builder
      # @param [Search] search_list Search class for getting list
      #
      # @return [Download]
      #
      def initialize(client, app, search_list)
        super(client, app)
        @songs = {}
        @queue = 0
        @success = 0
        @failed = 0
        @search_list = search_list
        @downloader = GrooveDl::Downloader.new(@client)
        @downloader.type = 'gui'
        @app.get_object('directory_chooser').filename = Dir.tmpdir
      end

      ##
      # Event when button download is clicked
      #
      def on_btn_download_clicked
        return if @queue.zero?
        @app.get_object('btn_clear_queue').sensitive = false
        @app.get_object('btn_add_to_queue').sensitive = false

        download_songs
      end

      ##
      # Event when button clear queue is clicked
      #
      def on_btn_clear_queue_clicked
        @app.get_object('download_queue_list_store').clear
      end

      ##
      # Event when button add to queue is clicked
      #
      def on_btn_add_to_queue_clicked
        selected = {}
        column_id = GrooveDl::Widgets::Search::COLUMN_ID
        column_checkbox = GrooveDl::Widgets::Search::COLUMN_CHECKBOX
        search_list_store = @app.get_object('search_list_store')
        search_list_store.each do |_model, _path, iter|
          next unless iter[column_checkbox]
          selected[iter[column_id]] = @search_list.data[iter[column_id]]
          iter[column_checkbox] = false
        end

        @queue_store = @app.get_object('download_queue_list_store')
        @failed_store = @app.get_object('download_failed_list_store')
        @success_store = @app.get_object('download_success_list_store')
        create_queue_item(selected)

        @queue = @songs.count
        @app.get_object('download_label_queue')
          .set_text(format('Queue (%d)', @queue))
      end

      ##
      # Append row in queue list store
      #
      # @param [Hash] data Data parsed
      #
      def create_queue_item(data)
        data.each do |id, element|
          if element.is_a?(Grooveshark::Song)
            iter = @queue_store.append
            iter[QUEUE_COLUMN_PATH] =
              @downloader.build_path(@app.get_object('directory_chooser')
                                       .filename,
                                     element)
            iter[QUEUE_COLUMN_PGBAR_VALUE] = 0
            iter[QUEUE_COLUMN_PGBAR_TEXT] = nil
            @songs[element.id] = { iter: iter, song: element }
          else
            playlist = Grooveshark::Playlist.new(@client,
                                                 'playlist_id' => id)
            result = {}
            playlist.load_songs.each do |song|
              result[song.id] = song
            end

            create_queue_item(result)
          end
        end

        return if @songs.empty?
      end

      ##
      # Append row in failed list store
      #
      # @param [Gtk::TreeIter] i Iterable element
      # @param [String] reason Why this download have failed
      #
      def create_failed_item(i, reason)
        iter = @failed_store.append
        path = i[FAILED_COLUMN_PATH]
        iter[FAILED_COLUMN_PATH] = path
        iter[FAILED_COLUMN_REASON] = reason
      end

      ##
      # Append row in the success list store
      #
      # @param [Gtk::TreeIter] i Iterable element
      #
      def create_success_item(i)
        iter = @success_store.append
        path = i[SUCCESS_COLUMN_PATH]
        iter[SUCCESS_COLUMN_PATH] = path
        size = (File.size?(path).to_f / (1024 * 1024)).round(2)
        iter[SUCCESS_COLUMN_SIZE] = "#{size} MB"
      end

      ##
      # Download songs in queue
      #
      def download_songs
        concurrency = @app.get_object('concurrency_entry').text.to_i
        concurrency = 5 if concurrency.zero?
        Thread.abort_on_exception = true
        Thread.new do
          nb = 0
          @songs.each do |_id, s|
            nb += 1
            Thread.new do
              download_file(s)
              nb -= 1
            end
            sleep(0.5) until nb < concurrency
          end
        end
      end

      ##
      # Download song
      #
      # @param [Grooveshark::Song] song Song to download
      #
      def download_file(song)
        begin
          @downloader.download(song[:song], song[:iter])
          notify_success(song)
        rescue Errors::AlreadyDownloaded => e
          GrooveDl.configuration.logger.info(e.message)
          notify_success(song)
        rescue Grooveshark::GeneralError => e
          GrooveDl.configuration.logger.error(e)
          notify_error(song, e)
        end
        @app.get_object('download_label_queue')
          .set_text(format('Queue (%d)', @queue -= 1))
        @queue_store.remove(song[:iter])
      end

      ##
      # Notify success
      #
      # @param [Grooveshark::Song] song Song displayed in success page
      #
      def notify_success(song)
        create_success_item(song[:iter])
        @app.get_object('download_label_success')
          .set_text(format('Success (%d)', @success += 1))
      end

      ##
      # Notify erro
      #
      # @param [Grooveshark::Song] song Song displayed in failed page
      # @param [StandardError] e Exception to retrieve message
      #
      def notify_error(song, e)
        create_failed_item(song[:iter], e.message)
        @app.get_object('download_label_failed')
          .set_text(format('Failed (%d)', @failed += 1))
      end

      ##
      # Open downloaded song
      #
      def on_menu_open_activate
        treeview = @app.get_object('download_success')
        iter = treeview.selection.selected
        Thread.new do
          path = iter[Download::QUEUE_COLUMN_PATH]
          system("xdg-open #{Shellwords.escape(path)}")
        end
      end

      ##
      # Open menu on right click
      #
      def on_download_success_button_press_event(widget, event)
        return unless event.is_a?(Gdk::EventButton) &&
                      event.button == RIGHT_CLICK

        path, _model = widget.get_path_at_pos(event.x, event.y)
        widget.selection.select_path(path)
        @app.get_object('success_menu')
          .popup(nil, nil, event.button, event.time)
      end
    end
  end
end
