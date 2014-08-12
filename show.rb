#  show.rb
#  
#  Copyright 2014 maxi <maxi@toshiba>

require 'parseconfig'

class Show
	def initialize(file)
    @file_name = file
		@config = ParseConfig.new(file)
	end
    
	def add_show
    print 'New show name: '
    @new_show = gets.chomp.capitalize
	
    print 'Season: '
    @new_season = gets.chomp
	
    print 'Episode: ' 
		@new_episode = gets.chomp
    
		# add show
		# soon
	end

	def check_update(update)
		# soon
	end	
	
	def check_show_number(show_number)
		# soon
	end

  def checked_limits(input)
    input.to_i < 99 && input.to_i > 1
  end

  def finish(show_number)
    #soon
  end

  def greet
    puts 'Available commands:'
    puts '{a}dd, {p}rint/{s}how, {u}pdate/{m}odify, {e}xit/{q}uit '
  end

	def print_shows
    puts 'SHOES:'

    @config.get_groups.each_with_index do |group, index|
			puts "#{index+1}) [#{@config[group.to_s]['finished'] == 'true' ? "\u2713".encode('utf-8') : "\u2717".encode('utf-8')}] " \
           "#{group} -> s.#{@config[group.to_s]['season']} ep.#{@config[group.to_s]['episode']}"
		end
  end

  def sync

    file = File.open(@file_name, 'w')
    @config.write(file)
    puts 'Sync finished.'
    file.close
  end

  def update 
    print 'Show number: '
    show_number = $stdin.gets.chomp.to_i
		check_show_number(show_number)

    print 'New [s]eason, [e]pisode or [f]inish show: '
    update = $stdin.gets.chomp.downcase
		check_update(update)

    case update
      when 'season', 's'
        update_season(show_number)

      when 'episode', 'e'
        update_episode(show_number)

      when 'finish', 'f'
        finish(show_number)
      else
        puts 'Try again!'
    end
  end
  
	def update_season(show_number)
    print 'New season: '
    updated_season = $stdin.gets.chomp
    return unless checked_limits(updated_season)

    @config.get_groups.each_with_index do | group, index |
      if index+1 == show_number
        @config[group]['season'] = updated_season
        break
      end
    end

    sync()

	end
	
	def update_episode(show_number)
    print 'New episode: '
    updated_episode = $stdin.gets.chomp
    return unless checked_limits(updated_episode)

    @config.get_groups.each_with_index do | group, index |
      if index+1 == show_number
        @config[group]['episode'] = updated_episode
        break
      end
    end

    sync()

  end

  private :update_season, :update_episode, :check_update, :check_show_number, :sync

end		# class Show

if __FILE__ == $PROGRAM_NAME
  puts 'Welcome!'

	show = Show.new(ARGV[0])

	loop do
		# menu part 
    show.greet
    print 'Your action: '
    input = $stdin.gets.chomp
	
		# parse part
    case input
      when 'add', 'a'
        show.add_show

      when 'print', 'show', 'p', 's'
        show.print_shows

      when 'modify', 'update', 'm', 'u'
        show.update

      when 'exit', 'quit', 'e', 'q'
        exit

      else
        puts 'Incorrect input!'
    end

  end

end