#!/usr/bin/perl

use CGI;
use strict;
use File::stat;
use Data::Dumper;
use Sort::Versions;
use DBI qw(:sql_types);
use Date::Period::Human;

my $limite = 100;
my $self = "http://ari1975162.ddns.net:81/cgi-bin/index.pl";
my $file;
my $wwwdir = "/var/www/htdocs/landsat";
my $wwwdirrel = "/landsat";
my $db_file = "/tmp/pru.db";
my %pathrow_desc;
my %bands_desc;
my $q = CGI->new;                    # create new CGI object
print $q->header;                    # create the HTTP header

my @order = $q->param('sort');
my $pat = $q->param('pat');

my $d = Date::Period::Human->new({ lang => 'en' });

my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");

%pathrow_desc = (
	           225084 => 'central',
		   231087 => 'sur',
	           226084 => 'noroeste',
				       );

%bands_desc = (
	           'B1' => 'Coastal (0.43 - 0.45) 30 m',
	           'B2' => 'Blue (0.45 - 0.51)  30m',
	           'B3' => 'Green (0.53 - 0.59)	30m',
	           'B4' => 'Red (0.64 - 0.67) 30m',
	           'B5' => 'NIR (0.85 - 0.88) 30m',
	           'B6' => 'SWIR 1 (1.57 - 1.65) 30m',
	           'B7' => 'SWIR 2 (2.11 - 2.29) 30m',
	           'B8' => 'Pan (0.50 - 0.68) 15m',
	           'B9' => 'Cirrus (1.36 - 1.38) 30m',
	           'B10' => 'TIRS 1 (0.6 - 11.19)  100m',
	           'B11' => 'TIRS 2 (11.5 - 12.51) 100m',
	           'BQA' => 'QA',
				       );


my $ordersql;
if (@order) {

	foreach (@order){

		if ($ordersql) {
			$ordersql .= " , $_" ;
		} else {
			$ordersql = $_ ;
		}

	}
	
}

if ($ordersql) {
	$ordersql = ",".$ordersql;
}


my $SQL = "SELECT id,
	file_name ,
        sensor ,
        proc_cor_level ,
        path_row ,
        acq_date ,
        proc_date ,
        coll_number ,
        coll_cat,
        band ,
        ext_1 ,
        ext_2,
        file_epoch,
        geo 	FROM files  ORDER BY acq_date$ordersql DESC  ";

my $sth = $dbh->prepare($SQL);


eval {$sth->execute();};



print "<html>\n";



opendir( DIR, $wwwdir) ;
							 


my @file_list = grep ! /^\./, readdir DIR; 
closedir(DIR); 




print "L1TP - Radiometrically calibrated and orthorectified using ground points and digital elevation model (DEM) data to correct for relief displacement . These are the highest quality Level-1 products suitable for pixel-level time series analysis.<p>\n";
print "https://landsat.usgs.gov/landsat-collections<p>\n";
print "GCS,GEOGCS:  Geographic Coordinate System<p>\n";
print "PCS, PROJCS: Proyected Coordinate System<p>\n";
print "Datum: datum connects the spheroid to the earth's surface.<p>\n";
print <<END;
<table border=1>
<tr><th>BAND</th><th>DESCRIPTION</th></tr>
<tr><td>5</td><td>NIR</td></tr>
<tr><td>2</td><td>Blue</td></tr>
<tr><td>3</td><td>Green</td></tr>
<tr><td>4</td><td>Red</td></tr>
</table>


END


print "Order by: acq_time ". $ordersql. "<p>";
print "Order by: acq_time ". $ordersql. "<p>";

print "<form action=>";

print "Filter file_name= <input type=text name=pat value=$pat> ";

print "<table border=1><tr><td>Thumbnail</td><td><a href=$self?order=file_name>Filename</a><input type=checkbox name=sort value=file_name></td><td><a href=$self?order=sensor>LC</a><input type=checkbox name=sort value=sensor></td><td><a href=$self?order=proc_cor_level>Proc. Corr. Level</a><input type=checkbox name=sort value=proc_cor_level></td><td><a href=$self?order=path_row>WRS Path/row</a><input type=checkbox name=sort value=path_row></td><td><a href=$self?order=acq_date>Acquisition <input type=checkbox name=sort value=acq_date></d></td><td><a href=$self?order=proc_date>Processing</a><input type=checkbox name=sort value=proc_date></td><td><a href=$self?order=coll_number> Collection Number</a><input type=checkbox name=sort value=coll_number></td><td><a href=$self?order=coll_cat> Collection Category</a><input type=checkbox name=sort value=coll_cat></td><td><a href=$self?order=band>Band Name Wavelength (micrometers) 	Resolution (meters)</a></td><td><a href=$self?order=ext_1> Ext. 1</a></td><td><a href=$self?order=ext_2>Ext. 2</a></td><td><a href=$self?order=file_epoch>Downloaded local</a></td><td>Geotiff/gdalinfo</td></tr>\n";


