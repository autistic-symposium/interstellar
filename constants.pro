;-------------------------------------------------------------------------------------------
; Constants and variables.
; I use the following subfolders for data:
;			i) /Name_of_your_science with subfolders for each filter;
;			ii) /standard with subfolders for each filter;
;			iii) /flat with subfolders /high and /low and subsubfoldres
;				for each filter;
;			iv) /dark with subfolders for each exposure time.
;			v) output/science, output/calibration, output/standard,
;				output/photometry, output/airmass.
;
;--------------------------------------------------------------------------------------------

cNameScience = 'm35'
cFrameSize = 512
cNumberFilesScience = 10
cNumberFilesStandard = 20
cNumberFilesFlat = 10
cNumberFilesDark = 10
cNameExt = '.fit'
cNameExtAlig = '.fits'

cNumberFilters = 3
cFilters=['B','V','I']
cFilterFolder=['B/','V/','I/']


az = [37,40, 39, 38, 37.5]
z = [1./(cos(az[0])),- 1./(cos(az[1])), 1./(cos(az[2])), 1./(cos(az[3])), 1./(cos(az[4])) ]


; -------------- Folder and File Destination:----------------------
cOutCalFolder = 'output/calibration/'
cOutSciFolder = 'output/science/'
cOutStanFolder = 'output/standard/'
cOutPhotoFolder = 'output/photometry/'
cOutAirFolder = 'output/airmass/'
cOutDiagFolder = 'output/diagrams/'


;------------ Calibration Constants ------------------------------
cNumberExpTime = 6
cScienceFolder = cNameScience + '/'
cStandardFolder =  'standard/'
cFlatFolder = 'flat/'
cExposureTimes=['005','01','025','1','5','15']
cDarkFolder = ['dark/005/','dark/01/','dark/025/','dark/1/','dark/5/','dark/15/']
cExposureTimeScience = cExposureTimes[5]
cExposureTimeStandard = [cExposureTimes[5], cExposureTimes[5], cExposureTimes[4]]
cExposureTimesFlatHigh = [ cExposureTimes[3], cExposureTimes[3],  cExposureTimes[1]] ; B,V,I
cExposureTimesFlatLow = [cExposureTimes[2],cExposureTimes[2], cExposureTimes[0]]


; ---------------- Photometry Constants --------------------------
;---- find
cHmin =[279+3*sqrt(270),850+3*sqrt(850), 3120+3*sqrt(3120)]  
cFWHM = 5

;--- aper
cSharp= [0.2,1.0] 
cRound = [-1.0,1.0] 
cPhDig = 2.0 
cApertures= [5]
cSkyRad = [10,20]
cBadPix= [0,0]


; ------------- Diagram Constants
aBlueCox = [1.64, 1.80+1.67] ; 
