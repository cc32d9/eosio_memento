use strict;
use warnings;
use Getopt::Long;
use DBI;

$| = 1;

my $db_name;
my $db_host = 'localhost';
my $db_user = 'memento_rw';
my $db_password = 'LKpoiinjdscudfc';

my $keep_days;

my $ok = GetOptions
    (
     'database=s' => \$db_name,
     'dbhost=s'  => \$db_host,
     'dbuser=s'  => \$db_user,
     'dbpw=s'    => \$db_password,
     'keepdays=i' => \$keep_days,
    );


if( not $ok or not defined($keep_days) or not defined($db_name) or scalar(@ARGV) > 0)
{
    print STDERR "Usage: $0 --keepdays=N --database=DBNAME [options...]\n",
        "The utility opens a WS port for Chronicle to send data to.\n",
        "Options:\n",
        "  --database=DBNAME  \[$db_name\]\n",
        "  --dbhost=HOST      \[$db_host\]\n",
        "  --dbuser=USER      \[$db_user\]\n",
        "  --dbpw=PASSWORD    \[$db_password\]\n",
        "  --keepdays=N       delete the history older tnan N days\n";
    exit 1;
}


my $dsn = 'dbi:MariaDB:database=' . $db_name . ';host=' . $db_host;

my $db;

my $keep_blocks = $keep_days * 24 * 7200;

getdb();

{
    # sanity check
    my $sth = $db->{'dbh'}->prepare('SELECT count(*) FROM SYNC');
    $sth->execute();
    my $writers = $sth->fetchall_arrayref();
    if( $writers->[0][0] > 1 )
    {
        die("memento is running in dual-writer mode, no need to launch the dataguard\n");
    }
}

printf STDERR ("Automatically pruning the history older than %d blocks\n", $keep_blocks);

my $last_irrev = 0;

while(1)
{
    $db->{'sth_get_min_irrev'}->execute();
    my $r = $db->{'sth_get_min_irrev'}->fetchall_arrayref();
    if( $r->[0][0] > $last_irrev )
    {
        $last_irrev = $r->[0][0];
        $db->{'sth_prune_transactions'}->execute($last_irrev - $keep_blocks);
        $db->{'dbh'}->commit();
        printf STDERR ("irreversible=%d\n", $last_irrev);
    }

    sleep(10);
}

sub getdb
{
    if( defined($db) and defined($db->{'dbh'}) and $db->{'dbh'}->ping() )
    {
        return;
    }

    my $dbh = $db->{'dbh'} = DBI->connect($dsn, $db_user, $db_password,
                                          {'RaiseError' => 1, AutoCommit => 0});
    die($DBI::errstr) unless $dbh;

    $db->{'sth_get_min_irrev'} = $dbh->prepare('SELECT MIN(irreversible) FROM SYNC');

    $db->{'sth_prune_transactions'} = $dbh->prepare('DELETE FROM TRANSACTIONS WHERE block_num < ?');
}
