#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
use JSON;
use MP3::Tag;
use LWP::UserAgent;
use Data::Printer;
require HTTP::Cookies;

MP3::Tag->config(write_v24 => 1);

print "Enter a Genre/Artist that you would like to search or just hit enter for latest:";

my $answer = <>;
chomp($answer);

my $ua = LWP::UserAgent->new(
		agent 	=> 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.75 Safari/535.',
		timeout	=> 20);

$ua->cookie_jar(HTTP::Cookies->new(file => "cookies.txt", autosave => 1));		
		
my $response = $ua->get(_search($answer));
my @source = split(/\n/, $response->decoded_content); 

foreach my $line (@source) {
		
		next unless $line =~ m/^\s*\{"page_cur":/;
		$line =~ s|</script>||;
		
		my $shit = decode_json($line);
		
		
		foreach my $track ( @{ $shit->{tracks} }) {
			my @songinfo = ();
			push @songinfo,
				$track->{id},
				$track->{key},
				$track->{artist},
				$track->{song};
				
			 _getsong($ua, \@songinfo);
		}
		
}		
									
sub _getsong {														
	$ua = shift;															
	my $songinfo = shift;	
													
	(my $unixtitle = $songinfo->[3]) =~ s/(\s|\/)/_/g;						
	(my $unixartist = $songinfo->[2]) =~ s/(\s|\/)/_/g;
	my $file = "/Users/havox/Desktop/Dubstep/$unixartist-$unixtitle.mp3";
	
	my $response = $ua->get("http://www.hypem.com/serve/source/$songinfo->[0]/$songinfo->[1]");

	unless (-e $file){		#unless file does not exist, download
		$ua->mirror(decode_json($response->decoded_content)->{url} , $file);
	}
	return $file;
}

sub _search {
	$answer = shift;
	my $url = "";
	
	if ($answer eq ""){
		$url = "http://www.hypem.com/popular?ax=1\n";
	}
	else{
		$url = "http://www.hypem.com/search/$answer?ax=1\n";
	}

return $url;
}
