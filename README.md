# glue - Bonds items together

## Example

	> glue
	Accounts on this computer (123.123.123.123)
	
	Username: stephenfalken
	Hash: 4FBD4CEA97C5752CAAD3B435B51404EE
	Password: Joshua

## Installation

Glue can install itself onto a USB drive for portability.

	> install
	Where is the USB drive?
	E:

	...

	Success

If installation fails, try removing Glue from the USB drive, then reinstalling Glue.

## Usage

 * Install Glue onto a USB drive.
 * Insert the USB drive into a computer.
 * Autorun may execute Glue automatically.
 * If not, nagivate to `USB:\glue\` and execute `glue.exe`.

## Removal

Glue can remove itself from a USB drive.

	> uninstall
	Where is the USB drive?
	E:

	...

	Success

## Credits

 * [pwdump6](http://www.foofus.net/~fizzgig/pwdump/) - Hash retrieval
 * [OnlineHashCrack](http://www.onlinehashcrack.com/) - Password retrieval
 * [Strawberry Perl](http://strawberryperl.com/) - Perl for Windows
 * [PAR::Packer](http://search.cpan.org/~rschupp/PAR-Packer-1.012/lib/PAR/Packer.pm) - Perl -> Exe compilation