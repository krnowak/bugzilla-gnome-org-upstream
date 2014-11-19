# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::ExtTestNew;
use strict;
use base qw(Bugzilla::Extension);

# This code for this is in ./extensions/ExtTestNew/lib/Util.pm
use Bugzilla::Extension::ExtTestNew::Util;

our $VERSION = '0.01';

# See the documentation of Bugzilla::Hook ("perldoc Bugzilla::Hook" 
# in the bugzilla directory) for a list of all available hooks.
sub db_schema_abstract_schema {
    my ($self, $args) = @_;
    my $schema = $args->{'schema'};
    my $tab_1 = {
        FIELDS => [
            id                  => {TYPE => 'MEDIUMSERIAL', NOTNULL => 1,
                                    PRIMARYKEY => 1},
            value               => {TYPE => 'varchar(64)', NOTNULL => 1}
        ]
    };
    my $tab_2 = {
        FIELDS => [
            id                  => {TYPE => 'SMALLSERIAL', NOTNULL => 1,
                                    PRIMARYKEY => 1},
            value               => {TYPE => 'varchar(64)', NOTNULL => 1},
            tab_1_id            => {TYPE => 'INT3', NOTNULL => 1,
                                    REFERENCES => {TABLE  => 'tab_1',
                                                   COLUMN => 'id',
                                                   DELETE => 'CASCADE'}}
        ],
        INDEXES => [
            tab_1_id_idx => {TYPE => 'UNIQUE', FIELDS => ['tab_1_id']}
        ]
    };

    $schema->{'tab_1'} = $tab_1;
    $schema->{'tab_2'} = $tab_2;
}

__PACKAGE__->NAME;
