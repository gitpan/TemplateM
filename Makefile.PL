require 5.005;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'              => 'TemplateM',
    'VERSION_FROM'      => 'TemplateM.pm', 
    'PREREQ_PM'         => {  # e.g., Module::Name => 1.1
           'File::Spec'  => 0.82,
           'LWP::Simple' => 1.00,
           'HTTP::Request' => 1.00,
           'LWP::UserAgent' => 1.00,
           'HTTP::Headers' => 1.00,
                           }, 
    'ABSTRACT_FROM'     => 'TemplateM.pm', # retrieve abstract from module
    'AUTHOR'            => 'Lepenkov Sergey <minus@mail333.com>',
);