print "</form>";

# first sort aquisition

#sort {
#	#
#         my @file_data = split(/[_.]/,$a);
#         my @file_datb = split(/[_.]/,$b);
#         my $a_stat = stat($wwwdir . "/".$a);
#         my $b_stat = stat($wwwdir . "/".$b);
#         #        $a_stat->mtime <=> $b_stat->mtime;
#         #        Sort by processing date                                                                               $file_datb[$order]      <=> $file_data[$order] ||  $file_datb[$order]      cmp $file_data[$order] ;
#         $file_datb[3]      <=> $file_data[3] ; }  @file_list  ;
#
#for my $file (sort {
#        
#	my @file_data = split(/[_.]/,$a);
#	my @file_datb = split(/[_.]/,$b);
#	my $a_stat = stat($wwwdir . "/".$a);
#        my $b_stat = stat($wwwdir . "/".$b);
#        $a_stat->mtime <=> $b_stat->mtime;
#        Sort by processing date
#        $file_datb[$order]	<=> $file_data[$order] ||  $file_datb[$order]      cmp $file_data[$order] ;
#        $file_datb[$order]      <=> $file_data[$order] ;
#
#    }  @file_list ) {
#        print "$file<p>\n";

# ACA!!
my $file_dat;
my $cont;
while ($file_dat = $sth->fetchrow_arrayref()) {
#    	next unless $file =~ /^LC/;
    	my $file = $file_dat->[1];
	next if $file =~ /thumbnail/;
	
	# hay regular exp
	if ($pat) {
		next unless $file =~ $pat;
	}

	$cont++;
	if ($cont == $limite) {
		last;
	}
	print "<tr>";
	# Landsat collection 1 product identifier
#	my @file_dat = split(/[_.]/,$file);
	# L fixed x sensor (C = OLI/TIRS combined)
	my $l_sensor_sat = $file_dat->[2];
	# processing correction level  L1TP L1GT L1GS
	my $proc_cor_level = $file_dat->[3];
	# PPP WRS path , RRR WRS ROW
	my $path_row = $file_dat->[4];

	if ($pathrow_desc{$path_row}) {

		$path_row .= " '".$pathrow_desc{$path_row}."'";
	}

	# Acquisition time YYYY year MM month DD day
	my $acq_time = $file_dat->[5];
	my $acq_time_human = $d->human_readable($acq_time);


	# Processing time YYYY year MM month DD day
	my $proc_time = $file_dat->[6];
	my $proc_time_human = $d->human_readable($proc_time);

	# Collection number
	my $col_num = $file_dat->[7];
	# Collection category RT real time, T1 = tier 1, T2 = Tier 2
	my $col_cat = $file_dat->[8];

	my $band = $file_dat->[9];
	if ($bands_desc{$band}) {

		$band .= " ".$bands_desc{$band};
	}

	my $geo_data = $file_dat->[13];
#	$band = substr($band,0,2);
#
        my $ext1 = $file_dat->[10];
        my $ext2 = $file_dat->[11];

	my $downloaded_time = $file_dat->[12];
	my $downloaded_human = $d->human_readable($downloaded_time);

	my $thumb_deberia  = $file;
	if (($thumb_deberia =~ s/\.TIF/.thumbnail.jpg/) || ($thumb_deberia =~ s/\.jpg/.thumbnail.jpg/)) {

		# Existe un thumbnail
		if (-e $wwwdir . "/$thumb_deberia"){
			my $hrefimg = "$wwwdirrel/$file";
			print "<td><a href=\"$hrefimg\"><img src=\"/landsat/$thumb_deberia\" alt=\"preview of img\"</a></td>\n";
		} else {
			print '<td>&nbsp</td>';
		}



	} else {
			print '<td>&nbsp</td>';
	}
	
        print "<td>$file</td><td>$l_sensor_sat</td><td>$proc_cor_level</td><td>$path_row</td><td>$acq_time_human</td><td>$proc_time_human</td><td>$col_num</td><td>$col_cat</td><td>$band</td><td>$ext1</td><td>$ext2</td><td>$downloaded_human</td><td>$geo_data</td>";


	print "</tr>\n";

}

print "</table>\n";
print "</html>\n";






