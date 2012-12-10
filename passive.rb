#!/usr/bin/env ruby

require 'formatador'

# passive voice detection, inspired by: http://matt.might.net/articles/shell-scripts-for-passive-voice-weasel-words-duplicates/

IRREGULAR_PASSIVES = %w{
  awoken
  been born beat
  become begun bent
  beset bet bid
  bidden bound bitten
  bled blown broken
  bred brought broadcast
  built burnt burst
  bought cast caught
  chosen clung come
  cost crept cut
  dealt dug dived
  done drawn dreamt
  driven drunk eaten fallen
  fed felt fought found
  fit fled flung flown
  forbidden forgotten
  foregone forgiven
  forsaken frozen
  gotten given gone
  ground grown hung
  heard hidden hit
  held hurt kept knelt
  knit known laid led
  leapt learnt left
  lent let lain lighted
  lost made meant met
  misspelt mistaken mown
  overcome overdone overtaken
  overthrown paid pled proven
  put quit read rid|ridden
  rung risen run sawn|said
  seen sought sold sent
  set sewn shaken shaven
  shorn shed shone shod
  shot shown shrunk shut
  sung sunk sat slept
  slain slid slung slit
  smitten sown spoken sped
  spent spilt spun spit
  split spread sprung stood
  stolen stuck stung stunk
  stridden struck strung
  striven sworn swept
  swollen swum swung taken
  taught torn told thought
  thrived thrown thrust
  trodden understood upheld
  upset woken worn woven
  wed wept wound won
  withheld withstood wrung
  written
}

REGULAR_PASSIVES = %w{
  am are
  be been being
  is
  was were
  \w+ed
}

string = if $stdin.isatty
  ARGV.join(" ")
else
  $stdin.read
end

highlighted = string.gsub(/(^|\s)(#{(IRREGULAR_PASSIVES + REGULAR_PASSIVES).join("|")})(\s|$)/) {"#{$1}[negative]#{$2}[/]#{$3}"}
if highlighted == string
  Formatador.display_line("Congrats, no passive voice!")
else
  Formatador.display_line("#{highlighted}")
end
