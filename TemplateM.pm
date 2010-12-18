package TemplateM;
require 5.005;
use strict;

#
# TemplateM - *ML templates processing module 
#
# Version: 3.00 
# Date   : 14.12.2010
#
# $Revision: 1.2 $
#
# $Id: TemplateM.pm,v 1.2 2010/12/18 17:59:15 abalama Exp $
#

=head1 NAME

TemplateM - *ML templates processing module 

=head1 VERSION

Version 2.23 

26 May 2008

=head1 SYNOPSIS

    use TemplateM;
    use TemplateM 3.00;
    use TemplateM 'galore';
    use TemplateM 3.00 'galore';

    $template = new TemplateM(
            -file => 'http://localhost/foo.shtml',
            -utf8 => 1,
        );

    # DEFAULT:

    $template->cast({foo => 'value1', bar => 'value2', ... });
    my %h = ( ... );
    $template->cast(\%h);

    $template->cast_loop ("block_label", {foo => 'value1', bar => 'value2', ... });
    $template->finalize ("block_label);

    $template->cast_if('block_label', $predicate);

    # GALORE:

    my $block = $template->start('block_label');
    $block->loop(foo => 'value1', bar => 'value2', ... );

    $template->stash(foo => 'value1', bar => 'value2', ...);
    $block->stash(baz => 'value1', ... );

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
    
    cgi, val, do, loop, if, endif, else, endelse

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
        <!-- val: bar -->
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

    my $template = new TemplateM( -template => "blah-blah-blah" );

This invoking takes directive to use simple text as template.

Below is the attribute list of constructor:

=over 8

=item asfile

B<Asfile flag> designates either path or filehandle to file is passed for reading from disk, bypassing 
the method of remote obtaining of a template.

=item cache

B<Cache> is the absolute or relative path to directory for cache files storage. This directory needs to have a permission to read and write files.
When B<cache> is missed caching is disabled. Caching on is recommended for faster module operations.

=item file

B<Template filename> is the filename, opened filehandler (GLOB) or locations of a template. 
Supports relative or absolute pathes,
and also template file locator. Relative path can forestall with ./ prefix or without it.
Absolute path must be forestall with / prefix. Template file locator is the URI formatted string.
If the file is missed, it use ``index.shtml' from current directory as default value.

=item header

B<HTTP header> uses as value by default before main content template print (method html).

    my $template = new TemplateM( -header => "Content-type: text/html; charset=UTF-8\n\n");
    print $template->html;

=item login and password

B<User Login> and B<user password> are data for standard HTTP-authorization.
Login and password will be used when the template defined via locator and when remote access is
protected by HTTP-authorization of remote server. When user_login is missed the access to remote
template file realizes simplified scheme, without basic HTTP-authorization.

=item method

B<Request method> points to method of remote HTTP/HTTPS access to template page. Can take values: "GET", 
"HEAD", "PUT" or "POST". HEAD methods can be used only for headers getting.

=item onutf8 or utf8

B<onutf8 flag> turn UTF8 mode for access to a file. The flag allow to get rid of a forced setting utf-8 
flag for properties template and work by method Encode::_utf8_on() 

=item template

B<HTTP content> (template). This attribute has to be defined when template content is not
able to get from a file or get it from remote locations. E.g. it has to be defined when
a template selects from a database. Defining of this attribute means disabling of
precompile result caching! 

=item timeout

B<Timeout> is the period of cache file keeping in integer seconds.
When the value is missed cache file "compiles" once and will be used as template.
Positive value has an effect only then template file is dynamic and it changes in time.
Previous versions of the module sets value 20 instead 0 by default.
It had to set the value -1 for "compilation" disabling.
For current version of the module value can be 0 or every positive number. 0 is
equivalent -1 of previous versions of the module.

=item reqcode

B<Request code> is the pointer to the subroutine must be invoked for HTTP::Request object 
after creation via method new.

Sample:

    -reqcode => sub { 
        my $req = shift;
        ...
        $req-> ...
        ...
        return 1;
    }

=item rescode

B<Response code> is the pointer to the subroutine must be invoked for HTTP::Response after 
creation via calling $ua->request($req).

Sample:

    -rescode => sub { 
        my $res = shift;
        ...
        $res-> ...
        ...
        return 1;
    }      

=item uacode

B<UserAgent code> is the pointer to the subroutine must be invoked for LWP::UserAgent after 
creation via method new().

Sample:

    -uacode => sub { 
        my $ua = shift;
        ...
        $ua-> ...
        ...
        return 1;
    }

=item uaopts

B<UserAgent options> is the pointer to the hash containing options for defining parameters of 
UserAgent object's constructor. (See LWP::UserAgent)

Example:

    -uaopts => {
        agent                 => "Mozilla/4.0",
        max_redirect          => 10,
        requests_redirectable => ['GET','HEAD','POST'],
        protocols_allowed     => ['http', 'https'], # Required Crypt::SSLeay
        cookie_jar            => new HTTP::Cookies(
                file     => File::Spec->catfile("/foo/bar/_cookies.dat"),
                autosave => 1 
            ),
        conn_cache            => new LWP::ConnCache(),
    }

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

B<Value> - Value, which CGI-script sets. Member of the L<label> manpage

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

=head2 EXAMPLE

In test.pl file:

    use TemplateM 3.00 'galore';

    my $tpl = new TemplateM(
        -file   => 'test.tpl',
        -asfile => 1,
    );

    $tpl->stash(
        module  => (split(/\=/,"$tpl"))[0],
        version => $tpl->VERSION,
        scheme  => $tpl->scheme()." / ".$tpl->{module},
        date    => scalar(localtime(time())),
    );

    my $row_box = $tpl->start('row');
    foreach my $row ('A'..'F') {
        $row_box->loop({});
        my $col_box = $row_box->start('col');
        foreach my $col (1...6) {
            $col_box->loop( foo  => $row.$col );
            $col_box->cast_if(div=>(
                    ('A'..'F')[$col-1] ne $row
                    &&
                    ('A'..'F')[6-$col] ne $row
                ));
        }
        $col_box->finish;
    }
    $row_box->finish;

    binmode STDOUT, ':raw';
    print $tpl->output();

In test.tpl file:

    **********************
    *                    *
    *  Simple text file  *
    *                    *
    **********************

    Table
    =====
    <!-- do: row -->
    +-----------------+
    |<!-- do: col --><!-- if: div --><!-- val: foo --><!-- endif: div -->
    <!-- else: div -->  <!-- endelse: div -->|<!-- loop: col --><!-- loop: row -->
    +-----------------+

    Data
    ====

    Module       : <!-- cgi: module -->
    Version      : <!-- cgi: version -->
    Scheme       : <!-- cgi: scheme -->
    Current date : <!-- cgi: date -->

Result:

    **********************
    *                    *
    *  Simple text file  *
    *                    *
    **********************

    Table
    =====

    +-----------------+
    |  |A2|A3|A4|A5|  |
    +-----------------+
    |B1|  |B3|B4|  |B6|
    +-----------------+
    |C1|C2|  |  |C5|C6|
    +-----------------+
    |D1|D2|  |  |D5|D6|
    +-----------------+
    |E1|  |E3|E4|  |E6|
    +-----------------+
    |  |F2|F3|F4|F5|  |
    +-----------------+

    Data
    ====

    Module       : TemplateM
    Version      : 3.00
    Scheme       : galore / GaloreWin32
    Current date : Sat Dec 18 12:37:10 2010

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

C<LWP>, C<LWP::UserAgent>, C<HTTP::Request>, C<HTTP::Response>, C<HTTP::Headers>

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

2.22 Files in the distribution package are changed

2.23 File access errors corrected

3.00 Changes:

    * Full UTF8 support added
    * Direct reading of template file from a disk added
    * SSL (HTTPS) support added
    * Error while getting template via LWP::Simple module fixed
    * Ability of use UserAgent, Request and Response objects added (see libwww-perl)

=head1 TODO

    * simultaneous multiple declared do-loop structure blocks processing.

=head1 THANKS

Thanks to Dmitry Klimov for technical translating C<http://fla-master.com>.

=head1 AUTHOR

Lepenkov Sergey (Serz Minus), C<minus@mail333.com>

=head1 COPYRIGHTS

Copyright (C) 1998-2010 D&D Corporation. All Rights Reserved

=cut

use vars qw($VERSION);
our $VERSION = '3.00';
our @ISA;

use Encode;
use Carp qw/croak confess carp cluck/;
use File::Spec;

use TemplateM::Util;

use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use HTTP::Headers;

my $mpflag = 0;
if (exists $ENV{MOD_PERL}) {
    if (exists $ENV{MOD_PERL_API_VERSION} && $ENV{MOD_PERL_API_VERSION} == 2) {
        $mpflag = 2;
        require Apache2::Response;
        require Apache2::RequestRec;
        require Apache2::RequestUtil;
        require Apache2::RequestIO;
        require Apache2::ServerRec;
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

BEGIN {
    sub errstamp { "[".(caller(1))[3]."]" }
}

sub new {
    my $class = shift;
    my @arg = @_;
    
    # GET Args
    my ($file, $login, $password, $cachedir, $timeout, $header, $template, 
        $asfile, $onutf8, $method, $uaopt, $uacode, $reqcode, $rescode);
    ($file, $login, $password, $cachedir, $timeout, $header, $template,
        $asfile, $onutf8, $method, $uaopt, $uacode, $reqcode, $rescode) = read_attributes(
        [
            [qw/FILE URL FILENAME URI/],
            [qw/LOGIN USER/],
            [qw/PASSWORD PASSWD/],
            [qw/CACHE CACHEFILE CACHEDIR/],
            [qw/TIMEOUT TIME INTERVAL/],
            [qw/HEAD HEADER/],
            [qw/TEMPLATE TPL TMPL TPLT TMPLT CONTENT/],
            
            [qw/ASFILE ONFILE/],
            [qw/UTF8 UTF-8 ONUTF8 ASUTF8 UTF8ON UTF8_ON ON_UTF8 USEUTF8/],
            [qw/METH METHOD/], #  "GET", "HEAD", "PUT" or "POST".
            [qw/UAOPT UAOPTS UAOPTION UAOPTIONS UAPARAMS/],
            
            [qw/UACODE/],
            [qw/REQCODE/],
            [qw/RESCODE/],
            
        ], @arg ) if defined $arg[0];

    # DEFAULTS & BLESS
    $file ||= 'index.shtml';
    my $cache = '';
    if (ref $file eq 'GLOB') {
        $asfile = 1;
    } else {
        $cache = _get_cachefile($cachedir, $file);
    }

    unless (defined $template) {
        if ($asfile) {
            $template = _load_file($file, $onutf8);
        } else {
            if ( _timeout_ok($cache, $timeout) ) {
                $template = _load_url(
                        $file, $login, $password, $onutf8, $method,
                        $uaopt, $uacode, $reqcode, $rescode
                    );
                if ($cache) {
                    if ($template eq '') {
                        $template = _load_cache($cache, $onutf8);
                    } else {
                        _save_cache($cache, $onutf8, $template);
                    }
                }
            } else {
                $template = _load_cache($cache, $onutf8) if $cache;
            }
        }
    }

    Encode::_utf8_on($template) if $onutf8;

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
            # Galore
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
sub scheme { module( @_ ) }
sub schema { module( @_ ) }
sub AUTOLOAD {
    my $self = shift;
    $self->html(@_)
}
sub DESTROY {
    my $self = shift;
    undef($self);
}

sub _load_url {
    my $file     = shift || '';
    my $login    = shift || '';
    my $password = shift || '';
    my $onutf8   = shift || 0;
    my $method   = shift || 'GET';
    my $uaopt    = shift || {};
    my $uscode   = shift || undef;
    my $reqcode  = shift || undef;
    my $rescode  = shift || undef;

    my $url  = '';
    my $html = '';

    if ($file =~/^\//) {
        $url = _get_uri($file, 0);
    } elsif ($file =~/^\w+\:\/\//) {
        $url = $file;
    } else {
        $url = _get_uri($file, 1);
    }   

    my $ua  = new LWP::UserAgent(%$uaopt); 
    $uscode->($ua) if ($uscode && ref($uscode) eq 'CODE');
    my $req = new HTTP::Request(uc($method), $url);
        $req->authorization_basic($login, $password) if $login;
        $reqcode->($req) if ($reqcode && ref($reqcode) eq 'CODE');
    my $res = $ua->request($req);
        $rescode->($res) if ($rescode && ref($rescode) eq 'CODE');
    if ($res->is_success) {
        if ($onutf8) {
            $html = $res->decoded_content || '';
            Encode::_utf8_on($html);
        } else {
            $html = $res->content || '';
        }
    } else {
        carp(errstamp," An error occurred while trying to obtain the resource \"$url\" (",$res->status_line,")");
    }

    return $html;
}
sub _save_cache {
    my $cf      = shift || '';
    my $onutf8 = shift;
    my $content = shift || '';
    my $OUT;

    my $flc = 0;
    if (ref $cf eq 'GLOB') {
       $OUT = $cf;
    } else {
        open $OUT, '>', $cf or croak(errstamp," An error occurred while trying to write in file \"$cf\" ($!)");
        flock $OUT, 2 or croak(errstamp," An error occurred while blocking in file \"$cf\" ($!)");
        $flc = 1;
    }

    binmode $OUT, ':raw:utf8' if $onutf8;
    binmode $OUT unless $onutf8;
    print $OUT $content;
    close $OUT if $flc;
    return 1;
}
sub _load_cache {
    my $cf = shift || '';
    my $onutf8 = shift;
    my $IN;

    if ($cf && -e $cf) {
        if (ref $cf eq 'GLOB') {
            $IN = $cf;
        } else {
            open $IN, '<', $cf or croak(errstamp," An error occurred while trying to read from file \"$cf\" ($!)");
        }
        binmode $IN, ':raw:utf8' if $onutf8;
        binmode $IN unless $onutf8;
        return scalar(do { local $/; <$IN> });
    } else {
        carp(errstamp," An error occurred while opening file \"$cf\" ($!)");
    }

    return '';
}
sub _load_file {
    my $fn     = shift || '';
    my $onutf8 = shift;
    my $IN;

    if (ref $fn eq 'GLOB') {
        $IN = $fn;
    } else {
        open $IN, '<', $fn or croak(errstamp," An error occurred while trying to read from file \"$fn\" ($!)");
    }
    binmode $IN, ':raw:utf8' if $onutf8;
    binmode $IN unless $onutf8;
    return scalar(do { local $/; <$IN> });
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
    my $server_port = $ENV{SERVER_PORT} || '';

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
        $hostname    = $r->hostname();
        $server_port = $r->server->port();
    }

    $request_uri =~ s/\?.+$//;
    $request_uri = ($request_uri =~ /^\/(.+\/).*/ ? $1 : '');

    my $url = "http://";
    $url = "https://" if $server_port eq '443';

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


1;

__END__

