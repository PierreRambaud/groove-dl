# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Download section
    module Download
      # List page
      module List
        # Queue tree
        class Queue < Gtk::Box
          attr_reader :store, :data
          attr_writer :downloader, :client
          attr_accessor :failed, :success, :queue

          COLUMN_PATH,
          COLUMN_PGBAR_VALUE,
          COLUMN_PGBAR_TEXT = *(0..2).to_a

          def load(client, window)
            @success = 0
            @failed = 0
            @queue = 0
            @client = client
            @window = window
            @data = {}
            @downloader = GrooveDl::Downloader.new(@client)
            @downloader.type = 'gui'

            sw = Gtk::ScrolledWindow.new
            sw.shadow_type = Gtk::ShadowType::ETCHED_IN
            sw.set_policy(Gtk::PolicyType::AUTOMATIC,
                          Gtk::PolicyType::AUTOMATIC)
            pack_start(sw, expand: true, fill: true, padding: 0)

            @store = Gtk::ListStore.new(String, Integer, String)
            create_model
            treeview = Gtk::TreeView.new(@store)
            treeview.rules_hint = true

            sw.add(treeview)

            add_columns(treeview)
          end

          def create_model(data = {})
            data.each do |id, element|
              if element.is_a?(Grooveshark::Song)
                iter = @store.append
                iter[COLUMN_PATH] =
                  @downloader.build_path(@window
                                           .find_by_name('directory_chooser')
                                           .filename,
                                         element)
                iter[COLUMN_PGBAR_VALUE] = 0
                iter[COLUMN_PGBAR_TEXT] = nil
                @data[element.id] = { iter: iter, song: element }
              else
                playlist = Grooveshark::Playlist.new(@client,
                                                     'playlist_id' => id)
                result = {}
                playlist.load_songs.each do |song|
                  result[song.id] = song
                end

                create_model(result)
              end
            end

            return if @data.empty?
            @queue = @data.count
            @window.find_by_name('download_book').set_label('QUEUE', @queue)
          end

          def add_columns(treeview)
            renderer = Gtk::CellRendererText.new
            column = Gtk::TreeViewColumn.new('Path',
                                             renderer,
                                             'text' => COLUMN_PATH)
            column.fixed_width = 650
            treeview.append_column(column)

            renderer = Gtk::CellRendererProgress.new
            column = Gtk::TreeViewColumn.new('Progress',
                                             renderer,
                                             value: COLUMN_PGBAR_VALUE,
                                             text: COLUMN_PGBAR_TEXT)
            column.fixed_width = 100
            treeview.append_column(column)
          end

          def download
            concurrency = @window.find_by_name('concurrency_entry').text.to_i
            concurrency = 5 if concurrency == 0
            Thread.abort_on_exception = true
            Thread.new do
              nb = 0
              @data.each do |_id, s|
                nb += 1
                Thread.new do
                  begin
                    @downloader.download(s[:song], s[:iter])
                    @window.find_by_name('download_success_list')
                      .create_model(s[:iter])
                    @window.find_by_name('download_book')
                      .set_label('SUCCESS', @success += 1)
                  rescue StandardError => e
                    GrooveDl.configuration.logger.error(e)
                    @window.find_by_name('download_failed_list')
                      .create_model(s[:iter], e.message)
                    @window.find_by_name('download_book')
                      .set_label('FAILED', @failed += 1)
                  end

                  @window.find_by_name('download_book')
                    .set_label('QUEUE', @queue -= 1)
                  @store.remove(s[:iter])

                  nb -= 1
                end
                sleep(0.5) until nb < concurrency
              end
            end
          end
        end
      end
    end
  end
end