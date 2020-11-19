# ρ-MtreeRing
## What is ρ-MtreeRing?
ρ-MtreeRing is an Free Open Source Software for tree rings microdensity analysis on Shiny. It is developed from MtreeRing [1].

## Installing ρ-MtreeRing
Download **app.R** file on your computer and launch it on R or RStudio. We highly recommend open Shiny interface on browser by clicking on the upper-left displayed option `Open in Browser`.


![OpenInBrowser_](https://user-images.githubusercontent.com/74645623/99637329-fa468380-2a44-11eb-8695-56193a9c3a90.png)


## Using ρ-MtreeRing

### Data Loading  

**Upload Sample Image**  
At *Image Upload* box, browse and select a X-ray digitalized image from your computer and click on `Load`. Image will be displayed on the *Image Preview* box and can be cropped to select the area of interest or rotated to led recent years or bark on the left of the image.

![ImagePrev](https://user-images.githubusercontent.com/74645623/99530335-75eef480-29a1-11eb-964d-cd6ebb58b9bb.png)


**Light Calibration**  
Fill available thickness and intensity boxes or load it from a file from your computer from stepped calibration wedge values. Afterwards, regression algorithm can be chosen from `Local regression` or `Cubic smoothing spline`. Once those data are fulfilled, click on the `Plot` button. Therefore, steps and regression curve will be displayed from *XRing* [2] based script.  

![LightCal](https://user-images.githubusercontent.com/74645623/99530486-a59dfc80-29a1-11eb-8be6-20ea8d29a8a6.png)


### Density Analysis

**Entry Sample Info**
Complete Sample ID, Year of obtention. DPI and Sample thickness are required to obtain comparative values of ring width and density among different samples.  
At *Path Info* box, you can select the desired path mode (pay attention to ring detection requirements) and number of pixels to extract density profile.

![SampleInfo](https://user-images.githubusercontent.com/74645623/99530605-d5e59b00-29a1-11eb-8b7f-19e7480c6438.png)


**Path Creation**  
In the *Main Window*, firstly select path limits by double-left-clicking on the left side (recent years) of the sample to place the beginning of the segment and continue delimiting path segments across the sample perpendicularly to ring limits. If you need to zoom in/out the sample, you can use the bars placed behind an on the left of the working window.
Path width for density extraction can be changed throughout the entire analysis. 

**Ring Detection and Editing** 
Once the desired path is set, confirm the ring selection method options at *Detection Options* box and click on `Run Detection for Years`.
If, unfortunately, automatic ring detection did not work properly, you can modify ring borders on `Ring Editing` mode. One click on the desired ring border set a new border, while you can select one or multiple ring borders by clicking and dragging to delete them by clicking on `Delete Border`.

**Earlywood/Latewood Detection and Editing**  
For intra-annual border detection click on `Run Detection for Early-Late Wood`. Furthermore, you can edit those borders in the same way that for ring borders by enablig `Edit Early/Late Wood` box in the `Ring Editing` mode.

*WARNING*: In case you measure Earlywood/Latewood number of intra-annual borders must be equal to number of ring borders.

![MainInfo](https://user-images.githubusercontent.com/74645623/99530533-b9e1f980-29a1-11eb-9864-9c6589f7956d.png)

### Results

**Optional Sample Info**  
In this window you can complete various information about site, species, researcher or date.

**Output**
Analysed measures can be exported on various formats:  
1.-*Comma Separated Values*. Containing density and ring measures.
2.-*Excel format*. Containing density, ring measures and optional info.
3.-*RWL*. Containing ring measures.
4.-*Project at RDS format*. Containing data to reopen the project by loading it further on for corrections. 

![Results](https://user-images.githubusercontent.com/74645623/99530723-f7df1d80-29a1-11eb-9e20-5035f0ad3c59.png)


## References

[1] Jingning Shi, Wei Xiang, Qijing Liu, Sher Shah,
MtreeRing: An R package with graphical user interface for automatic measurement of tree ring widths using image processing techniques,
Dendrochronologia,
Volume 58,
2019,
125644,
ISSN 1125-7865,
https://doi.org/10.1016/j.dendro.2019.125644.
(http://www.sciencedirect.com/science/article/pii/S1125786519301006)

[2] Filipe Campelo, Konrad Mayer, Michael Grabner,
xRing—An R package to identify and measure tree-ring features using X-ray microdensity profiles,
Dendrochronologia,
Volume 53,
2019,
Pages 17-21,
ISSN 1125-7865,
https://doi.org/10.1016/j.dendro.2018.11.002.
(http://www.sciencedirect.com/science/article/pii/S112578651830095X)

