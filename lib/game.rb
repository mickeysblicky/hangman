require_relative 'player.rb'
require 'yaml'
$alphabet = ('a'..'z').to_a

class Game

    def initialize(name="Player", file="File not created", hangman="______\n|     |\n|     \n|     \n|     \n|", random_word="", wrong=0, board_array=[], guesses=[])
        @name = name
        @file = file
        @hangman = hangman
        @random_word = random_word
        @wrong = wrong
        @board_array = board_array
        @guesses = guesses
    end

    def rng
        @file_size = File.foreach("words_5-12.txt").count
        @index = 0
        
        @random = Random.rand(1..@file_size)
        
        File.foreach("words_5-12.txt") do |word|
            @index += 1
            next if @index != @random
            @random_word = word.chomp
        end 
        adding_word_board(@random_word)
    end

    def adding_word_board(word)
        word_size = word.length
        for a in 1..word_size
            @board_array << "_"
        end
    end

    def reset_word_board
        @board_array = []
    end

    def reset_hanging_man 
        @hangman = "______\n|     |\n|     \n|     \n|     \n|"
        @wrong = 0
    end

    def reset_guesses
        @guesses = []
    end

    def show_boards
        puts @hangman
        puts "\n#{@board_array.join(" ")}"
        puts "\nYour guesses: #{@guesses.join(" ")}"
    end

    def show_files
        puts "\nCurrent file: #{@file}"
        Dir.foreach("saved") do |file|
            file.slice!(".yaml")
            puts file
        end
    end

    def add_body_parts(count)

        if count == 0
            show_boards()

        elsif count == 1
            @hangman.insert(21, "0")
            puts "\nadded head\n"
            show_boards()

        elsif count == 2
            @hangman.insert(28, "/")
            puts "\nadded left arm\n"
            show_boards()

        elsif count == 3
            @hangman.insert(29, "|")
            puts "\nadded back\n"
            show_boards()

        elsif count == 4
            @hangman.insert(30, "\\")
            puts "\nadded right arm\n"
            show_boards()

        elsif count == 5
            @hangman.insert(38, "/")
            puts "\nadded left leg\n"
            show_boards()

        elsif count == 6
            @hangman.insert(40, "\\")
            puts "\nadded right leg\n"
            show_boards()
        end
    end
    
    def play
        rng()
        make_guess()
    end

    def loading(file)
        chosen_file = file.insert(-1, ".yaml")
        puts "Loading..."
        contents = YAML.load(File.read("saved/#{chosen_file}"))
        start_loaded_game(contents)
    end

    def start_loaded_game(hash)
        game = Game.new(hash[:name], hash[:file], hash[:hangman], hash[:random_word], hash[:wrong], hash[:board_array], hash[:guesses])
        game.make_guess
    end

    def make_guess
        puts "\nType 'save' if you want to save the game at anytime."
        puts "\nType 'exit' if you want to exit the game at anytime."
        show_boards()
        until over?()
            puts "\n#{@name}. What letter do you want to guess.\n"
            guess = gets.chomp.downcase
            if guess == "save"
                puts "\nSaving..."
                puts "\nType 'cancel' if you want to cancel saving.\n \nPress 'enter' to continue saving."
                answer = gets.chomp.downcase
                if answer == "cancel"
                    puts "Canceling..."
                    next
                end
                puts "\nWhat do you want to call the saved file? Or save to an existing file."

                show_files()

                saved_file = gets.chomp
                to_yaml(saved_file)
                save_file(saved_file, @yams)
            elsif guess == "exit"
                exit
            else
                
                until guess.length == 1 && $alphabet.any? {|e| e == guess} == true && @guesses.any?(guess) == false

                    if guess.length != 1
                        puts "\nError."
                        puts "\nGuess must be a single letter."
                        show_boards()
                        puts "\n#{@name}. What letter do you want to guess?\n"
                        guess = gets.chomp.downcase
                    elsif @guesses.any?(guess) == true
                        puts "\nError."
                        puts "\nYou already guessed #{guess}."
                        show_boards()
                        puts "\n#{@name}. What letter do you want to guess?\n"
                        guess = gets.chomp.downcase
                    elsif $alphabet.any? {|e| e == guess} == false
                        puts "\nError."
                        puts "\nGuess must be a letter."
                        show_boards()
                        puts "\n#{@name}. What letter do you want to guess?\n"
                        guess = gets.chomp.downcase
                    end

                    if guess == "save"
                        puts "\nSaving..."
                        puts "\nType 'cancel' if you want to cancel saving.\n \nPress 'enter' to continue saving."
                        answer = gets.chomp.downcase
                        if answer == "cancel"
                            puts "Canceling..."
                            break
                        end
                        puts "\n#{@name}. What do you want to call the saved file? Or save to an existing file."
                        saved_file = gets.chomp
                        to_yaml(saved_file)
                        save_file(saved_file, @yams)

                    elsif guess == "exit"
                        exit
                    end
                        
                end

                if guess == "save"
                    
                else
                    @guesses << guess
                    check_guess(guess)
                end

            end
        end
        replay()
    end

    def check_guess(letter)
        match = false
        rand_array = @random_word.split("")
        rand_array.each_with_index do |l, i|
            if letter == l
                match = true
                @board_array.insert(i, letter)
                @board_array.slice!(i+1)
            end
        end
        if match == false
            @wrong += 1
            add_body_parts(@wrong)
        elsif match == true
            show_boards()
        end
    end

    def win?()
        @board_array.all? {|e| e != "_"}
    end

    def loss?
        @hangman[40] == "\\"
    end

    def over?
        
        if win?()
            puts "\nYou won!"
        elsif loss?()
            puts "\nYou lost."
            puts "\nWord was #{@random_word}"
        end
        
        win?() || loss?()
    end

    def replay
            puts "\nDo you want to play again? 'Y' for yes. 'N' for no."
            answer = gets.chomp.downcase
            until answer == "y" || answer == "n"
                puts "Error"
                puts "\nDo you want to play again? 'Y' for yes. 'N' for no."
                answer =  gets.chomp.downcase
            end
            if answer == "y"
                puts "\nDo you want to save this file?"
                puts "\nType 'save' to save file.\nType 'N' to start next game."
                answer = gets.chomp.downcase
                
                until answer == "save" || answer == "n"
                    puts "\nError."
                    puts "\nDo you want to save this file?"
                    puts "\nType 'save' to save file.\nType 'N' to start next game."
                    answer = gets.chomp.downcase
                end

                if answer == "save"
                    puts "\n#{@name}. What do you want to call the saved file? Or save to an existing file."
                    show_files()

                    saved_file = gets.chomp
                    to_yaml(saved_file)
                    save_file(saved_file, @yams)

                    reset_word_board()
                    reset_guesses()
                    reset_hanging_man()

                    play()
                elsif answer == "n" 
                    reset_word_board()
                    reset_guesses()
                    reset_hanging_man()
    
                    play()
                end
                
            elsif answer == "n"
                puts "\nDo you want to save this file?"
                puts "\nType 'save' to save file.\nType 'N' to exit"
                answer = gets.chomp.downcase
                until answer == "save" || answer == 'n'
                    puts "\nError."
                    puts "\nDo you want to save this file?"
                    puts "\nType 'save' to save file.\nType 'N' to exit"
                    answer = gets.chomp.downcase
                end
                if answer == "save"
                    puts "\n#{@name}. What do you want to call the saved file? Or save to an existing file."
                    show_files()

                    saved_file = gets.chomp
                    to_yaml(saved_file)
                    save_file(saved_file, @yams)
                elsif answer == 'n'
                    exit
                end
            end
    end

    def save_file(file, yam)
        Dir.mkdir('saved') unless Dir.exist?('saved')
        filename = "saved/#{file}.yaml"
        File.open(filename, 'w') do |file|
            file.puts yam
        end
        puts "File saved."
    end

    def to_yaml(file_name)
        @yams = YAML.dump ({
            :name => @name,
            :file => file_name,
            :hangman => @hangman,
            :random_word => @random_word,
            :wrong => @wrong,
            :board_array => @board_array,
            :guesses => @guesses
        })
    end

    def from_yaml(hash)
        data = YAML.load hash
        p data
    end

end