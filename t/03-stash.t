#########################################################################
#
# Lepenkov Sergey (Serz Minus), <minus@mail333.com>
#
# Copyright (C) 1998-2010 D&D Corporation. All Rights Reserved
# 
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: 03-stash.t,v 1.1 2010/12/18 16:58:39 abalama Exp $
#
#########################################################################

use Test::More tests => 5;
BEGIN { use_ok('TemplateM', 'galore'); };

my $tpl;
$tpl = new_ok(TemplateM=>[\*DATA],'TemplateM');
is($tpl && $tpl->scheme(),'galore','module checking');
ok($tpl && $tpl->stash(scheme=>$tpl->{module}), 'call stash() method');
my $output;
ok($output = $tpl->output(), 'call output() method');

__DATA__
Scheme: <!-- cgi: scheme -->
Data:
  foo
  bar
  baz
