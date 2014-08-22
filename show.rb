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

    #TODO: make check() here

    print 'New show name: '
    @new_show = '[' + $stdin.gets.chomp.split(' ').collect { |i| i.capitalize}.join(' ') + ']'
    puts @new_show

    print 'Season: '
    @new_season = 'season = ' + $stdin.gets.chomp
	  puts @new_season

    print 'Episode: ' 
		@new_episode = 'episode = ' + $stdin.gets.chomp
    puts @new_episode

    print 'Finished? (true/false): '
    @new_finished = 'finished = ' + $stdin.gets.chomp

    @space = "\n"
    @file_to_add_show = File.open(@file_name, 'a') # => to write only from the end of file

    # write to file using formatting as in config file
    @file_to_add_show.write(@space + @space + @new_show + @space + @new_season + @space \
                          + @new_episode + @space + @new_finished + @space)
    @file_to_add_show.close

    reset()
	end

	def checked_update(update)
    case update
      when 'season', 's', 'episode', 'e', 'finish', 'f', 'name', 'n'
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
           "#{group} #{"\u2799".encode('utf-8')} s.#{@config[group.to_s]['season']} ep.#{@config[group.to_s]['episode']}"
		end
  end

  def reset()
    @config = ParseConfig.new(@file_name)
    puts 'Reset finished.'
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

  ## TODO: organize 'private' section
  private :checked_update, :checked_show_number, :find_show_name
  private :update_season, :update_episode, :update_name
  private :reset, :sync
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
        show.add_show()

      when 'print', 'show', 'p', 's'
        show.print_shows()

      when 'modify', 'update', 'm', 'u'
        show.update()

      when 'exit', 'quit', 'e', 'q'
        exit

      else
        puts 'Try again!'
    end

  end

end