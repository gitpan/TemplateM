package TemplateM::Galore;
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
sub start {
    my $self = shift;
    my $label = shift;
    die("[start] Incorrect call of method \"START\"") unless (defined($label));

    my $tpl = '';
    $tpl = $2 if $self->{work} =~ m/<!--\s*do:\s*($label)\s*-->(.*?)<!--\s*loop:\s*\1\s*-->/s;
   
    my $wrk = '';
   
    my $stk = '';

    return bless {
        template => $tpl,
        work     => $wrk,
        stackout => $stk,
        label    => $label,
        pobj     => $self,
        tf       => 1
    };
}

sub loop {
    my $self = shift;
    my $hr  = $_[0];
    die("[loop] Incorrect call of method \"LOOP\"") unless (defined($hr));
    
    if (defined($hr) && (ref($hr) ne "HASH")) {
        if (ref($hr) eq "ARRAY") {
            $hr = {@$hr};
        } else {
            $hr = {@_};
        }
    }

    $self->{stackout} .= $self->{work};
  
    my $wrk = $self->{template};
   
    $wrk =~ s/<!--\s*val:\s*(\S+?)\s*-->/_exec_directive($hr,$1,'val')/ieg if defined($hr);
   
    $self->{work} = $wrk
}

sub finish {
    my $self = shift;

    $self->{stackout} .= $self->{work};
   
    $self->{work} = '';
   
    my $label = $self->{label};
    my $stack = $self->{stackout};
   
    if ($self->{pobj}->{tf}) {
        $self->{pobj}->{work} =~ s/<!--\s*do:\s*($label)\s*-->(.*?)<!--\s*loop:\s*\1\s*-->/$stack/s
    } else {
        $self->{pobj}->{looparr}->{$self->{label}} = $stack
    }
}
sub finalize { finish(@_) }
sub cast {
    my $self = shift;
    my $hr   = $_[0];
    
    die("[cast] Incorrect call of method \"CAST\"") unless $hr;

    unless (ref($hr) eq "HASH") {
        $hr = {@_};
    }
    
    $self->{work} =~ s/<!--\s*cgi:\s*(\S+?)\s*-->/_exec_directive($hr, $1, 'cgi')/ieg;
}
sub stash { cast(@_) }
sub ifelse {
    my $self = shift;
    my $label = shift || '';
    my $predicate = shift || 0;

    die("[efelse] Incorrect call of method \"IFELSE\"") unless (defined($label));
    
    if ($predicate) {
       $self->{work} =~ s/<!--\s*if:\s*($label)\s*-->(.*?)<!--\s*end_?if:\s*\1\s*-->/$2/igs;
       $self->{work} =~ s/<!--\s*else:\s*($label)\s*-->.*?<!--\s*end_?else:\s*\1\s*-->//igs;
    } else { 
       $self->{work} =~ s/<!--\s*else:\s*($label)\s*-->(.*?)<!--\s*end_?else:\s*\1\s*-->/$2/igs;
       $self->{work} =~ s/<!--\s*if:\s*($label)\s*-->.*?<!--\s*end_?if:\s*\1\s*-->//igs;
    }

}
sub cast_if { ifelse(@_) }
sub output {
    my $self = shift;
    my $property = shift || 'stackout';

    if (! $self->{tf} and $property eq 'stackout') {
        $self->{work} =~ s/<!--\s*do:\s*(\S+?)\s*-->(.*?)<!--\s*loop:\s*\1\s*-->/_analize($self->{looparr},$1)/egs;
        $self->{stackout} = $self->{work};
    }
    return $self->{$property} || ''
}
sub html {
    my $self = shift;
    my $header = $self->{header} || '';
    ($header) = read_attributes([['HEAD','HEADER']],@_) if (defined $_[0]);

    return $header . $self->output()
}
#
# Internal functions
#
sub _exec_directive {
    my ($hr, $directive, $sig) = @_;
    
    if (defined($hr->{$directive})) {
        return $hr->{$directive};
    } else {
        return $sig?('<!-- '.$sig.': '.$directive.' -->'):'';
    }
}
sub _analize {
    my ($hr, $directive) = @_;
    if (defined($hr->{$directive})) {
        return $hr->{$directive}
    } 
    return ''
    
}
1;
