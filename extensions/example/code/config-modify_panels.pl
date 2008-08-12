# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# The contents of this file are subject to the Mozilla Public
# License Version 1.1 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of
# the License at http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS
# IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
# implied. See the License for the specific language governing
# rights and limitations under the License.
#
# The Original Code is the Bugzilla Example Plugin.
#
# The Initial Developer of the Original Code is Canonical Ltd.
# Portions created by Canonical Ltd. are Copyright (C) 2008 
# Canonical Ltd. All Rights Reserved.
#
# Contributor(s): Max Kanat-Alexander <mkanat@bugzilla.org>

use strict;
use warnings;
use Bugzilla;
my $panels = Bugzilla->hook_args->{panels};

# Add the "Example" auth methods.
my $auth_params = $panels->{'auth'}->{params};
my ($info_class)   = grep($_->{name} eq 'user_info_class', @$auth_params);
my ($verify_class) = grep($_->{name} eq 'user_verify_class', @$auth_params);

push(@{ $info_class->{choices} },   'CGI,Example');
push(@{ $verify_class->{choices} }, 'Example');