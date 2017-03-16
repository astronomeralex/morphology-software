#Directions for Measuring Half-light Radii

##Software you need
* Nick's Scripts: phot.script, runcentroid.script, makephotscript.pl, processphot.pl
	* These rely on Iraf, Perl and Nick's combinecol perl library, Nick's SExtractor files: centroid_v.sex, gems_v.sex
	* They also rely on SExtractor and its default files in your working directory (default.config, default.conv, default.nnw, default.param)





##To Run:
* Images should be square, all the same size, and should not have multiple fits extentions.
* fitslist should be a list of all the fits files you want to measure. Each file should have one galaxy in the center of the frame. In general these are postage stamps from Candels or other imaging programs. You can make this by sending your ```ls spam*.fits > fitslist``` where spam is whatever you need to specify only the images you're working on. 
* You also need weight images. For naming convention, add _wht to end of filename before file extention. On recommendation from Nick, we generally use images of all ones. This does throw off the photometry error, but not the half-light radius. Nick's weight images are the inverse square root of the HST weight images, I think? Once you have all the weight files, you need to make a file called wtstats, which lists their properties. In iraf do ```imstat *wht.fits > wtstats```
* In phot.script, check to make sure the scale factor (scalefac in makephotscript.pl) is correct. Units are arcseconds per pixel.
* In runcentroid.script check to make sure imcenter is correct. This is in pixels to the center of the image. Also set the suffix (-suf) to the suffix of the weight images. Generally I use wht. 
* To run ```./phot.script N1 N2``` where N1 is the step size, and N2 is the maximum radius in pixels. For HST ACS, I usually use ```./phot.script 0.5 20```. In the middle of this, you will need to run a script in iraf.

##Output
* This will output an .apphot file for each image. The columns are radius in pixels, flux in counts, flux in magnitude, magnitude error. Note that the error is significantly overextimated using all ones in the weight images.
* Combined output is allrad.N1.N2.dat. Columns are file name and half-light radius; all the rest are off because are weight images are off.