PerlFinder - Technical Preview
Created by June R. Tate <june@theonelab.com>

PerlFinder is a simple GTK+2 perl application that attempts to work
as closely as the MacOS X Finder as possible. At it's core,
PerlFinder is simply a file management program, but it aims to
eventually be a small replacement for the horribly bloated GNOME
Nautilus file manager.

At it's current stage, PerlFinder is merely a toy to look at -- a
proof of concept, as it were, since documentation for Gtk2 and
Gtk2::GladeXML is sparse, at best. For now, PerlFinder only allows
you to look around on your filesystem in the NeXTStep-like column
view.

PerlFinder has currently been tested on only one platform: Debian
Linux. There should be no problems to get it running on another
UNIX-like platform other than Linux, aside from getting the Gtk2,
Gtk2::GladeXML and XML::Simple perl modules installed.

Note that this program MUST be run as follows:

     foo:~$ cd perlfinder
     foo:~/perlfinder$ src/perlfinder

This is done because, in it's current state, PerlFinder cannot be
installed system wide at this time. Note that PerlFinder also dumps
out tons of debugging information, so don't be afraid of the copius
junk it spews out.

I have written some documentation in perldoc format inside the
perlfinder/src/perlfinder file, which is viewable with the
traditional perldoc utility. Failing that, I have also converted it
to plaintext in the file "perldoc.txt".

All code, including the Glade files in
perlfinder/share/perlfinder/glade were written by me. The icons in
perlfinder/share/perlfinder/icons were borrowed from the GNOME
Project.

        -- June
