puts "Base de donné email de mairies."
puts "chargement en cours........."

require 'nokogiri'
require 'open-uri'
require 'json'
require 'csv'
require 'bundler'
require 'googleauth'

require_relative "lib/scrapper.rb"
Bundler.require

scrap = Scrapper.new
puts "Choisir une action"
puts "1- Mettre à jour la base de donnée local au format JSON"
puts "2- Mettre à jour la base de donnée en ligne google worksheet."
puts "3-Mettre à jour/créer la base de donné local au format CSV."
puts "<ENTRER>- Quitter le programme."


  case gets.chomp
  when "1"
    scrap.create_town_url_array
    scrap.create_town_email_hash
    scrap.save_as_json
  when "2"
    scrap.open_json
    scrap.save_as_spreadsheet
  when "2"
    scrap.save_as_csv
  end
