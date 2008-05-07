package TemplateM;
require 5.005;
use strict;

#
# TemplateM - Templates processing module
#
# Version: 2.21 
# Date   : 06.05.2008
#

=head1 NAME

TemplateM - *ML templates processing module 

=head1 VERSION

Version 2.21 

06 May 2008

=head1 SYNOPSIS

    use TemplateM;
    use TemplateM 2.21;
    use TemplateM 'galore';
    use TemplateM 2.21 'galore';

    $template = new TemplateM(
        -file => 'template_file',
        -login => 'user_login',
        -password => 'user_password',
        -cache => 'cache_files_absolute_path',
        -timeout => 'timeout',
        -header => 'HTTP_header',
        -template => 'HTTP_content'
        );
    my %htm = ( ... );
    $template = new TemplateM(\%htm);

    # DEFAULT:

    $template->cast({label1=>value1, label2=>value2, ... });
    my %h = ( ... );
    $template->cast(\%h);

    $template->cast_loop ("block_label", {label1=>value1, label2=>value2, ... });
    $template->finalize ("block_label);
    
    $template->cast_if('block_label', predicate);

    # GALORE:

    my $block = $template->start('block_label');

    $block->loop(label1 => 'A', label2 => 'B', ... );

    $template->stash(label1 => 'value1', label2 => 'value2', ...);
    $block->stash(label1 => 'value1', ... );

    $template->ifelse("ifblock_label", $predicate)
    $block->ifelse("ifblock_label", $predicate)

    $block->output;

    $block->finish;

    $template->output;
    $template->html("Content-type: text/html\n\n");

=head1 ABSTRACT

The TemplateM module means for text templates processing in XML, HTML, TEXT and so on formats. TemplateM is the alternative to most of standard modules, and it can accomplish remote access to template files, has simple syntax, small size and flexibility. Then you use TemplateM, functionality and data are completely separated, this is quality of up-to-date web-projects.

=head1 TERMS

=head2 Scheme

Set of methods prodiving process template's structures.

=head2 Template

File or array of data which represents the set of instructions, directives and tags of markup languages and statistics.

=head2 Directive

Name of structure in a template for substitution. There are a number of directives:
    
    cgi, val, do, loop, if, else

=head2 Structure

Structure is the tag or the group of tags in a template which defining a scope of substitution.
The structure consist of tag <!-- --> and formatted content:
	
    DIRECTIVE: LABEL

The structure can be simple or complex. Simple one is like this:

    <!-- cgi: foo -->
    or
    <!-- val: bar -->

Complex structure is the group of simple structures which constitutive a "section"

    <!-- do: foo -->
    ...
    <!-- loop: foo -->

    even so:

    <!-- if: foo -->
    ...
    <!-- endif: foo -->
    <!-- else: foo -->
    ...
    <!-- endelse: foo -->

=head2 Label

This is identifier of structure. E.g. foo, bar, baz

    <!-- cgi: foo -->

=head1 DESCRIPTION

=head2 SCHEMES

While defining use it can specify 2 accessible schemes - galore or default.
It is not obligatory to point at default scheme.

Default scheme is basic and defines using of basic methods:

C<cast, cast_if, cast_loop, finalize and html>

Default scheme methods is expedient for small-datasize projects.

Galore scheme is the alternative for base scheme and it defines own set of methods:

C<stash, start, loop, finish, ifelse, output and html>

In order to get knowing which of schemes is activated you need to invoke methods either module() or scheme()

    my $module = $template->module;
    my $module = $template->scheme;

In order to get know real module name of the used scheme it's enough to read property 'module' of $template object

    my $module = $template->{module};

=head2 CONSTRUCTOR

Constructor new() is the principal method independent of selected scheme. Almost simple way to use the constructor is:

    my $template = new TemplateM( -cache => "." );

This invoking takes directive to use template file named index.shtml in current directory and uses the current directory for cache files storage.

Below is the attribute list of constructor:

=over 8

=item file

B<Template filename> is the filename or locations of a template. Supports relative or absolute pathes,
and also template file locator. Relative path can forestall with ./ prefix or without it.
Absolute path must be forestall with / prefix. Template file locator is the URI formatted string.
If the file is missed, it use ``index.shtml' from current directory as default value.

=item login and password

B<User Login> and B<user password> are data for standard HTTP-authorization.
Login and password will be used when the template defined via locator and when remote access is
protected by HTTP-authorization of remote server. When user_login is missed the access to remote
template file realizes simplified scheme, without basic HTTP-authorization.

=item cache

B<Cache> is the absolute or relative path to directory for cache files storage. This directory needs to have a permission to read and write files.
When B<cache> is missed caching is disabled. Caching on is recommended for faster module operations.

=item timeout

B<Timeout> is the period of cache file keeping in integer seconds.
When the value is missed cache file "compiles" once and will be used as template.
Positive value has an effect only then template file is dynamic and it changes in time.
Previous versions of the module sets value 20 instead 0 by default.
It had to set the value -1 for "compilation" disabling.
For current version of the module value can be 0 or every positive number. 0 is
equivalent -1 of previous versions of the module.

=item header

B<HTTP header> uses as value by default before main content template print.

    my $template = new TemplateM( -header => "Content-type: text/html; charset=UTF-8\n\n");
    print $template->html;

=item template

B<HTTP content> (template). This attribute has to be defined when template content is not
able to get from a file or get it from remote locations. E.g. it has to be defined when
a template selects from a database. Defining of this attribute means disabling of
precompile result caching! 

=back

=head2 DEFAULT SCHEME METHODS (BASIC METHODS) 

It is enough to define the module without parameters for using of basic methods.

    use TemplateM;

After that only basic metods will be automatically enabled.

=head3 cast

Modification of labels (cgi labels)

    $template->cast({label1=>value1, label2=>value2, ... });

=over 8

=item label

B<Label> - name will be replaced with appropriate L<value> in tag <!-- cgi: label -->

=item value

B<Value> - Value, which CGI-script sets. Member of L<label>

=back

=head3 cast_loop

Block labels modification (val labels)

    $template->cast_loop (block_label, {label1=>value1, label2=>value2, ... }]);

