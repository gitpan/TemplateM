#########################################################################
#
# Lepenkov Sergey (Serz Minus), <minus@mail333.com>
#
# Copyright (C) 1998-2010 D&D Corporation. All Rights Reserved
# 
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: 04-loop.t,v 1.1 2010/12/23 08:24:03 abalama Exp $
#
#########################################################################

use Test::More tests => 7;
BEGIN { use_ok('TemplateM', 'galore'); };

my $tpl;
$tpl = new_ok(TemplateM=>[\*DATA],'TemplateM');
is($tpl && $tpl->scheme(),'galore','module checking');

my $box;
ok($box = $tpl->start('foo'), 'call start() method');
foreach (qw/foo bar baz qux quux corge grault garply waldo fred plugh/) {
    $box->loop(item=>$_)
}
ok($box->finish, 'call finish() method');
my $output;
ok($output = $tpl->output(), 'call output() method');
ok($output && $output=~/quux/,'string "quux" finded');

# print $output;
__DATA__
Loop:
<!-- do: foo -->
  <!-- val: item --><!-- loop: foo -->
