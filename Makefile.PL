#!/usr/bin/env perl

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile;

sub MY::postamble {
  return <<'END';
glue: glue.pl
	pp -o glue.exe --gui -M LWP::UserAgent -M Time::HiRes glue.pl

perlwarn:
	-find . -type f -name '*.p[lm]' -o -name '*.t' -exec perl -MO=Lint -cw {} 2>&1 \; | grep -v "syntax OK" | grep -v "Can't locate"

perlcritic:
	-perlcritic -q .

csslint:
	-csslint .

lint: perlwarn perlcritic csslint
END
}
