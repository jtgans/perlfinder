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

package PerlFinder::MainWindow;

use strict;
use Gtk2;
use Gtk2::GladeXML;
use Gtk2::SimpleList;

use Data::Dumper;

use PerlFinder::PerlFinder;
use PerlFinder::Preferences;
use PerlFinder::FileList;

my $WindowCount = 0;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self = {
        _PERLFINDER  => new PerlFinder::PerlFinder(),
        _WINDOWCOUNT => \$WindowCount,
        _WINDOW      => undef,
        _SHORTCUTS   => undef,
        _GLADE       => undef
    };

    bless($self, $class);
    $self->newWindow();

    return $self;
}

sub newWindow {
    my $self = shift;
    $self->{_GLADE} = Gtk2::GladeXML->new($self->{_PERLFINDER}->getShareDir() .'/glade/perlfinder.glade');

    if ($self->{_GLADE}) {
        $self->{_GLADE}->signal_autoconnect_from_package($self);

        $self->{_WINDOW} = $self->{_GLADE}->get_widget('PerlFinder');
        $self->{_SHORTCUTS} = Gtk2::SimpleList->new_from_treeview($self->{_GLADE}->get_widget('ShortcutView'),
                                                                  'icon' => 'pixbuf',
                                                                  'name' => 'markup'
                                                                  );
        $self->{_SHORTCUTS}->set_data_array($self->{_PERLFINDER}->getConfig("shortcuts"));
        $self->{_SHORTCUTS}->get_selection->set_mode('single');
        $self->{_SHORTCUTS}->select(0);
        $self->{_WINDOW}->show_all();

        ${$self->{_WINDOWCOUNT}}++;
        print "New window: Window count is now ${$self->{_WINDOWCOUNT}}\n";
    } else {
        die("PerlFinder::MainWindow->newWindow: Can't load ". $self->{_PERLFINDER}->getShareDir() ."/glade/perlfinder.glade");
    }

    return 1;
}

sub closeWindow {
    my $self = shift;

    if (${$self->{_WINDOWCOUNT}} == 1) {
        Gtk2->main_quit;
    }

    ${$self->{_WINDOWCOUNT}}--;
    print "Closed window: Window count is now ${$self->{_WINDOWCOUNT}}\n";
    return 0;
}

sub showPreferences {
    my $self = shift;
    my $preferences = new PerlFinder::Preferences;

    $preferences->show();
}

sub cursorChanged {
    my $self = shift;
    my @selected = $self->{_SHORTCUTS}->get_selected_indices();
    my $view = $self->{_GLADE}->get_widget('FileView');
    my @data = $self->{_PERLFINDER}->{CONFIG}->{shortcuts}[$selected[0]];
    
    new PerlFinder::FileList($view, $self->{_PERLFINDER}->{CONFIG}->{shortcuts}[$selected[0]][3]);
}

1;