=over 8

=item block_label

B<Block label> - Block identification name.
The name will be inserted in tags <!-- do: block_label --> and <!-- loop: block_label --> - all content
between this tags processes like labels, but the tag will be formed as <!-- val: label -->

=back

=head3 finalize

Block finalizing

    $template->finalize(block_label);
    
Block finalizing uses for not-processed blocks deleting. You need use finalizing every time you use blockes.

=head3 cast_if

    $template->cast_if(ifblock_label, predicate);

Method analyses boolean value of predicate. If value is true, the method prints if-structure content only.

    <!-- if: label -->
        ... blah blah blah ...
    <!-- end_if: label -->

otherwise the method prints else-structure content only.

    <!-- else: label -->
        ... blah blah blah ...
    <!-- end_else: label -->

=head3 html

Template finalizing

    print $template->html(-header=>HTTP_header);
    print $template->html(HTTP_header);
    print $template->html;

The procedure will return formed document after template processing.
if header is present as argument it will be added at the beginning of template's return.

=head2 GALORE SCHEME METHODS

It is enough to define the module with parameter 'galore' for using of galore scheme methods.

    use TemplateM 'galore';

=head3 stash

stash (or cast) method is the function of import variables value into template.

    $template->stash(title => 'PI' , pi => 3.1415926);

This example demonstrate how all of <!-- cgi: title --> and <!-- cgi: pi --> structures
will be replaced by parameters of stash method invoking.

In contrast to default scheme, in galore scheme stash method process directives <!-- cgi: label --> only
with defined labels when invoking, whereas cast method of default scheme precess all of
directives <!-- cgi: label --> in template!

=head3 start and finish

Start method defines the beginning of loop, and finish method defines the end.
Start method returns reference to the subtemplate object, that is all between do and loop directives.

    <!-- do: block_label -->
        ... blah blah blah ...
            <!-- val: label1 -->
            <!-- val: label2 -->
            <!-- cgi: label -->
        ... blah blah blah ...
    <!-- loop: block_label -->

    my $block = $template->start(block_label);
    ...
    $block->finish;

For acces to val directives it is necessary to use loop method, and for access to cgi directives use stash method.

=head3 loop

The method takes as parameters a hash of arguments or a reference to this hash.

    $block->loop(label1 => 'A', label2 => 'B');
    $block->loop({label1 => 'A', label2 => 'B'});

Stash method also can be invoked in $block object context.

    $block->stash(label => 3.1415926);

=head3 ifelse

    $template->ifelse("ifblock_label", $predicate)
    $block->ifelse("ifblock_label", $predicate)

