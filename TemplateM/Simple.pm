package TemplateM::Simple;
use strict;

use Exporter;
use vars qw($VERSION);
our $VERSION = 2.20;

use base qw/Exporter/;
use TemplateM::Util;

our @EXPORT = qw(
        html
    );

#
# Methods
#
sub cast {
    my $self = shift;
    my $hr   = $_[0]; 

    die("[cast] Incorrect call of method \"CAST\"") unless $hr;

    unless (ref($hr) eq "HASH") {
        $hr = {@_};
    }
    
    $self->{template}=~s/<!--\s*cgi:\s*(\S+?)\s*-->/_exec_directive($hr, $1)/ieg;
}
sub stash { cast(@_) }

sub cast_loop {
    my $self = shift;
    my $name = shift || '';
    my $ar = $_[0];
    
    die("[cast_loop] Incorrect call of method \"CAST_LOOP\"") unless ($name);
   
    if (ref($ar) eq "HASH") {
       $ar=[$ar];
    } else {
       $ar = [{@_}] if ref($ar) ne "ARRAY";
    }
    
    my $pattern = '';
    if ($self->{template} =~ m/<!--\s*do:\s*$name\s*-->(.*)<!--\s*loop:\s*$name\s*-->/s) {
        $pattern = $1 || ''
    }
    my $pattern_copy = $pattern;
    my $out;
    foreach (@{$ar}) {
      $pattern = $pattern_copy;
      $pattern =~ s/<!--\s*val:\s*(\S+?)\s*-->/_exec_directive($_,$1)/ieg;
      $out.=$pattern;
    }
   
    $self->{template} =~ s/(<!--\s*do:\s*$name\s*-->).*(<!--\s*loop:\s*$name\s*-->)/$out$1$pattern_copy$2/s;
}
sub loop { cast_loop(@_) }
sub finalize {
    my $self = shift;
    my $name = shift;
    
    die("[finalize] Incorrect call of method \"FINALIZE\"") unless ($name);
    
    $self->{template} =~ s/<!--\s*do:\s*$name\s*-->.*<!--\s*loop:\s*$name\s*-->//s;
}
sub finish { finalize (@_) }
sub cast_if {
    my $self = shift;
    my $name = shift;
    my $predicate = shift || 0;
    die("[cast_if] Incorrect call of method \"CAST_IF\"") unless ($name);
    
    if ($predicate) {
       $self->{template} =~ s/<!--\s*if:\s*$name\s*-->(.*)<!--\s*end_?if:\s*$name\s*-->/$1/s;
       $self->{template} =~ s/<!--\s*else:\s*$name\s*-->.*<!--\s*end_?else:\s*$name\s*-->//s;
    } else { 
       $self->{template} =~ s/<!--\s*else:\s*$name\s*-->(.*)<!--\s*end_?else:\s*$name\s*-->/$1/s;
       $self->{template} =~ s/<!--\s*if:\s*$name\s*-->.*<!--\s*end_?if:\s*$name\s*-->//s;
    }
}
sub ifelse { cast_if(@_) }

sub html {
    my $self = shift;
    my $header = $self->{header} || '';
    ($header) = read_attributes([['HEAD','HEADER']],@_) if (defined $_[0]);
    return $header.$self->{template};
}
sub output { html(@_) }
#
# Internal functions
#
sub _exec_directive {
    my ($hr, $directive) = @_;
    
    if (defined($hr->{$directive})) {
        return $hr->{$directive};
    } else {
        return '';
    }
}



1;
