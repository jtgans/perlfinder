#!/usr/bin/perl -w

=head1 LICENSE

This file is part of perlfinder.

Perlfinder is free software; you can redistribute it and/or modify
it under the terms  of the GNU General Public License as published
by the Free Software Foundation; either version 2 of the License,
or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNEESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details. 

You should have recieved a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA.

=head1 AUTHOR

June R. Tate <june@theonelab.com>

=cut

package PerlFinder::PerlFinder;

use lib (-e '@LIBDIR@' ? '@LIBDIR@' : $ENV{PWD} .'/lib');

use Gtk2 -init;
use Gtk2::GladeXML;
use XML::Simple ":strict";
use Data::Dumper;

use PerlFinder::MainWindow;
use PerlFinder::Preferences;

my $Instance = undef;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    my $in_production = 0;

    $self->{PREFIX}   =  ($in_production ? "!PREFIX!" : $ENV{PWD});
    $self->{VERSION}  = ($in_production ? "!VERSION!" : "Development Version");
    $self->{LIBDIR}   = $self->{PREFIX} ."/lib";
    $self->{SHAREDIR} = $self->{PREFIX} ."/share/perlfinder";
    $self->{PIDFILE}  = "/var/run/perlfinder.pid";
    $self->{RCDIR}    = $ENV{HOME} ."/.perlfinder";

    $self->{DEFAULTS} = {version => $self->{VERSION}};
    $self->{CONFIG}   = {};

    $self->{_INSTANCE} = \$Instance;

    # Code to setup a singleton
    if (defined(${$self->{_INSTANCE}})) {
        return ${$self->{_INSTANCE}};
    } else {
        bless($self, $class);
        ${$self->{_INSTANCE}} = $self;
        return ${$self->{_INSTANCE}};
    }
}

sub loadConfig {
    my $self = shift;

    if (-e "$self->{RCDIR}/config.xml") {
        %{$self->{CONFIG}} = %{XMLin("$self->{RCDIR}/config.xml", ForceArray => ["shortcuts"], KeyAttr => {})};
    } else {
        print STDERR "*** No config.xml file found. Loading defaults.\n";
        %{$self->{CONFIG}} = %{$self->{DEFAULTS}};
    }

    if ((!$self->{CONFIG}->{version}) or ($self->{CONFIG}->{version} ne $self->{VERSION})) {
        print STDERR "*** Your config file is from a different version. User beware.\n";
    }

    return 1;
}

sub saveConfig {
    my $self = shift;

    if (!$self->{CONFIG}->{version}) {
        $self->{CONFIG}->{version} = $self->{VERSION};
    }

    if (! -d $self->{RCDIR}) {
        mkdir($self->{RCDIR});
    }

    if (-e "$self->{RCDIR}/config.xml") {
        unlink("$self->{RCDIR}/config.xml");
    }

    XMLout($self->{CONFIG},
           OutputFile => "$self->{RCDIR}/config.xml",
           KeyAttr => {}
           );

    return 1;
}

sub findIcon {
    my $self = shift;
    my $filename = shift;

    if (-e "$self->{RCDIR}/icons/$filename" ) {
        print "Found icon in $self->{RCDIR}/icons/$filename.\n";
        return "$self->{RCDIR}/icons/$filename";
    }

    if (-e "$self->{SHAREDIR}/icons/$filename") {
        print "Found icon in $self->{SHAREDIR}/icons/$filename.\n";
        return "$self->{SHAREDIR}/icons/$filename";
    }
    
    if (-e "$self->{PREFIX}/share/icons/$filename") {
        print "Found icon in $self->{PREFIX}/share/icons/$filename.\n";
        return "$self->{PREFIX}/share/icons/$filename";
    }
    
    if (-e "$self->{PREFIX}/share/pixmaps/$filename") {
        print "Found icon in $self->{PREFIX}/share/pixmaps/$filename.\n";
        return "$self->{PREFIX}/share/pixmaps/$filename";
    }

    print "*** Couldn't find icon $filename.\n";
    return "";
}

sub addShortcut {
    my $self = shift;
    my $name = shift;
    my $icon_fname = $self->findIcon(shift);
    my $path = shift;
    my $icon;

    if ($icon_fname ne "") {
        $icon = Gtk2::Gdk::Pixbuf->new_from_file_at_size($icon_fname, 32, 32);
    } else {
        $icon = Gtk2::Gdk::Pixbuf->new(GDK_COLORSPACE_RGB, TRUE, 1, 32, 32);
    }

    push(@{$self->{CONFIG}->{shortcuts}}, [$icon, $name, $icon_fname, $path]);
}

sub initShortcuts {
    my $self = shift;

    if (! $self->{CONFIG}->{shortcuts} ) {
        print "*** No shortcuts defined in the rc file. Creating a new list for you.\n";
        $self->addShortcut("System", "GNOME-Terminal-BabyTux.png", "/");
        $self->addShortcut("Home", "Home.png", $ENV{HOME});
        $self->addShortcut("Documents", "GNOME-HTML.png", $ENV{HOME} ."/Documents");
    } else {
        print @{$self->{CONFIG}->{shortcuts}} ." shortcuts loaded.\n";

        foreach (0 .. @{$self->{CONFIG}->{shortcuts}} - 1) {
            my $filename;

            $filename = $self->{CONFIG}->{shortcuts}[$_][2];
            print "Loading icon $filename...\n";
            $self->{CONFIG}->{shortcuts}[$_][0] = Gtk2::Gdk::Pixbuf->new_from_file_at_size($filename, 32, 32);
        }
    }
}

sub getShareDir {
    my $self = shift;
    return $self->{SHAREDIR};
}

sub getConfig {
    my $self = shift;
    my $key = shift;

    return $self->{CONFIG}->{$key};
}

sub startPerlFinder {
    my $self = shift;
    my $mainwindow;

    print "RCDIR: $self->{RCDIR}\n";
    print "PREFIX: $self->{PREFIX}\n";
    print "SHAREDIR: $self->{SHAREDIR}\n";

    if (open(PIDFILE, ">$self->{PIDFILE}")) {
        print PIDFILE $$;
        close(PIDFILE);
    }

    $self->loadConfig();
    $self->initShortcuts();

    $mainwindow = new PerlFinder::MainWindow();
    Gtk2->main;

    unlink($self->{PIDFILE});
    $self->saveConfig();
    exit;
}

1;
