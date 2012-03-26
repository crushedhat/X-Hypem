#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
use JSON;
use LWP::UserAgent;
require HTTP::Cookies;

my $ua = LWP::UserAgent->new(
		agent 	=> 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.75 Safari/535.',
		timeout	=> 20);

		$ua->cookie_jar(HTTP::Cookies->new(file => "cookies.txt", autosave => 1));
		
my $response = $ua->get("http://www.hypem.com/?ax=1");
my @shit = split(/\n/, $response->decoded_content); 	#Initial page source is sucked into @shit as 1 line
my @songinfo = ();											#Split seperates all indivdual lines of page source


foreach my $line (@shit){											# every line in array
	next if ($line !~ m/^\s*(id:|key: |artist:|song:)'(.*)',/); 		# ^ begining of line
		push @songinfo,$2;													# s spaces (with * multiple)
																		# () What you are searching for
	if ($1 eq 'song:'){												#$1 first set of () - $2 second capture group						
		_getsong($ua , \@songinfo);
		@songinfo = ();				
	}
}											

sub _getsong {																#[0] = id:
	$ua = shift;															#[1] = key:
	my $songinfo = shift;													#[2] = artist:
	(my $unixtitle = $songinfo->[3]) =~ s/(\s|\/)/_/g;						#[3] = song:
	(my $unixartist = $songinfo->[2]) =~ s/(\s|\/)/_/g;
	my $file = "/Users/havox/Desktop/FUHYPEM/$unixartist-$unixtitle.mp3";
	
	my $response = $ua->get("http://www.hypem.com/serve/source/$songinfo->[0]/$songinfo->[1]");
	
	unless (-e $file){		#unless is if file does not exist
		$ua->mirror(decode_json($response->decoded_content)->{url} , $file);
	}
}
