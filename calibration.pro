@fixpix
@strc

pro calibration


;**********************************************************************************
;**********************************************************************************
;
; [MARINA VON STEINKIRCH, SPRING/2012]
;
; TO COMPILE IT IN IDL:
;	1) Make sure you have the folders defined in constants.pro.
;	2) Set the initial contant names and values in constants.pro.
;	3) Type IDL> .compile calibration
;	   Type IDL> calibration
;
; COLLECTION OF MACROS IN IDL TO PERFORM CALIBRATION, ASTROMETRY, PHOTOMETRY, 
; AND TO STUDY THE INTERSTELLAR DUST EXTINCTION OF A OPEN CLUSTER:
;	1) aligning.pro
;	2) calibration.pro  (this)
;	3) astrometry.pro
;	4) airmass.pro
;	5) photometry.pro
;	6) diagrams.pro  
;
; THIS MACRO WILL: 
;	1) Read the images into array, and median combine to _raw_ stack.
;		a) The science in different filters (and align/astrometry).
;		b) The standard in different filters (and align/astrometry).
;		c) The flat in different filters and exposure times (low and high).
;		d) The dark in different exposure times (low, high, science, standard).
;	2) Create Master Dark Frame, reduce from science, standard, and flats, and 
;	median combine to _dark_ stack.
;	3) Create Mater Flat Frame, reduce from science and stardard, and combine
;	the resulting science and standard images to _flat_ stack.
;	4) Create Bad Pixel Frame, reduce from combine from science and standard,
;	and median combine to _pix_ stack.
;
; (variable names c for constants, a for array, f for file names, i for images)
;
;**********************************************************************************
;**********************************************************************************

@constants
@calibration_arrays



;----------------------------------------------------------------------
; 1) Read the all the images of our science, put into an array (raw)
;----------------------------------------------------------------------
for j=0, cNumberFilters-1 do begin
	for i=0, cNumberFilesScience-1 do begin
   		fSc =  cScienceFolder + cFilterFolder[j]  + strtrim(i+1,2) + '_align' + cNameExt		
		iSc = readfits(fSc,hSc)	
		iSc = float(iSc)
		aScience(j,i,*,*) = iSc	
	endfor
	for i=0, 9 do begin
		fSt =  cStandardFolder + cFilterFolder[j]  + strtrim(i+1,2) +  '_align_A1' + cNameExt
		iSt = readfits(fSt,hSt)
		iSt = float(iSt)
		aStandard(j,i,*,*) = iSt
	endfor
	for i=0, 9 do begin
		fSt2 =  cStandardFolder + cFilterFolder[j]  + strtrim(i+1,2) +  '_align_A2' + cNameExt
		iSt2 = readfits(fSt2,hSt2)
		iSt2 = float(iSt2)
		aStandard2(j,i,*,*) = iSt2
	endfor
	for i=0, cNumberFilesFlat-1 do begin		
		fFl = cFlatFolder + 'low/' + cFilterFolder[j]  + strtrim(i+1,2) + cNameExt
 		iFl = readfits(fFl,hFl)
		iFl = float(iFl)
		aFlatLow(j,i,*,*) = iFl
	endfor
	for i=0, cNumberFilesFlat-1 do begin		
		fFh = cFlatFolder + 'high/' + cFilterFolder[j]  + strtrim(i+1,2) + cNameExt
 		iFh = readfits(fFh,hFh)
		iFh = float(iFh)
		aFlatHigh(j,i,*,*) = iFh
	endfor  	
endfor
for j=0, cNumberExpTime-1 do begin
	for i=0, cNumberFilesDark-1 do begin
		fDa = cDarkFolder[j]  + strtrim(i+1,2) + cNameExt
		iDa = readfits(fDa, hDa)
		iDa = float(iDa)
		aDark(j,i,*,*) = iDa
	endfor
endfor

for j=0, cNumberFilters-1 do begin
	for x=0,cFrameSize-1 do begin
		for y=0,cFrameSize-1 do begin
			for i=0,cNumberFilesScience-1 do begin
				aScienceFilter(i,x,y) = aScience(j,i,x,y)	
			endfor
			for y=0,cFrameSize-1 do begin
				for i=0,9 do begin
					aStandardFilter(i,x,y) = aStandard(j,i,x,y)	
				endfor
				for i=0, 9 do begin
					aStandardFilter2(i,x,y) = aStandard2(j,i,x,y)	
				endfor
			for i=0,cNumberFilesFlat-1 do begin
				aFlatHighFilter(i,x,y) = aFlatHigh(j,i,x,y)	
				aFlatLowFilter(i,x,y) = aFlatLow(j,i,x,y)	
			endfor			
		endfor
	endfor
	for x=0,cFrameSize-1 do begin
		for y=0,cFrameSize-1 do begin
		    	aScienceFrame(x,y) = median( aScienceFilter(*,x,y), /even )
			aStandardFrame(x,y) = median( aStandardFilter(*,x,y), /even ) 
			aStandardFrame2(x,y) = median( aStandardFilter2(*,x,y), /even ) 
		    	aFlatLowFrame(x,y) =  median( aFlatLowFilter(*,x,y), /even ) 
			aFlatHighFrame(x,y) =  median( aFlatHighFilter(*,x,y), /even )
		endfor
	endfor		
	writefits, cOutStanFolder + 'standard_raw_A1_' + cFilters[j] + cNameExt, aStandardFrame, hSt	
	writefits, cOutStanFolder + 'standard_raw_A2_' + cFilters[j] + cNameExt, aStandardFrame2, hSt2
	writefits, cOutSciFolder  + cNameScience + '_raw_' + cFilters[j] + cNameExt, aScienceFrame, hSc
	writefits, cOutCalFolder + 'FlatLow_' + cFilters[j] + cNameExt, aFlatLowFrame, hFl
	writefits, cOutCalFolder + 'FlatHigh_' + cFilters[j] + cNameExt, aFlatHighFrame, hFh
