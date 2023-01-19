require_relative 'lib/game.rb'
require_relative 'lib/player.rb'

puts "Hangman"
puts "\nPlayer, what is your name?"
p1name = gets.chomp

puts "\n#{p1name}. Do you want to start a new game? Or load a saved file?"
puts "\nType 'new' to start a new game.\nType 'load' to load a saved file."

answer = gets.chomp.downcase

until answer == "new" || answer == "load"
    puts "\nError."
    puts "\n#{p1name}. Do you want to start a new game? Or load a saved file?"
    puts "\nType 'new' to start a new game.\nType 'load' to load a saved file."
    answer = gets.chomp.downcase
end

if answer == "new"
    puts "\nType 'play' when you are ready to start.\nType 'exit' to exit game."
    answer = gets.chomp.downcase
    until answer == "play" || answer == "exit"
        puts "\nError."
        puts "\nType 'play' when you are ready to start.\nType 'exit' to exit game."
        answer = gets.chomp.downcase
    end

    if answer == "play"
        puts "\nStarting new game..."
        game = Game.new(p1name)
        game.play
    elsif answer == "exit"
        exit
    end

elsif answer == "load"
    file_array = []
    puts "\nChoose a saved file by typing its name.\n "
    Dir.foreach("saved") do |file|
        file.slice!(".yaml")
        puts file
        file_array << file
    end
    chosen_file = gets.chomp
    until file_array.any? {|e| e == chosen_file}
        puts "\nError"
        puts "\n#{chosen_file} does not exist."
        puts "\nChoose a saved file by typing its name."
        chosen_file = gets.chomp
    end

    puts "\nLoading file: #{chosen_file}"

    puts "\nType 'play' when you are ready. Type 'exit' to exit program."
    answer = gets.chomp.downcase

    until answer == "play" || answer == "exit"
        puts "\nError"
        puts "\nType 'play' when you are ready. Type 'exit' to exit program."
        answer = gets.chomp.downcase
    end
    
    if answer == "play"
        
        game = Game.new()
        game.loading(chosen_file)
    elsif answer == "exit"
        exit
    end
end