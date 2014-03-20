pro astrometry


;**********************************************************************************
;**********************************************************************************
;
; [MARINA VON STEINKIRCH, SPRING/2012]
;
; TO COMPILE IT IN IDL:
;	1) Make sure you have the folders defined in constants.pro.
;	2) Set the initial constant names and values in constants.pro.
;	3) Align the final calibrated images by -solve-field (astrometry.net)
;	3) Type IDL> .compile astrometry
;	   Type IDL> astrometry
;
; COLLECTION OF MACROS IN IDL TO PERFORM CALIBRATION, ASTROMETRY, PHOTOMETRY, 
; AND TO STUDY THE INTERSTELLAR DUST EXTINCTION OF A OPEN CLUSTER:
;	1) aligning.pro
;	2) calibration.pro 
;	3) astrometry.pro  (this)
;	4) airmass.pro
;	5) photometry.pro
;	6) diagrams.pro  
;
; THIS MACRO WILL: 
;	1) Align final frams with hastrom, rotate.
;
;**********************************************************************************
;**********************************************************************************

@constants

;------ Science -------------------
fB =  cOutSciFolder  + cNameScience + '_final_' + cFilters[0] +  cNameExtAlig
B = readfits(fB,hB)
B = rotate(B,3)
writefits,  cOutSciFolder  + cNameScience + '_final_aligned_B' + cNameExtAlig, B, hB

fV=  cOutSciFolder  + cNameScience + '_final_' + cFilters[1] + cNameExtAlig
V = readfits(fV,hV)
hastrom, V, hV, V_shift, hV_shift, hB, MISSING=-10000
V = rotate(V,3)
writefits,  cOutSciFolder  + cNameScience + '_final_aligned_V' + cNameExtAlig, V_shift, hV_shift

fI=  cOutSciFolder  + cNameScience + '_final_' + cFilters[2] +  cNameExtAlig
I = readfits(fI,hI)
hastrom, I, hI, I_shift, hI_shift, hB, MISSING=-10000
I = rotate(I,3)
writefits,  cOutSciFolder  + cNameScience + '_final_aligned_I' + cNameExtAlig, I_shift, hI_shift, hI


; ----------- Standard -----------
fB =  cOutStanFolder  + 'standard_final_A1_' + cFilters[0] +  cNameExtAlig
B = readfits(fB,hB)
B = rotate(B,3)
writefits,  cOutStanFolder  + 'standard_final_aligned_B_A1' + cNameExtAlig, B,hB

fV=  cOutStanFolder  + 'standard_final_A1_' + cFilters[1] + cNameExtAlig
V = readfits(fV,hV)
hastrom, V, hV, V_shift, hV_shift, hB, MISSING=-10000
V = rotate(V,3)
writefits,  cOutStanFolder  + 'standard_final_aligned_V_A1' + cNameExtAlig, V_shift, hV_shift

fI=  cOutStanFolder  + 'standard_final_A1_' + cFilters[2] +  cNameExtAlig
I = readfits(fI,hI)
hastrom, I, hI, I_shift, hI_shift, hB, MISSING=-10000
I = rotate(I,3)
writefits,  cOutStanFolder  + 'standard_final_aligned_I_A1' + cNameExtAlig, I_shift, hI_shift, hI


fB =  cOutStanFolder  + 'standard_final_A2_' + cFilters[0] +  cNameExtAlig
B = readfits(fB,hB)
B = rotate(B,3)
writefits,  cOutStanFolder  + 'standard_final_aligned_B_A2' + cNameExtAlig, B,hB

fV=  cOutStanFolder  + 'standard_final_A2_' + cFilters[1] + cNameExtAlig
V = readfits(fV,hV)
V = rotate(V,3)
hastrom, V, hV, V_shift, hV_shift, hB, MISSING=-10000
writefits,  cOutStanFolder  + 'standard_final_aligned_V_A2' + cNameExtAlig, V_shift, hV_shift

fI=  cOutStanFolder  + 'standard_final_A2_' + cFilters[2] +  cNameExtAlig
I = readfits(fI,hI)
hastrom, I, hI, I_shift, hI_shift, hB, MISSING=-10000
I = rotate(I,3)
writefits,  cOutStanFolder  + 'standard_final_aligned_I_A2' + cNameExtAlig, I_shift, hI_shift, hI

end

