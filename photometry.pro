pro  photometry


;**********************************************************************************
;**********************************************************************************
;
; [MARINA VON STEINKIRCH, SPRING/2012]
;
; TO COMPILE IT IN IDL:
;	1) Make sure you have the folders defined in constants.pro.
;	2) Set the initial contant names and values in constants.pro.
;	3) Type IDL> .compile photometry	
;	   Type IDL> photometry
;
; COLLECTION OF MACROS IN IDL TO PERFORM CALIBRATION, ASTROMETRY, PHOTOMETRY, 
; AND TO STUDY THE INTERSTELLAR DUST EXTINCTION OF A OPEN CLUSTER:
;	1) aligning.pro
;	2) calibration.pro 
;	3) astrometry.pro
;	4) airmass.pro
;	5) photometry.pro  (this)
;	6) diagrams.pro 
;
; THIS MACRO WILL: 
;	1) Read the science in 3 filters.
;	2) Find positions and fluxes(find).
;	3) Do aperture photometry (aper).
;	4) Do cluster identification.
;	5) Save the magnitudes for each color.
;
;**********************************************************************************
;**********************************************************************************

@constants
@standard

;-------- Reading Catalogue from simbad
readcol,'m35.dat', NumberMember, NumberMember, oRA,oDE, VData, VIData, BVData, eVData, eVIData, eBVData, RA, DE


; ------ Reading imagings in three filters
fS=  cOutSciFolder  + cFilters[0] + cNameExtAlig
iS0 = readfits(fS,hS0)
fS=  cOutSciFolder  + cFilters[1] + cNameExtAlig
iS1 = readfits(fS,hS1)
fS=  cOutSciFolder  + cFilters[2] + cNameExtAlig
iS2 = readfits(fS,hS2)

	
; ------- Aligning Images
hastrom, iS1, hS1, hS0, MISSING = 0
hastrom, iS2, hS2, hS0, MISSING = 0


;-------- Aperture Photometry
find, iS0, xS0, yS0, Flux0, Sharp, Round, cHmin[0], cFWHM, cRound, cSharp
aper, iS0, xS0, yS0, MagAper0, MagErr0,  Sky0, SkyErr0, cPhDig, cApertures, cSkyRad, cBadPix, /exact
aper, iS0, xS0, yS0, FluxAper, MagErr,  Sky, SkyErr, cPhDig, cApertures, cSkyRad, cBadPix, /exact, /flux

find, iS1, xS1, yS1, Flux1, Sharp, Round, cHmin[1], cFWHM, cRound, cSharp
aper, iS1, xS1, yS1, MagAper1, MagErr1,  Sky1, SkyErr1, cPhDig, cApertures, cSkyRad, cBadPix, /exact
aper, iS1, xS1, yS1, FluxAper1, MagErr1,  Sky1, SkyErr1, cPhDig, cApertures, cSkyRad, cBadPix, /exact, /flux

find, iS2, xS2, yS2, Flux2, Sharp, Round, cHmin[2], cFWHM, cRound, cSharp
aper, iS2, xS2, yS2, MagAper2, MagErr2,  Sky2, SkyErr2, cPhDig, cApertures, cSkyRad, cBadPix, /exact
aper, iS2, xS2, yS2, FluxAper2, MagErr2,  Sky2, SkyErr2, cPhDig, cApertures, cSkyRad, cBadPix, /exact, /flux



;---------- fitting (same fashion as in the airmas to get more information about the conversion)
cMagGood = where(MagAper1 gt 1 and MagAper1 le 30)
Mag1= MagAper1[cMagGood]
point1 = Max(Mag1)
point2 = Min(Mag1)
x1 =  - 2.5 * alog(Max(Flux1)/cExposureTimeScience)
x2 =  - 2.5 * alog(Min(Flux1)/cExposureTimeScience)
a1 = (point1-point2)/(x1-x2)
b1 = (point1+point2 - a1*(x1+x2))/2

cMagGood = where(MagAper0 gt 1 and MagAper0 le 30)
Mag0= MagAper0[cMagGood]
point1 = Max(Mag0)
point2 = Min(Mag0)
x1 =  - 2.5 * alog(Max(Flux0)/cExposureTimeScience)
x2 =  - 2.5 * alog(Min(Flux0)/cExposureTimeScience)
a0 = (point1-point2)/(x1-x2)
b0 = (point1+point2 - a0*(x1+x2))/2

cMagGood2 = where(MagAper2 gt 1 and MagAper2 le 30)
Mag2= MagAper2[cMagGood]
point1 = Max(Mag2)
point2 = Min(Mag2)
print, point1
print, point2
x1 =  - 2.5 * alog(Max(Flux2)/cExposureTimeScience)
x2 =  - 2.5 * alog(Min(Flux2)/cExposureTimeScience)
a2= (point1-point2)/(x1-x2)
b2 = (point1+point2 - a2*(x1+x2))/2



;----------- correcting airmass and calculating the magnitude
aMag0= - 2.5 * alog(Flux0/cExposureTimeScience)*a0 +  b0; - aAir[0]*z[0+2] , +3
aMag1 = - 2.5 * alog(Flux1/cExposureTimeScience)*a1 + b1 -3; - aAir[1]*z[1+2]
aMag2 = - 2.5 * alog(Flux2/cExposureTimeScience)*a2 + b2-5; - aAir[2]*z[2+2]  ;-2

;---------- cluster identification
extast, hS0,astr
xy2ad, xS0, yS0,astr, A0, D0
srcor, RA, DE, A0,D0,30, ind01,ind02;,option=2
extast, hS1,astr
xy2ad, xS1, yS1,astr, A1, D1
srcor, RA, DE, A1,D1,5, ind11,ind12;,option=2
extast, hS2,astr
xy2ad, xS2, yS2,astr, A2, D2
srcor, RA, DE, A2,D2,40, ind21,ind22;,option=2

RAm0 = RA[ind02]
RAm1 = RA[ind12]
RAm2 = RA[ind22]
DEm0 = DE[ind02]
DEm1 = DE[ind12]
DEm2 = DE[ind22]
Mag0 = aMag0[ind01]
Mag1 = aMag1[ind11]
Mag2 = aMag2[ind21]

n0 = n_elements(Mag0)
n1 = n_elements(Mag1)
n2 = n_elements(Mag2)

BV = fltarr(n1)
V = fltarr(n1)
VI = fltarr(n1)


for i=0, n0-1 do begin
	for j=0, n1-1 do begin
		if RAm0[i] eq RAm1[j] and DEm0[i] eq DEm1[j] then begin
			BV(i) = Mag0[i] - Mag1[j]
			V(i) = 	Mag1[j]
		endif
	endfor
endfor

for i=0, n0-1 do begin
	for j=0, n1-1 do begin
		if RAm1[i] eq RAm2[j] and DEm2[i] eq DEm2[j] then begin
			VI(i) = Mag1[i] - Mag2[j]
		endif   
	endfor
endfor


;--------- saving the color data
save, BV  , VI,  V, filename= cOutPhotoFolder+ 'color.dat'

end
