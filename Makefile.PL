#!/usr/bin/perl -w
use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'                  => 'TemplateM',
    'VERSION_FROM'          => 'TemplateM.pm', 
    'ABSTRACT_FROM'         => 'TemplateM.pm',
    'PREREQ_PM' => {
           'File::Spec'     => 0.82,
           'LWP'            => 5.80,
           'LWP::UserAgent' => 5.80,
           'HTTP::Headers'  => 5.80,
           'HTTP::Request'  => 5.80,
           'HTTP::Response' => 5.80,
        }, 
    
    'AUTHOR'                => 'Lepenkov Sergey (Serz Minus), <minus@mail333.com>',
);
