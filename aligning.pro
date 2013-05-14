pro aligning


;**********************************************************************************
;**********************************************************************************
;
; [MARINA VON STEINKIRCH, SPRING/2012]
;
; TO COMPILE IT IN IDL:
;	1) Make sure you have the folders defined in constants.pro.
;	2) Set the initial contant names and values in constants.pro.
;	3) Type IDL> .compile aligning
;	   Type IDL> aligning
;
; COLLECTION OF MACROS IN IDL TO PERFORM CALIBRATION, ASTROMETRY, PHOTOMETRY, 
; AND TO STUDY THE INTERSTELLAR DUST EXTINCTION OF A OPEN CLUSTER:
;	1) aligning.pro (this)
;	2) calibration.pro 
;	3) astrometry.pro
;	4) airmass.pro
;	5) photometry.pro
;	6) diagrams.pro  
;
; THIS MACRO WILL: 
;	1) Read the science and standard images into array, for differente filters.
;	2) Align all the images of the stack with the first one.
;	7) Run a gaussian fit to improve the alignment.
;
; (variable names c for constants, a for array, f for file names, i for images)
;
;**********************************************************************************
;**********************************************************************************

@constants


;----------------------------------------------------------------------
; 1) Read the all the images and their headers, align them with the 
; first of the stack.
;----------------------------------------------------------------------
for j=0, cNumberFilters-1 do begin
	for i=0, cNumberFilesScience-1 do begin
   		fSc =  cScienceFolder + cFilterFolder[j]  + strtrim(i+1,2) + cNameExt 		
		iSc = readfits(fSc,hSc)	
		cRA = sxpar(hSc,'CRVAL1') 
		cDEC = sxpar(hSc,'CRVAL2')
  		if i eq 0 then begin
    			cRAref = cRA					
    			cDECref = cDEC  
  		endif
		cRAoffset = cRAref - cRA 				
  		cDECoffset = cDECref - cDEC  
	  	cRAoffsetPixels = cRAoffset * 90000.   		; Converting degrees to pixels.
  		cDECoffsetPixels = cDECoffset * 90000.
  		iSc2 = shift(iSc, round(cRAoffsetPixels), round(cDECoffsetPixels) )	
		writefits,  cScienceFolder + cFilterFolder[j]  + strtrim(i+1,2) + '_align0' + cNameExt, iSc2, hSc
	endfor

for i=0, 9 do begin
		fSt =  cStandardFolder + cFilterFolder[j]  + strtrim(i+1,2) + cNameExt
		iSt = readfits(fSt,hSt)
		cRA = sxpar(hSt,'CRVAL1') 
		cDEC = sxpar(hSt,'CRVAL2')
  		if i eq 0 then begin
    			cRAref = cRA					
    			cDECref = cDEC 
		endif 
	  	cRAoffset = cRAref - cRA 				
  		cDECoffset = cDECref - cDEC  
  		cRAoffsetPixels = cRAoffset * 90000.   		
  		cDECoffsetPixels = cDECoffset * 90000.
  		iSt2 = shift(iSt, round(cRAoffsetPixels), round(cDECoffsetPixels) )	
		writefits, cStandardFolder + cFilterFolder[j]  + strtrim(i+1,2) +  '_align0_A1' + cNameExt, iSt2, hSt		
	endfor	
	for i=0, 9 do begin
		fSt =  cStandardFolder + cFilterFolder[j]  + strtrim(i+11,2) + cNameExt
		iSt = readfits(fSt,hSt)
		cRA = sxpar(hSt,'CRVAL1') 
		cDEC = sxpar(hSt,'CRVAL2')
  		if i eq 10 then begin
    			cRAref = cRA					
    			cDECref = cDEC 
		endif 
	  	cRAoffset = cRAref - cRA 				
  		cDECoffset = cDECref - cDEC  
  		cRAoffsetPixels = cRAoffset * 90000.   		
  		cDECoffsetPixels = cDECoffset * 90000.
  		iSt2 = shift(iSt, round(cRAoffsetPixels), round(cDECoffsetPixels) )	
		writefits, cStandardFolder + cFilterFolder[j]  + strtrim(i+1,2) +  '_align0_A2' + cNameExt, iSt2, hSt				
	endfor	
endfor

;----------------------------------------------------------------------
; 2) Gaussian fit to improve the alignment.
;----------------------------------------------------------------------
for j=0, cNumberFilters-1 do begin
	for i=0, cNumberFilesScience-1 do begin
   		fSc =  cScienceFolder + cFilterFolder[j]  + strtrim(i+1,2) + '_align0' + cNameExt 		
		iSc = readfits(fSc,hSc)	
  		cCutOut = iSc(291:497,215:446)
  		aDummy = gauss2dfit(cCutOut,cCoefficients)
  		cXcenter = cCoefficients(4)
  		cYcenter = cCoefficients(5)
  		if i eq 0 then begin
   			cXref = cXcenter  
   			cYref = cYcenter  
  		endif
		if i eq 10 then begin
   			cXref = cXcenter  
   			cYref = cYcenter  
  		endif
		cXoffset = cXref - cXcenter  
  		cYoffset = cYref - cYcenter 
  		iSc2 = shift(iSc, round(cXoffset), round(cYoffset) )	
		writefits,  cScienceFolder + cFilterFolder[j]  + strtrim(i+1,2) + '_align' + cNameExt, iSc2, hSc
	endfor
	for i=0, 9 do begin
		fSt =  cStandardFolder + cFilterFolder[j]  + strtrim(i+1,2) + '_align0_A1' + cNameExt
		iSt = readfits(fSt,hSt)
		cCutout = iSt(291:497,215:446)
 		aDummy = gauss2dfit(cCutout,cCoefficients)
  		cXcenter = cCoefficients(4)
  		cYcenter = cCoefficients(5)
  		if i eq 0 then begin
   			cXref = cXcenter  
   			cYref = cYcenter  
  		endif
		cXoffset = cXref - cXcenter  
  		cYoffset = cYref - cYcenter 
  		iSt2 = shift(iSt, round(cXoffset), round(cYoffset) )	
		writefits, cStandardFolder + cFilterFolder[j]  + strtrim(i+1,2) +  '_align_A1' + cNameExt, iSt2, hSt		
	endfor	
	for i=0 , 9 do begin
		fSt =  cStandardFolder + cFilterFolder[j]  + strtrim(i+1,2) + '_align0_A2' + cNameExt
		iSt = readfits(fSt,hSt)
		cCutout = iSt(291:497,215:446)
 		aDummy = gauss2dfit(cCutout,cCoefficients)
  		cXcenter = cCoefficients(4)
  		cYcenter = cCoefficients(5)
  		if i eq 0 then begin
   			cXref = cXcenter  
   			cYref = cYcenter  
  		endif
		cXoffset = cXref - cXcenter  
  		cYoffset = cYref - cYcenter 
  		iSt2 = shift(iSt, round(cXoffset), round(cYoffset) )	
		writefits, cStandardFolder + cFilterFolder[j]  + strtrim(i+1,2) +  '_align_A2' + cNameExt, iSt2, hSt
endfor




end
