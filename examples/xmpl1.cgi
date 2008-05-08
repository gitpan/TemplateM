#!/usr/bin/perl -w

use strict;

use TemplateM 2.22 'galore';
use CGI;
my $q = new CGI;

my $tmpl;
read DATA, $tmpl, 1000;

my $template = new TemplateM(
        -template => $tmpl,
        -header   => "Content-type: text/html; charset=UTF-8\n\n",
    );

$template->stash(
        title => 'TemplateM',
        version => $template->VERSION,
        scheme => uc($template->scheme)
    );

my @headers = qw/
        NUMBER
        NAME
        DATA
    /;

my @peoples = (
    [
        12,
        'Andy Wayment',
        ['wandy@foo.bar', '+1123-456-789']
    ],
    [
        45,
        'Klaus Festiwal',
        ['fklaus@foo.bar']
    ],
    [
        250,
        'Tommi Lee',
        ['ltommi@foo.bar', '+1123-789-456', 'CANADA']
    ],
    [
        269,
        'Klaus Maine',
        ['mklaus@foo.bar', '+4254-133-845', 'GERMANY']
    ]
);

$template->stash(head1 => 'Peoples:');
my $hs = $template->start('headers');
foreach (@headers) {
   $hs->loop(h => $_) 
}
$hs->finish;

my $peoples = $template->start('peoples');
foreach my $p (@peoples) {
    $peoples->loop( number => $p->[0], name => $p->[1]);
    my $data = $peoples->start('data');
        my $i = 0;
        my $c = $#{$p->[2]} ;
        foreach my $d (@{$p->[2]}) {
            $data->loop(string => $d);
            $data->ifelse('hr', $i != $c);
            $i++;
        }
    $data->finish;
}
$peoples->finish;

$template->stash(head2 => 'Code:');
open CODEF, __FILE__;
my $code;
read CODEF, $code, 3000;
$template->stash(code => $q->escapeHTML($code));
close CODEF;

print $template->html();

exit;

__END__

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><!-- cgi: title -->  <!-- cgi: version --></title>
</head>
<body>

<h1><!-- cgi: title --> <!-- cgi: version --></h1>
<h2>Scheme:  <!-- cgi: scheme --></h2>
<hr>

<h2><!-- cgi: head1 --></h2>
<table border=1>
	<tr>
		<!-- do: headers -->
		<th><!-- val: h --></th>
		<!-- loop: headers -->
	</tr>
	<!-- do: peoples -->
	<tr>
		<td><!-- val: number --></td>
		<td><!-- val: name --></td>
		<td>
			<!-- do: data -->
				<!-- val: string --><!-- if: hr --><hr><!-- endif: hr -->
			<!-- loop: data -->
		</td>
	</tr>
	<!-- loop: peoples -->
</table>

<h2><!-- cgi: head2 --></h2>
<pre>
<!-- cgi: code -->
</pre>

</body>
</html>
