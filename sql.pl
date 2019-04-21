use DBI qw(:sql_types);
use strict;
use Time::Local;
use Data::Dumper;

my $db_file = "/tmp/pru.db";
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");

my $wwwdir = "/var/www/htdocs/landsat";

my $sth = $dbh->prepare("DROP TABLE files  ");
eval {$sth->execute();};

my $sth = $dbh->prepare("CREATE TABLE files (	id integer primary key autoincrement, 
			file_name VARCHAR(255),
			sensor VARCHAR(255),
			proc_cor_level VARCHAR(255),
			path_row VARCHAR(255),
			acq_date int,
			proc_date int,
			coll_number int,
			coll_cat VARCHAR(255),
			band VARCHAR(255),
			ext_1 VARCHAR(255),
			ext_2 VARCHAR(255),
			file_epoch int,
		        geo VARCHAR(255))");

#$sth->bind_param(1, $blob, SQL_BLOB);
#
$sth->execute();

opendir( DIR, $wwwdir) ;

my @file_list = readdir DIR;
closedir(DIR);

my $sth = $dbh->prepare("INSERT INTO files ( 
			file_name ,
			sensor,
			proc_cor_level ,
			path_row ,
			acq_date ,
			proc_date ,
			coll_number ,
			coll_cat ,
			band ,
			ext_1 ,
			ext_2 ,
	       		file_epoch,
	                geo	) values (?,?,?,?,?,?,?,?,?,?,?,?,?)");

for my $file (@file_list){
	print "file = $file\n";
	next unless ($file =~ /^L/);

        # Landsat collection 1 product identifier
         my @file_dat = split(/[_.]/,$file);

         # L fixed x sensor (C = OLI/TIRS combined)
         my $l_sensor_sat = $file_dat[0];

         # processing correction level  L1TP L1GT L1GS
         my $proc_cor_level = $file_dat[1];

         # PPP WRS path , RRR WRS ROW
         my $path_row = $file_dat[2];

         # Acquisition time YYYY year MM month DD day
	 # ej. 20181221
         my $acq_time = $file_dat[3];
	 $acq_time =~ /(\d{4})(\d{2})(\d{2})/;
	 print $acq_time."( $3 $2 $1) \n";
	 my $epoch_acq_time = timelocal(0,0,0,$3,$2-1,$1); 

         # Processing time YYYY year MM month DD day
         my $proc_time = $file_dat[4];
	 $proc_time =~ /(\d{4})(\d{2})(\d{2})/;
	 my $epoch_proc_time = timelocal(0,0,0,$3,$2-1,$1); 

         # Collection number
         my $col_num = $file_dat[5];

         # Collection category RT real time, T1 = tier 1, T2 = Tier 2
         my $col_cat = $file_dat[6];

         my $band = $file_dat[7];
         my $ext1 = $file_dat[8];
         my $ext2 = $file_dat[9];

	 my $epoch_timestamp = (stat($wwwdir."/".$file))[9] or die $!; 

	 my $geodata;
	 my $authority;

	 if ($file =~ /\.TIF|tif/)  {
	 	open (PIPE, "gdalinfo -mm $wwwdir"."/".$file."|");

	 	while (<PIPE>) {
		 	my $lin = $_;
		 	chomp;

		 	if  ($lin =~ /Size is/ ) {
			 	$geodata .= $lin . "\n";
		 	}
		 	if  ($lin =~ /AUTHORITY/ ) {
			 	$authority = $lin;
		 	}
		 	if  ($lin =~ /Band/ ) {
			 	$geodata .= $lin;
		 	}
		 	if  ($lin =~ /Computed/ ) {
			 	$geodata .= $lin;
		 	}
		 	if  ($lin =~ /Upper|Lower|Center/ ) {
			 	$geodata .= $lin;
		 	}
	 	}
	 	close (PIPE);
		$geodata .= $authority;
 	}




	 #print scalar localtime($epoch_timestamp);


	$sth->bind_param(1,$file,SQL_VARCHAR);
	$sth->bind_param(2,$l_sensor_sat,SQL_VARCHAR);
	$sth->bind_param(3,$proc_cor_level,SQL_VARCHAR);
	$sth->bind_param(4,$path_row,SQL_VARCHAR);
	$sth->bind_param(5,$epoch_acq_time,SQL_INTEGER);
	$sth->bind_param(6,$epoch_proc_time,SQL_INTEGER);
	$sth->bind_param(7,$col_num,SQL_VARCHAR);
	$sth->bind_param(8,$col_cat,SQL_VARCHAR);
	$sth->bind_param(9,$band,SQL_VARCHAR);
	$sth->bind_param(10,$ext1,SQL_VARCHAR);
	$sth->bind_param(11,$ext2,SQL_VARCHAR);
	$sth->bind_param(12,$epoch_timestamp,SQL_INTEGER);
	$sth->bind_param(13,$geodata,SQL_VARCHAR);
	$sth->execute();

}

system("chmod a+rw   $db_file");
system("chmod o+rw   $db_file");
system("chmod g+rw   $db_file");

