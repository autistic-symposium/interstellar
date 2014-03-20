pro diagrams


;**********************************************************************************
;**********************************************************************************
;
; [MARINA VON STEINKIRCH, SPRING/2012]
;
; TO COMPILE IT IN IDL:
;	1) Make sure you have the folders defined in constants.pro.
;	2) Set the initial contant names and values in constants.pro.
;	3) Type IDL> .compile diagrams
;	   Type IDL> diagrams
;
; COLLECTION OF MACROS IN IDL TO PERFORM CALIBRATION, ASTROMETRY, PHOTOMETRY, 
; AND TO STUDY THE INTERSTELLAR DUST EXTINCTION OF A OPEN CLUSTER:
;	1) aligning.pro
;	2) calibration.pro 
;	3) astrometry.pro
;	4) airmass.pro
;	5) photometry.pro
;	6) diagrams.pro  (this)
;
; THIS MACRO WILL: 
;	1) Read data from photometry and plot diagrams.
;	2) Plot color-color and find extinction.
;	3) Plot magnitude-color and find distance and age.
;
;**********************************************************************************
;**********************************************************************************

@constants


; -------Restoring data from photometry.

restore,cOutPhotoFolder +'color.dat' ;	BV  , VI,  V
readcol,'m35.dat', NumberMember, NumberMember, oRA,oDE, VData, VIData, BVData, eVData, eVIData, eBVData, RA, DE
readcol,'iso.sav', isoB, isoV
readcol,'iso2.sav', isoB2, isoV2


coxx = fltarr(1)
coxx(0)= -0.24
coxy = fltarr(1)
a = where(Min(BV))
coxy(0)= VI[a]

bluest = Min(BV) ; larger index, redder
Ebv = coxx - bluest
Av = 3.086*(Ebv)
print, Ebv
print, Av


;------- Colour-Colour Diagram  
;device, decomposed=0  
;loadct,5 

names= ['Simbad Catalogue', 'Measured', 'Cox(2000) Bluest Locus']
dots = [3,4,6]
colors = [100, 200, 300]

;plot, VI , BV,/nodata, psym=3, title='Colour-Colour Diagram',xtitle='B-V',ytitle='V-I',xrange=[-0.5,1.5], yrange=[-0.5,1]
;legend, names, color = colors, psym = dots
;oplot,  VIData, BVData , psym=dots[0], color = colors[0]
;oplot, BV, VI , psym=dots[1], color = colors[1]
;oplot,  coxx, coxy, psym = dots[2], color = colors[2]
;iPic = tvrd()
;write_png, cOutDiagFolder +  'cc.png', iPic


;------ Colour-Magnitude Diagram
cox2x= [ -0.3,-0.24,-0.17,-0.11,-0.02, 0.05,0.15, 0.3, 0.35]
cox2y=[-4,-2.45,-1.2, -0.25,0.65,1.3, 1.95, 2.7, 3.6]
n = n_elements(BV)
Bun = fltarr(n)
Vun = fltarr(n)
for i=0, n-1 do begin
	Bun[i] = BV[i]+Ebv
	Vun[i] = V[i]+Av
endfor


names= ['Simbad Catalogue', 'Measured with Av= 2.27', 'Measured with Av=0 (unextincted)',  'Cox(2000) Main Sequence']
dots = [3,4,5,6]
colors = [100, 200,300, 400]

;plot,  BV,V,/nodata, psym=3, title='Colour-Magnitude Diagram',xtitle='B-V',ytitle='V',yrange=[20, -10], xrange=[-.5,1]
;legend, names, color = colors, psym = dots
;oplot,   BVData , VData, psym=dots[0], color = colors[0]
;oplot,  BV, V , psym=dots[1], color = colors[1]
;oplot, Bun, Vun , psym=dots[2], color = colors[2]
;oplot,  cox2x, cox2y, psym = dots[3], color = colors[3]
;iPic = tvrd()
;write_png, cOutDiagFolder +  'mc.png', iPic



; ----------- Calculating distances
;----- galactic ext law
m35galactic = 2.2
m= (Av*sin(m35galactic))/18
dgal= 10^((m-Vun+5)/5)
dgal=10^6*dgal
print, dgal


;----- main sequence fitting
deltaV=cox2y - Vun
d = 10^(1 + deltaV/5)
print, d*10^(6)


;------- Estimating age from isochones

names= ['Simbad Catalogue', 'CMD Isochrone for Av=0.65','CMD Isochrone for Av=2.2' , 'Measured']
dots = [6,4,5, 4]
colors = [100, 200,300, 400]

;plot,  isoV,isoB-isoV,/nodata, psym=3, title='Isochrone Fiting',xtitle='B-V',ytitle='V',yrange=[0, 20], xrange=[0,2]
;legend, names, color = colors, psym = dots
;oplot,   BVData , VData, psym=dots[0], color = colors[0]
;oplot,  isoV, isoB - isoV , psym=dots[1], color = colors[1]
;oplot,  isoV2, isoB2 - isoV2 , psym=dots[3], color = colors[3]
;oplot, Bun, Vun , psym=dots[2], color = colors[2]
;iPic = tvrd()
;write_png, cOutDiagFolder +  'iso.png', iPic


; ---- Fiting
Age=10^(8)
yfit = curvefit(Vun, Bun,1, Age)
print, isoV
print, chi




end

