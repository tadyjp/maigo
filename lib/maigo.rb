# encoding: utf-8

require "maigo/version"
require 'nokogiri'

module Maigo

  def self.execute(dir)
    missing_controllers, missing_outlets = self.find_missing_outlets(dir)

    if missing_controllers.size == 0 && missing_outlets.size == 0
      puts 'Woot! No missing outlets!'
    end

    if missing_controllers.size > 0
      puts 'Missing ViewControllers:'
      missing_controllers.each do |missing_controller|
        puts "  #{missing_controller}"
      end
    end

    if missing_outlets.size > 0
      puts 'Missing Outlets:'
      missing_outlets.each do |missing_outlet|
        puts "  #{missing_outlet}"
      end
    end
  end

  def self.find_missing_outlets(dir)
    storyboard_outlet_hash = {}

    Dir.glob("#{dir}/**/*.storyboard") do |file|
      xml = Nokogiri::XML(open(file))

      xml.xpath('//viewController').each do |node|
        storyboard_outlet_hash[node["customClass"]] = []

        node.xpath("connections/outlet").each do |outlet|
          storyboard_outlet_hash[node["customClass"]] << outlet["property"]
        end
      end
    end

    source_outlet_hash = {}
    Dir.glob("#{dir}/**/*.swift") do |file|
      class_name = nil

      open(file).each do |line|
        if line =~ /class\s+(\w+)/
          class_name = $1
          if line =~ /class\s+var/ or line =~ /class\s+func/
            class_name = nil
            next
          end
        end
      end

      next if class_name.nil?

      source_outlet_hash[class_name] = []

      open(file).each do |line|
        if line =~ /@IBOutlet\s.*var\s(\w+)/
          outlet_name = $1
          next if line =~ /\/\/.*@IBOutlet/
          source_outlet_hash[class_name] << outlet_name
        end
      end
    end

    missing_controllers = []
    missing_outlets = []

    # compare outlets
    storyboard_outlet_hash.each do |controller, outlets|
      # find missing controllers
      if source_outlet_hash[controller].nil?
        missing_controllers << controller
        next
      end

      # find missing outlets
      outlets.each do |outlet|
        if !source_outlet_hash[controller].include?(outlet)
          missing_outlets << [controller, outlet]
        end
      end
    end

    return missing_controllers, missing_outlets
  end

end