Method is equal to cast_if method of default scheme. The difference, ifelse method
can be processed with $template or $block, whereas cast_if method has deal with $template object.

=head3 output

The method returns result of template processing. Output method has deal with $template and $block object:

    $block->output;
    $template->output;

=head3 html

The method is completely equal to html method of default scheme.

=head2 TEMPLATEM'S AND SSI DIRECTIVES

The module can be used with SSI directives together, like in this shtml-sample:
    
    <html>
        <!--#include virtual="head.htm"-->
    <body>
        <center><!-- cgi: head --><center>
        <!-- do: BLOCK_P -->
            <p><!-- val: content --></p>
        <!-- loop: BLOCK_P -->
    </body>
    </html>

=head1 ENVIRONMENT

No environment variables are used.

=head1 BUGS

Please report them.

=head1 SEE ALSO

LWP, CGI

=head1 DIAGNOSTICS

The usual warnings if it cannot read or write the files involved.

=head1 HISTORY

1.00 Initial release

1.10 Working with cache ability is added

1.11 Inner method's interface had structured

1.21 New time managment for templates caching. You can set how long template file will be cached before renew. 

2.00 New abilities

    * Simultaneous templates using errors is eliminated.
    * Alternate interface of using methods is added.
    * Method of conditional representation of template CAST_IF is added.

2.01 Cache-file access errors corrected

2.20 Module structure has rebuilt and changes has done

    * galore scheme added
    * update method deleted and constructor interface changed
    * errors of cachefile compiling was corrected
      (prefix is deleted, CRLF consecution output is corrected)
    * UTF-8 codepage for templates added
    * mod_perl 1.00 and 2.00 support added

2.21 Mass data processing error under MS Windows is corrected

=head1 TODO

    * simultaneous multiple declared do-loop structure blocks processing.

=head1 THANKS

Thanks to Dmitry Klimov for technical translating C<http://fla-master.com>.

=head1 AUTHOR

Lepenkov Sergey (Serz Minus), C<minus@mail333.com>

=head1 COPYRIGHTS

Copyright (C) 1998-2008 D&D Corporation. All Rights Reserved

=cut

use vars qw($VERSION);
our $VERSION = 2.21;
our @ISA;

use TemplateM::Util;

use LWP::Simple;
use HTTP::Request;
use LWP::UserAgent;
use HTTP::Headers;

use File::Spec;

my $mpflag = 0;
if (exists $ENV{MOD_PERL}) {
    if (exists $ENV{MOD_PERL_API_VERSION} && $ENV{MOD_PERL_API_VERSION} == 2) {
        $mpflag = 2;
        require Apache2::Response;
        require Apache2::RequestRec;
        require Apache2::RequestUtil;
        require Apache2::RequestIO;
        require APR::Pool;
    } else {
        $mpflag = 1;
        require Apache;
    }
}

my $os = $^O || 'Unix';
my %modules = (
        default => "Simple",
        galore  => ($os eq 'MSWin32' or $os eq 'NetWare') ? "GaloreWin32" : "Galore"
    );
my $module;

sub import {
    my ($class, @args) = @_;
    my $mdl = shift(@args) || 'default';
    $module = $modules{lc($mdl)} || $modules{default};
    require "TemplateM/$module.pm";
    @ISA = ("TemplateM::$module");
}

