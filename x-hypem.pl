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
my @page_source = split(/\n/, $response->decoded_content); 	#Initial page source is sucked into @source as 1 line
							#Split seperates all indivdual lines of page source
my @songinfo = ();

foreach my $line (@page_source){						
	next if ($line !~ m/^\s*(id:|key: |artist:|song:)'(.*)',/); 		
		push @songinfo,$2;					
																		
	if ($1 eq 'song:'){																	
		_getsong($ua , \@songinfo);
		@songinfo = ();				
	}
}											

sub _getsong {							#[0] = id:
	$ua = shift;						#[1] = key:
	my $songinfo = shift;					#[2] = artist:
	(my $unixtitle = $songinfo->[3]) =~ s/(\s|\/)/_/g;	#[3] = song:
	(my $unixartist = $songinfo->[2]) =~ s/(\s|\/)/_/g;
	my $file = "/$unixartist-$unixtitle.mp3"; #add the directory to save the songs within " "
	
	my $response = $ua->get("http://www.hypem.com/serve/source/$songinfo->[0]/$songinfo->[1]");
	
	unless (-e $file){		#if file does not exist already then download it
		$ua->mirror(decode_json($response->decoded_content)->{url} , $file);
	}
}
