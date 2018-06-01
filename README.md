# Morphology Software!
Collection of morphology software from Bond et al. (2009 and others) and Hagen et al (2017)

If you use this, please cite Hagen et al. (2017) https://arxiv.org/abs/1610.01163 and Bond et al. (2009) ApJ, 705, 639 http://adsabs.harvard.edu/abs/2009ApJ...705..639B

Everything is run in the directory with your files except for MyCols.pm and combinecols, which just need to be located in your path.

The scripts rely on Perl, SExtractor, and IRAF.

## Directions
NB: If you encounter an error or if a direction is unclear, please submit an issue or send me an email.
* Make square cutouts of your sources using cutout.py or your favorite online cutout generator
* Make a list of all the images you want to analyze using `ls *.fits > fitslist`
* Make fake weight images by generating a fits image with all ones in the data (you could use numpy's oneslike for this) and save one of these for each fits image you want to analyze. Have `_wht` at the end of the filename. So, `name.fits` has a weight image of `name_wht.fits`.
* Make a list of the wht images using `ls *wht.fits > whtlist`
* In IRAF run imstat on the wht images using `imstat @whtlist > wtstats`
* Now its time to edit the scripts
	* In phot.script change the scale factor to your plate scale in arcsec/pixel. Edit the number after `-scalefac` in line 3
	* In datb.par change the scale factor to your plate scale in arcsec/pixel. Edit line 1
	* In runcentroid.script edit the number of `-imcenter` to be center pixel of your image. Remember that this script assumed your cutouts are square.
	* In runcentroid.script edit the (-suf) to the suffix of the weight images. Generally I use wht.

* Now run phot.script with the first input being the difference between each photometry aperture done to calculate the half-light radius, and the second being the maximum number of pixels. For instance `phot.script 0.5 20` would go out to 20 pixels in half pixel increments. When this script runs, you will have to run an iraf script called `allphot.cl`. Run this in iraf using `cl < allphot.cl`. The output from phot.script will be a file called allrad.0.5.20.dat (with the numbers changed depending on your settings) which will have the filename (column 1) and half-light radii in pixels (column 2). Each fits image will also have a corresponding phot file containing the photometry at each interval. This is useful for calculating half-ligh radii via other methods.
        * before running the IRAF script allphot.cl, must epar phot task:
                * interactive = no
                * datapar = datb.par
                * centerp = centerb.par
                * fitskyp = skyb.par
                * photpar = photb.par
                * verify = no
                * update = no
                * NOTE: can use "unlearn phot" to restore default settings to phot

* Now you can use `convert_allrad.py` to convert the pixel units to physical units, or using `morphology.py` to calculate half-light radius using eta or find the concentration index. Have fun!
