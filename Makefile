all: glue

glue: glue.pl
	pp -o glue.exe --gui -M LWP::UserAgent -M Time::HiRes glue.pl

lint:
	-perlcritic . | grep -v "source OK"

clean:
	-rm glue.exe
	-rm glue
