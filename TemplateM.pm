package TemplateM;
require 5.008;
$VERSION = "2.01";

#
# TemplateM - модуль работы с шаблонами 
#
# Version: 2.01 
# Date   : 23.10.2006
#


=head1 NAME

TemplateM - Templates processing module 

=head1 VERSION

Version 2.01 
23.10.2006

=head1 SYNOPSIS
    
unshift(@INC,module_directory_absolute_path);
require TemplateM;

or: 

use lib module_directory_absolute_path; # if the module is installed in user's directory
use TemplateM; 

=head2 Object $template creation

as list:

$template = new TemplateM(template_file,username,user_password, cache_files_absolute_path, timeout, http_header);

or as implicit hash array (every key of hash array must be forestall the "-" sign):

$template = new TemplateM(-file=>'template_file',-user=>'username',-password=>'user_password',
            -cache=>'cache_files_absolute_path', -timeout=>'timeout', -header=>'HTTP_header');

or as reference to hash array or as hash array:

$template = new TemplateM({file=>'template_file',user=>'username',password=>'user_password',
            cache=>'cache_files_absolute_path', timeout=>'timeout', header=>'HTTP_header'});


=head2 Update object $template

$template->update(template_file, username, user_password, cache_files_absolute_path, timeout, http_header);

Method "update" is used like "new" method, but "new" method is more prefer

=over 8

=item template_file

B<template filename>. The template file have to be located in CGI-script directory or one level up directory. 
    
If the module can't able to obtain access to the file, the error message will be evoked. 

=item username

