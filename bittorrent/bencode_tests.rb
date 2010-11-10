require 'bencode'
require 'rubygems'
require 'shindo'

Shindo.tests('BitTorrent::Bencode', ['bencode']) do

  @example_torrent_data = File.open('example.torrent').read.chomp
  @example_torrent_hash = {"announce"=>"http://tracker.amazonaws.com:6969/announce", "info"=>{"name"=>"fog.png", "x-amz-key"=>"fog.png", "piece\nlength"=>262144, "pieces"=>"\\300\\256'\\303\\035\\221SO\\220\\266]\\321\\232_\\247\\277g\\224(\\276", "length"=>14136, "x-amz-bucket"=>"geemus"}, "announce-list"=>[["http://tracker.amazonaws.com:6969/announce"]]}

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

    tests(@example_torrent_data).returns(@example_torrent_hash) do
      BitTorrent::Bencode.decode(@example_torrent_data)
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

    tests(@example_torrent_hash).returns(@example_torrent_data) do
      BitTorrent::Bencode.encode(@example_torrent_hash)
    end

  end

end
