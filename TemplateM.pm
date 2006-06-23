package TemplateM;
require 5.008;
$VERSION = "1.21";

#
# TemplateM - модуль работы с шаблонами 
#
# Version: 1.21 
# Date   : 16.05.2006
#

=head1 NAME

TemplateM - Templates processing module 

=head1 VERSION

Version 1.21 
16.05.2006

=head1 SYNOPSIS
    
print "Content-type: text/html\n\n";
unshift(@INC,module_directory_absolute_path);
require TemplateM;

or: 

use lib module_directory_absolute_path;
use TemplateM; 

=head2 Object $template creation

$template = new TemplateM(template_file,username,user_password, cache_files_absolute_path, timeout);

=head2 Update object $template

$template->update(template_file,username,user_password, cache_files_absolute_path, timeout);

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

B<Timeout> is the period (in seconds) of template's updating delay. Default value is 1200 seconds

=back

=head2 Modification of labels (cgi labels)

$template->cast({label=>value, label=>value, ...=>...});

=over 8

=item label

B<Label> - name will be replaced with appropriate L<value> in tag <!-- cgi: label -->

=item value

B<Value> - Value, which CGI-script sets. Member of L<label>

=back

=head2 Block labels modification (val labels)

$template->cast_loop ("block_name", [{label=>value, label=>value, ...=>...}]);

=over 8

=item block_name

B<Block_name> - Block identification name. The name will be inserted in tags <!-- do: block_name --> and <!-- loop: block_name --> - all content between this tags processes like labels, but the tag will be formed as <!-- val: label -->

=back

=head2 Block finalizing

$template->finalize(block_name);
    
Block finalizing uses for not-processed blocks deleting. You need use finalizing every time you use blockes.

=head2 Template finalizing

print $template->html || 'Inner error!';

The procedure will return formed document after template processing.

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

=head1 THANKS

Thanks to Andrew Syrba for useful and valuable information 

=head1 AUTHOR

Lepenkov Sergey (Serz Minus), C<minus@mail333.com>

=head1 COPYRIGHTS

Copyright (C) 1998-2006 D&D Corporation. All Rights Reserved

=cut

BEGIN {
  use LWP::Simple;
  use HTTP::Request;
  use LWP::UserAgent;
  use HTTP::Headers;
}

sub new {
    my ($class, $file, $login, $password, $cachedir, $timeout) = @_;
    my $self = {};                       # Определяем объект
    $self{timeout} = $timeout || 1200;   # Таймаут доступа к шаблону (30 минут)
    $self{file} = $file || 'index.shtml';# Имя файла шаблона
    $self{login} = $login       || '';   # Логин виртуального клиента 
    $self{password} = $password || '';   # Пароль виртуального клиента
    $self{cachedir}=$cachedir || '';       # Путь до файлов кэша
    
    if (&timeout_ok($file,$self{cachedir})) {     
      $self{template}= &geturl($file,$login,$password); # Принимаем ресурс
      if ($self{cachedir}) {                # Указан путь до кэша?
          if ($self{template} eq '') {       # Не прочитался кэш? 
            $self{template}=&load_cache($file,$self{cachedir});
          } else {                           # Прочитался кэш?
            &save_cache($file,$self{cachedir},$self{template});
          }
      }
    } else {
      $self{template}=&load_cache($file,$self{cachedir});
    }

    &template_error ("Ошибка получения ресурса<br><br><i>$file</i>") unless $self{template};
    bless $self, $class;                 # Создаем объект!
    return $self;
}
#&cachefilename($self{file},$self{cachedir}).'<br>\n'.
sub update {
    my ($self, $file, $login, $password, $cachedir, $timeout) = @_;
    $self = {};
    $self{timeout} = $timeout || 1200;   # Таймаут доступа к шаблону (20 минут)
    $self{login} = $login  || '';
    $self{password} = $password || '';
    $self{cachedir}=$cachedir || '';
    $self{file} = $file || 'index.shtml';# Имя файла шаблона

    if (&timeout_ok($file,$self{cachedir})) {     
      $self{template}= &geturl($file,$login,$password);
      if ($self{cachedir}) {
        if ($self{template} eq '') {
          $self{template}=&load_cache ($file,$self{cachedir});
        } else {                    
          &save_cache ($file,$self{cachedir},$self{template});
        }
      }
    } else {
      $self{template}=&load_cache($file,$self{cachedir});
    }

    &template_error ("Ошибка получения ресурса<br><br><i>$file</i>") unless $self{template};
    return $self;
}

sub cast {
    # Модифицируем все значения (cgi:)
    my ($self, $hr) = @_;
    $self{template}=~s/<!--\s*cgi:\s*(\S+?)\s*-->/_exec_directive($hr, $1)/ieg;
    return $self{template};
}