B<username> of virtual client. The username have to be present in .htaccess file (or in other Apache's configuration file like .htaccess).
    
Set username blank then you don't use HTTP-authorization via Apache. 

=item user_password

B<User password> of virtual client. See L<username>

=item cache_files_absolute_path

B<Absolute path> to the cache directory. Cache will not be used when this parameter is not presented.

=item timeout

B<Timeout> is the period (in seconds) of template's updating delay. Default value is 1200 seconds.

if updating delay parameter is "-1" the updating delay will be perpetual

=item HTTP_header

B<HTTP_header> is used to send a raw HTTP header before template processing by html method

=back

=head2 Modification of labels (cgi labels)

$template->cast({label=>value, label=>value, ...=>...});

or

$template->cast(label=>value, label=>value, ...=>...);

=over 8

=item label

B<Label> - name will be replaced with appropriate L<value> in tag <!-- cgi: label -->

=item value

B<Value> - Value, which CGI-script sets. Member of L<label>

=back

=head2 Block labels modification (val labels)

$template->cast_loop ("block_name", [{label=>value, label=>value, ...=>...}]);

or

$template->cast_loop ("block_name", {label=>value, label=>value, ...=>...});

or

$template->cast_loop ("block_name", %hash);

=over 8

=item block_name

B<Block_name> - Block identification name. The name will be inserted in tags <!-- do: block_name --> and <!-- loop: block_name --> - all content between this tags processes like labels, but the tag will be formed as <!-- val: label -->

=back


=head2 CAST_IF method

$template->cast_if('block_name', 'condition');

method prints blocks according to the condition.

if condition is true the if-block will be printed:

<!-- if: name -->
    block content if
<!-- end_if: name -->

and else-block not will be printed.

If the condition is false,  vice versa, else-block will be printed and if-block will be passed

In all of cases names of this blocks must bethe same!

=head2 Block finalizing

$template->finalize(block_name);
    
Block finalizing uses for not-processed blocks deleting. You need use finalizing every time you use blockes.

=head2 Template finalizing

print $template->html(-header=>'HTTP_header') || 'Inner error!';

or

print $template->html({header=>'HTTP_header'}) || 'Inner error!';

or

print $template->html('HTTP_header') || 'Inner error!';

The procedure will return formed document after template processing.
if header is present as argument it will be added at the beginning of template's return.

=head1 DESCRIPTION

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

=head1 SEE ALSO

perl

=head1 DIAGNOSTICS

The usual warnings if it cannot read or write the files involved.

=head1 HISTORY

1.00 Initial release

1.10 Working with cache ability is added

1.11 Inner method's interface had structured

1.21 New time managment for templates caching. You can set how long
     template file will be cached before renew. 

2.00 - Simultaneous templates using errors is eliminated.
     - Alternate interface of using methods is added.
     - Method of conditional representation of template CAST_IF is added.

2.01 


=head1 THANKS

Thanks to Andrew Syrba for useful and valuable information.

Thanks to Dmitry Klimov for technical translating.

=head1 AUTHOR

Lepenkov Sergey (Serz Minus), C<minus@mail333.com>

=head1 COPYRIGHTS

Copyright (C) 1998-2006 D&D Corporation. All Rights Reserved

=cut

my $self;  

BEGIN {
  use LWP::Simple;
  use HTTP::Request;
  use LWP::UserAgent;
  use HTTP::Headers;
}

sub new {
    my $class = shift;
    my @arg = @_;
    
    my ($file, $login, $password, $cachedir, $timeout, $header) =
    _read_attributes ([[FILE,URL],[LOGIN,USER],PASSWORD,[CACHE,CACHEFILE,CASH],[TIMEOUT,'TIME',INTERVAL],[HEAD,HEADER]],@arg) if defined $arg[0];
    
    $self = bless {
            timeout => 0,
            file => '',
            login => '',
            password => '',
            cachedir => '',
            template => '',
            header=>''
        },$class; # Строим объект
    
    $self->{timeout} = $timeout || 1200;     # Таймаут доступа к шаблону (20 минут)
    $self->{file} = $file || 'index.shtml';  # Имя файла шаблона
    $self->{login} = $login       || '';     # Логин виртуального клиента 
    $self->{password} = $password || '';     # Пароль виртуального клиента
    $self->{cachedir}=$cachedir || '';       # Путь до файлов кэша
    $self->{header}= $header || '';          # HTTP заголовок, если при выводе он требуется
    
    if (&timeout_ok($self->{file},$self->{cachedir})) {     
      # Файл старый или не указан вообще или его ни разу не записывали!
      $self->{template}= &geturl($self->{file},$self->{login},$self->{password}); # Принимаем ресурс
      if ($self->{cachedir}) {               # Указан путь до кэша?
          if ($self->{template} eq '') {     # Не принялся URL
            $self->{template}=&load_cache($self->{file},$self->{cachedir});
          } else {                           # Принялся URL
            &save_cache($self->{file},$self->{cachedir},$self->{template});
          }
      }
    } else {
      $self->{template}=&load_cache($self->{file},$self->{cachedir});
    }

    &template_error ("An error occurred while trying to obtain the resource (Ошибка получения ресурса):<br><br><i>".$self->{file}."</i>") unless $self->{template};
    return $self;
}


sub update {
    my $self = shift;
    my @arg = @_;
    
    my ($file, $login, $password, $cachedir, $timeout, $header) =
        _read_attributes ([[FILE,URL],[LOGIN,USER],PASSWORD,[CACHE,CACHEFILE,CASH],[TIMEOUT,'TIME',INTERVAL],[HEAD,HEADER]],@_) if defined $arg[0];


    $self->{timeout} = $timeout || 1200;   # Таймаут доступа к шаблону (20 минут)
    $self->{login} = $login  || '';
    $self->{password} = $password || '';
    $self->{cachedir}=$cachedir || '';
    $self->{file} = $file || 'index.shtml';# Имя файла шаблона
    $self->{header}= $header || '';          # HTTP заголовок, если при выводе он требуется

    if (&timeout_ok($self->{file},$self->{cachedir})) {     
      $self->{template}= &geturl($self->{file},$self->{login},$self->{password});
      if ($self->{cachedir}) {
        if ($self->{template} eq '') {
          $self->{template}=&load_cache ($self->{file},$self->{cachedir});
        } else {                    
          &save_cache ($self->{file},$self->{cachedir},$self->{template});
        }
      }
    } else {
      $self->{template}=&load_cache($self->{file},$self->{cachedir});
    }

    &template_error ("An error occurred while trying to obtain the resource (Ошибка получения ресурса при обновлении):<br><br><i>".$self->{file}."</i>") unless $self->{template};
    return $self;
}

sub cast {
    # Модифицируем все значения (cgi:)
    # my ($self, $hr) = @_;
    my $self = shift;
    my $hr = $_[0];
    &template_error("Incorrect call of method \"CAST\"!") unless $hr;
    unless (ref($hr) eq "HASH") {
        $hr={@_};
    }
    
    $self->{template}=~s/<!--\s*cgi:\s*(\S+?)\s*-->/_exec_directive($hr, $1)/ieg;
    return $self->{template};
}

sub cast_loop {
    # Модифицируем блок (do: - loop:)
    my $self = shift;
    my $name = shift || '';
    &template_error("Incorrect call of method \"CAST_LOOP\"!") unless ($name);
    my $ar = $_[0];
    
    if (ref($ar) eq "HASH") {
       $ar=[$_[0]];
    } else {
        $ar = [{@_}] if ref($ar) ne "ARRAY";
    }
    
    $self->{template} =~ m/<!--\s*do:\s*$name\s*-->(.*)<!--\s*loop:\s*$name\s*-->/s;
    my $pattern = $1 || '';
    my $pattern_copy = $pattern;
    my $out;
    foreach (@{$ar}) {
      $pattern = $pattern_copy;
      $pattern =~ s/<!--\s*val:\s*(\S+?)\s*-->/_exec_directive($_,$1)/ieg;
      $out.=$pattern;
    }
   
    $self->{template} =~ s/(<!--\s*do:\s*$name\s*-->).*(<!--\s*loop:\s*$name\s*-->)/$out$1$pattern_copy$2/s;

    return $self->{template};
}

sub finalize {
    # Завершаем блок (do: - loop:)
    my $self = shift;
    my $name = shift;
    &template_error("Incorrect call of method \"FINALIZE\"!") unless ($name);
    
    $self->{template} =~ s/<!--\s*do:\s*$name\s*-->.*<!--\s*loop:\s*$name\s*-->//s;
    return $self->{template};
}

sub cast_if {
    my $self = shift;
    my $name = shift;
    my $predicate = shift || 0;
    &template_error("Incorrect call of method \"CAST_IF\"!") unless ($name);
    
    if ($predicate) {
       $self->{template} =~ s/<!--\s*if:\s*$name\s*-->(.*)<!--\s*end_?if:\s*$name\s*-->/$1/s;
       $self->{template} =~ s/<!--\s*else:\s*$name\s*-->.*<!--\s*end_?else:\s*$name\s*-->//s;
    } else { 
       $self->{template} =~ s/<!--\s*else:\s*$name\s*-->(.*)<!--\s*end_?else:\s*$name\s*-->/$1/s;
       $self->{template} =~ s/<!--\s*if:\s*$name\s*-->.*<!--\s*end_?if:\s*$name\s*-->//s;
    }

    return $self->{template};
}


sub html {
    # Выдаем результат на печать
    my $self = shift;
    my $header = $self->{header} || '';
    ($header) = _read_attributes ([[HEAD,HEADER]],@_) if (defined $_[0]);
    return $header.$self->{template};
}

sub _exec_directive {
    # Выполняем внутреннюю директиву
    my ($hr, $directive) = @_;
    
    if (defined($hr->{$directive})) {
        return $hr->{$directive};
    } else {
        return '';
    }
}


sub geturl {
  #
  # Получение ресурса простым или аутентификационным способом в зависимости от аргумента
  #
  
  # Поддерживаются 3 режима работы. 
  #   - По пути относительно текуще папки
  #   - По пути относительно WEB-сервера
  #   - По адресу внешнего URL
  
  my ($file,$login,$password)=@_;
  my ($url,$html);

  my $hostname = $ENV{HTTP_HOST} || '';
  my $curent_file = $ENV{SCRIPT_NAME} || '';
  $curent_file=~m/^\/(.+\/).*/;       
  my $find = $1 || '';
  if ($file =~/^\//) {
    # Файл указан относительно хоста
    $url='http://'.$hostname.$file;
  } else {
    # Файл указан относительно текущего пути
    $url='http://'.$hostname.'/'.$find.$file;
  }   
  if ($file =~/^http\:\/\//) {
    # Файл указан абсолютным URL
    $url = $file;
  }


  if ($login eq '') {
    $html=get($url);
  } else {
    my $ua = new LWP::UserAgent; 
    my $req = new HTTP::Request(GET => $url);
    $req->authorization_basic($login, $password); 
    my $res=$ua->request($req);
    $html= $res->is_success?$res->content : '';
  }

return $html;
}

sub save_cache {
    my ($file,$cachedir,$dataarea)=@_;
    my $ident_path=$file;
    $ident_path=~s/(\.)|(\/)|(\\)|(:)|(\?)|(\&)|(\%)/_/g;
    my $filename=$cachedir."/".$ident_path;

    open CACHE, ">$filename" or &template_error ("An error occurred while trying to write in (Ошибка записи файла) <br>$filename");
      flock CACHE,2; 
      print CACHE "<!--- CACHE-FILE: $ident_path - ".&current_dt." --->\n\n";
      print CACHE $dataarea;
    close CACHE;
}

sub load_cache {
    my ($file,$cachedir)=@_;
    my $htmlret='';
    my $fname;
    if ($file) { # Файл указан!
        my $ident_path=$file;
        $ident_path=~s/(\.)|(\/)|(\\)|(:)|(\?)|(\&)|(\%)/_/g;
        $fname=$cachedir."/".$ident_path;
        if (-e "$fname") {
            open CACHE, "$fname" or &template_error ("An error occurred while trying to read from (Ошибка чтения файла)<br>$fname");
            flock CACHE,2;
                while (<CACHE>){
                   $htmlret.=$_;
                }
            close CACHE;
        }
    }
    
    &template_error ("An error occurred while trying to obtain the resource (Ошибка получения ресурса)<br><br><i>$file</i><br><br>or read file (или чтения файла)<br><br><i>$fname</i>") unless $htmlret;
    return $htmlret||'';
}

sub current_dt {
  # Текущая дата и время строгого формата: DD.MM.YYYY HH.MM.SS
  my @dt=localtime(time);
  my $cdt= (($dt[3]>9)?$dt[3]:'0'.$dt[3]).'.'.(($dt[4]+1>9)?$dt[4]+1:'0'.($dt[4]+1)).'.'.($dt[5]+1900)." ".(($dt[2]>9)?$dt[2]:'0'.$dt[2]).":".(($dt[1]>9)?$dt[1]:'0'.$dt[1]).':'.(($dt[0]>9)?$dt[0]:'0'.$dt[0]);
  return $cdt;
}

sub template_error {
my $data_error=shift || 'An error in the module TemplateM!';

print $self->{header} || "Content-type: text/html\n\n";
print <<"HTML";
  <html>
    <head>
      <title>An error in the module TemplateM!</title>
    </head>
    <body>
     <br><br><br><br>
     <center><h1>
     
        $data_error
     
     </h1></center>
    </body>
  </html>
HTML
exit;
}
sub timeout_ok {
 my ($file,$cachedir)=@_;
 if ($cachedir and $file) {
  $file=~s/(\.)|(\/)|(\\)|(:)|(\?)|(\&)|(\%)/_/g;
  my $path_and_file=$cachedir.'/'.$file;
  
  return 1 unless (-e "$path_and_file"); # файла кэша просто нет!

  my @statfile = stat($path_and_file);
  if ((time-$statfile[9]) > $self->{timeout}) {
   # Файл слишком стар!
   return 0 if $self->{timeout} == -1; # Установлен флаг неучитывания времени - постоянно читаем кэш!
   return 1;
  } else {
   # Файл не устарел!
   return 0;
  } 
 } else {
  # Файл не указан, значит он стар!
  return 1;
 } 
}

sub AUTOLOAD {
    my $self = shift;
    if (defined $_[0]) {
        $self->html(@_ );
    } else {
        $self->html();
    }
}

sub _read_attributes {
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

__END__
