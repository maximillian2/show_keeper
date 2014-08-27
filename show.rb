# Author:: Maksym Tymoshyk (mailto:maxi.ua.1996@gmail.com)
# Copyright::  Copyright (c) 2014 maxi, @home

require 'parseconfig'

# This class holds information about watched shows and can write it to file.
# For further changes it can read information from file.

class Show

  # Remember file name and create instance of config file to work with
	def initialize(file)
		begin

			raise ArgumentError, 'No file name' if file.nil?
			raise SystemCallError, 'No such file' unless File.readable?(file)

			@file_name = file
			@config = ParseConfig.new(@file_name)

		rescue ArgumentError, SystemCallError
			puts "File name not specified or not correct. Maybe it doesn't exist at all."
			puts 'Choose one from available:'
			Dir.glob('*.txt').each {|i| print "#{i.split('.')[0]} "}
			puts; print '> '
			file = "#{$stdin.gets.chomp}.txt"
			retry
		end

	end

  # Write show to file and resets the file to see the changes
	def add_show(new_show, new_season, new_episode, new_finished)

    #TODO: make check() here

		@new_show = "\n[#{new_show}]\nseason = #{new_season.to_s}\nepisode = #{new_episode.to_s}\nfinished = #{new_finished}\n"

		@file = File.open(@file_name, 'a') # => write only from the end of file
		@file.write(@new_show)
		# @file_name = 'info.txt'
		@file.close unless @file.nil?

    reset()
	end

	# Validate number given for season/episode
	def check_limits(input)
		input.to_i < 99 && input.to_i > 1
	end

	# Print out greeting each iteration to look over the commands
	def greet()
		puts 'Available commands:'
		puts '{a}dd, {p}rint/{s}how, {u}pdate/{m}odify, {e}xit/{q}uit '
	end

	# Print out all shows in formatted way
	def print_shows()
		puts 'SHOWS:'
		@config.get_groups.each_with_index do |group, index|
			puts "#{index+1}) [#{@config[group.to_s]['finished'] == 'true' ? "\u2713".encode('utf-8') : "\u2717".encode('utf-8')}] #{group} #{"\u2799".encode('utf-8')} s.#{@config[group.to_s]['season']} ep.#{@config[group.to_s]['episode']}"
		end
	end


	# Toggles show to finished/unfinished state
	def finish(show_name)
		@config[show_name]['finished'] = @config[show_name]['finished'] == 'true' ?  'false' : 'true'
		sync()
	end

	# Ask for information what to update and then launch methods after validating input
	def update()
		print 'Show number: '
		show_number = $stdin.gets.chomp.to_i
		return unless checked_show_number(show_number)

		print 'New {s}eason, {e}pisode, show {n}ame or {f}inish (toggle) show: '
		update = $stdin.gets.chomp.downcase
		return unless checked_update(update)

		show_name = find_show_name(show_number)

		case update
			when 'season', 's'
				update_season(show_name)

			when 'episode', 'e'
				update_episode(show_name)

			when 'finish', 'f'
				finish(show_name)

			when 'name', 'n'
				update_name(show_name)

			else
				puts 'Try again!'
		end
	end

	private

  # Validate input for update section
	def checked_update(update)
    case update
      when 'season', 's', 'episode', 'e', 'finish', 'f', 'name', 'n'
        return true
      else
        return false
    end

	end

  # Validate number given for shows
	def checked_show_number(show_number)
	  return true if show_number < @config.get_groups.length+1
    false
  end

  # Find show name by show number
  def find_show_name(show_number)
    @config.get_groups.each_with_index do | group, index |
      if index+1 == show_number
       return group
      end
    end
  end

  # Reload the file given to apply changes
  def reset()
    @config = ParseConfig.new(@file_name)
    puts 'Reset finished.'
  end

  # Write changes to file. Similar to reset()
  def sync()
    file = File.open(@file_name, 'w')
    @config.write(file)
    puts 'Sync finished.'
    file.close
  end

  # Change season in given show
	def update_season(show_name)
    print 'New season: '
    updated_season = $stdin.gets.chomp
    return unless check_limits(updated_season)

    @config[show_name]['season'] = updated_season

    sync()

	end

  # Change episode number in given show
	def update_episode(show_name)
    print 'New episode: '
    updated_episode = $stdin.gets.chomp
    return unless check_limits(updated_episode)

    @config[show_name]['episode'] = updated_episode

    sync()

  end

  # Change show name in given show
  def update_name(show_name)
    # print 'New name: '
    # updated_name = $stdin.gets.chomp
    # @config.get_groups.each_with_index do |group, index|
    #   if group == show_name
    #     @config.get_groups[index] = updated_name
    #     break
    #   end
    # end
    #
    # ## ERROR HERE!!!1
    # sync()

	end

end		# class Show

if __FILE__ == $PROGRAM_NAME
  puts 'Welcome!'

	show = Show.new(ARGV[0])

	loop do
	  show.greet
    print 'Your action: '
    input = $stdin.gets.chomp
	
	  case input
			when 'add', 'a'

				print 'New show name: '
				new_show = $stdin.gets.chomp.split(' ').collect { |i| i.capitalize }.join(' ')

				if new_show.nil? || new_show.tr('0-9', '').empty?
					puts 'Name should consist letters. Try again'
					next
				end

				print 'Season: '
				new_season = $stdin.gets.chomp

				if new_season < '1'
					puts "Season number can't be less than 1"
					next
				elsif new_season > '30'
					print 'Seriously so long? (type again to continue): '
					new_season = $stdin.gets.chomp
				end

				print 'Episode: '
				new_episode = $stdin.gets.chomp

				print 'Finished? ({t}rue/{f}alse): '
				new_finished = $stdin.gets.chomp

				case new_finished
					when 't'
						new_finished = 'true'
					when 'f'
						new_finished = 'false'
					else
						new_finished
				end

				show.add_show(new_show, new_season, new_episode, new_finished)

      when 'print', 'show', 'p', 's'
        show.print_shows()
      when 'modify', 'update', 'm', 'u'
        show.update()
      when 'exit', 'quit', 'e', 'q'
        exit
      else
        puts 'Try again!'
    end # case section
  end # loop section
end # if section