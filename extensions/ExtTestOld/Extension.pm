# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::ExtTestOld;
use strict;
use base qw(Bugzilla::Extension);

# This code for this is in ./extensions/ExtTestOld/lib/Util.pm
use Bugzilla::Extension::ExtTestOld::Util;

our $VERSION = '0.01';

# See the documentation of Bugzilla::Hook ("perldoc Bugzilla::Hook" 
# in the bugzilla directory) for a list of all available hooks.
sub db_schema_abstract_schema {
    my ($self, $args) = @_;
    my $schema = $args->{'schema'};
    my $tab_1 = {
        FIELDS => [
            id                  => {TYPE => 'SMALLSERIAL', NOTNULL => 1,
                                    PRIMARYKEY => 1},
            value               => {TYPE => 'varchar(64)', NOTNULL => 1}
        ]
    };
    my $tab_2 = {
        FIELDS => [
            id                  => {TYPE => 'SMALLSERIAL', NOTNULL => 1,
                                    PRIMARYKEY => 1},
            value               => {TYPE => 'varchar(64)', NOTNULL => 1},
            tab_1_id            => {TYPE => 'INT2', NOTNULL => 1,
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

sub install_before_final_checks {
    my ($self, $args) = @_;
    my $silent = $args->{'silent'};
    my $dbh = Bugzilla->dbh();
    my $rows = $dbh->selectall_arrayref("SELECT COUNT(id) FROM tab_1") or die $dbh->errstr();
    my @sql_values = ();

    return if (@{$rows} > 0 and @{$rows->[0]} > 0 and $rows->[0][0] > 0);

    print "Inserting values to tab_1\n" unless $silent;

    $dbh->do("INSERT INTO tab_1(value) VALUES ('ajwaj'), ('meh'), ('groan')") or die $dbh->errstr();
    print "Getting all values from tab_1 where there is an 'a'\n" unless $silent;
    $rows = $dbh->selectall_arrayref("SELECT id FROM tab_1 WHERE value LIKE '%a%'") or die $dbh->errstr();
    print "Got " . scalar(@{$rows}) . " rows\n" unless $silent;
    foreach my $row (@{$rows}) {
        my $id = $row->[0];
        my $value = "a $id";

        push(@sql_values, "('$value', $id)");
    }
    if (@sql_values > 0) {
        my $sql = "INSERT INTO tab_2(value, tab_1_id) VALUES " . join(', ', @sql_values);

        print "Inserting values to tab_2\n" unless $silent;
        $dbh->do($sql) or die $dbh->errstr();
    }
}

__PACKAGE__->NAME;
