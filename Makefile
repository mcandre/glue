all: glue

glue: glue.pl
	pp -o glue.exe --gui -M LWP::UserAgent -M Time::HiRes glue.pl

perl:
	-for f in *.pl; do perl -MO=Lint -cw $$f 2>&1 | grep -v "syntax OK"; done
	-for f in **/*.pl; do perl -MO=Lint -cw $$f 2>&1 | grep -v "syntax OK"; done
	-for f in *.pm; do perl -MO=Lint -cw $$f 2>&1 | grep -v "syntax OK"; done
	-for f in **/*.pm; do perl -MO=Lint -cw $$f 2>&1 | grep -v "syntax OK"; done

perlcritic:
	-perlcritic . | grep -v "source OK"

lint: perl perlcritic

clean:
	-rm glue.exe
	-rm glue
