# Created by Matyáš Pokorný on 2019-03-20.

require_relative '../src/rom'

app = ROM::Application.new('.', :debug => ARGV.include?('-d'))

app.start