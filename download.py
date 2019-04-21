#use strict;

#my $wget = "/usr/bin/wget";
#my $cwd = "cd /tmp";
#my $listurl = "https://landsat-pds.s3.amazonaws.com/c1/L8/scene_list.gz";
#
#my $ret = system("$cwd $wget $listurl");
#print $ret;

import os
import sys
import subprocess
import re
import os.path
from operator import itemgetter
from lxml import html
import urllib2
from bs4 import BeautifulSoup
# from urllib.parse import urlparse
#from urlparse import urlparse
import urlparse
from pprint import pprint

wget = "/usr/bin/wget"
wkdir = "/var/www/htdocs/landsat"
listurl = "https://landsat-pds.s3.amazonaws.com/c1/L8/scene_list.gz"

comwget = wget + " " + listurl
comgzip = "/usr/bin/gzip -df"
commv = "/usr/bin/mv -f"
tempfile = "/tmp/list.gz"
temp     = "/tmp/list"
pathlocalimg = "/tmp"

row_desc = 226
column_desc = 84

row_asc = 112
column_asc = 160

print "Inicio."

try:
    print "Por cambiar directorio " + wkdir + "..."
    os.chdir(wkdir)

except Exception as ret:
    print "Error: "
    sys.exit(ret)

#ret = os.system(comwget)

print "Por ejecutar " + comwget + "..."

p = subprocess.Popen(comwget, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

print "Salio."


# buscamos el nombre del archivo que bajo - puede ser .1 .2etc
for line in p.stdout.readlines():
        print line
        retval = p.wait()

        m = re.search('\'(.*)\'', line)
        if m :  
                nomfile = m.group(0)


print "Baje el archivo " + nomfile + "."
com = commv + " " + nomfile + " " + tempfile

print "Por ejecutar " + com

p = subprocess.call(com, shell=True)

if p<> 0 :
        print "Error al ejecutar " + com
        sys.exit(p)


com = comgzip + " " + tempfile

print "Por ejecutar " + com

p = subprocess.call(com, shell=True)

if p<> 0 :
        print "Error al ejecutar " + comgzip
        sys.exit(p)


#com = "/usr/bin/grep \"" + str(row_desc) + "," + str(column_desc) + "\" " + temp  + " | tac"
# no estoy seguro com = com + "; /usr/bin/grep \"" + str(column_asc) + "," + str(row_asc) + "\" " + temp 

#navarro es 225,84
#com =  "/usr/bin/grep 226,84 list | tac | head -3 >lista226_84 ; /usr/bin/grep 225,84 list | tac | head -3 >>lista ; cat lista "


#a vaca muerta desc Path:      231     Row:    87
# ANDA com =  "/usr/bin/egrep 226084_2018\|226084_2019 /tmp/list   | tail -20 >lista226_84 ; /usr/bin/egrep 225084_2018\|225084_2019  /tmp/list  | tail -20 >lista225_84 ; /usr/bin/egrep 231087_2018\|231087_2019 /tmp/list |  tail -20 >lista231_87 ;  cat lista226_84 lista225_84 lista231_87"

# prueba

com =  "/usr/bin/egrep 225084_2019  /tmp/list  | tail -1 >lista225_84 ; /usr/bin/egrep 226084_2019 /tmp/list   | tail -1 >lista226_84   ; /usr/bin/egrep 231087_2019 /tmp/list |  tail -1 >lista231_87 ;  cat lista231_87 lista226_84 lista225_84" 
 

print "Por ejecutar " + com

p = subprocess.Popen(com, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

cont = 0


print "Recorriendo linea x linea..."
# buscamos el nombre del archivo que bajo - puede ser .1 .2etc
for line in p.stdout.readlines():

        print "File: "  + line
        # productId,entityId,acquisitionDate,cloudCover,processingLevel,path,row,min_lat,min_lon,max_lat,max_lon,download_url

        cont = cont +1

        campos = line.split(",")
        productid = campos[0]
        entityid = campos[1]  
        acq_date = campos[2]
        cloudcover = campos[3]
        proclevel = campos[4]
        path = campos[5]
        row = campos[6]
        min_lat = campos[7]
        min_lon = campos[8]
        max_lat = campos[9]
        max_lon = campos[10]
        downurl = campos[11]
        print nomfile + ": " + "Linea #" + str(cont) + " acq_date: " + acq_date + " path:" + path + " row:" + row + " downurl:" + downurl

        print "Bajando " + downurl

        # Bajamos la pagina 
        response = urllib2.urlopen(downurl)
        html = response.read()

        # Sacamos el "path" de esta pagina
        url_path =  downurl.split("/")[0:9]
        # debug muy bueno !! print dir(o.path)
        # url_path[1] = "/"
        url_path = '/'. join(url_path)
        print "url_path = " + url_path

        # Buscamos los links a
        soup = BeautifulSoup(html,"lxml")
        links = soup.find_all('a')

        #filename = downurl.rfind("/")+1
        #a = urlparse.urlparse(downurl)
        #print a


        print "Recorriendo pagina link x link..."

        # Recorremos los links con a
        for tag in links:
            link = tag.get('href',None)
            if link is not None:
                imglink = url_path + "/" + link
                print "Por bajar: " +  imglink

#                filename = imglink.rfind("/")+1
                filename =  imglink.split("/")[-1]
#                a = urlparse.urlparse(downurl)
                print "filename!!! = " + filename

                # Si no existe..
                archimg = wkdir + "/" + filename
                print "Existe " + archimg + "?"
                existe = os.path.exists(archimg)
                if not existe:

                    print "NO existe!!!"
                    comwget = "/usr/bin/wget " + imglink
                    print "Por ejecutar " + comwget + "..."

                    # p = subprocess.Popen(comwget, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                    p = subprocess.Popen(comwget, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                    print "Salio."
                    for line in p.stdout.readlines():
                         print line
                         retval = p.wait()
                else:
                    print "Existe no se baja."




#        print fecha
        retval = p.wait()


#        m = re.search('\'(.*)\'', line)
#        if m :  
#                nomfile = m.group(0)




print "fin"
