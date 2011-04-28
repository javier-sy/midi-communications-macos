#!/usr/bin/env ruby

module CoreMIDI

  module Entity

                # has the device been initialized?
    attr_reader :enabled,
                # unique Numeric id of the device
                :id,
                :name,
                # :input or :output
                :type

    alias_method :enabled?, :enabled

    def initialize(id, options = {}, &block)
      @name = options[:name]
      @id = id

      # cache the type name so that inspecting the class isn't necessary each time
      @type = self.class.name.split('::').last.downcase.to_sym

      @enabled = false
    end

    # select the first device of type <em>type</em>
    def self.first(type)
      all_by_type[type].first
    end

    # select the last device of type <em>type</em>
    def self.last(type)
      all_by_type[type].last
    end

    # a Hash of :input and :output devices
    def self.all_by_type
      available_devices = { :input => [], :output => [] }
      available_devices
    end

    # all devices of both types
    def self.all
    end

  end

end