sub new {
    my $class = shift;
    my @arg = @_;
    
    # GET Args
    my ($file, $login, $password, $cachedir, $timeout, $header, $template);
    ($file, $login, $password, $cachedir, $timeout, $header, $template) = read_attributes(
        [
            ['FILE','URL'],
            ['LOGIN','USER'],
            'PASSWORD',
            ['CACHE','CACHEFILE','CACHEDIR'],
            ['TIMEOUT','TIME','INTERVAL'],
            ['HEAD','HEADER'],
            ['TEMPLATE','TPL','TMPL','TPLT','TMPLT','CONTENT']
        ], @arg ) if defined $arg[0];
    
    # DEFAULTS & BLESS
    $file ||= 'index.shtml';
    my $cache = _get_cachefile($cachedir, $file);


    unless ($template) {
        if ( _timeout_ok($cache, $timeout) ) {     
            $template = load_url($file, $login, $password);
            if ($cache) {
                if ($template eq '') {
                    $template = load_cache($cache);
                } else {
                    save_cache($cache, $template);
              }
            }
        } else {
            $template = load_cache($cache) if $cache;
        }
    }

    templatem_error("[new] An error occurred while trying to obtain the resource $file") unless $template;

    my $stk = $modules{galore} eq "GaloreWin32" ? [] : '';
    
    my $self = bless {
            timeout  => $timeout  || 0,
            file     => $file     || '',
            login    => $login    || '',
            password => $password || '',
            cachedir => $cachedir || '',
            cache    => $cache    || '',
            template => $template || '',
            header   => $header   || '',
            module   => $module   || '',
            work     => $template || '',
            stackout => $stk,
            looparr  => {}
        }, $class;
    
    return $self;
}
sub module {
    my $self = shift;
    my %hm = reverse %modules;
    lc($hm{$self->{module}})
}
sub scheme { module( @_) }
sub schema { module( @_) }
sub load_url {
    my $file = shift || '';
    my $login = shift || '';
    my $password = shift || '';

    my $url = '';
    my $html = '';

    if ($file =~/^\//) {
        $url = _get_uri($file, 0);
    } elsif ($file =~/^\w+\:\/\//) {
        $url = $file;
    } else {
        $url = _get_uri($file, 1);
    }   

    if ($login eq '') {
        $html = get($url);
    } else {
        my $ua = new LWP::UserAgent; 
        my $req = new HTTP::Request(GET => $url);
        $req->authorization_basic($login, $password); 
        my $res = $ua->request($req);
        $html = $res->is_success?$res->content : '';
    }

    return $html;
}

sub save_cache {
    my $cachefile = shift || '';
    my $dataarea  = shift || '';
    
    local *CACHE;
    open CACHE, ">$cachefile" or templatem_error("[save_cache] An error occurred while trying to write in $cachefile");
        binmode CACHE;
        flock CACHE, 2 or templatem_error("[save_cache] An error occurred while blocking in $cachefile"); 
        print CACHE $dataarea;
    close CACHE;
}

sub load_cache {
    my $cachefile = shift || '';
    my $htmlret='';
 
    local *CACHE;
   
    if ($cachefile && -e $cachefile) {

        open CACHE, "$cachefile" or templatem_error("[load_cache] An error occurred while trying to read from $cachefile");
            read(CACHE, $htmlret, -s $cachefile) unless -z $cachefile;
        close CACHE;
    } else {
        templatem_error("[load_cache] An error occurred while opening $cachefile");
    }
    
    templatem_error ("File $cachefile is empty") unless $htmlret;
    
    return $htmlret;
}


sub templatem_error {
    my $message = shift || 'An error in the module TemplateM';
    die($message)
}
sub _timeout_ok {
    my $cachefile = shift || '';
    my $timeout   = shift || 0;
    
    return 1 unless $cachefile && -e $cachefile;

    my @statfile = stat($cachefile);
    
    return 0 unless $timeout;

    if ((time()-$statfile[9]) > $timeout) {
        return 1;
    } else {
        return 0;
    } 
}

sub _get_cachefile {
    my ($dir, $file) = @_;
    return '' unless $dir;
    
    $file=~s/[.\/\\:?&%]/_/g;
    
    return File::Spec->catfile($dir,$file)
}

sub _get_uri {
    my $file = shift || '';
    my $tp   = shift || '0';
    return '' unless $file;
    my $request_uri = $ENV{REQUEST_URI} || '';
    my $hostname    = $ENV{HTTP_HOST}   || '';
    
    my $r;
    if ($mpflag) {
        if ($mpflag == 2) {
            # mod_perl 2
            eval('$r = Apache2::RequestUtil->request()');
        } elsif ($mpflag == 1) {
            # mod_perl 1
            eval('$r = Apache->request()');
        }
        $request_uri = $r->uri();
        $hostname = $r->hostname();
    }
    
    $request_uri =~ s/\?.+$//;
    $request_uri = $1 if $request_uri =~ /^\/(.+\/).*/;

    my $url = "http://";
    if ($tp == 1) {
        # 1
        $file =~ s/^\.?\/+//;
        $url .= $hostname.'/'.$request_uri.$file;
    } else {
        # 0
        $url .= $hostname.$file;
    }

    return $url;
}
sub AUTOLOAD {
    my $self = shift;
    $self->html(@_)
}
sub DESTROY {
    my $self = shift;
    undef($self);
}

1;

__END__

