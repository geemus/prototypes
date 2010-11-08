require 'bencode'
require 'rubygems'
require 'shindo'

Shindo.tests('BitTorrent::Bencode', ['bencode']) do

  tests('decode') do

    tests('i42e').returns(42) do
      BitTorrent::Bencode.decode('i42e')
    end

    tests('4:spam').returns('spam') do
      BitTorrent::Bencode.decode('4:spam')
    end

    tests('l4:spami42ee').returns(['spam', 42]) do
      BitTorrent::Bencode.decode('l4:spami42ee')
    end

    tests('d3:bar4:spam3:fooi42ee').returns({'bar' => 'spam', 'foo' => 42}) do
      BitTorrent::Bencode.decode('d3:bar4:spam3:fooi42ee')
    end

    tests('d4:listl4:spami42eee').returns({'list' => ['spam', 42]}) do
      BitTorrent::Bencode.decode('d4:listl4:spami42eee')
    end

  end

  tests('encode') do

    tests('42').returns('i42e') do
      BitTorrent::Bencode.encode(42)
    end

    tests('"spam"').returns('4:spam') do
      BitTorrent::Bencode.encode("spam")
    end

    tests('["spam", 42]').returns('l4:spami42ee') do
      BitTorrent::Bencode.encode(["spam", 42])
    end

    tests({'bar' => 'spam', 'foo' => 42}).returns('d3:bar4:spam3:fooi42ee') do
      BitTorrent::Bencode.encode({'bar' => 'spam', 'foo' => 42})
    end

    tests({'list' => ['spam', 42]}).returns('d4:listl4:spami42eee') do
      BitTorrent::Bencode.encode({'list' => ['spam', 42]})
    end

  end

end
