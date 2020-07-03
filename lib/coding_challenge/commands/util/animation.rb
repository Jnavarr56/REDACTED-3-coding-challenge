# frozen_string_literal: true

require 'tty-progressbar'
require 'tty-spinner'
require 'lolcat'

module Animation
  def intro_loading_bars_animation
    bars = TTY::ProgressBar::Multi.new('Prepping for awesomeness 😎 [:bar] :percent', head: '>')
    bar1 = bars.register('Crossing my fingers I get a job  :percent [:bar] ', total: 30, head: '>', output: $stdout)
    bar2 = bars.register("Doin' a motivation dance         :percent [:bar] ", total: 30, head: '>', output: $stdout)

    bars.start

    th1 = Thread.new { 30.times { sleep(0.075); bar1.advance } }
    th2 = Thread.new { 30.times { sleep(0.05); bar2.advance } }
    [th1, th2].each(&:join)
  end

  def intro_title_animation
    path_dirs = __dir__.split('/')
    path_dirs.pop

    greeting_title_ascii_file = File.open("#{path_dirs.join('/')}/text/greeting_title_ascii.txt")
    greeting_title_ascii_str = greeting_title_ascii_file.read
    system "echo '#{greeting_title_ascii_str}' | lolcat -a -d 1"
  end

  def loading_animation(text = 'Loading...', delay = 3)
    spinner = TTY::Spinner.new("[:spinner] #{text}", format: :pulse_2, clear: true)
    spinner.auto_spin
    sleep(delay)
    spinner.stop
  end

  def type_effect(text)
    i = 0
    text.length.times do
      print text[i]
      i += 1
      sleep(0.025)
    end
    puts ' '
  end
end