sub cast_loop {
    # Модифицируем блок (do: - loop:)
    my ($self, $name, $ar, $finalize) = @_;
    $self{template} =~ m/<!--\s*do:\s*$name\s*-->(.*)<!--\s*loop:\s*$name\s*-->/s;
    my $pattern = $1;
    my $pattern_copy = $pattern;
    my $out;
    foreach (@{$ar}) {
      $pattern = $pattern_copy;
      $pattern =~ s/<!--\s*val:\s*(\S+?)\s*-->/_exec_directive($_,$1)/ieg;
      $out.=$pattern;
    }
    if ($finalize) {
      $self{template} =~ s/<!--\s*do:\s*$name\s*-->.*<!--\s*loop:\s*$name\s*-->/$out/s;
    } else {
      $self{template} =~ s/(<!--\s*do:\s*$name\s*-->).*(<!--\s*loop:\s*$name\s*-->)/$out$1$pattern_copy$2/s;
    }
    return $self{template};
}

sub finalize {
    # Завершаем блок (do: - loop:)
    my ($self,$name) = @_;
    $self{template} =~ s/<!--\s*do:\s*$name\s*-->.*<!--\s*loop:\s*$name\s*-->//s;
    return $self{template};
}

sub html {
    # Выдаем результат на печать
    my $self = $_[0];
    return $self{template};
}

sub _exec_directive {
    # Выполняем внутреннюю директиву
    my ($hr, $directive) = @_;
    return $$hr{$directive} if defined($$hr{$directive});
}


sub geturl {
  #
  # Получение ресурса простым или аутентификационным способом в зависимости от аргумента
  #
  my ($file,$login,$password)=@_;
  my ($url,$html);

  my $hostname = $ENV{HTTP_HOST} || '';
  my $curent_file = $ENV{SCRIPT_NAME} || '';
  $curent_file=~m/^\/(.+\/).*/;       
  my $find = $1 || '';
  if ($file =~/^\//) {
    $url='http://'.$hostname.$file;
  } else {
    $url='http://'.$hostname.'/'.$find.$file;
  }   

  if ($login eq '') {
    $html=get($url);
  } else {
    $ua = new LWP::UserAgent; 
    $req = new HTTP::Request(GET => $url);
    $req->authorization_basic($login, $password); 
    $res=$ua->request($req);
    $html= $res->is_success?$res->content : '';
  }

return $html;
}

sub save_cache {
    my ($file,$cachedir,$dataarea)=@_;
    my $ident_path=$file;
    $ident_path=~s/(\.)|(\/)|(\\)|(:)|(\?)|(\&)|(\%)/_/g;
    my $filename=$cachedir."/".$ident_path;

    open CACHE, ">$filename" or &template_error ("Ошибка записи файла<br>$filename");
      flock CACHE,2; 
      print CACHE "<!--- CACHE-FILE: $ident_path - ".&current_dt." --->\n\n";
      print CACHE $dataarea;
    close CACHE;
}

sub load_cache {
    my ($file,$cachedir)=@_;
    my $htmlret='';
    my $fname;
    if ($file) {
        my $ident_path=$file;
        $ident_path=~s/(\.)|(\/)|(\\)|(:)|(\?)|(\&)|(\%)/_/g;
        $fname=$cachedir."/".$ident_path;
        if (-e "$fname") {
            open CACHE, "$fname" or &template_error ("Ошибка чтения файла<br>$fname");
            flock CACHE,2;
                while (<CACHE>){
                   $htmlret.=$_;
                }
            close CACHE;
        }
    
    }
    
    &template_error ("Ошибка получения ресурса<br><br><i>$file</i><br><br>или чтения файла<br><br><i>$fname</i>") unless $htmlret;
    return $htmlret||'';
}

sub current_dt {
  # Текущая дата и время строгого формата: DD.MM.YYYY HH.MM.SS
  my @dt=localtime(time);
  my $cdt= (($dt[3]>9)?$dt[3]:'0'.$dt[3]).'.'.(($dt[4]+1>9)?$dt[4]+1:'0'.($dt[4]+1)).'.'.($dt[5]+1900)." ".(($dt[2]>9)?$dt[2]:'0'.$dt[2]).":".(($dt[1]>9)?$dt[1]:'0'.$dt[1]).':'.(($dt[0]>9)?$dt[0]:'0'.$dt[0]);
  return $cdt;
}

sub template_error {
my $data_error=shift || 'Ошибка работы модуля TEMPLATE';
print <<"HTML";
  <html><head><title>ОШИБКА МОДУЛЯ TEMPLATE</title></head><body>
     <br><br><br><br>
     <center><h2>
     
        $data_error
     
     </h2></center>
  </body></html>
HTML
exit;
}
sub timeout_ok {
 my ($file,$cachedir)=@_;
 if ($cachedir and $file) {
  $file=~s/(\.)|(\/)|(\\)|(:)|(\?)|(\&)|(\%)/_/g;
  my $path_and_file=$cachedir.'/'.$file;

  my @statfile = stat($path_and_file);
  if ((time-$statfile[9]) > $self{timeout}) {
   return 1;
  } else {
   return 0;
  } 
 } else {
  return 1;
 } 
}

sub AUTOLOAD {
    my $self = shift;
    $self->html;
}
1;

__END__
