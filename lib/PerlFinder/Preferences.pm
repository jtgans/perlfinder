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

package PerlFinder::Preferences;

use strict;
use Gtk2;
use Gtk2::GladeXML;

use PerlFinder::PerlFinder;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self = {
        _PERLFINDER => new PerlFinder::PerlFinder(),
        _WINDOW => undef,
        _GLADE  => undef
    };

    bless($self, $class);

    $self->{_GLADE} = Gtk2::GladeXML->new($self->{_PERLFINDER}->getShareDir() .'/glade/preferences.glade');

    if ($self->{_GLADE}) {
        $self->{_WINDOW} = $self->{_GLADE}->get_widget('preferences');
    } else {
        die("PerlFinder::MainWindow: Can't load ". $self->{_PERLFINDER}->getShareDir() ."/glade/perlfinder.glade");
    }

    return $self;
}

sub show {
    my $self = shift;

    $self->{_WINDOW}->show_all();
}

1;