endfor



;-------------------------------------------------------------------------
;2) Substract dark.
;-------------------------------------------------------------------------
for j=0, cNumberFilters-1 do begin
	for x=0,cFrameSize-1 do begin
		for y=0,cFrameSize-1 do begin
		    	aDarkMedian(j,x,y) =  median( aDark(*,*,x,y), /even ) 
		endfor
	endfor	
endfor

for j=0, cNumberFilters-1 do begin
	for m=0, cNumberExpTime-1 do begin
		for i=0, cNumberFilesScience-1 do begin
			if cExposureTimes(m) eq cExposureTimeScience then begin
				aScience(j,i,*,*) = aScience(j,i,*,*) - aDarkMedian(j,*,*)
			endif
		endfor
		
		for i=0, 9 do begin
			if cExposureTimes(m) eq cExposureTimeStandard then begin
				aStandard(j,i,*,*) = aStandard(j,i,*,*) - aDarkMedian(j,*,*)
			endif	
		endfor

		for i=0, 9 do begin
			if cExposureTimes(m) eq cExposureTimeStandard then begin
				aStandard2(j,i,*,*) = aStandard2(j,i,*,*) - aDarkMedian(j,*,*)
			endif	
		endfor

		for i=0, cNumberFilesFlat-1 do begin
			for k=0, cNumberFilters-1 do begin
				if cExposureTimes(m) eq cExposureTimesFlatLow(k) then begin	
					aFlatLow(k,i,*,*) = aFlatLow(k,i,*,*) - aDarkMedian(k,*,*)
				endif	
				if cExposureTimes(m) eq cExposureTimesFlatHigh(k)  then begin
					aFlatHigh(k,i,*,*) = aFlatHigh(k,i,*,*) - aDarkMedian(k,*,*)
				endif
			endfor
		endfor
	endfor
endfor

for j=0, cNumberFilters-1 do begin
	for x=0,cFrameSize-1 do begin
		for y=0,cFrameSize-1 do begin
			for i=0,cNumberFilesScience-1 do begin
				aScienceFilter(i,x,y) = aScience(j,i,x,y)	
			endfor
			for i=0,9 do begin
				aStandardFilter(i,x,y) = aStandard(j,i,x,y)	
			endfor
			for i=0, 9 do begin
				aStandardFilter2(i,x,y) = aStandard2(j,i,x,y)	
			endfor
			for i=0,cNumberFilesFlat-1 do begin
				aFlatHighFilter(i,x,y) = aFlatHigh(j,i,x,y)	
				aFlatLowFilter(i,x,y) = aFlatLow(j,i,x,y)	
			endfor			
		endfor
	endfor
	for x=0,cFrameSize-1 do begin
		for y=0,cFrameSize-1 do begin
			aStandardFrame(x,y) = median( aStandardFilter(*,x,y), /even ) 
			aStandardFrame2(x,y) = median( aStandardFilter2(*,x,y), /even ) 
		    	aFlatLowFrame(x,y) =  median( aFlatLowFilter(*,x,y), /even ) 
			aFlatHighFrame(x,y) =  median( aFlatHighFilter(*,x,y), /even )
		endfor
	endfor		
	writefits, cOutStanFolder + 'standard_dark_A1_' + cFilters[j] + cNameExt, aStandardFrame, hSt	
	writefits, cOutStanFolder + 'standard_dark_A2_' + cFilters[j] + cNameExt, aStandardFrame2, hSt2

	writefits, cOutSciFolder  + cNameScience + '_dark_' + cFilters[j] + cNameExt, aScienceFrame, hSc
	writefits, cOutCalFolder + 'FlatLow_' + cFilters[j] + cNameExt, aFlatLowFrame, hFl
	writefits, cOutCalFolder + 'FlatHigh_' + cFilters[j] + cNameExt, aFlatHighFrame, hFh
	for x=0,cFrameSize-1 do begin
		for y=0,cFrameSize-1 do begin
			aFlatHighMedian(j,x,y) = aFlatHighFrame(x,y)
			aFlatLowMedian (j,x,y) = aFlatLowFrame(x,y)	
			for i=0,cNumberFilesScience-1 do begin
				aScience(j,i,x,y) = aScienceFrame(x,y)
			endfor
			for i=0,9 do begin
				aStandard(j,i,x,y) = aStandardFrame(x,y)
			endfor
			for i=0, 9 do begin
				aStandard2(j,i,x,y) = aStandardFrame2(x,y)
			endfor
		endfor			
	endfor
