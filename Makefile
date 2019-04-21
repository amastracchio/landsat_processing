
LOG = makefile.log

ALLTIFF8 = $(wildcard *B8.TIF)
PROGSBAND8 = $(patsubst %.TIF,%.projected.tif,$(ALLTIFF8))

ALLTIFF6 = $(wildcard *B6.TIF)
PROGSBAND6 = $(patsubst %.TIF,%.projected.tif,$(ALLTIFF6))

ALLTIFF5 = $(wildcard *B5.TIF)
PROGSBAND5 = $(patsubst %.TIF,%.projected.tif,$(ALLTIFF5))

ALLTIFF4 = $(wildcard *B4.TIF)
PROGSBAND4 = $(patsubst %.TIF,%.projected.tif,$(ALLTIFF4))

ALLTIFF3 = $(wildcard *B3.TIF)
PROGSBAND3 = $(patsubst %.TIF,%.projected.tif,$(ALLTIFF3))

ALLTIFF2 = $(wildcard *B2.TIF)
PROGSBAND2 = $(patsubst %.TIF,%.projected.tif,$(ALLTIFF2))

ALLTIFF = $(wildcard *.TIF)
ALLTHUMBS = $(patsubst %.TIF,%.thumbnail.jpg,$(ALLTIFF))

ALLTHUMBLARGE = $(wildcard *thumb_large.jpg)
ALLTHUMBSLARGE = $(patsubst %.jpg,%.thumbnail.jpg,$(ALLTHUMBLARGE))




# Elegimos B2 pero puede ser cualquiera es solo para tomar el nombre
COMBINED_VISUAL = $(patsubst %_B2.TIF,%.visual.TIF,$(ALLTIFF2))

COMBINED_VISUAL_PAN = $(patsubst %_B3.TIF,%.visual.pan.TIF,$(ALLTIFF3))

# Elegimos B2 pero puede ser cualquiera es solo para tomar el nombre
COMBINED_FOREST = $(patsubst %_B2.TIF,%.forest.TIF,$(ALLTIFF2))

#all: $(PROGSBAND6) $(PROGSBAND5)  $(PROGSBAND4) $(PROGSBAND3) $(PROGSBAND2)  $(COMBINED_VISUAL) $(COMBINED_FOREST) $(ALLTHUMBS) $(ALLTHUMBSLARGE) $(COMBINED_VISUAL_PAN)

#all: $(COMBINED_VISUAL_PAN)    $(COMBINED_VISUAL) $(ALLTHUMBSLARGE) $(ALLTHUMBS) 
# progs al cohete pero para que no lo tome como files intermediate y los borre despues
all:   $(ALLTHUMBSLARGE) $(ALLTHUMBS) $(PROGSBAND8)   $(PROGSBAND4) $(PROGSBAND3) $(PROGSBAND2) $(COMBINED_VISUAL) $(COMBINED_VISUAL_PAN) 


#$(COMBINED_VISUAL_PAN): $(PROGSBAND8)   $(PROGSBAND4) $(PROGSBAND3) $(PROGSBAND2) 

#$(COMBINED_VISUAL):  $(PROGSBAND4)  $(PROGSBAND3)  $(PROGSBAND2)




%.visual.pan.TIF: %_B8.projected.tif %_B4.projected.tif %_B3.projected.tif %_B2.projected.tif
	echo "To make $@ preqrequisites $^" >>$(LOG)
#	gdal_pansharpen.py LC80420362016085LGN00_B8.TIF LC80420362016085LGN00_B4.TIF LC80420362016085LGN00_B3.TIF LC80420362016085LGN00_B2.TIF carrizo-20160325-oli-pan.tif -r bilinear -co COMPRESS=DEFLATE -co PHOTOMETRIC=RGB
#
	-rm -f  temp_10.tif
#	gdal_pansharpen.py $^ $@ -co COMPRESS=DEFLATE  -r bilinear -co COMPRESS=DEFLATE -co PHOTOMETRIC=RGB
	gdal_pansharpen.py $^ temp_10.tif -co COMPRESS=DEFLATE  -r bilinear  -co PHOTOMETRIC=RGB
#	gdal_pansharpen.py $^ temp_10.tif -co COMPRESS=DEFLATE  -r bilinear -co COMPRESS=DEFLATE -co PHOTOMETRIC=RGB
#	convert  -sigmoidal-contrast  50x16%   temp_10.tif $@ 
	convert -depth 8  -channel R -gamma 1.03 -channel G -gamma 1.03  -channel RGB -sigmoidal-contrast  60x13%  temp_10.tif $@ 
	# cp LC08_L1TP_225084_20190131_20190206_01_T1_B8.projected.tfw LC08_L1TP_225084_20190131_20190206_01_T1_B8.projected.tif
#	cp $(patsubst %.tif,%.tfw,$<) $(patsubst %_B8.projected.tif,%.visual.pan.tfw,$<)
	cp $(patsubst %.tif,%.tfw,$<) $(patsubst %.TIF,%.tfw,$@)
	gdal_edit.py -a_srs EPSG:3857 $@


