#!/usr/bin/ruby

require 'rubygems'
require 'formatador'

mhr = (ARGV[0] || 195).to_i

Formatador.display_line
Formatador.display_line("Training Bands for MHR [bold]#{mhr}[/]")

bands = []

bands << { :band => 'UT2', :hr => "#{(mhr * 0.55).round}-#{(mhr * 0.70).round}", :spm => '18-20', :feels => 'Relaxed. Able to carry on a conversation.' }
bands << { :band => 'UT1', :hr => "#{(mhr * 0.70).round}-#{(mhr * 0.80).round}", :spm => '20-24', :feels => 'Working. Feel Warmer. Heart rate and resiration up. May sweat.' }
bands << { :band =>  'AT', :hr => "#{(mhr * 0.80).round}-#{(mhr * 0.85).round}", :spm => '24-28', :feels => 'Hard work. Heart rate and respiration up. Carbon dioxide build up. Sweating. Breathing hard.' }
bands << { :band =>  'TR', :hr => "#{(mhr * 0.85).round}-#{(mhr * 0.90).round}", :spm => '28-32', :feels => 'Stressed. Panting. Sweating freely.' }
bands << { :band =>  'AN', :hr => "#{(mhr * 0.90).round}-#{(mhr * 1.00).round}", :spm =>   '32+', :feels => 'Very stressful. Gasping. Sweating heavily.' }

Formatador.display_table(bands, [:band, :hr, :spm, :feels])
Formatador.display_line
