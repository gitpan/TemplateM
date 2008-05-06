package TemplateM::Util;
use strict;

=head1 NAME

TemplateM::Util - Internal utilities used by TemplateM module

=head1 SYNOPSIS

use TemplateM::Util;

=head1 DESCRIPTION

no public subroutines

=head1 AUTHOR INFORMATION

Copyright 1995-1998, Lincoln D. Stein.  All rights reserved.  

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

Address bug reports and comments to: lstein@cshl.org.  When sending
bug reports, please provide the version of CGI.pm, the version of
Perl, the name and version of your Web server, and the name and
version of the operating system you are using.  If the problem is even
remotely browser dependent, please provide information about the
affected browers as well.

=head1 SEE ALSO

L<CGI>

=cut

use Exporter;
use vars qw($VERSION);
our $VERSION = 2.20;

use base qw/Exporter/;

our @EXPORT = qw(
        read_attributes
    );

sub read_attributes {
    my($order,@param) = @_;
    return () unless @param;

    if (ref($param[0]) eq 'HASH') {
        @param = %{$param[0]};
    } else {
        return @param unless (defined($param[0]) && substr($param[0],0,1) eq '-');
    }

    # map parameters into positional indices
    my ($i,%pos);
    $i = 0;
    foreach (@$order) {
        foreach (ref($_) eq 'ARRAY' ? @$_ : $_) {
            $pos{lc($_)} = $i;
        }
        $i++;
    }

    my (@result,%leftover);
    $#result = $#$order;  # preextend
    while (@param) {
        my $key = lc(shift(@param));
        $key =~ s/^\-//;
        if (exists $pos{$key}) {
            $result[$pos{$key}] = shift(@param);
        } else {
            $leftover{$key} = shift(@param);
        }
    }

    push (@result,_make_attributes(\%leftover,1)) if %leftover;
    @result;
}

sub _make_attributes {
    my $attr = shift;
    return () unless $attr && ref($attr) && ref($attr) eq 'HASH';
    my $escape = shift || 0;
    my(@att);
    foreach (keys %{$attr}) {
        my($key) = $_;
        $key=~s/^\-//;
        ($key="\L$key") =~ tr/_/-/; # parameters are lower case, use dashes
        my $value = $escape ? $attr->{$_} : $attr->{$_};
        push(@att,defined($attr->{$_}) ? qq/$key="$value"/ : qq/$key/);
    }
    return @att;
}

1;