%.thumbnail.jpg: %.TIF
	echo "To make $@ preqrequisites $^" >>$(LOG)
	-convert -thumbnail 400 $^ $@

%thumb_large.thumbnail.jpg: %thumb_large.jpg
	echo "To make $@ preqrequisites $^" >>$(LOG)
	-convert -thumbnail 400 $^ $@

# Visual join
#$(COMBINED_VISUAL):  $(PROGSBAND4)  $(PROGSBAND3)  $(PROGSBAND2)
#$(COMBINED_VISUAL):  $(PROGSBAND4) 

#
# near true visible =  band 4 ,3 and 2
# forest management =  Near infrared (5) , short wave infrarred (6) and visible  red (4)
# NIR, SWIR, and visible red, using bands 5, 6, and 4 
#
%.visual.TIF: %_B4.projected.tif %_B3.projected.tif %_B2.projected.tif
#	convert -combine $^  $@
	echo "To make $@ preqrequisites $^" >>$(LOG)
	rm -f temp_8.tif
# 15/4/2019	gdal_merge.py -v -ot Byte -separate -of GTiff -co PHOTOMETRIC=RGB -o temp_8.tif $^
	gdal_merge.py -v -separate -ot UInt16 -co PHOTOMETRIC=RGB  -of GTiff -o  temp_8.tif $^
	# Choose B4 but can be any
#	convert -depth 8 $@ temp_8.tif
#	convert -channel B -gamma 0.925 -channel R -gamma 1.03 -channel RGB -sigmoidal-contrast  50x16%  -depth 8 temp_8.tif $@ 
#	convert  -sigmoidal-contrast  50x16%   temp_8.tif $@ 
	#color correct blue bands to deal with haze and correct across all brands for brightness, contrast and saturation
#`	convert -channel B -gamma 1.05 -channel RGB -sigmoidal-contrast 20,20% -modulate 100,150 temp_8.tif $@ 
#`	convert -channel B -gamma 1.05 -channel RGB -sigmoidal-contrast 50,16% -modulate 100,150 temp_8.tif $@ 
#	convert -channel B -gamma 1.05 -channel RGB -sigmoidal-contrast 20,20% -modulate 100,150 temp_8.tif $@ 
	convert -depth 8  -channel R -gamma 1.03 -channel G -gamma 1.03  -channel RGB -sigmoidal-contrast  60x13%  temp_8.tif $@ 
	#use a cubic downsampling method to add overview
#	gdaladdo -r cubic temp_8.tif 2 4 8 10 12
#	mv #temp_8.tif $@
#
#	#
	cp $(patsubst %.tif,%.tfw,$<) $(patsubst %_B4.projected.tif,%.visual.tfw,$<)
	gdal_edit.py -a_srs EPSG:3857 $@

%.forest.TIF: %_B5.projected.tif %_B6.projected.tif %_B4.projected.tif
#	convert -combine $^  $@
	echo "To make $@ preqrequisites $^" >>$(LOG)
	rm -f temp_8.tif
	gdal_merge.py -v -ot Byte -separate -of GTiff -co PHOTOMETRIC=RGB -o temp_8.tif $^
	# Choose B4 but can be any
#	convert -depth 8 $@ temp_8.tif
#	convert -channel B -gamma 0.925 -channel R -gamma 1.03 -channel RGB -sigmoidal-contrast  50x16%  -depth 8 temp_8.tif $@ 
#	convert  -sigmoidal-contrast  50x16%   temp_8.tif $@ 
	#color correct blue bands to deal with haze and correct across all brands for brightness, contrast and saturation
	convert -channel B -gamma 1.25 -channel G -gamma 1.25  -channel RGB -sigmoidal-contrast 25,25%  temp_8.tif $@ 
	#use a cubic downsampling method to add overview
#	gdaladdo -r cubic temp_8.tif 2 4 8 10 12
#	mv #temp_8.tif $@
#
#	#
	cp $(patsubst %.tif,%.tfw,$<) $(patsubst %_B4.projected.tif,%.forest.tfw,$<)
	gdal_edit.py -a_srs EPSG:3857 $@

%.projected.tif: %.TIF
	# Creamos la proyeccion
	echo Making $@
	echo "To make $@ preqrequisites $^" >>$(LOG)
	echo Projection of band and convert to 8 bits. Some error is ok
#	rm -f temp_8.tif
	gdalwarp -t_srs EPSG:3857 $< $@
	# write to .tfw (geo data)
	listgeo -tfw  $@
	rm -f pro.tif
	cp $@ pro.tif
#	gdal_translate -ot Byte -scale 0 65535 0 255 pro.tif $@
#	16/4/2019
	cp pro.tif $@
#	convert -depth 8 $@ temp_8.tif
#	cp temp_8a.tif $@
#	gdal_edit.py -a_srs EPSG:3857 $@