endfor



;----------------------------------------------------------------------
; 3) Base-process by dividing by flat.
;----------------------------------------------------------------------
for j=0, cNumberFilters-1 do begin
	aVoid = Max(Histogram(aFlatHighMedian(j,*,*),OMIN=mn), mxpos)
	cMode = mn + mxpos
	aFlatHighNorm(j,*,*) = aFlatHighMedian(j,*,*)/cMode
endfor
for j=0, cNumberFilters-1 do begin
	for i=0, cNumberFilesScience-1 do begin
		aScience(j,i,*,*) = aScience(j,i,*,*)/aFlatHighNorm(j,*,*)
	endfor
	for i=0,9 do begin
		aStandard(j,i,*,*) = aStandard(j,i,*,*)/aFlatHighNorm(j,*,*)
	endfor	
	for i=0, 9 do begin
		aStandard2(j,i,*,*) = aStandard2(j,i,*,*)/aFlatHighNorm(j,*,*)
	endfor	
endfor

for j=0, cNumberFilters-1 do begin
	for x=0,cFrameSize-1 do begin
		for y=0,cFrameSize-1 do begin
			for i=0,cNumberFilesScience-1 do begin
				aScienceFilter(i,x,y) = aScience(j,i,x,y)	
			endfor
			for i=0,9 do begin
				aStandardFilter(i,x,y) = aStandard(j,i,x,y)
			endfor	
			for i=0, 9 do begin
				aStandardFilter2(i,x,y) = aStandard2(j,i,x,y)
			endfor				
		endfor
	endfor
	for x=0,cFrameSize-1 do begin
		for y=0,cFrameSize-1 do begin
		    	aScienceFrame(x,y) = median( aScienceFilter(*,x,y), /even )
			aStandardFrame(x,y) = median( aStandardFilter(*,x,y), /even ) 
			aStandardFrame2(x,y) = median( aStandardFilter2(*,x,y), /even ) 
		endfor
	endfor		
	
	writefits, cOutStanFolder + 'standard_flat_A1_' + cFilters[j] + cNameExt, aStandardFrame, hSt	
	writefits, cOutStanFolder + 'standard_flat_A2_' + cFilters[j] + cNameExt, aStandardFrame2, hSt2
endfor	
	writefits, cOutSciFolder  + cNameScience + '_flat_' + cFilters[j] + cNameExt, aScienceFrame, hSc
endfor


;----------------------------------------------------------------------
; 4) Fixing bad pixels.  
;----------------------------------------------------------------------
for j=0, cNumberFilters-1 do begin
	aPixFlat(j,*,*) =  aFlatHighMedian(j,*,*)/aFlatLowMedian(j,*,*)
	for x=0, cFrameSize-1 do begin
		for y=0, cFrameSize-1 do begin
			aPix(x,y) = aPixFlat(j,x,y)
		endfor	
	endfor
	aMean = mean(aPix)
	aDev = stddev(aPix)
	for x=0, cFrameSize-1 do begin
		for y=0, cFrameSize-1 do begin
			if aPix(x,y) - aMean lt 5*aDev then begin
				aCalFrame(x,y)=1
			endif else begin  
      				aCalFrame(x,y)=0.
			endelse		
		endfor
	endfor	
endfor

for j=0, cNumberFilters-1 do begin
	for x=0,cFrameSize-1 do begin
		for y=0,cFrameSize-1 do begin
			for i=0,cNumberFilesScience-1 do begin
				aScienceFrame(x,y) = aScience(j,i,x,y)	
			endfor
			for i=0,9 do begin
				aStandardFrame(x,y) = aStandard(j,i,x,y)	
			endfor
			for i=0, 9 do begin
				aStandardFrame2(x,y) = aStandard2(j,i,x,y)	
			endfor
		endfor
	endfor
	fixpix, aScienceFrame, aCalFrame, aScienceFinal
	fixpix, aStandardFrame2, aCalFrame, aStandardFinal2
	fixpix, aStandardFrame2, aCalFrame, aStandardFinal2
	aScienceFinal = sigma_filter(aScienceFinal, N_SIGMA=5)
	aStandardFinal = sigma_filter(aStandardFinal, N_SIGMA=5)
	writefits, cOutStanFolder + 'standard_badpix_A1_' + cFilters[j] + cNameExt, aStandardFrame, hSt	
	writefits, cOutStanFolder + 'standard_badpix_A2_' + cFilters[j] + cNameExt, aStandardFrame2, hSt2
	writefits, cOutSciFolder  + cNameScience  + '_badpix_'+ cFilters[j] + cNameExt, aScienceFrame, hSc	
endfor

end
