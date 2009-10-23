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

package PerlFinder::FileList;

use strict;
use Fcntl qw(:mode);
use Gtk2;
use Gtk2::SimpleList;
use Data::Dumper;

use PerlFinder::PerlFinder;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self = {
        _PERLFINDER => new PerlFinder::PerlFinder(),
        _CONTAINER  => shift(),
        _PATH       => shift(),
        _HPANE      => undef,
        _SCROLLVIEW => undef,
        _SIMPLELIST => undef,
        _FILE_LIST  => undef
    };

    bless($self, $class);
    $self->setupView();

    return $self;
}

sub setupView {
    my $self = shift;
    my @files;

    # Setup our file list first
    $self->{_FILE_LIST} = [];
    opendir(DIR, $self->{_PATH});

    foreach my $file (grep { /^[^.]/ } readdir(DIR)) {
        if (-f $self->{_PATH} .'/'. $file) {
            if (-x $self->{_PATH} .'/'. $file) {
                push(@{$self->{_FILE_LIST}}, [Gtk2::Gdk::Pixbuf->new_from_file_at_size($self->{_PERLFINDER}->getShareDir() ."/icons/gnome-fs-executable.png", 32, 32), $file]);
            } else {
                push(@{$self->{_FILE_LIST}}, [Gtk2::Gdk::Pixbuf->new_from_file_at_size($self->{_PERLFINDER}->getShareDir() ."/icons/gnome-fs-regular.png", 32, 32), $file]);
            }
        } elsif (-d $self->{_PATH} .'/'. $file) {
            push(@{$self->{_FILE_LIST}}, [Gtk2::Gdk::Pixbuf->new_from_file_at_size($self->{_PERLFINDER}->getShareDir() ."/icons/gnome-fs-directory.png", 32, 32), $file]);
        } elsif (-l $self->{_PATH} .'/'. $file) {
            push(@{$self->{_FILE_LIST}}, [Gtk2::Gdk::Pixbuf->new_from_file_at_size($self->{_PERLFINDER}->getShareDir() ."/icons/gnome-fs-regular.png", 32, 32), $file]);
        } elsif (-b $self->{_PATH} .'/'. $file) {
            push(@{$self->{_FILE_LIST}}, [Gtk2::Gdk::Pixbuf->new_from_file_at_size($self->{_PERLFINDER}->getShareDir() ."/icons/gnome-fs-blockdev.png", 32, 32), $file]);
        } elsif (-c $self->{_PATH} .'/'. $file) {
            push(@{$self->{_FILE_LIST}}, [Gtk2::Gdk::Pixbuf->new_from_file_at_size($self->{_PERLFINDER}->getShareDir() ."/icons/gnome-fs-chardev.png", 32, 32), $file]);
        } elsif (-p $self->{_PATH} .'/'. $file) {
            push(@{$self->{_FILE_LIST}}, [Gtk2::Gdk::Pixbuf->new_from_file_at_size($self->{_PERLFINDER}->getShareDir() ."/icons/gnome-fs-fifo.png", 32, 32), $file]);
        } elsif (-S $self->{_PATH} .'/'. $file) {
            push(@{$self->{_FILE_LIST}}, [Gtk2::Gdk::Pixbuf->new_from_file_at_size($self->{_PERLFINDER}->getShareDir() ."/icons/gnome-fs-socket.png", 32, 32), $file]);
        } else {
            warn("Unknown file type for file $file -- not a directory and not a file");
        }
    }

    closedir(DIR);

    # Now clean out the container
    my @children = $self->{_CONTAINER}->get_children();
    if ($children[1]) {
        $self->{_CONTAINER}->remove($children[1]);
    }

    # Setup our hpaned
    $self->{_HPANE} = new Gtk2::HPaned->new();

    # Setup our scrollview for the files list
    $self->{_SCROLLVIEW} = new Gtk2::ScrolledWindow();
    $self->{_SCROLLVIEW}->set_policy('never', 'always');

    # Now setup our file list
    $self->{_SIMPLELIST} = new Gtk2::SimpleList('Icon' => "pixbuf", 'Filename' => "text");
    $self->{_SIMPLELIST}->set_headers_visible(0);
    $self->{_SIMPLELIST}->signal_connect(cursor_changed => sub { $self->cursorChanged() });
    $self->{_SIMPLELIST}->set_data_array($self->{_FILE_LIST});

    # Now add the SimpleList to the ScrollWindow
    $self->{_SCROLLVIEW}->add_with_viewport($self->{_SIMPLELIST});

    # Add the ScrollWindow to the left pane of the HPaned
    $self->{_HPANE}->add1($self->{_SCROLLVIEW});

    # And finally add the Hpaned to the container
    $self->{_CONTAINER}->add2($self->{_HPANE});

    # Now show all
    $self->{_CONTAINER}->show_all();
}

sub cursorChanged {
    my $self = shift;
    my @selected = $self->{_SIMPLELIST}->get_selected_indices();
    my $scrollview;

    if ($self->{_HPANE}->child2()) {
        # Horrible hack to remove the second view from the second part
        # of the hpaned. This should _really_ be done as a
        # $self->{_HPANE}->remove2() call, if it existed. =o/ 

        my @children = $self->{_HPANE}->get_children();
        $self->{_HPANE}->remove($children[1]);
    }

    print Dumper($self->{_FILE_LIST}[$selected[0]][1]);

    # Check to see if it's a regular file or a directory
    if (-d $self->{_PATH} ."/". $self->{_FILE_LIST}[$selected[0]][1]) {
        new PerlFinder::FileList($self->{_HPANE}, $self->{_PATH} ."/". $self->{_FILE_LIST}[$selected[0]][1]);
    } else {
        # new PerlFinder::FileDisplay($scrollview, $self->{_PATH} ."/". $self->{_FILE_LIST}[$selected[0]][1]);
        print $self->{_FILE_LIST}[$selected[0]][1] ." is not a directory. *** PULL UP THE DISPLAY PANE!\n";
    }
}

1;
