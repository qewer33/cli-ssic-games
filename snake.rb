require 'io/console'


class Snake

    attr_reader :coords
    attr_accessor :direction
    attr_writer :map_width
    attr_writer :map_height

    def initialize
        @coords = [[20, 5], [20, 6], [20, 7], [20, 8], [20, 9], [20, 10]]
        @direction = "DOWN"
        @map_width = 0
        @map_height = 0
    end

    def move
        case @direction
        when "UP"
            @coords[-1][1] == 1 ? @coords.push([@coords[-1][0], @map_height - 1]) : @coords.push([@coords[-1][0], @coords[-1][1] - 1])
        when "RIGHT"
            @coords[-1][0] == @map_width - 1 ? @coords.push([1, @coords[-1][1]]) : @coords.push([@coords[-1][0] + 1, @coords[-1][1]])
        when "LEFT"
            @coords[-1][0] == 1 ? @coords.push([@map_width - 1, @coords[-1][1]]) : @coords.push([@coords[-1][0] - 1, @coords[-1][1]])
        when "DOWN"
            @coords[-1][1] == @map_height - 1 ? @coords.push([@coords[-1][0], 1]) : @coords.push([@coords[-1][0], @coords[-1][1] + 1])
        end
        @coords.shift
    end

    def grow
        case @direction
        when "UP" then @coords.unshift([@coords[0][0], @coords[0][1] + 1])
        when "RIGHT" then @coords.unshift([@coords[0][0] - 1, @coords[0][1]])
        when "LEFT" then @coords.unshift([@coords[0][0] + 1, @coords[0][1]])
        when "DOWN" then @coords.unshift([@coords[0][0], @coords[0][1] - 1])
        end
    end
end


class Game

    def initialize
        @width = IO.console.winsize[1]
        @height = IO.console.winsize[0] - 2
        @game_speed = 0.2
        @score = 0

        @snake = Snake.new
        @snake.map_width = @width
        @snake.map_height = @height
        @fruit_pos = []

        @input_thread = Thread.new do
            loop do
                input = STDIN.getch
                case input
                when "w" then @snake.direction = "UP" if @snake.direction != "DOWN"
                when "a" then @snake.direction = "LEFT" if @snake.direction != "RIGHT"
                when "s" then @snake.direction = "DOWN" if @snake.direction != "UP"
                when "d" then @snake.direction = "RIGHT" if @snake.direction != "LEFT"
                when "\u0003" then exit(1)
                end
            end
        end

        @game_thread = Thread.new do
            loop do
                @snake.move

                if @snake.coords[-1] == @fruit
                    @score += 1
                    @snake.grow
                    spawn_fruit
                end

                render
                sleep(@game_speed)
            end
        end
    end

    def run
        spawn_fruit
        @input_thread.join
        @game_thread.join
    end

    def render
        system("clear") | system("cls")

        draw_header_bar
        (0...@height).each do |y|
            (0...@width).each do |x|
                if @snake.coords.include?([x, y]) then printf("#")
                elsif [x, y] == @fruit then printf("o")
                else printf(" ")
                end
            end
            printf "\n\r"
        end
    end

    private

    def draw_header_bar
        printf "snake.rb"
        (0...@width - "snake.rbscore: #{@score} ".length).each { printf " " }
        printf "score: #{@score} \n\r"
    end

    def spawn_fruit
        @fruit = [rand(1...@width), rand(1...@height)]
    end
end

game = Game.new
game.run
