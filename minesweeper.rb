require 'readline'
require 'rainbow/refinement'

using Rainbow


class Board

  DEFAULT_CHAR = " "
  MINE_CHAR = "X"
  COVER_CHAR = "▅"
  FLAG_CHAR = "f"

  attr_accessor :width
  attr_accessor :height
  attr_accessor :mine_spawn_chance

  attr_reader :real_board
  attr_reader :game_board
  attr_reader :mines

    def initialize
        @width = 9
        @height = 9
        @mine_spawn_chance = 9
        @real_board = []
        @game_board = []
        @mines = []
    end

    def reset
        # reset real board
        @real_board = (0...@width).map { (0...@height).map { rand(1..@mine_spawn_chance) == 1 ? MINE_CHAR : DEFAULT_CHAR } }

        (0...@width).each do |x|
            (0...@height).each do |y|
                count = 0
                count += 1 if get_tile(x+1, y+1) == MINE_CHAR
                count += 1 if get_tile(x+1, y) == MINE_CHAR
                count += 1 if get_tile(x+1, y-1) == MINE_CHAR
                count += 1 if get_tile(x-1, y+1) == MINE_CHAR
                count += 1 if get_tile(x-1, y) == MINE_CHAR
                count += 1 if get_tile(x-1, y-1) == MINE_CHAR
                count += 1 if get_tile(x, y+1) == MINE_CHAR
                count += 1 if get_tile(x, y-1) == MINE_CHAR
                @real_board[x][y] = count.to_s unless count == 0
            end
        end

        # fill mines Array
        (0...@width).each { |x| (0...@height).each { |y| @mines.push([x, y]) if tile_mine?(x, y) } }

        # reset game board
        @game_board = (0...@width).map { (0...@height).map { COVER_CHAR } }
    end

    def display
        width_spacing = " "
        height_spacing = " "
        @height > 9 ? extra_height_spacing = " " : extra_height_spacing = ""

        printf "   #{extra_height_spacing}"
        (0...@width).each do |x|
            x > 9 ? width_spacing = " " : width_spacing = "  " if @width > 9
            printf "#{x}#{width_spacing}".bright.blue
        end
        printf "\n"
        (0...@height).each do |y|
            y > 9 ? height_spacing = " " : height_spacing = "  "
            printf "#{y}#{height_spacing}#{extra_height_spacing}".bright.blue
            (0...@width).each do |x|
                @width > 9 ? width_spacing = "  " : width_spacing = " "
                printf "#{@game_board[x][y]}#{width_spacing}"
            end
            printf "\n"
        end
    end

    def check_tile(x, y)
        return x >= 0 && y >= 0 && x < @width && y < @height
    end

    def get_tile(x, y)
        check_tile(x, y) ? @real_board[x][y] : false
    end

    def tile_open?(x, y)
        check_tile(x, y) ? @game_board[x][y] == DEFAULT_CHAR : false
    end

    def tile_mine?(x, y)
        return get_tile(x, y) == MINE_CHAR
    end

    def get_neighbors_cords(x, y)
        [
        [x+1, y+1],
        [x+1, y],
        [x+1, y-1],
        [x-1, y+1],
        [x-1, y],
        [x-1, y-1],
        [x, y+1],
        [x, y-1]
        ] if check_tile(x, y)
    end

    def open_tile(x, y)
        check_tile(x, y) ? @game_board[x][y] = @real_board[x][y] : return
        # if the tile is empty, open all neighbour empty tiles
        if get_tile(x, y) == DEFAULT_CHAR
            get_neighbors_cords(x, y).each do |n|
                open_tile(n[0], n[1]) if !tile_open?(n[0], n[1]) && get_tile(n[0], n[1]) == DEFAULT_CHAR
            end
        end
    end

    def flag_tile(x, y)
        check_tile(x, y) ? @game_board[x][y] = FLAG_CHAR : return
    end
end


class Game

    PROMPT = (" >>> ").bg(:blue) + " "
    DIFFICULTIES = {
        "EASY" => [9, 9, 9], # [board_width, board_height, 1/mine_spawn_chance]
        "MEDIUM" => [12, 12, 8],
        "HARD" => [16, 16, 7],
        "INSANE" => [20, 20, 5]
    }

    def initialize
        @game_started = false
        @board = Board.new
        @commands = {
            "new" => method(:cmd_new),
            "n" => method(:cmd_new),
            "open" => method(:cmd_open),
            "o" => method(:cmd_open),
            "flag" => method(:cmd_flag),
            "f" => method(:cmd_flag)
        }
        @diff = DIFFICULTIES["EASY"]
    end

    def run
        system("clear") | system("cls")
        puts "welcome to ".green + "minesweeper".bright.blue
        puts "start a new game with: ".green + "new <difficulty>".yellow
        puts "there are 4 difficulties to choose from: ".green + "easy, medium, hard and insane".yellow
        loop do
            if @game_started
                system("clear") | system("cls")
                @board.display
            end
            while input = Readline.readline(PROMPT, false)
                command = input.split(" ")[0]
                args = input.sub(command, "")

                if @commands.key?(command)
                    @commands[command].call(args)
                end

                break if @game_started
            end
        end
    end

    def cmd_new(args)
        args = args.split(" ")
        if args.empty?
            @diff = DIFFICULTIES["EASY"]
        elsif DIFFICULTIES.key?(args[0].upcase)
            @diff = DIFFICULTIES[args[0].upcase]
        else
            puts "The difficulty can only one of the following: easy, medium, hard, insane".yellow
            return
        end

        @board.width = @diff[0]
        @board.height = @diff[1]
        @board.mine_spawn_chance = @diff[2]

        @board.reset
        @game_started = true
    end

    def cmd_open(args)
        args = args.split(" ")
        @board.open_tile(args[0].to_i, args[1].to_i)
        lose_game if @board.tile_mine?(args[0].to_i, args[1].to_i)
    end

    def cmd_flag(args)
        args = args.split(" ")
        @board.flag_tile(args[0].to_i, args[1].to_i)
    end

    def win_game
        (0...@board.width) do |x|
            (0...@board.height) do |y|

            end
        end
    end

    def lose_game
        @board.mines.each do |t|
            @board.open_tile(t[0], t[1])
        end
        system("clear") | system("cls")
        @board.display
        @game_started = false
        puts "haha L noob u lost".red
    end
end

game = Game.new
game.run

