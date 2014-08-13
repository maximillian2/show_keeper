#  show.rb
#  
#  Copyright 2014 maxi <maxi@toshiba>

require 'parseconfig'

class Show
	def initialize(file)
    @file_name = file
		@config = ParseConfig.new(@file_name)
	end
    
	def add_show()
    print 'New show name: '
    @new_show = gets.chomp.capitalize
	
    print 'Season: '
    @new_season = gets.chomp
	
    print 'Episode: ' 
		@new_episode = gets.chomp
    
		# add show
		# soon
	end

	def checked_update(update)
    case update
      when 'season', 's', 'episode', 'e', 'finish', 'f'
        return true
      else
        return false
    end

	end
	
	def checked_show_number(show_number)
	  return true if show_number < @config.get_groups.length+1
    false
  end

  def checked_limits(input)
    input.to_i < 99 && input.to_i > 1
  end

  def find_show_name(show_number)
    @config.get_groups.each_with_index do | group, index |
      if index+1 == show_number
       return group
      end
    end
  end

  def finish(show_name)
    if @config[show_name]['finished'] == 'true'
      @config[show_name]['finished'] = 'false'
    else
      @config[show_name]['finished'] = 'true'
    end

    sync()

  end

  def greet()
    puts 'Available commands:'
    puts '{a}dd, {p}rint/{s}how, {u}pdate/{m}odify, {e}xit/{q}uit '
  end

	def print_shows()
    puts 'SHOWS:'

    @config.get_groups.each_with_index do |group, index|
			puts "#{index+1}) [#{@config[group.to_s]['finished'] == 'true' ? "\u2713".encode('utf-8') : "\u2717".encode('utf-8')}] " \
           "#{group} -> s.#{@config[group.to_s]['season']} ep.#{@config[group.to_s]['episode']}"
		end
  end

  def sync()
    file = File.open(@file_name, 'w')
    @config.write(file)
    puts 'Sync finished.'
    file.close
  end

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
  
	def update_season(show_name)
    print 'New season: '
    updated_season = $stdin.gets.chomp
    return unless checked_limits(updated_season)

    @config[show_name]['season'] = updated_season

    sync()

	end
	
	def update_episode(show_name)
    print 'New episode: '
    updated_episode = $stdin.gets.chomp
    return unless checked_limits(updated_episode)

    @config[show_name]['episode'] = updated_episode

    sync()

  end

  def update_name(show_name)
    # soon
  end

  private :checked_update, :checked_show_number, :find_show_name, :update_season, :update_episode, :sync

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