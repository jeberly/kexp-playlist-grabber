#!/usr/bin/env ruby

# USAGE:  To use run ./kexp for the last song information from KEXP.org radio station
# If you want more songs pass in a song number argument like > ./kexp 5   (for last 5 songs)
# author: John Eberly 

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'ostruct'

# TODO add output format options and launch options
class Kexp
  def self.grab(last)
    doc = Nokogiri::HTML(open('http://kexp.org/playlist/playlist.aspx'))
    tracks = doc.css('.song')
    meta = 0; songs = []; song = OpenStruct.new
    tracks.css('dd').each_with_index do |track, i|
      next if i == 0
      if track.css('dd').any?
        meta = 0
        songs << song
        song = OpenStruct.new
        next
      end
      meta += 1
      content = track.content.chomp
      case meta
        when 1 then song.time     = content
        when 2 then song.artist   = content
        when 3 then song.title    = content
        when 4 then song.album    = content
        when 6 then song.released = content
        when 7 then song.lable    = content
      end
    end
    songs << song
    songs[0..last-1].each{|s| puts [s.artist, s.title, s.album].delete_if(&:empty?).join(', ')}
  end
end

last_song_count = ARGV.first.to_i if ARGV.first
Kexp.grab(last_song_count || 1)