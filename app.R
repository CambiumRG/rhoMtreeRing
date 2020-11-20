packages = c("shiny", "shinyjs", "shinyWidgets", "shinydashboard", 
             "shinyMatrix", "shinyFiles", "MtreeRing","dplR","measuRing",
             "rgdal", "raster", "zip", "testthat", "magrittr", "magick", 
             "imager", "spatstat", "openxlsx")
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinydashboard)
library(shinyMatrix)
library(shinyFiles)
library(MtreeRing)
library(rgdal)
library(raster)
library(zip)
library(testthat)
library(magrittr)
library(magick)
library(imager)
library(dplR)
library(spatstat)
library(measuRing)
library(dplyr)
library(openxlsx)

# Run the application
createUI <- function()
{
  shiny.title <- dashboardHeader(title = 'ρ-MtreeRing')
  shiny.sider <- dashboardSidebar(
    sidebarMenu(
      menuItem('Data Loading',tabName = 'input_pre', 
               icon = icon('folder-open', lib = 'font-awesome'), selected = TRUE),
      menuItem('Analysis',tabName = 'mea_arg', 
               icon = icon('gear', lib = 'font-awesome')),
      menuItem('Results',tabName = 'mea_results', 
               icon = icon('download', lib = 'font-awesome'))
    )
  )
  page1 <- fluidPage(
    shinyjs::useShinyjs(),
    fluidRow(
      box(
        title = div(style = 'color:#FFFFFF;font-size:80%; 
            font-weight: bolder', 'Image Preview'),
        width = 12, status = 'primary', solidHeader = T, collapsible = T,
        prettyCheckbox(
          inputId = "wh_ratio", 
          label = div(style = 'color:black;font-weight: bolder;',
                      'Maintain original width/height ratio'), 
          shape = "curve", value = F, status = "success"),
        hr(),
        plotOutput('pre.img',
                   brush = brushOpts(
                     id = "plot1_brush",
                     opacity = 0.25,
                     resetOnNew = TRUE)
        )
      ),
    ),
    fluidRow(
      column(4, 
             box(
               title = div(style = 'color:#FFFFFF;font-size:80%;
                           font-weight: bolder', 'Image Upload'),
               width = NULL, status = 'primary', solidHeader = T, collapsible = T,
               fileInput('selectfile', 'Choose an image file',
                         buttonLabel = 'Browse...', width = '95%'),
               actionButton(
                 'buttoninputimage', 'Load ',
                 class = "btn btn-primary btn-md",
                 icon = icon('upload',  "fa-1x"),
                 style = 'color:#FFFFFF;text-align:center; 
                 font-weight: bolder;font-size:110%;'),
               useSweetAlert()
            ),
            box(
              title = div(style = 'color:#FFFFFF;font-size:80%; 
                          font-weight: bolder', 'Load Project'), 
              status = 'primary', 
              solidHeader = T, collapsible = T, width = NULL,
              fileInput('load_project', 
                        'Choose a rds file with the project variables',
                        buttonLabel = 'Browse...', width = '95%'),
              actionButton(
                'buttonproject', 'Load',
                class = "btn btn-primary btn-md",
                icon = icon('upload',  "fa-1x"),
                style = 'color:#FFFFFF;text-align:center; 
                font-weight: bolder;font-size:110%;'),
            ),
      ), 
      column(4, 
             box(
               title = div(style = 'color:#FFFFFF;font-size:80%;
        font-weight: bolder', 'Image Cropping'),
               width = NULL, status = 'primary', solidHeader = T, collapsible = T,
               helpText("To remove unwanted cores and irrelevant objects, ",
                        "move the mouse to the core you wish to measure and",
                        "create a rectangle by brushing, see details below.",
                        style = 'color:black;font-size:90%;text-align:justify;'),
               prettyRadioButtons(inputId = "cropcondition", label = "",
                                  choiceNames = 'UNCROPPED', choiceValues = list('a'),
                                  status = "danger", shape = "square",
                                  fill = FALSE, inline = FALSE),
               prettyCheckbox(
                 inputId = "showcropp", 
                 label = div(style = 'color:black;font-weight: bolder;', 'Show Help'),
                 shape = "curve", value = F, status = "success"
               ),
               conditionalPanel(
                 condition = 'input.showcropp',
                 helpText(
                   "The operation \"brush\" allows users to create a transparent ", 
                   "rectangle on the image and drag it around. For cores scanned ", 
                   "side by side, the user can choose a core of interest by brushing.", 
                   style = 'color:black;text-align:justify;'),
                 helpText(
                   "After brushing, click on the button \"Crop\" to create a",
                   " cropped area. The measurement will be performed within", 
                   " this area, rather than the whole (uncropped) image.",
                   style = 'color:black;text-align:justify;'),
                 helpText(
                   "To cancel this operation, click on the button \"Cancel\".",
                   " If the transparent rectangle exists, the user should first ",
                   "click on the outer region of the rectangle (this will make the",
                   " rectangle disappear) and then click on the button \"Cancel\".",
                   style = 'color:#FF0000;text-align:justify;')
               ),  
               
               hr(),
               actionButton(
                 'buttoncrop', 'Crop',
                 class = "btn btn-primary btn-md",
                 icon = icon('crop',"fa-1x"),
                 style = 'color:#FFFFFF;text-align:center;
        font-weight: bolder;font-size:110%;')
             ),
      ), 
      column(4, 
             box(
               title = div(style = 'color:#FFFFFF;font-size:80%;
        font-weight: bolder', 'Image Rotation'),
               width = NULL, status = 'primary', solidHeader = T, collapsible = T,
               prettyRadioButtons(inputId = "rotatede", label = "",
                                  choices = c("90 degrees" = "rotate90",
                                              "180 degrees" = "rotate180",
                                              "270 degrees" = "rotate270"),
                                  shape = "curve", status = "success",
                                  fill = TRUE, inline = TRUE),
               helpText("Rotation angle in degrees. Note that the bark ",
                        "side should be placed at the left side of the ",
                        "graphics window and the pith side at the right.",
                        style = 'color:black;font-size:90%;text-align:justify;'),
               actionButton(
                 'buttonrotate', 'Rotate',
                 class = "btn btn-primary btn-md",
                 icon = icon('repeat',"fa-1x"),
                 style = 'color:#FFFFFF;text-align:center;
        font-weight: bolder;font-size:110%;'),
             ),
      ), 
    ),
    fluidRow(
      # Box to fill in data for light calibration
      box(
        title = div(style = 'color:#FFFFFF;font-size:80%;
        font-weight: bolder', 'Light Calibration'), status = 'primary', 
        solidHeader = T, collapsible = T, width = 6,
        helpText("Introduce thickness parameters",
                 "as well as image intensity, number of steps",
                 "and the material density for densitometry analysis",
                 style = 'color:black;font-size:90%;text-align:justify;'),
        numericInput("density", "Density (g/cm3)", 1.20, step = 0.1),
        selectInput("reg_model", label = "Regression Algorithm", 
                    choices = list("Local regression" = 'local_regression', 
                                   "Cubic smoothing spline " = 'spline_regression'), 
                    selected = 'local_regression'),
        prettyCheckbox(
          inputId = "loadMatrix", 
          label = div(style = 'color:black;font-weight: bolder;','Load from File'), 
          shape = "curve", value = F, status = "success"),
        conditionalPanel(
          condition = '!input.loadMatrix',
          tableOutput("static"),
          numericInput("nsteps", "Number of Steps:", 2, min = 1, max = 30),
          matrixInput("thickness_matrix",
                      value = matrix(0, 2, 2,dimnames = 
                                       list(NULL,c("Thickness","Intensity"))),
                      rows = list(
                        editableNames = TRUE),
                      class = "numeric",
                      cols = list(names = TRUE)
          ),
          uiOutput("matrixcontrol")),
        conditionalPanel(
          condition = 'input.loadMatrix',
          fileInput('path_matrix', 'Choose a csv file with calibration parameters',
                    buttonLabel = 'Browse...', width = '95%'),
        ),
        conditionalPanel(
          condition = '!input.loadMatrix',
          shinySaveButton("save_calibration", "Save file", "Save file as ...", 
                          filetype = list(csv = "csv")),
          br()),
        hr(),
        actionButton(
          'buttondensity', 'Plot',
          class = "btn btn-primary btn-md",
          icon = icon('upload',  "fa-1x"),
          style = 'color:#FFFFFF;text-align:center;
        font-weight: bolder;font-size:110%;'),
        hr()
      ), 
      # Box for diplaying light Calibration
      box(
        title = div(style = 'color:#FFFFFF;font-size:80%; 
        font-weight: bolder', 'Light Calibration Curve'),width = 6, 
        status = 'primary', solidHeader = T, collapsible = T,
        plotOutput("light")
      ),
    ),
  )
  page2 <- 
    fluidPage(
      fluidRow(
        column(4,
               box(
                 title = div(style = 'color:#FFFFFF;font-size:80%;
            font-weight: bolder', 'Sample Info'), height = "50%",
                 width = NULL, status = 'primary', solidHeader = T, 
                 collapsible = T,
                 textInput('tuid', 'Series ID', '', width = '75%'),
                 textInput('sample_yr', 'Year', '', '75%'),
                 textInput('dpi', 'DPI', '', '75%'),
                 textInput('sample_thickness', 'Sample thickness', '', '75%'),
               ),
               box(
                 title = div(style = 'color:#FFFFFF;font-size:80%;
            font-weight: bolder', 'Path info'), height = "50%",
                 width = NULL, status = 'primary', solidHeader = T, 
                 collapsible = T,
                 pickerInput(
                   inputId = "sel_sin_mul", 
                   div(
                     style = 'color:black;font-weight:bolder;font-size:90%', 
                     'Path Mode'), 
                   width = '87%',
                   choices = c("Single Segment", "Multi Segments"),
                   options = list(style = "btn-primary")
                 ),
                 conditionalPanel(
                   condition = 'input.sel_sin_mul == "Single Segment"',
                   prettyCheckbox(
                     inputId = "hor_path", 
                     label = div(
                       style = 'color:black;font-weight: bolder;font-size:90%', 
                       'Horizontal path'), 
                     shape = "curve", value = T, status = "success"
                   )
                 ),
                 conditionalPanel(
                   condition = 'input.sel_sin_mul == "Multi Segments"',
                   numericInput('num_seg', 
                                div(style = 'color:black;font-weight:bolder;
                                    font-size:90%', 
                                    'Number of segments'),
                                value = 1, min = 1, max = 1, step = 1, 
                                width = "75%"),
                 ),
                 numericInput('pixelspath', 
                              div(style = 'color:black;font-weight:bolder;
                                  font-size:90%', 
                                  'Pixels for density profile'),
                              value = 5, min = 0, max = 20, step = 1, 
                              width = "75%"),
               ),
        ),
        column(4,
               box(
                 title = div(style = 'color:#FFFFFF;font-size:80%;
            font-weight: bolder', 'Label Options'), height = "auto",
                 width = NULL, status = 'primary', solidHeader = T, 
                 collapsible = T,
                 sliderInput('linelwd', 'Path width', 
                             0.2, 3, 1, 0.1, width = '80%'),
                 sliderInput('label.cex', 'Magnification for labels',
                             0.2, 3, 1.5, 0.1, width = '80%'),
                 radioGroupButtons(
                   inputId = "pch", 
                   label = 'Symbol for borders', 
                   status = "btn btn-primary btn-md",
                   size = 'sm',
                   choiceNames = list(
                     div(style = 'color:#FFFFFF;font-weight: bolder;',
                         icon('circle', 'fa-lg')), 
                     div(style = 'color:#FFFFFF;font-weight: bolder;',
                         icon('circle', 'fa-1x')), 
                     div(style = 'color:#FFFFFF;font-weight: bolder;',
                         icon('circle-o', 'fa-1x')), 
                     div(style = 'color:#FFFFFF;font-weight: bolder;',
                         icon('times', 'fa-1x')),
                     div(style = 'color:#FFFFFF;font-weight: bolder;',
                         icon('plus', 'fa-1x'))
                   ),
                   selected = '20', 
                   choiceValues = list('19', '20', '1', '4', '3'),
                   width = '100%'
                 ),
                 colorSelectorInput(
                   inputId = "border.color", label = "Color for year borders",
                   choices = c("black", "gray", "white", "red", "#FF6000", 
                               "#FFBF00", "#DFFF00", "#80FF00", "#20FF00", 
                               "#00FF40", "#00FF9F", "cyan", "#009FFF", "#0040FF",
                               "#2000FF", "#8000FF", "#DF00FF", "#FF00BF"),
                   selected = '#20FF00', mode = "radio", display_label = FALSE, 
                   ncol = 9
                 ),
                 colorSelectorInput(
                   inputId = "border_el_wood.color", 
                   label = "Color for early-late wood borders",
                   choices = c("black", "gray", "white", "red", "#FF6000", 
                               "#FFBF00", "#DFFF00", "#80FF00", "#20FF00", 
                               "#00FF40", "#00FF9F", "cyan", "#009FFF", "#0040FF",
                               "#2000FF", "#8000FF", "#DF00FF", "#FF00BF"),
                   selected = 'red', mode = "radio", display_label = FALSE,
                   ncol = 9
                 ),
                 colorSelectorInput(
                   inputId = "label.color", label = "Color for labels",
                   choices = c("black", "gray", "white", "red", "#FF6000", 
                               "#FFBF00", "#DFFF00", "#80FF00", "#20FF00", 
                               "#00FF40", "#00FF9F", "cyan", "#009FFF", "#0040FF",
                               "#2000FF", "#8000FF", "#DF00FF", "#FF00BF"),
                   selected = '#FFBF00', mode = "radio", display_label = FALSE, 
                   ncol = 9
                 ),
                 prettyCheckbox(
                   inputId = "decades", 
                   label = div(
                     style = 'color:black;font-weight: bolder;font-size:90%', 
                     'Years in Decades'), 
                   shape = "curve", value = F, status = "success"
                 )
               )
        ),
        column(4,
               box(
                 title = div(style = 'color:#FFFFFF;font-size:80%; 
            font-weight: bolder', 'Detection Options'),  height = "auto",
                 width = NULL, status = 'primary', solidHeader = T, 
                 collapsible = T,
                 radioGroupButtons(
                   inputId = "method",
                   label = div(style = 'color:black;font-weight: 
                               bolder;font-size:85%',
                               'Ring detection method'),
                   status = "btn btn-primary btn-md",
                   selected = 'canny',
                   size = 'normal',
                   choiceNames = list(
                     div(style = 'color:#FFFFFF;font-weight: 
                         bolder;font-size:85%',
                         'Watershed'),
                     div(style = 'color:#FFFFFF;font-weight: 
                         bolder;font-size:85%',
                         'Canny'),
                     div(style = 'color:#FFFFFF;font-weight: 
                         bolder;font-size:85%',
                         'measuRing')
                   ),
                   choiceValues = list('watershed', 'canny', 'lineardetect'), 
                   width = '100%'
                 ),
                 conditionalPanel(
                   condition = 'input.method=="watershed"',
                   selectInput('watershed.threshold',
                               'Otsu threshold',
                               c('Auto (Recommended)' = 'auto',
                                 'Custom' = 'custom.waterthr'),
                               width = '75%'
                   ),
                   conditionalPanel(
                     condition = 'input["watershed.threshold"]=="auto"',
                     sliderInput('watershed.adjust',
                                 'Threshold adjusment factor',
                                 0.5, 1.5, 0.8, 0.05, width = '85%')
                   ),
                   conditionalPanel(
                     condition = 'input["watershed.threshold"]=="custom.waterthr"',
                     textInput('watershed.threshold2', 
                               'Threshold value', '', width = '75%'),
                     'A value of the form XX% (e.g. 98%)',
                     br(),
                     br()
                   )
                 ),
                 conditionalPanel(
                   condition = 'input.method=="canny"',
                   prettyCheckbox(
                     inputId = "defaultcanny", 
                     label = div(
                       style = 'color:black;font-size:90%;font-weight: bolder;',
                       "Auto threshold (Recommended)"), 
                     shape = "curve", value = T, status = "success"),
                   conditionalPanel(
                     condition = 'input.defaultcanny',
                     sliderInput('canny.adjust',
                                 'Threshold adjusment factor',
                                 0.8, 1.8, 1.4, 0.05, width = '85%')
                   ),
                   conditionalPanel(
                     condition = '!input.defaultcanny',
                     textInput('canny.t2', 'Threshold for strong edges', '', 
                               '85%'),
                     textInput('canny.t1', 'Threshold for weak edges', '', 
                               '85%')
                   ),
                   sliderInput('canny.smoothing', 'Degree of smoothing',
                               0, 5, 2, 1, width = '85%')
                 ),
                 conditionalPanel(
                   condition = 'input.method!="lineardetect"',
                   prettyCheckbox(inputId = "defaultse", 
                                  label = div(
                                    style = 'color:black;font-size:90%;
                                    font-weight:bolder;',
                                    "Default structuring elements"), 
                                  shape = "curve", value = T, 
                                  status = "success"),
                   conditionalPanel(
                     condition = '!input.defaultse',
                     numericInput('struc.ele1', 'First structuring element', 
                                  3, 1, 100, 1, "75%"),
                     numericInput('struc.ele2', 'First structuring element', 
                                  9, 1, 100, 1, "75%")
                   ),
                   hr()
                 ),
                 conditionalPanel(
                   condition = 'input.method=="lineardetect"',
                   textInput('origin', ' Origin in smoothed gray', '0', '75%'),
                   hr()
                 ),
                 helpText('Automatic detection may take a few seconds.',
                          style = 'color:black;font-size:90%;')
               ),
        ),
      ),
      fluidRow(
        box(
          title = div(style = 'color:#FFFFFF;font-size:100%;
        font-weight: bolder', 'Main Window'),
          width = 12, status = 'primary', solidHeader = T, collapsible = T,
          radioGroupButtons(inputId = "sel_mode", status = "primary",
                            label = 
                              div(style = 'color:black;font-weight: 
                                  bolder;font-size:110%',
                                  'Working mode selector'),
                            choiceNames = list(
                              div(style = 'color:#FFFFFF;font-weight: 
                                  bolder;font-size:110%',
                                  'Path Creation'),
                              div(style = 'color:#FFFFFF;font-weight: 
                                  bolder;font-size:110%',
                                  'Ring Detection'),
                              div(style = 'color:#FFFFFF;font-weight: 
                                  bolder;font-size:110%',
                                  'Ring Editing')
                            ),
                            # direction = "vertical",
                            choiceValues = list('sel_path', 'sel_det', 
                                                'sel_edit')
          ),
          conditionalPanel(
            condition = "input.sel_mode == 'sel_path'",
            actionButton(
              'rm_last', 'Remove Last',
              class = "btn btn-warning btn-md", icon = icon('reply'),
              style = 'color:#FFFFFF;text-align:center;font-weight: bolder'
            ),
            useSweetAlert(),
            actionButton(
              'rm_all', 'Remove All',
              class = "btn btn-danger btn-md", icon = icon('trash'),
              style = 'color:#FFFFFF;text-align:center;font-weight: bolder'
            ),
            useSweetAlert(),
            br(),
            br(),
            prettyCheckbox(
              inputId = "pre_path", 
              label = div(style = 'color:black;font-weight: bolder;',
                          'Show the preview path'), 
              shape = "curve", value = F, status = "success")
          ),
          conditionalPanel(
            condition = "input.sel_mode == 'sel_det'",
            actionButton(
              'button_run_auto_xray', 'Run Detection for Years',
              class = "btn btn-success btn-md", icon = icon('play'),
              style = 'color:#FFFFFF;text-align:center;font-weight: bolder'
            ),
            actionButton(
              'button_run_auto_early', 'Run Detection for Early-Late Wood',
              class = "btn btn-success btn-md", icon = icon('play'),
              style = 'color:#FFFFFF;text-align:center;font-weight: bolder'
            ),
            useSweetAlert(),
            br(),
            br(),
          ),
          conditionalPanel(
            condition = "input.sel_mode == 'sel_edit'",
            actionButton(
              'buttonzoomdel', 'Delete Border',
              class = "btn btn-warning btn-md",
              icon = icon('eraser'),
              style = 'color:#FFFFFF;text-align:center;font-weight: bolder'
            ),
            useSweetAlert(),
            actionButton(
              'rm_all_border', 'Remove All',
              class = "btn btn-danger btn-md", icon = icon('trash'),
              style = 'color:#FFFFFF;text-align:center;font-weight: bolder'
            ),
            useSweetAlert(),
            br(),
            br()
          ),
          prettyCheckbox(
            inputId = "wh_ratio2", 
            label = div(style = 'color:black;font-weight: bolder;',
                        'Maintain original width/height ratio'), 
            shape = "curve", value = F, status = "success"
          ),
          shinyjs::disabled(
            prettyCheckbox(
              inputId = "show_profile", 
              label = div(style = 'color:black;font-weight: bolder;',
                          'Show Density Profile'), 
              shape = "curve", value = F, status = "success"
            )
          ),
          conditionalPanel(
            condition = "input.sel_mode == 'sel_det'",
            prettyCheckbox(
              inputId = "show_wood", 
              label = div(style = 'color:black;font-weight: bolder;',
                          'Show Early/Late Wood'), 
              shape = "curve", value = F, status = "success")
          ),
          conditionalPanel(
            condition = "input.sel_mode == 'sel_edit'",
            prettyCheckbox(
              inputId = "edit_wood", 
              label = div(style = 'color:black;font-weight: bolder;',
                          'Edit Early/Late Wood'), 
              shape = "curve", value = F, status = "success")
          ),
          hr(),
          fluidPage(
            fluidRow(
              conditionalPanel(condition = "input.show_profile",
                               column(width = 11,
                                      plotOutput('profile_edit',height = "200px")
                               )
              ),
              column(width = 11,
                     plotOutput('ring_edit', height = "310px",
                                dblclick = "plot2_dblclick",
                                brush = brushOpts(
                                  id = "plot2_brush", resetOnNew = TRUE
                                ),
                                hover = hoverOpts(
                                  id = "plot2_hover", delay = 300,
                                  delayType = "debounce"
                                )
                     )
              ),
              column(width = 1,
                     br(), br(),
                     noUiSliderInput(
                       width = "100px", height = "250px",
                       inputId = "img_ver", label = NULL, tooltips = F,
                       min = 0, max = 1000, step = 10,
                       value = c(0, 1000), margin = 10,
                       orientation = "vertical", behaviour = "drag"
                     )
              ),
            ),
            br(),
            fluidRow(
              column(
                width = 11, offset = 0,
                sliderInput(
                  inputId = "img_hor", label = NULL,
                  min = 0, max = 100, value = c(0, 100), step = 1, 
                  round = T, ticks = F, dragRange = T, post = "%"
                )
              )
            )
          )
        )
      ),
      
    )
  page3 <- fluidPage(
    
    fluidRow(
      box(title = div(style = 'color:#FFFFFF;font-size:80%;
            font-weight: bolder', 'Optional Sample Info'), height = "50%",
          width = 12, status = 'primary', solidHeader = T, collapsible = T, 
          collapsed = F,
          column(width = 4,
                 textInput('sample_site_id', 'Site ID', '', '75%'),
                 textInput('sample_site', 'Site Name', '', '75%'),
                 textInput('sample_parcel', 'Plot', '', '75%'),
                 textInput('sample_country', 'State or Country', '', '75%'),
          ),
          column(width = 4, 
                 textInput('sample_species', 'Species', '', '75%'),
                 textInput('sample_species_code', 'Species Code', '', '75%'),
                 textInput('sample_elevation', 'Elevation', '', '75%'),
                 textInput('sample_latitude', 'Latitude', '', '75%'),
          ),
          column(width = 4,
                 textInput('sample_longitude', 'Longitude', '', '75%'),
                 #textInput('sample_first_year', 'First Year', '', '75%'),
                 #textInput('sample_last_year', 'Last Year', '', '75%'),
                 textInput('sample_investigator', 'Lead Researcher', '', 
                           '75%'),
                 textInput('sample_date', 'Completion Date', 
                           format(Sys.time(), "%Y-%m-%d"), '75%')
          ),
      ),
    ),
    fluidRow(
      tabBox(
        title = div(
          style = 'color:black;font-weight: bolder;',
          icon('cog', class = 'fa-spin', lib = 'font-awesome'), 'Output'),
        width = 12,
        tabPanel(
          div(style = 'color:black;font-weight: bolder;',
              icon('arrow-down', 'fa-1x'), ' CSV'
          ),
          textInput('csv.name', 'Name of the csv file', '', width = '50%'),
          helpText(
            style = 'color:black;font-weight: normal;',
            'The filename extension is not required. ',
            'Leave blank to use the current series ID.'
          ),
          helpText(
            style = 'color:#FF0000;font-weight: normal;',
            'Attention: if running the app within an RStudio window',
            ', the rename operation doesn\'t work. Please run the app',
            ' within a browser.'
          ),
          hr(),
          downloadButton(
            'RingWidth.csv', 'Download CSV',
            class = "btn btn-primary btn-md",
            style = 'color:#FFFFFF;text-align:center;font-weight:bolder;'
          )
        ),
        tabPanel(
          div(style = 'color:black;font-weight: bolder;',
              icon('arrow-down', 'fa-1x'), ' Excel'),
          textInput('excel.name', 'Name of the excel file', '', width = '50%'),
          downloadButton(
            'RingWidth.xlsx', 'Download excel',
            class = "btn btn-primary btn-md",
            style = 'color:#FFFFFF;text-align:center;font-weight:bolder;'
          )
        ),
        tabPanel(
          div(style = 'color:black;font-weight: bolder;',
              icon('arrow-down', 'fa-1x'), ' RWL'),
          textInput('rwl.name', 'Name of the rwl file', '', width = '50%'),
          helpText(style = 'color:black;font-weight: normal;',
                   'The filename extension is not required. ',
                   ' Leave blank to use the current series ID.'),
          helpText(style = 'color:#FF0000;font-weight: normal;',
                   'Attention: if running the app within an RStudio window',
                   ', the rename operation doesn\'t work. Please run the app',
                   ' within a browser.'),
          hr(),
          selectInput('tuprec', 'Precision of the rwl file',
                      c('0.01' = '0.01', '0.001' = '0.001'),
                      selected = '0.01', width = '50%'),
          helpText(style = 'color:black;font-weight: normal;', 
                   'Units are in mm.'),
          hr(),
          downloadButton(
            'RingWidth.rwl', 'Download RWL',
            class = "btn btn-primary btn-md",
            style = 'color:#FFFFFF;text-align:center;font-weight:bolder;'
          )
        ),
        tabPanel(
          div(style = 'color:black;font-weight: bolder;',
              icon('arrow-down', 'fa-1x'), 'Project'),
          textInput('rds_project.name', 'Name of the rds file', '', 
                    width = '50%'),
          helpText(
            style = 'color:black;font-weight: normal;',
            'The filename extension is not required. ',
            'Leave blank to use the current series ID.'
          ),
          helpText(
            style = 'color:#FF0000;font-weight: normal;',
            'Attention: if running the app within an RStudio window',
            ', the rename operation doesn\'t work. Please run the app',
            ' within a browser.'
          ),
          hr(),
          downloadButton(
            'Project.rds', 'Download RDS file',
            class = "btn btn-primary btn-md",
            style = 'color:#FFFFFF;text-align:center;font-weight:bolder;'
          )
        )
      ),
    )
  )
  
  shiny.body <- dashboardBody(
    tabItems(
      tabItem(tabName = 'input_pre', page1),
      tabItem(tabName = 'mea_arg', page2),
      tabItem(tabName = 'mea_results', page3)
    )
  )
  ui <- dashboardPage(
    shiny.title,
    shiny.sider,
    shiny.body
  )
  return(ui)
}

################################################
createServer <- function(input, output, session) 
{
  f.morphological <- function(seg.data, struc.ele1, struc.ele2, x.dpi) {
    cim <- as.cimg(seg.data)
    cim2 <- erode_rect(cim, sx = struc.ele1[1], sy = struc.ele1[2], sz = 1L)
    cim2 <- dilate_rect(cim2, sx = struc.ele1[1], sy = struc.ele1[2], sz = 1L)
    cim2 <- dilate_rect(cim2, sx = struc.ele1[1], sy = struc.ele1[2], sz = 1L)
    cim2 <- erode_rect(cim2, sx = struc.ele1[1], sy = struc.ele1[2], sz = 1L)
    cim2 <- erode_rect(cim2, sx = struc.ele2[1], sy = struc.ele2[2], sz = 1L)
    cim2 <- dilate_rect(cim2, sx = struc.ele2[1], sy = struc.ele2[2], sz = 1L)
    return(cim2)
  }
  hat <- function(seg.mor, x.dpi, watershed.threshold, watershed.adjust) {
    black.hat <- mclosing_square(seg.mor, size = round(x.dpi / 10))
    black.hat <- black.hat - seg.mor
    black.hat <- threshold(black.hat, thr = watershed.threshold, 
                           approx = FALSE, adjust = watershed.adjust)
    black.hat <- 1 - black.hat
    black.hat.mat <- black.hat[, , 1, 1]
    return(black.hat.mat)
  }
  normalize <- function(x, max.value, min.value) {
    x_norm <- ((x - min.value)/(max.value - min.value))
    return(x_norm)
  }
  denormalize <- function(x_norm, max.value, min.value) {
    x <- (x_norm * (max.value - min.value)) + min.value
    return(x)
  }
  correct.color <- function(water.c2) {
    color.adj <- function(i, water.c2, diff.m) {
      color.position <- which(water.c2 == i, arr.ind = T)
      row.range <- range(color.position[, 1])
      row.range <- row.range[1]:row.range[2]
      color.adjacent <- integer()
      for (j in row.range) {
        row.p <- which(color.position[, 1] == j)
        min.column <- color.position[row.p, 2] %>% min
        color.diff <- which(diff.m[, j] != 0)
        color.pre.p <- color.diff[which(color.diff == min.column) - 1] - 1
        color.pre <- water.c2[j, color.pre.p]
        color.adjacent <- c(color.adjacent, color.pre)
      }
      max(color.adjacent)
    }  
    water.c3 <- cbind(matrix(-1, nrow(water.c2), 1), 
                      matrix(0, nrow(water.c2), 1), 
                      water.c2)
    diff.m <- apply(water.c3, 1, function(x) c(0, diff(x)))
    color.max <- max(water.c2)
    df.color <- data.frame(color = c(1:color.max), 
                           adj = rep(NA, times = color.max))
    for (i in 1:color.max) {
      test.c <- color.adj(i, water.c3, diff.m)
      df.color[i, 2] <- test.c
    }
    for (i in -1:color.max) {
      adj.c <- which(df.color[, 2] == i) 
      if (length(adj.c) >= 2) {   
        max.c <- max(df.color[adj.c, 1])  
        covered.c <- sort(df.color[adj.c, 1])
        covered.c <- covered.c[-length(covered.c)]
        for (j in covered.c) {
          cl <- which(water.c3 == j, arr.ind = T)
          water.c3[cl] <- max.c
          df.color[which(df.color == j, arr.ind = T)] <- max.c
        }
      } 
    }
    return(water.c3[, -c(1, 2)])
  }
  water.im <- function(black.hat, correct) {
    water.c <- connected(im(black.hat), background = 0, method = "C")
    water.c2 <- apply(water.c$v, 2, function(x){
      x[is.na(x)] <- 0
      return(x)
    })
    if (correct)
      water.c2 <- correct.color(water.c2)
    return(water.c2)
  }
  watershed.im <- function(water.seg, seg.data) {
    normalize <- function(x) return((x - min(x))/(max(x) - min(x)))
    imgra <- imgradient(as.cimg(seg.data), axes = "y", scheme = 2)
    watershed.seg <- watershed(as.cimg(water.seg), imgra, fill_lines = F)
    return(watershed.seg[,, 1, 1])
  }
  
  f.sort <- function(bor_xy, dp) {
    filter.col <- diff(bor_xy$x) >= dp/10
    filter.col <- c(TRUE, filter.col)
    bor_xy <- bor_xy[filter.col,]
    return(bor_xy)
  }
  # Plots borders on top of img
  plot.marker <- function(path.info, hover.xy, sample_yr, l.w, pch,
                          bor.color, lab.color, label.cex, bor_el.color, el_wood)
  {
    if (is.null(path.info$x))
      return()
    p.max <- path.info$max
    p.x <- path.info$x - crop.offset.xy$x
    p.y <- path.info$y - crop.offset.xy$y
    p.type <- path.info$type
    p.hor <- path.info$horizontal
    # dpi <- path.info$dpi TODO: check
    len <- length(p.x)
    # plot path
    if (len == 1)
      points(p.x, p.y, pch = 16, col = lab.color)
    if (len >= 2) 
      points(p.x, p.y, type = 'l', col = lab.color, lty = 1, lwd = l.w)
    if (input$sel_mode == 'sel_path' & len < p.max & input$pre_path) {
      y <- ifelse(p.hor, p.y[len], hover.xy$y)
      points(c(p.x[len], hover.xy$x), c(p.y[len], y), 
             type = 'l', col = lab.color, lty = 2, lwd = l.w)
    }
    if (!is.null(el_wood) & (input$show_wood | input$edit_wood)) {
      df_el_wood.loc <- el_wood
      # Here we have the data of the borders and path pixels and yr printing
      if (nrow(df_el_wood.loc) >= 1) {
        bx <- df_el_wood.loc$x - crop.offset.xy$x
        by <- df_el_wood.loc$y - crop.offset.xy$y
        bz <- df_el_wood.loc$z
        bz <- bz[order(bx)]
        by <- by[order(bx)]
        bx <- sort(bx)
        
        if (length(bx) >= 1) {
          points(bx, by, col = bor_el.color, type = "p", 
                 pch = pch, cex = label.cex * 0.75)
        }
      }
    }
    
    # plot border point
    if (!is.null(df.loc$data)) {
      df.loc <- df.loc$data
      # Here we have the data of the borders and path pixels and yr printing
      if (nrow(df.loc) >= 1) {
        bx <- df.loc$x - crop.offset.xy$x
        by <- df.loc$y - crop.offset.xy$y
        bz <- df.loc$z
        bz <- bz[order(bx)]
        by <- by[order(bx)]
        bx <- sort(bx)
        if (length(bx) >= 1) {
          lenbx <- length(bx)
          points(bx, by, col = bor.color, type = "p", 
                 pch = pch, cex = label.cex * 0.75)
          if (input$decades) {
            oddvalsx <- seq(1, length(bx), by = 10)
            oddvalsy <- seq(1, length(by), by = 10)
            year.u <- c(seq(sample_yr,(sample_yr - length(by)  + 1),by = -10))
            bx_mod <- bx[oddvalsx]
            by_mod <- by[oddvalsy]
            text(bx_mod, by_mod, year.u, adj = c(1.5, 0.5), 
                 srt = 90, col = lab.color, cex = label.cex)
          }
          else{
            year.u <- c(sample_yr:(sample_yr - length(by) + 1))
            text(bx, by, year.u, adj = c(1.5, 0.5), 
                 srt = 90, col = lab.color, cex = label.cex)
          }
          border.num <- 1:lenbx
          text(bx, by, border.num, adj = c(0.5, -1.25), 
               col = lab.color, cex = label.cex)
        }
      }
    }
  }
  f.rw <- function(outfile, sample_yr, dpi) {
    df.loc <- outfile
    bx <- df.loc$x
    by <- df.loc$y
    bz <- df.loc$z
    by <- by[order(bx)]
    bz <- bz[order(bx)]
    bx <- sort(bx)
    dp <- dpi/25.4 # TODO: Check 
    
    lenbx <- length(bx)
    dx <- diff(bx)
    dy <- diff(by)
    d <- sqrt(dx^2 + dy^2)
    rw <- c(NA, round(d / dp, 2))
    years <- c(sample_yr:(sample_yr - lenbx + 1))
    df.rw <- data.frame(year = years, x = bx, y = by, ring.width = rw)
    
    return(df.rw)
  }
  
  calc.se <- function(se, dpi, order) {
    if (is.null(se)) {
      if (order == 1)
        se1 <- dpi/400
      if (order == 2)
        se1 <- dpi/80
      se <- c(se1, se1) %>% round
    }
    return(se)
  }
  
  get_slope <- function(x1, y1, x2, y2) {
    dy <- y2 - y1
    dx <- x2 - x1
    slope <- atan(dy/dx)
    return(slope)
  }
  
  get_angle <- function(x1, y1, x2, y2) {
    # counterclockwise
    theta <- get_slope(x1, y1, x2, y2) * (180/pi)
    return(theta)
  }
  
  euclidean_distance <- function(x1, x2, y1, y2) {
    dist <- sqrt((x2 - x1)^2 + (y2 - y1)^2)
    return(dist)
  }
  
  crop_path <- function(img, px, py, pixelspath) {
    py <- dim(img)[1] - py # axis goes in different direction
    points <- cbind(x = px, y = py)
    angles <- vector(mode = "list", length = length(px) - 1)
    
    for (i in 2:nrow(points)) {
      point1 <- as.numeric(points[i - 1,])
      point2 <- as.numeric(points[i,])
      angles[i - 1] <- get_angle(point1[1], point1[2], point2[1], point2[2])
    }
    path.matrix <- matrix(, nrow = pixelspath * 2 + 1, ncol = 0)
    path.coord.x <- c(1)
    for (i in 1:length(angles)) {
      point1 <- as.numeric(points[i,])
      point2 <- as.numeric(points[i + 1,])
      
      x1 <- point1[1]
      y1 <- point1[2]
      x2 <- point2[1]
      y2 <- point2[2]
      
      angle <- angles[[i]]
      angle <- 180 - angle
      
      if (angle == 0) {
        p <- as.matrix(img)[(y1 - pixelspath):(y1 + pixelspath), x1:x2]
      }
      else {
        rad <- (angle) * (pi/180)
        im.rotated <- rotate(as.im(as.matrix(img)), angle = rad)
        
        x1.new <- x1 * cos(rad) - y1 * sin(rad)
        y1.new <- y1 * cos(rad) + x1 * sin(rad)
        x2.new <- x2 * cos(rad) - y2 * sin(rad)
        y2.new <- y2 * cos(rad) + x2 * sin(rad)
        
        corners.x <- as.array(corners(im.rotated)$x)
        corners.y <- as.array(corners(im.rotated)$y)
        
        corners.x.min <- min(corners.x)
        corners.x.max <- max(corners.x)
        corners.y.min <- min(corners.y)
        corners.y.max <- max(corners.y)
        
        x.res <- (corners.x.max - corners.x.min) / dim(im.rotated)[2]
        y.res <- (corners.y.max - corners.y.min) / dim(im.rotated)[1]
        
        x.min <- corners.x.min
        if (corners.x.min < 0) {
          x.min <- 0 - corners.x.min
        }
        y.min <- corners.y.min
        if (corners.y.min < 0) {
          y.min <- 0 - corners.y.min
        }
        
        y.init <- (y1.new + y.min) / y.res
        x.initial <- (x1.new + x.min) / x.res
        x.end <- (x2.new + x.min) / x.res
        
        p <- as.matrix(im.rotated)[(y.init - pixelspath):(y.init + pixelspath),
                                   x.initial:x.end]
      }
      
      path.matrix <- cbind(path.matrix, p)
      path.coord.x <- append(path.coord.x, dim(path.matrix)[2])
    }
    list(path.matrix, path.coord.x)
  }
  
  # Detection algorithms
  automatic.det <- function(
    img, method, dpi, px, py, path.hor, path.df,
    watershed.threshold, watershed.adjust, struc.ele1, struc.ele2,
    default.canny, canny.t1, canny.t2, canny.adjust, canny.smoothing, origin
  )
  {   
    dp <- dpi/25.4 # TODO:check
    dimt <- dim(img)
    dimcol <- dimt[2]
    dimrow <- dimt[1]
    
    struc.ele1 <- calc.se(struc.ele1, dpi, 1) # TODO:check
    struc.ele2 <- calc.se(struc.ele2, dpi, 2) # TODO:check
    
    # X direction
    pxmin <- min(px) - round(1.5 * struc.ele2[1])
    if (pxmin <= 0)
      pxmin <- 0
    pxmax <- max(px) + round(1.5 * struc.ele2[1])
    if (pxmax >= dimcol)
      pxmax <- dimcol
    # Y direction
    pymin <- min(py) - 2 * struc.ele2[1]
    if (pymin <= 0)
      pymin <- 0
    pymax <- max(py) + 2 * struc.ele2[1]
    if (pymax >= dimrow)
      pymax <- dimrow
    # crop an image
    delta.y <- 0
    if (pymin == 0) {
      delta.y <- 1
    }
    delta.x <- 0
    if (pxmin == 0) {
      delta.x <- 1
    }
    
    seg.data <- img[(pymin + delta.y):pymax, (pxmin + delta.x):pxmax]
    seg.data <- seg.data / max(seg.data)
    tdata <- seg.data
    
    if (method == 'watershed') {
      seg.mor <- f.morphological(seg.data, struc.ele1, struc.ele2, dpi)
      black.hat <- hat(seg.mor, dpi, watershed.threshold, watershed.adjust)
      marker.img <- water.im(black.hat, T)
      seg.data <- watershed.im(marker.img, seg.mor)
      s2 <- seg.data[, -1]
      s2 <- cbind(s2, matrix(max(s2), ncol = 1, nrow = nrow(s2)))
      seg.data <- as.cimg(s2 - seg.data)
      
    }  
    if (method == 'canny') {
      seg.mor <- f.morphological(seg.data, struc.ele1, struc.ele2, dpi)
      if (default.canny) {
        seg.data <- cannyEdges(as.cimg(seg.mor), alpha = canny.adjust, 
                               sigma = canny.smoothing)
      } else {
        seg.data <- cannyEdges(as.cimg(seg.mor), t1 = canny.t1, t2 = canny.t2,
                               alpha = canny.adjust, sigma = canny.smoothing)
      }
    } 
    
    # intersection operations
    if (method != 'lineardetect') {
      bor_xy <- where(seg.data == TRUE)
      bor_xy <- bor_xy[, c(2, 1)]
      colnames(bor_xy) <- c('x', 'y')
      bor_xy$x <- bor_xy$x + pxmin - 1
      bor_xy$y <- nrow(seg.data) - bor_xy$y + pymin
      
      bor_xy <- intersect(bor_xy, path.df)
      bor_xy <- f.sort(bor_xy, dp)
      bor_xy$z <- 'u'
      
      filter_edge <- function(bor_xy, tdata, pxmin, pymin, dp) {
        bor_row <- nrow(tdata) - bor_xy$y + pymin
        bor_col <- bor_xy$x - pxmin
        num_dp <- dp * 0.2
        num_dp <- ifelse(num_dp %% 2 == 0, num_dp + 1, num_dp)
        mat <- matrix(c(bor_row, bor_col - (num_dp - 1) / 2), ncol = 2)
        pixel_mat <- matrix(nrow = length(bor_row), ncol = 0)
        
        # calculate slope
        for (i in 1:num_dp) {
          pixel_mat <- cbind(pixel_mat, tdata[mat])
          mat[,2] <- mat[,2] + 1
        }
        calc_slope <- function(x){
          lm(x ~ c(1:num_dp)) %>% coef %>% as.numeric
        }
        slope <- apply(pixel_mat, 1, calc_slope)
        bor_xy <- bor_xy[slope[2,] < 0,]
      }
      filter_edge_catch_errors <- function(bor_xy, tdata, pxmin, pymin, dp) {
        out <- tryCatch(filter_edge(bor_xy, tdata, pxmin, pymin, dp), 
                        error = function(e) bor_xy)
        return(out)
      }
      bor_xy_2 <- filter_edge_catch_errors(bor_xy, tdata, pxmin, pymin, dp)
      if (sum(is.na(bor_xy_2$x)) != length(bor_xy_2$x)) {
        bor_xy <- bor_xy_2
      }
    }
    if (method == 'lineardetect') {
      attributes(seg.data)['image'] <- 'img'
      smoothed <- graySmoothed(seg.data, ppi = dpi)
      borders <- linearDetect(smoothed, origin = origin)
      borders <- borders + pxmin
      bor_xy <- data.frame(x = borders, y = py[1], z = 'u')
    }
    return(bor_xy)
  } 
  readImg <- function(img, img.name) {
    img.size <- file.size(img)/1024^2
    options(warn = -1)
    
    r <- brick(img)
    data.type <- dataType(r)
    nbands <- nbands(r)
    ncols <- ncol(r)
    nrows <- nrow(r)
    tree.data <- getValues(r)
    max.value <- max(tree.data)
    min.value <- min(tree.data)
    dim(tree.data) <- c(ncols, nrows, nbands)
    
    if (nbands == 4) {
      tree.data <- tree.data[,,1:3] # skip alpha channel
      nbands <- 3
    }
    if (nbands == 3) {
      r <- tree.data[,,1]
      g <- tree.data[,,2]
      b <- tree.data[,,3]
      tree.data <- (r + g + b) / 3
      tree.data <- as.integer(tree.data)
    }
    tdata <- t(matrix(tree.data, nrow = ncols))
    
    rm(tree.data)
    gc()
    
    list(tdata = tdata, min.value = min.value, max.value = max.value, 
         data.type = data.type, img.name = img.name)
  }
  imgInput <- function(tdata, tdata.copy, img.name, max.value, 
                       plot1_rangesx, plot1_rangesy) {
    
    dim.tdata <- dim(tdata.copy)
    xleft <- 0
    ybottom <- 0
    xright <- dim.tdata[2]
    ytop <- dim.tdata[1]
    par(mar = c(2.5, 2, 2, 0))
    # 0729
    if (input$wh_ratio) {
      im <- image_read(as.raster(tdata.copy / max.value))
      plot(im, xlim = c(xleft, xright), ylim = c(ybottom, ytop),
           main = img.name, xlab = "", ylab = "", cex.main = 1.2)
    } else {
      plot(x = c(xleft, xright), y = c(ybottom, ytop),
           xlim = c(xleft, xright), ylim = c(ybottom, ytop),
           main = img.name, xlab = "", ylab = "",
           type = "n", axes = F, cex.main = 1.2)
      rasterImage(as.raster(tdata.copy / max.value), xleft, ybottom,
                  xright, ytop, interpolate = FALSE)
    }
    axis(1, col = "grey", cex.axis = 1)
    axis(2, col = "grey", cex.axis = 1)
    if (!is.null(plot1_rangesx)) {
      xmin <- plot1_rangesx[1]
      xmax <- plot1_rangesx[2]
      ymin <- plot1_rangesy[1]
      ymax <- plot1_rangesy[2]
      
      dimt <- dim(tdata)
      if (dimt[1] * dimt[2] >= 1.2e+07) {
        xmin <- xmin/4
        xmax <- xmax/4
        ymin <- ymin/4
        ymax <- ymax/4
      }
      x <- c(xmin, xmax, xmax, xmin, xmin)
      y <- c(ymin, ymin, ymax, ymax, ymin)
      points(x, y, type = 'l', lty = 2, lwd = 1.5)
    }
  }
  imgInput_crop <- function(tdata, max.value, ver, hor) {
    # crop an image based on slider info
    dim.tdata <- dim(tdata)
    dimcol <- dim.tdata[2]
    dimrow <- dim.tdata[1]
    crop.x <- as.integer(hor[2]*dimcol/100)
    crop.y <- as.integer(ver[2]*dimrow/1000)
    ini.x <- as.integer(hor[1]*dimcol/100)
    ini.y <- as.integer(ver[1]*dimrow/1000)
    
    delta.x <- 0
    if (ini.x == 0) {
      delta.x <- 1
    }
    delta.y <- 0
    if (ini.y == 0) {
      delta.y <- 1
    }
    
    tdata <- tdata[(ini.y + delta.y):(crop.y), (ini.x + delta.x):(crop.x)]
    dim.tdata <- dim(tdata)
    
    xleft <- 0
    ybottom <- 0
    xright <- dim.tdata[2]
    ytop <- dim.tdata[1]
    par(mar = c(0, 0, 0, 0), mai = c(0, 0, 0, 0))
    # 0730
    if (input$wh_ratio2) {
      im <- image_read(as.raster(tdata / max.value))
      par(mar = c(0, 0, 0, 0), xaxs = 'i', yaxs = 'i')
      plot(im, xlim = c(xleft, xright), ylim = c(ybottom, ytop),
           main = '', xlab = "", ylab = "", cex.main = 1.2)
    } else {
      par(mar = c(0, 0, 0, 0), xaxs = 'i', yaxs = 'i')
      plot(x = c(xleft, xright), y = c(ybottom, ytop),
           xlim = c(xleft, xright), ylim = c(ybottom, ytop),
           main = '', xlab = "", ylab = "",
           type = "n", axes = F, cex.main = 1.2)
      rasterImage(as.raster(tdata/max.value), xleft, ybottom,
                  xright, ytop, interpolate = FALSE)
    }
    return(tdata)  
  }
  rotateImg <- function(tdata, degree) {
    rotate <- function(x) t(apply(x, 2, rev))
    if (degree == 90) {
      tdata <- rotate(tdata)
    }
    else if (degree == 180) {
      tdata <- rotate(rotate(tdata))
    }
    else if (degree == 270) {
      tdata <- rotate(rotate(rotate(tdata)))
    }
    return(tdata)
  }
  
  estimate_coords_path <- function(path.info.x, path.info.y, x.coords, 
                                   y.coords, profile.path.coord.x) {
    j.init <- 1
    coords <- c()
    y.coords <- y.coords[order(x.coords)]
    x.coords <- sort(x.coords)
    for (i in 2:length(path.info.x)) {
      for (j in j.init:length(x.coords)) { # borders
        if ((x.coords[j] >= path.info.x[i - 1]) & 
            (x.coords[j] < path.info.x[i])) {
          dist <- euclidean_distance(path.info.x[i - 1], x.coords[j],
                                     path.info.y[i - 1], y.coords[j])
          j.init <- j
          coords <- append(coords, as.integer(profile.path.coord.x[i - 1] + dist))
        }
      }
    }
    return(coords)
  }
  # Functions listed above are used for shiny app
  
  options(shiny.maxRequestSize = 150*(1024^2), shiny.trace = FALSE)
  
  # Reactive Values
  calibration.model <- reactiveValues(data = NULL)
  calibration.values.min_max <- reactiveValues(min.value = NULL, 
                                               max.value = NULL)
  calibration.density.min_max <- reactiveValues(min.value = NULL, 
                                                max.value = NULL)
  calibration_profile <- reactiveValues(data = NULL, coords.x = NULL)
  img.file <- reactiveValues(data = NULL, 
                             min.value = NULL, 
                             max.value = NULL,
                             data.type = NULL,
                             img.name = NULL,
                             resize.ratio = NULL)
  img.file.crop <- reactiveValues(data = NULL)
  img.file.copy <- reactiveValues(data = NULL)
  img.file.path <- reactiveValues(data = NULL)
  plot1_ranges <- reactiveValues(x = NULL, y = NULL)
  plot2_ranges <- reactiveValues(x = NULL, y = NULL)
  df.loc <- reactiveValues(data = NULL, ID = NULL)
  el_wood.loc <- reactiveValues(data = NULL)
  crop.offset.xy <- reactiveValues(x = NULL, y = NULL)
  hover.xy <- reactiveValues(x = NULL, y = NULL)
  path.info <- reactiveValues(x = NULL, y = NULL, type = NULL, ID = NULL,
                              horizontal = NULL, num.segments = NULL,
                              dpi = NULL, max = NULL, df = NULL)
  calibration.curve <- reactiveValues(thickness = NULL, grayscale = NULL)
  rw.dataframe <- reactiveValues(data = NULL)
  
  # It modifies the entries of the matrix based on the number of steps the 
  # user wants
  output$matrixcontrol <- renderDataTable({
    if (!input$loadMatrix) {
      m <- matrix(0, input$nsteps, 2, dimnames = 
                    list(NULL, c("Thickness", "Intensity")))
      if (!is.null(calibration.curve$thickness)) {
        if (input$nsteps == length(calibration.curve$thickness)) {
          m[, 1] <- calibration.curve$thickness
          m[, 2] <- calibration.curve$grayscale
        }
        else if (input$nsteps > length(calibration.curve$thickness)) {
          m[1:length(calibration.curve$thickness), 1] <- 
            calibration.curve$thickness
          m[1:length(calibration.curve$thickness), 2] <- 
            calibration.curve$grayscale
        }
        else {
          m[, 1] <- calibration.curve$thickness[1:input$nsteps]
          m[, 2] <- calibration.curve$grayscale[1:input$nsteps]
        }
      }
      updateMatrixInput(session = session, "thickness_matrix", m)
    }
  })
  
  observeEvent(input$buttoninputimage, {
    # Image
    img.file$data <- NULL
    img.file$max.value <- NULL
    img.file$min.value <- NULL
    img.file$data.type <- NULL
    img.file$img.name <- NULL
    img.file.copy$data <- NULL
    img.file.crop$data <- NULL
    # Plot
    plot1_ranges$x <- NULL
    plot1_ranges$y <- NULL
    plot2_ranges$x <- NULL
    plot2_ranges$y <- NULL
    # Path
    path.info$x <- NULL
    path.info$y <- NULL
    path.info$type <- NULL
    path.info$ID <- NULL
    path.info$horizontal <- NULL
    path.info$dpi <- NULL # TODO: check
    path.info$max <- NULL
    path.info$df <- NULL
    path.info$num.segments <- NULL
    # Wood Info
    rw.dataframe$data <- NULL
    df.loc$data <- NULL
    df.loc$ID <- NULL
    el_wood.loc$data <- NULL
    # Profile
    calibration.values.min_max$min.value <- NULL
    calibration.values.min_max$max.value <- NULL
    calibration.density.min_max$min.value <- NULL
    calibration.density.min_max$max.value <- NULL
    calibration_profile$data <- NULL
    calibration.curve$thickness <- NULL
    calibration.curve$grayscale <- NULL
    
    updatePrettyRadioButtons(
      session = session, inputId = "cropcondition",
      choiceNames = 'UNCROPPED', choiceValues = list('a'),
      prettyOptions = list(shape = "curve", status = "danger",
                           fill = F, inline = F)
    )
    updateActionButton(session, "buttoncrop", label = "Crop")
    updatePrettyRadioButtons(
      session = session, inputId = "rotatede",
      label = "Clockwise Rotation",
      choices = c("90 degrees" = "rotate90",
                  "180 degrees" = "rotate180",
                  "270 degrees" = "rotate270"),
      prettyOptions = list(shape = "curve", status = "success",
                           fill = F, inline = F)
    )
  })
  observeEvent(input$buttonrotate, {
    img <- input$selectfile["datapath"] %>% as.character
    img.check1 <- ifelse(length(img) >= 1, TRUE, FALSE)
    img.check2 <- FALSE
    if (img.check1)
      img.check2 <- ifelse(nchar(img) > 1, TRUE, FALSE)
    if (any(!img.check1, !img.check2, is.null(img.file$data))) {
      et <- paste('The preview image has not been generated')
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    degree <- input$rotatede %>% substring(7) %>% as.numeric
    img.file$data <- rotateImg(img.file$data, degree)
    img.file.crop$data <- img.file$data
    img.file.copy$data <- rotateImg(img.file.copy$data, degree)
    
    plot1_ranges$x <- NULL
    plot1_ranges$y <- NULL
    plot2_ranges$x <- NULL
    plot2_ranges$y <- NULL
    # Path
    path.info$x <- NULL
    path.info$y <- NULL
    path.info$type <- NULL
    path.info$ID <- NULL
    path.info$horizontal <- NULL
    path.info$dpi <- NULL # TODO:check
    path.info$max <- NULL
    path.info$df <- NULL
    # Wood Info
    df.loc$data <- NULL
    df.loc$ID <- NULL
    rw.dataframe$data <- NULL
    el_wood.loc$data <- NULL
    # Profile
    calibration_profile$data <- NULL
    
    updateTextInput(session, "m_line", value = '',
                    label = 'Y-coordinate of the path')
    updatePrettyRadioButtons(
      session = session, inputId = "cropcondition",
      choiceNames = 'UNCROPPED', choiceValues = list('a'),
      prettyOptions = list(shape = "curve", status = "danger",
                           fill = F, inline = F)
    )
    updateActionButton(session, "buttoncrop", label = "Crop")
  })
  
  # This event reacts to activating button plot from light calibration, 
  # when activated it saves 
  # the plot in variable lightplot
  observeEvent(input$buttondensity, {
    #  It first determines if the img is loaded
    if (is.null(img.file$data)) {
      imgf <- input$selectfile
      if (is.null(imgf)) {
        et <- paste('The image file has not been uploaded')
        sendSweetAlert(
          session = session, title = "Error", text = et, type = "error"
        )
        return()
      }
      img <- as.character(imgf["datapath"])
      img.name <- as.character(imgf["name"])
    }
    
    calibration_profile$data <- NULL
    
    if (!input$loadMatrix) {
      if (max(input$thickness_matrix[,2]) < img.file$max.value) {
        showNotification(paste("WARNING: max intensity inserted is 
                               lower than image max (", img.file$max.value, ")"), 
                         duration = 5)
      }
      if (min(input$thickness_matrix[,2]) > img.file$min.value) {
        showNotification(paste("WARNING: min intensity inserted is 
                               higher than image min (", img.file$min.value, ")"), 
                         duration = 5)
      }
      # Runs the calibration with the input data from thickness_matrix and density
      thickness_values <- input$thickness_matrix[,1]
      grayvalues <- input$thickness_matrix[,2]
    }
    else {
      density_matrix = read.table(input$path_matrix["datapath"] %>% as.character)
      if (max(density_matrix[,2]) < img.file$max.value) {
        showNotification(paste("WARNING: max intensity inserted is lower than (", 
                               img.file$max.value, ")"), duration = 5)
      }
      if (min(density_matrix[,2]) > img.file$min.value) {
        showNotification(paste("WARNING: min intensity inserted is higher than (", 
                               img.file$min.value, ")"), duration = 5)
      }
      thickness_values <- density_matrix[,1]
      grayvalues <- density_matrix[,2]
    }
    calibration.curve$thickness <- thickness_values
    calibration.curve$grayscale <- grayvalues
    
    # Regression method
    optical_density <- thickness_values * input$density
    
    calibration.values.min_max$min.value <- min(grayvalues)
    calibration.values.min_max$max.value <- max(grayvalues)
    calibration.density.min_max$min.value <- 
      optical_density[grayvalues == calibration.values.min_max$min.value]
    calibration.density.min_max$max.value <- 
      optical_density[grayvalues == calibration.values.min_max$max.value]
    
    if (input$reg_model == 'local_regression') {
      calibration_model <- loess(optical_density ~ grayvalues)
    }
    else {
      calibration_model <- smooth.spline(optical_density ~ grayvalues)
    }
    calibration.model$data <- calibration_model
  })
  
  lightplot <- eventReactive(input$buttondensity, {
    if (is.null(calibration.curve$thickness) || 
        is.null(calibration.model$data) || 
        is.null(input$reg_model)) {
      return()
    }
    
    thickness_values <- calibration.curve$thickness
    grayvalues <- calibration.curve$grayscale
    optical_density <- thickness_values * input$density
    
    calibration_model <- calibration.model$data
    
    rng_grayvalues <- range(grayvalues)
    xrange <- seq(min(c(img.file$min.value, calibration.values.min_max$min.value)), 
                  max(c(img.file$max.value,
                        calibration.values.min_max$max.value)), length.out = 1000)
    plot(optical_density ~ grayvalues, xlab = "Gray-values", 
         ylab = "Optical density")
    preds <- predict(calibration_model, xrange)
    
    if (input$reg_model != 'local_regression') {
      preds <- preds$y
    }
    preds[xrange > calibration.values.min_max$max.value] <- 
      calibration.density.min_max$max.value
    preds[xrange < calibration.values.min_max$min.value] <- 
      calibration.density.min_max$min.value
    lines(xrange, preds, col = 'red')
    
  })
  
  output$light <- renderPlot({
    lightplot()
  })
  
  observeEvent(input$buttonproject, {
    rdsf <- input$load_project
    if (is.null(rdsf)) {
      et <- paste('The rds file has not been uploaded')
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    rds <- as.character(rdsf["datapath"])
    rds.name <- as.character(rdsf["name"])
    
    f <- readRDS(rds)
    img.file$max.value <- as.numeric(f['img.file.max.value'])
    img.file$min.value <- as.numeric(f['img.file.min.value'])
    img.file$data.type <- f['img.file.data.type'][[1]]
    
    img.file$data <- f['img.file.data'][[1]]
    img.file.copy$data <- f['img.file.copy.data'][[1]]
    img.file.crop$data <- f['img.file.crop.data'][[1]]
    
    density <- f['density'][[1]]
    reg.model <- f['reg.model'][[1]]
    
    updateNumericInput(session, 'density', value = density)
    updateSelectInput(session, 'reg_model', selected = reg.model)
    
    plot1_ranges$x <- f['plot1_ranges.x'][[1]]
    plot1_ranges$y <- f['plot1_ranges.y'][[1]]
    plot2_ranges$x <- f['plot2_ranges.x'][[1]]
    plot2_ranges$y <- f['plot2_ranges.y'][[1]]
    path.info$x <- f['path.info.x'][[1]]
    path.info$y <- f['path.info.y'][[1]]
    path.info$type <- f['path.info.type'][[1]]
    path.info$ID <- f['path.info.ID'][[1]]
    path.info$horizontal <- f['path.info.horizontal'][[1]]
    path.info$dpi <- f['path.info.dpi'][[1]] # TODO:check
    path.info$max <- f['path.info.max'][[1]]
    path.info$df <- f['path.info.df'][[1]]
    rw.dataframe$data <- f['rw.dataframe.data'][[1]]
    df.loc$data <- f['df.loc.data'][[1]]
    df.loc$ID <- f['df.loc.ID'][[1]]
    el_wood.loc$data <- f['el_wood.loc.data'][[1]]
    calibration.values.min_max$min.value <- 
      f['calibration.values.min_max.min.value'][[1]]
    calibration.values.min_max$max.value <- 
      f['calibration.values.min_max.max.value'][[1]]
    calibration.density.min_max$min.value <- 
      f['calibration.density.min_max.min.value'][[1]]
    calibration.density.min_max$max.value <- 
      f['calibration.density.min_max.max.value'][[1]]
    calibration_profile$data <- f['calibration_profile.data'][[1]]
    calibration.curve$thickness <- f['calibration.curve.thickness'][[1]]
    calibration.curve$grayscale <- f['calibration.curve.grayscale'][[1]]
    calibration.model$data <- f['calibration.model.data'][[1]]
    path.info$num.segments <- f['num.seg'][[1]]
    tuid <- f['tuid'][[1]]
    sample.yr <- f['sample.yr'][[1]]
    dpi <- f['dpi'][[1]] # TODO:check
    sample.thickness <- f['sample.thickness'][[1]]
    sel.sin.mul <- f['sel.sin.mul'][[1]]
    num.seg <- f['num.seg'][[1]]
    hor.path <- f['hor.path'][[1]]
    pixels.path <- f['pixels.path'][[1]]
    sample.site.id <- f['sample.site.id'][[1]]
    sample.site <- f['sample.site'][[1]]
    sample.parcel <- f['sample.parcel'][[1]]
    sample.country <- f['sample.country'][[1]]
    sample.species <- f['sample.species'][[1]]
    sample.species.code <- f['sample.species.code'][[1]]
    sample.elevation <- f['sample.elevation'][[1]]
    sample.latitude <- f['sample.latitude'][[1]]
    sample.longitude <- f['sample.longitude'][[1]]
    sample.investigator <- f['sample.investigator'][[1]]
    sample.date <- f['sample.date'][[1]]
    
    updateTextInput(session, 'tuid', value = tuid)
    updateTextInput(session, 'sample_yr', value = sample.yr)
    updateTextInput(session, 'dpi', value = dpi)
    updateTextInput(session, 'sample_thickness', value = sample.thickness)
    updatePickerInput(session, 'sel_sin_mul', selected = sel.sin.mul)
    updateNumericInput(session, 'num_seg', value = num.seg)
    updatePrettyCheckbox(session, 'hor_path', value = hor.path)
    updateNumericInput(session, 'pixelspath', value = pixels.path)
    updateTextInput(session, 'sample_site_id', value = sample.site.id)
    updateTextInput(session, 'sample_site', value = sample.site)
    updateTextInput(session, 'sample_parcel', value = sample.parcel)
    updateTextInput(session, 'sample_country', value = sample.country)
    updateTextInput(session, 'sample_species', value = sample.species)
    updateTextInput(session, 'sample_species_code', value = sample.species.code)
    updateTextInput(session, 'sample_elevation', value = sample.elevation)
    updateTextInput(session, 'sample_latitude', value = sample.latitude)
    updateTextInput(session, 'sample_longitude', value = sample.longitude)
    updateTextInput(session, 'sample_investigator', value = sample.investigator)
    updateTextInput(session, 'sample_date', value = sample.date )
    
    if (!is.null(calibration_profile$data)) {
      updatePrettyCheckbox(
        session = session, inputId = "show_profile", 
        value = TRUE)
    }
    
    # Light Calibration Values
    m <- matrix(1, length(calibration.curve$thickness), 2, dimnames = 
                  list(NULL, c("Thickness", "Intensity")))
    m[,1] <- calibration.curve$thickness
    m[,2] <- calibration.curve$grayscale
    updateMatrixInput(session, 'thickness_matrix', value = m)
    
    updateNumericInput(session, 'nsteps', value = 
                         length(calibration.curve$thickness))
    
    # Light Calibration Curve
    thickness_values <- calibration.curve$thickness
    grayvalues <- calibration.curve$grayscale
    optical_density <- thickness_values * input$density
    
    calibration_model <- calibration.model$data
    rng_grayvalues <- range(grayvalues)
    xrange <- seq(min(c(img.file$min.value, calibration.values.min_max$min.value)), 
                  max(c(img.file$max.value, 
                        calibration.values.min_max$max.value)), length.out = 1000)
    preds <- predict(calibration_model, xrange)
    
    if (reg.model != 'local_regression') {
      preds <- preds$y
    }
    preds[xrange > calibration.values.min_max$max.value] <- 
      calibration.density.min_max$max.value
    preds[xrange < calibration.values.min_max$min.value] <- 
      calibration.density.min_max$min.value
    
    output$light <- renderPlot({
      plot(optical_density ~ grayvalues, xlab = "Gray-values", ylab = 
             "Optical density")
      lines(xrange, preds, col = 'red')
    })
  })
  
  observeEvent(input$buttoninputimage, {
    imgf <- input$selectfile
    if (is.null(imgf)) {
      et <- paste('The image file has not been uploaded')
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    img <- as.character(imgf["datapath"])
    img.name <- as.character(imgf["name"])
    
    updatePrettyRadioButtons(
      session = session, inputId = "rotatede",
      label = "Clockwise Rotation",
      choices = c("90 degrees" = "rotate90",
                  "180 degrees" = "rotate180",
                  "270 degrees" = "rotate270"),
      prettyOptions = list(shape = "curve", status = "success",
                           fill = F, inline = F)
    )
    plot1_ranges$x <- NULL
    plot1_ranges$y <- NULL
    plot2_ranges$x <- NULL
    plot2_ranges$y <- NULL
    df.loc$data <- NULL
    df.loc$ID <- NULL
    # Path
    path.info$x <- NULL
    path.info$y <- NULL
    path.info$type <- NULL
    path.info$ID <- NULL
    path.info$horizontal <- NULL
    path.info$dpi <- NULL # TODO:check
    path.info$max <- NULL
    path.info$df <- NULL
    # Wood Info
    df.loc$data <- NULL
    df.loc$ID <- NULL
    rw.dataframe$data <- NULL
    el_wood.loc$data <- NULL
    
    updatePrettyRadioButtons(
      session = session, inputId = "cropcondition",
      choiceNames = 'UNCROPPED', choiceValues = list('a'),
      prettyOptions = list(shape = "curve", status = "danger",
                           fill = F, inline = F)
    )
    updateActionButton(session, "buttoncrop", label = "Crop")
    img.file$data <- readImg(img, img.name)
    img.file$min.value <- img.file$data$min.value
    img.file$max.value <- img.file$data$max.value
    img.file$data.type <- img.file$data$data.type
    img.file$img.name <- img.file$data$img.name
    img.file$data <- img.file$data$tdata
    img.file$resize.ratio <- 1
    
    img.file.crop$data <- img.file$data
    
    tdata <- img.file$data
    dimcol <- dim(tdata)[1]
    dimrow <- dim(tdata)[2]
    
    if ((dimcol*dimrow) >= 1.2e+07) {
      resize.ratio <- 0.25
      img.file$resize.ratio <- resize.ratio
      resized.dim <- raster(nrow = as.integer(resize.ratio*dimcol), 
                            ncol = as.integer(resize.ratio*dimrow))
      ra <- raster(nrow = as.integer(dimcol), 
                   ncol = as.integer(dimrow))
      values(ra) <- as.vector(t(tdata) / img.file$max.value)
      
      img.file.copy$data <- as.matrix(
        as.integer(resample(ra, resized.dim, method = 'bilinear') * 
          img.file$max.value))
      
      rm(ra)
      gc()
      
    } else {
      img.file.copy$data <- img.file$data
    }
  })
  
  observeEvent(input$buttoncrop, {
    if (is.null(img.file$data)) {
      et <- paste('The preview image have not been generated')
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    plot1_brush <- input$plot1_brush
    plot1_ranges$x <- NULL
    plot1_ranges$y <- NULL
    plot2_ranges$x <- NULL
    plot2_ranges$y <- NULL
    df.loc$data <- NULL
    df.loc$ID <- NULL
    # path
    path.info$x <- NULL
    path.info$y <- NULL
    path.info$type <- NULL
    path.info$ID <- NULL
    path.info$horizontal <- NULL
    path.info$dpi <- NULL # TODO:check
    path.info$max <- NULL
    path.info$df <- NULL
    rw.dataframe$data <- NULL
    calibration_profile$data <- NULL
    
    updateTextInput(session, "tuid", value = '', label = 'Series ID')
    if (!is.null(plot1_brush)) {
      plot1_ranges$x <- c(round(plot1_brush$xmin), round(plot1_brush$xmax))
      plot1_ranges$y <- c(round(plot1_brush$ymin), round(plot1_brush$ymax))
      #0730
      dimt <- dim(img.file$data) 
      dimcol <- dimt[2]
      dimrow <- dimt[1]
      
      if (dimcol * dimrow >= 1.2e+07) {
        plot1_ranges$x <- plot1_ranges$x * 4
        plot1_ranges$y <- plot1_ranges$y * 4
      }
      
      if (plot1_ranges$x[1] <= 0) plot1_ranges$x[1] <- 0
      if (plot1_ranges$y[1] <= 0) plot1_ranges$y[1] <- 0
      if (plot1_ranges$x[2] >= dimcol) plot1_ranges$x[2] <- dimcol
      if (plot1_ranges$y[2] >= dimrow) plot1_ranges$y[2] <- dimrow
      
      xmin <- plot1_ranges$x[1]
      ymax <- dimrow - plot1_ranges$y[1]
      xmax <- plot1_ranges$x[2]
      ymin <- dimrow - plot1_ranges$y[2]
      
      if (xmin == 0) {
        xmin <- 1
      }
      if (ymin == 0) {
        ymin <- 1
      }
      
      img.file.crop$data <- img.file$data[ymin:ymax, xmin:xmax]
      
      updateActionButton(session, "buttoncrop", label = "Cancel")
      updatePrettyRadioButtons(
        session = session, inputId = "cropcondition",
        choiceNames = 'CROPPED', choiceValues = list('a'),
        prettyOptions = list(shape = "curve", status = "success",
                             fill = F, inline = F)
      )
    } else {
      img.file.crop$data <- img.file$data
      updateActionButton(session, "buttoncrop", label = "Crop")
      updatePrettyRadioButtons(
        session = session, inputId = "cropcondition",
        choiceNames = 'UNCROPPED', choiceValues = list('a'),
        prettyOptions = list(shape = "curve", status = "danger",
                             fill = F, inline = F)
      ) 
    }
  })
  
  output$pre.img <- renderPlot({
    if (is.null(img.file$data)) return()
    imgInput(img.file$data, img.file.copy$data, img.file$img.name, 
             img.file$max.value, plot1_ranges$x, plot1_ranges$y)
  })
  
  # update path options
  observeEvent(input$sel_sin_mul, {
    if (input$sel_sin_mul == "Single Segment") {
      updateNumericInput(session = session, inputId = 'num_seg', 
                         value = 1, min = 1, max = 1, step = 1)
      updatePrettyCheckbox(
        session = session, inputId = "hor_path", value = TRUE)
    } else {
      if (is.null(path.info$num.segments)) {
        updateNumericInput(session = session, inputId = 'num_seg', 
                           value = 2, min = 1, max = 10, step = 1)
        path.info$num.segments <- NULL
      }
      updatePrettyCheckbox(
        session = session, inputId = "hor_path", value = FALSE)
    }
  })
  
  # 0803 delete a segment
  observeEvent(input$rm_last, {
    if (is.null(path.info$x)) {
      et <- 'The path to be removed does not exist.'
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    
    if (length(path.info$x) == 1) {
      path.info$x <- NULL
      path.info$y <- NULL
      path.info$type <- NULL
      path.info$ID <- NULL
      path.info$horizontal <- NULL
      path.info$dpi <- NULL # TODO:check
      path.info$max <- NULL
      calibration_profile$data <- NULL
      plot2_ranges$x <- NULL
      plot2_ranges$y <- NULL
      
      updatePrettyCheckbox(
        session = session, inputId = "show_profile", 
        value = FALSE)
      
      et <- 'The path has been removed. You need to recreate a path.'
      sendSweetAlert(
        session = session, "Success", et, "success"
      )
      return()
    }
    
    if (length(path.info$x) >= 2) {
      calibration_profile$data <- NULL
      plot2_ranges$x <- NULL
      plot2_ranges$y <- NULL
      
      updatePrettyCheckbox(
        session = session, inputId = "show_profile", 
        value = FALSE)
      
      path.info$x <- path.info$x[-length(path.info$x)]
      path.info$y <- path.info$y[-length(path.info$y)]
      et <- 'The last endpoint added has been removed.'
      sendSweetAlert(
        session = session, "Success", et, "success"
      )
      return()
    }
  })
  # 0803 delete all segments
  observeEvent(input$rm_all, {
    if (is.null(path.info$x)) {
      et <- 'The path to be removed does not exist.'
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    if (length(path.info$x) >= 1) {
      el_wood.loc$data <- NULL
      path.info$x <- NULL
      path.info$y <- NULL
      path.info$type <- NULL
      path.info$ID <- NULL
      path.info$horizontal <- NULL
      path.info$dpi <- NULL # TODO:check
      path.info$max <- NULL
      df.loc$data <- NULL
      df.loc$ID <- NULL
      plot2_ranges$x <- NULL
      plot2_ranges$y <- NULL
      calibration_profile$data <- NULL
      
      updatePrettyCheckbox(
        session = session, inputId = "show_profile", 
        value = FALSE)
      
      et <- 'The path has been removed. You need to recreate a path.'
      sendSweetAlert(
        session = session, "Success", et, "success"
      )
      return()
    }
  })
  
  # del border points
  observeEvent(input$rm_all_border, {
    if (input$edit_wood) {
      if (is.null(el_wood.loc$data)) {
        et <- 'Early/Late borders were not found'
        sendSweetAlert(
          session = session, title = "Error", text = et, type = "error"
        )
        return()
      }
      el_wood.loc$data <- NULL
      et <- 'All early-wood borders have been removed'
      sendSweetAlert(
        session = session, "Success", et, "success"
      )
      return()
    }
    else{
      if (is.null(df.loc$data)) {
        et <- 'Ring borders were not found'
        sendSweetAlert(
          session = session, title = "Error", text = et, type = "error"
        )
        return()
      }
      
      df.loc$data <- NULL
      et <- 'All ring borders have been removed'
      sendSweetAlert(
        session = session, "Success", et, "success"
      )
      return()
    }
  })
  
  # record slider info
  observeEvent(input$img_ver, {
    if (is.null(img.file.crop$data))
      return()
    dimt <- dim(img.file.crop$data)
    dimrow <- dimt[1]
    crop.offset.xy$y <- dimrow - round(input$img_ver[2]*dimrow/1000)
  })
  observeEvent(input$img_hor, {
    if (is.null(img.file.crop$data))
      return()
    dimt <- dim(img.file.crop$data)
    dimcol <- dimt[2]
    crop.offset.xy$x <- input$img_hor[1]*dimcol/100 %>% round
  })
  observeEvent(img.file.crop$data, {
    if (is.null(img.file.crop$data))
      return()
    dimt <- dim(img.file.crop$data)
    dimcol <- dimt[1]
    dimrow <- dimt[2]
    crop.offset.xy$x <- input$img_hor[1]*dimcol/100 %>% round
    crop.offset.xy$y <- dimrow - round(input$img_ver[2]*dimrow/1000)
  })
  
  # record mouse position to generate a preview path
  observeEvent(input$plot2_hover, {
    hover.xy$x <- input$plot2_hover$x
    hover.xy$y <- input$plot2_hover$y
  })
  
  ## create path with mouse clicks
  observeEvent(input$plot2_dblclick, 
               {
                 if (input$sel_mode != "sel_path")
                   return()
                 if (is.null(img.file.crop$data)) {
                   et <- 'Path creation fails because the image has not been plotted'
                   sendSweetAlert(
                     session = session, title = "Error", text = et, type = "error"
                   )
                   return()
                 }
                 dpi <- as.numeric(input$dpi)
                 if (is.na(dpi)) {
                   et <- 'Please enter the DPI of the image'
                   sendSweetAlert(
                     session = session, title = "Error", text = et, type = "error"
                   )
                   return()
                 }
                 seriesID <- input$tuid
                 if (seriesID == '') {
                   et <- 'Please enter a series ID'
                   sendSweetAlert(
                     session = session, title = "Error", text = et, type = "error"
                   )
                   return()
                 }
                 dimt <- dim(img.file.crop$data)
                 dimrow <- dimt[1]
                 dimcol <- dimt[2]
                 
                 if (!is.null(path.info$max)) {
                   if (length(path.info$x) >= path.info$max) {
                     et <- paste('You have already created a path')
                     sendSweetAlert(
                       session = session, title = "Error", text = et, type = "error"
                     )
                     return()
                   }
                 }
                 if (length(path.info$x) >= 1) {
                   cur.p.x <- round(input$plot2_dblclick$x + crop.offset.xy$x)
                   last.point <- path.info$x[length(path.info$x)]
                   if (last.point >= cur.p.x) {
                     et <- paste('The x-position of the current point must be greater',
                                 'than the x-position of the previous point')
                     sendSweetAlert(
                       session = session, title = "Error", text = et, type = "error"
                     )
                     return()
                   }
                 }
                 px <- round(input$plot2_dblclick$x + crop.offset.xy$x)
                 if (px <= 0 | px >= dimcol) {
                   et <- paste('The X-coordinate of the endpoint is out of',
                               'range. Please click on the image.')
                   sendSweetAlert(
                     session = session, title = "Error", text = et, type = "error"
                   )
                   return()
                 }
                 crop.h <- round(diff(input$img_ver)*dimrow/1000)
                 if (input$plot2_dblclick$y >= crop.h | input$plot2_dblclick$y <= 0) {
                   et <- paste('The Y-coordinate of the endpoint is out of',
                               'range. Please click on the image.')
                   sendSweetAlert(
                     session = session, title = "Error", text = et, type = "error"
                   )
                   return() 
                 }
                 py <- round(input$plot2_dblclick$y + crop.offset.xy$y)
                 # dp <- dpi/25.4 # TODO:check
                 hor <- input$hor_path
                 if (length(path.info$x) >= 1) {
                   if (path.info$horizontal) {
                     py <- path.info$y[1]
                   }
                 }
                 path.info$x <- c(path.info$x, px)
                 path.info$y <- c(path.info$y, py)
                 if (length(path.info$x) == 1) {
                   rt <- paste('The beginning point of the path have 
                 been created.')
                   sendSweetAlert(
                     session = session, title = "Success", text = rt, 
                     type = "success"
                   )
                   # record path info only the first time you click
                   path.info$type <- input$sel_sin_mul
                   path.info$ID <- seriesID
                   path.info$horizontal <- input$hor_path
                   path.info$dpi <- dpi # TODO: check
                   path.info$max <- input$num_seg + 1
                   df.loc$ID <- input$tuid
                 }
                 # record xy-coordinates of the path
                 if (length(path.info$x) == path.info$max) {
                   rt <- paste('The ending point of the path have been created.',
                               'Please switch to another working mode.')
                   sendSweetAlert(
                     session = session, title = "Success", text = rt, 
                     type = "success"
                   )
                   px <- path.info$x
                   py <- path.info$y
                   path.df <- as.data.frame(matrix(ncol = 2, nrow = 0))
                   colnames(path.df) <- c('x', 'y')
                   len <- length(path.info$x) - 1
                   for (i in 1:len) {
                     p1 <- px[i]
                     p2 <- px[i + 1]
                     lm1 <- lm(py[c(i, i + 1)] ~ c(p1, p2))
                     cf1 <- coef(lm1)
                     x1 <- p1:p2
                     y1 <- cf1[1] + cf1[2] * x1
                     c1 <- data.frame(x = x1, y = y1)
                     path.df <- rbind(path.df, c1)
                   }
                   
                   path.df$y <- round(path.df$y)
                   path.info$df <- path.df
                 }
               })
  
  # Detect Early/late borders
  observeEvent(input$button_run_auto_early, { 
    if (is.null(path.info$df)) {
      et <- 'A path has not been created.'
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    
    dpi <- path.info$dpi
    # dp <- dpi/25.4 # TODO:check
    ph <- path.info$horizontal
    path.df <- path.info$df
    px <- path.info$x
    py <- path.info$y
    defaultse <- input$defaultse
    if (defaultse) {
      struc.ele1 <- NULL
      struc.ele2 <- NULL
    } else {
      struc.ele1 <- c(input$struc.ele1, input$struc.ele1) %>% as.numeric
      struc.ele2 <- c(input$struc.ele2, input$struc.ele2) %>% as.numeric
    }  
    img <- img.file.crop$data
    method <- input$method
    if (input$watershed.threshold == 'custom.waterthr') {
      watershed.threshold <- input$watershed.threshold2
    } else {
      watershed.threshold <- input$watershed.threshold
    }
    watershed.adjust <- input$watershed.adjust
    progressSweetAlert(
      session = session, id = "detect_progress",
      title = "Detection in progress",
      display_pct = F, value = 0
    )
    if (method == 'watershed') {
      el_wood.loc$data <- automatic.det(
        img, method, dpi, px, py, ph, path.df,
        watershed.threshold, watershed.adjust, struc.ele1, struc.ele2
      )
    }
    if (method == "canny") {
      default.canny <- input$defaultcanny
      canny.t1 <- as.numeric(input$canny.t1)
      canny.t2 <- as.numeric(input$canny.t2)
      canny.adjust <- input$canny.adjust
      canny.smoothing <- input$canny.smoothing
      el_wood.loc$data <- automatic.det(
        img, method, dpi, px, py, ph, path.df,
        watershed.threshold, watershed.adjust, struc.ele1, struc.ele2,
        default.canny, canny.t1, canny.t2, canny.adjust, canny.smoothing
      )
    }   
    if (method == "lineardetect") {
      if (path.info$type == "Multi Segments" | !ph) {
        rt <- paste('The linear detection supports only Single Segment',
                    'mode (without ring width correction). Please recreate',
                    'a horizontal single-segment path.')
        sendSweetAlert(
          session = session, title = "ERROR", text = rt, type = "warning"
        )
        return()
      }
      origin <- as.numeric(input$origin)
      f.df.loc <- automatic.det(
        img, method, dpi, px, py, ph, path.df, 
        struc.ele1 = struc.ele1, struc.ele2 = struc.ele2, origin = origin
      )
      el_wood.loc$data <- f.df.loc
    }
    number.border <- length(el_wood.loc$data$x)
    if (number.border == 0) {
      rt <- 'Ring border was NOT detected'
      closeSweetAlert(session = session)
      sendSweetAlert(
        session = session, title = "Error", text = rt, type = "error"
      )
    } else {
      rt <- paste(number.border, 'borders were detected')
      closeSweetAlert(session = session)
      sendSweetAlert(
        session = session, title = "Finished", text = rt, type = "success"
      )
    }
  })
  
  observeEvent(input$sel_mode, {
    if (input$sel_mode == "sel_det") {
      updatePrettyCheckbox(
        session = session, inputId = "edit_wood", value = FALSE)
    }
    if (input$sel_mode == 'sel_edit') {
      updatePrettyCheckbox(
        session = session, inputId = "show_wood", value = FALSE)
    }
    
  })
  
  observeEvent(input$show_profile | input$pixelspath, {
    if (is.null(path.info$df) | length(path.info$x) < 2 | 
        is.null(input$pixelspath)) {
      return()
    }
    
    sample_thickness <- as.numeric(input$sample_thickness)
    if (is.na(sample_thickness)) {
      et <- 'Please enter the sample thickness'
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    px <- path.info$x
    py <- path.info$y
    img <- img.file.crop$data
    pixelspath <- input$pixelspath
    
    path.data <- crop_path(img, px, py, pixelspath)
    tdata <- path.data[[1]]
    path.coord.x <- path.data[[2]]
    
    img.file.path$data <- tdata
    calibration_profile$coords.x <- path.coord.x
    
    if ((!is.null(calibration.model$data))) 
    { 
      data <- tdata  
      nrows <- dim(data)[1]
      data <- as.vector(t(data))
      
      if (input$reg_model == 'local_regression') {
        density_data <- predict(calibration.model$data, data) / sample_thickness
      }
      else {
        density_data <- predict(calibration.model$data, data) 
        density_data <- density_data$y / sample_thickness
      }
      # Replacing NAN values
      density_data[data > calibration.values.min_max$max.value] <- 
        calibration.density.min_max$max.value
      density_data[data < calibration.values.min_max$min.value] <- 
        calibration.density.min_max$min.value
      
      density_data <- matrix(data = density_data, nrow = nrows, byrow = TRUE)
      calibration_profile$data <- colMeans(density_data, na.rm = TRUE)
    }
  })
  
  # Detect rings for x-ray images
  observeEvent(input$button_run_auto_xray, { 
    if (is.null(path.info$df)) {
      et <- 'A path has not been created.'
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    
    dpi <- path.info$dpi # TODO: check
    dp <- dpi/25.4
    ph <- path.info$horizontal
    path.df <- path.info$df
    px <- path.info$x
    py <- path.info$y
    
    defaultse <- input$defaultse
    if (defaultse) {
      struc.ele1 <- NULL
      struc.ele2 <- NULL
    } else {
      struc.ele1 <- c(input$struc.ele1, input$struc.ele1) %>% as.numeric
      struc.ele2 <- c(input$struc.ele2, input$struc.ele2) %>% as.numeric
    } 
    img <- img.file.crop$data
    imgn <- img.file$max.value - img 
    
    method <- input$method
    if (input$watershed.threshold == 'custom.waterthr') {
      watershed.threshold <- input$watershed.threshold2
    } else {
      watershed.threshold <- input$watershed.threshold
    }
    watershed.adjust <- input$watershed.adjust
    progressSweetAlert(
      session = session, id = "detect_progress",
      title = "Detection in progress",
      display_pct = F, value = 0
    )
    if (method == 'watershed') {
      df.loc$data <- automatic.det(
        imgn, method, dpi, px, py, ph, path.df,
        watershed.threshold, watershed.adjust, struc.ele1, struc.ele2
      )
    }
    if (method == "canny") {
      default.canny <- input$defaultcanny
      canny.t1 <- as.numeric(input$canny.t1)
      canny.t2 <- as.numeric(input$canny.t2)
      canny.adjust <- input$canny.adjust
      canny.smoothing <- input$canny.smoothing
      df.loc$data <- automatic.det(
        imgn, method, dpi, px, py, ph, path.df,
        watershed.threshold, watershed.adjust, struc.ele1, struc.ele2,
        default.canny, canny.t1, canny.t2, canny.adjust, canny.smoothing
      )
    }   
    if (method == "lineardetect") {
      if (path.info$type == "Multi Segments" | !ph) {
        rt <- paste('The linear detection supports only Single Segment',
                    'mode (without ring width correction). Please recreate',
                    'a horizontal single-segment path.')
        sendSweetAlert(
          session = session, title = "ERROR", text = rt, type = "warning"
        )
        return()
      }
      origin <- as.numeric(input$origin)
      f.df.loc <- automatic.det(
        imgn, method, dpi, px, py, ph, path.df, 
        struc.ele1 = struc.ele1, struc.ele2 = struc.ele2, origin = origin
      )
      df.loc$data <- f.df.loc
    }
    number.border <- nrow(df.loc$data)
    if (number.border == 0) {
      rt <- 'Ring border was NOT detected'
      closeSweetAlert(session = session)
      sendSweetAlert(
        session = session, title = "Error", text = rt, type = "error"
      )
    } else {
      rt <- paste(number.border, 'borders were detected')
      closeSweetAlert(session = session)
      sendSweetAlert(
        session = session, title = "Finished", text = rt, type = "success"
      )
    }  
  })
  ## Ring editing mode
  observeEvent(input$plot2_dblclick, {
    if (input$sel_mode == "sel_det") {
      et <- paste('If you want to add new ring borders by double-clicking,',
                  'please switch to the "Ring Editing" mode')
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
  })
  # add a point by double clicking
  observeEvent(input$plot2_dblclick, {
    if (input$sel_mode != "sel_edit")
      return()
    if (is.null(img.file.crop$data)) {
      et <- paste('Adding new ring borders fails',
                  'because the image has not been plotted')
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    if (is.null(path.info$df)) {
      et <- paste('Adding new ring borders fails',
                  'because a path has not been created')
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    if (is.null(df.loc$data)) {
      bor.df <- matrix(nrow = 0, ncol = 3) %>% as.data.frame
      colnames(bor.df) <- c('x', 'y', 'z')
    } else {
      bor.df <- df.loc$data
    }
    dimt <- dim(img.file.crop$data)
    
    dimrow <- dimt[1]
    dimcol <- dimt[2]
    
    # mouse position info
    bor <- input$plot2_dblclick
    px <- round(bor$x + crop.offset.xy$x)
    y_cor <- round(bor$y + crop.offset.xy$y)
    if (px <= path.info$x[1] | px >= path.info$x[length(path.info$x)]) {
      et <- paste('The X-coordinate of the point you click is',
                  'out of range. Please click on the path')
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return()
    }
    # check y-coordinates
    crop.h <- round(diff(input$img_ver)*dimrow/1000)
    if (input$plot2_dblclick$y >= crop.h | input$plot2_dblclick$y <= 0) {
      et <- paste('The Y-coordinate of the point you click is',
                  'out of range. Please click on the path')
      sendSweetAlert(
        session = session, title = "Error", text = et, type = "error"
      )
      return() 
    }
    path.df <- path.info$df
    
    py <- path.df$y[path.df$x == px]
    temp.df <- data.frame(x = px, y = py, z = 'u')
    
    if (input$edit_wood) {
      el_wood.loc$data <- rbind(el_wood.loc$data, temp.df)
    }
    else{
      df.loc$data <- rbind(bor.df, temp.df)
    }
  })
  
  # delete points with a brush
  observeEvent(input$buttonzoomdel, {
    if (is.null(input$plot2_brush$xmin)) {
      err.text <- 'You have not selected ring borders with a brush'
      sendSweetAlert(
        session = session, title = "Error", text = err.text, type = "error"
      )
      return()
    } 
    if (is.null(path.info$df)) {
      err.text <- 'A path has not been created'
      sendSweetAlert(
        session = session, title = "Error", text = err.text, type = "error"
      )
      return()
    } 
    if (input$edit_wood) {
      if (is.null(el_wood.loc$data)) {
        remove.text <- 'Early/Late border was NOT found along the path'
        sendSweetAlert(
          session = session, title = "Error", text = remove.text, type = "error"
        )
        return()
      } 
    }
    else{
      if (is.null(df.loc$data)) {
        remove.text <- 'Ring border was NOT found along the path'
        sendSweetAlert(
          session = session, title = "Error", text = remove.text, type = "error"
        )
        return()
      } 
    }
    xmin <- round(input$plot2_brush$xmin + crop.offset.xy$x)
    xmax <- round(input$plot2_brush$xmax + crop.offset.xy$x)
    ymin <- round(input$plot2_brush$ymin + crop.offset.xy$y)
    ymax <- round(input$plot2_brush$ymax + crop.offset.xy$y)
    if (input$edit_wood) {
      df.el.loc <- el_wood.loc$data
      x.ranges <- df.el.loc$x
      delete.bor <- x.ranges >= xmin & x.ranges <= xmax
      y.ranges <- df.el.loc$y
      is.contain <- ymin <= y.ranges & ymax >= y.ranges
      delete.bor <- delete.bor & is.contain
      if (any(delete.bor)) {
        el_wood.loc$data <- el_wood.loc$data[!delete.bor,]
      } else {
        err.text <- 'Early/Late border was NOT found in the area you selected'
        sendSweetAlert(
          session = session, title = "Error", text = err.text, type = "error"
        )
      }
    }
    else{
      x.ranges <- df.loc$data$x
      delete.bor <- x.ranges >= xmin & x.ranges <= xmax
      y.ranges <- df.loc$data$y
      is.contain <- ymin <= y.ranges & ymax >= y.ranges
      delete.bor <- delete.bor & is.contain
      if (any(delete.bor)) {
        df.loc$data <- df.loc$data[!delete.bor,]
      } else {
        err.text <- 'Ring border was NOT found in the area you selected'
        sendSweetAlert(
          session = session, title = "Error", text = err.text, type = "error"
        )
      }
    }
  })
  # Prints  the core with the borders (if any). img.file.crop$data 
  # contains the data of the img. df.loc$data contains border points.
  output$ring_edit <- renderPlot({
    if (is.null(img.file$data)) return()
    fig1 <- imgInput_crop(img.file.crop$data, img.file$max.value, 
                          input$img_ver, input$img_hor)
    sample_yr <- as.numeric(input$sample_yr)
    if (is.na(sample_yr)) return()
    pch <- as.numeric(input$pch)
    bor.color <- input$border.color
    lab.color <- input$label.color
    bor_el.color <- input$border_el_wood.color
    l.w <- as.numeric(input$linelwd)
    label.cex <- as.numeric(input$label.cex)*0.7
    plot.marker(path.info, hover.xy, sample_yr, l.w, pch,
                bor.color, lab.color, label.cex, bor_el.color, el_wood.loc$data) 
  })
  
  output$profile_edit <- renderPlot({
    bor.color <- input$border.color
    py <- path.info$y
    dpi <- path.info$dpi # TODO: check
    img <- img.file.crop$data
    pixelspath <- input$pixelspath
    path.hor <- path.info$horizontal
    
    if (!is.null(calibration_profile$data)) { 
      x.coords <- df.loc$data$x
      y.coords <- df.loc$data$y
      path.info.x <- path.info$x
      path.info.y <- path.info$y
      
      dp <- dpi/25.4
      dimt <- dim(img)
      dimcol <- dimt[2]
      
      pxmin <- min(path.info.x)
      if (pxmin <= 0)
        pxmin <- 0
      pxmax <- max(path.info.x)
      if (pxmax >= dimcol)
        pxmax <- dimcol
      
      data <- calibration_profile$data
      if (pxmin > 0) {
        data <- append(data, rep(NA, pxmin), 0)
      }
      if ((dimcol - pxmax) > 0) {
        data <- append(data, rep(NA, (dimcol - pxmax)))
      }
      dimrow <- nrow(data.frame(data))
      
      par(mar = c(0, 0, 1, 0), xaxs = 'i')
      plot(data, xlim = c(round(input$img_hor[1]*dimrow/100), 
                        round(input$img_hor[2]*dimrow/100)), 
           ann = FALSE, xaxt = 'n', yaxt = 'n',type = 'l')
      
      if (!is.null(x.coords)) {
        profile.path.coord.x <- calibration_profile$coords.x
        coords <- estimate_coords_path(path.info.x, path.info.y, x.coords, 
                                       y.coords, profile.path.coord.x)
        bx <- pxmin + coords
        by <- max(data, na.rm = TRUE)
        
        abline(v = bx, col = bor.color)
        border.num <- 1:length(coords)
        lab.color <- input$label.color
        label.cex <- as.numeric(input$label.cex)*0.7
        text(bx, by, border.num, srt = 90, col = lab.color, 
             cex = label.cex) 
      }
      df_el_wood.loc <- el_wood.loc$data
      if (!is.null(df_el_wood.loc) & (input$show_wood | input$edit_wood)) {
        x.coords <- df_el_wood.loc$x
        y.coords <- df_el_wood.loc$y
        profile.path.coord.x <- calibration_profile$coords.x
        coords <- estimate_coords_path(path.info.x, path.info.y, x.coords, 
                                       y.coords, profile.path.coord.x)
        bx <- pxmin + coords
        bx <- sort(bx)
        by <- max(data, na.rm = TRUE)
        bor.color <- input$border_el_wood.color
        
        abline(v = bx, col = bor.color)
      }
    }
  })
  
  observeEvent(input$button_del, {
    if (is.null(path.info$df)) {
      rt <- paste('You can not remove ring borders because',
                  'the path has not been created.')
      sendSweetAlert(
        session = session, title = "Error", text = rt, type = "error"
      )
      return()
    }
    if (is.null(df.loc$data)) {
      rt <- paste('Ring borders were not found')
      sendSweetAlert(
        session = session, title = "Error", text = rt, type = "error"
      )
      return()
    }
  })
  
  observeEvent(input$save_calibration, {
    volumes <- c("UserFolder" = Sys.getenv("HOME"))
    shinyFileSave(input, "save_calibration", roots = volumes, session = session)
    fileinfo <- parseSavePath(volumes, input$save_calibration)
    if (nrow(fileinfo) > 0) {
      write.table(input$thickness_matrix, file = as.character(fileinfo$datapath), 
                  col.names = FALSE, quote = FALSE, row.names = FALSE)
    }
  })
  
  # Disable buttons
  observe({
    if (length(path.info$x) < 2 | is.null(path.info$df) | 
       is.null(input$pixelspath)) {
      shinyjs::disable("show_profile")
    }
    else {
      shinyjs::enable("show_profile")
    }
  })
  
  save_image <- function(filename, matrix, data.type) {
    data <- matrix
    r <- raster(data)
    writeRaster(r, filename, datatype = data.type, overwrite = TRUE)
  }
  
  f.yrho <- function(df.rw, profile, path.info, profile.path.coord.x) {
    rho.year.mean <- c(NA)
    rho.year.std <- c(NA)
    rho.year.max <- c(NA)
    rho.year.min <- c(NA)
    
    x.coords <- estimate_coords_path(path.info$x, path.info$y, df.rw$x, 
                                     df.rw$y, profile.path.coord.x)
    
    for (row in 2:nrow(df.rw)) {
      x1 <- x.coords[row - 1]
      x2 <- x.coords[row]
      
      tdata <- profile[x1:(x2 - 1)]
      p95 <- quantile(tdata, 0.95, na.rm = TRUE)
      p05 <- quantile(tdata, 0.05, na.rm = TRUE)
      tdata_p95 <- tdata[tdata >= p95]
      tdata_p05 <- tdata[tdata <= p05]
      rho.year.mean <- append(rho.year.mean, 
                              round(mean(tdata, na.rm = TRUE), digits = 4))
      rho.year.std <- append(rho.year.std, 
                             round(sd(tdata, na.rm = TRUE), digits = 4))
      rho.year.max <- append(rho.year.max, 
                             round(mean(tdata_p95, na.rm = TRUE), digits = 4))
      rho.year.min <- append(rho.year.min, 
                             round(mean(tdata_p05, na.rm = TRUE), digits = 4))
    }
    df <- data.frame(df.rw['year'], df.rw['x'], df.rw['y'], 
                     df.rw['ring.width'], rho.year.mean, rho.year.std, 
                     rho.year.max, rho.year.min)
    return(df)
  }
  
  f.elrho <- function(df.yrho, profile, elwood, path.info, 
                      profile.path.coord.x) {
    rho.lw.mean <- c(NA)
    rho.lw.std <- c(NA)
    rho.lw.max <- c(NA)
    rho.lw.min <- c(NA)
    rho.ew.mean <- c(NA)
    rho.ew.std <- c(NA)
    rho.ew.max <- c(NA)
    rho.ew.min <- c(NA)
    elw.x <- c(NA)
    elw.y <- c(NA)
    
    x.coords <- estimate_coords_path(path.info$x, path.info$y, df.yrho$x, 
                                     df.yrho$y, profile.path.coord.x)
    elwood.x.coords <- estimate_coords_path(path.info$x, path.info$y, elwood$x, 
                                            elwood$y, profile.path.coord.x)
    for (row in 2:nrow(df.yrho)) {
      x1 <- x.coords[row - 1]
      x2 <- x.coords[row]
      el.point <- elwood.x.coords[(elwood.x.coords >= x1) & 
                                    (elwood.x.coords <= x2)]
      original.el.point <- elwood$x[(elwood['x'] >= x1) & (elwood['x'] <= x2)]
      
      if (length(el.point) == 1) {
        elw.x <- append(elw.x, original.el.point)
        elw.y <- append(elw.y, elwood$y[(elwood['x'] == original.el.point)])
        # late wood
        tdata <- profile[x1:(el.point - 1)]
        p95 <- quantile(tdata, 0.95, na.rm = TRUE)
        p05 <- quantile(tdata, 0.05, na.rm = TRUE)
        tdata_p95 <- tdata[tdata >= p95]
        tdata_p05 <- tdata[tdata <= p05]
        rho.lw.mean <- append(rho.lw.mean, 
                              round(mean(tdata, na.rm = TRUE), digits = 4))
        rho.lw.std <- append(rho.lw.std, 
                             round(sd(tdata, na.rm = TRUE), digits = 4))
        rho.lw.max <- append(rho.lw.max, 
                             round(mean(tdata_p95, na.rm = TRUE), digits = 4))
        rho.lw.min <- append(rho.lw.min, 
                             round(mean(tdata_p05, na.rm = TRUE), digits = 4))
        # early wood
        tdata <- profile[el.point:(x2 - 1)]
        p95 <- quantile(tdata, 0.95, na.rm = TRUE)
        p05 <- quantile(tdata, 0.05, na.rm = TRUE)
        tdata_p95 <- tdata[tdata >= p95]
        tdata_p05 <- tdata[tdata <= p05]
        rho.ew.mean <- append(rho.ew.mean, 
                              round(mean(tdata, na.rm = TRUE), digits = 4))
        rho.ew.std <- append(rho.ew.std, 
                             round(sd(tdata, na.rm = TRUE), digits = 4))
        rho.ew.max <- append(rho.ew.max, 
                             round(mean(tdata_p95, na.rm = TRUE), digits = 4))
        rho.ew.min <- append(rho.ew.min, 
                             round(mean(tdata_p05, na.rm = TRUE), digits = 4))
      }
      else {
        elw.x <- append(elw.x, NA)
        elw.y <- append(elw.y, NA)
        rho.lw.mean <- append(rho.lw.mean, NA)
        rho.lw.std <- append(rho.lw.std, NA)
        rho.lw.max <- append(rho.lw.max, NA)
        rho.lw.min <- append(rho.lw.min, NA)
        rho.ew.mean <- append(rho.ew.mean, NA)
        rho.ew.std <- append(rho.ew.std, NA)
        rho.ew.max <- append(rho.ew.max, NA)
        rho.ew.min <- append(rho.ew.min, NA)
      }
    }
    df <- data.frame(df.yrho['year'], df.yrho['x'], df.yrho['y'], 
                     df.yrho['ring.width'], df.yrho['rho.year.mean'], 
                     df.yrho['rho.year.std'], 
                     df.yrho['rho.year.max'], df.yrho['rho.year.min'], 
                     elw.x, elw.y, 
                     rho.lw.mean, rho.lw.std, rho.lw.max, rho.lw.min,
                     rho.ew.mean, rho.ew.std, rho.ew.max, rho.ew.min)
    return(df)
  }
  
  output$RingWidth.csv <- downloadHandler(
    filename =  function() {
      if (is.null(img.file$data)) {
        img.name <- 'Download Fail'
        return(paste0(img.name, '.csv'))
      } else {
        img.name <- input$tuid
      }
      if (input$csv.name != '')
        img.name <- input$csv.name
      return(paste0(img.name, '.csv'))
    },
    content = function(filename) {
      if (is.null(df.loc$data)) {
        error.text <- 'Ring border was not found along the path'
        sendSweetAlert(
          session = session, title = "Error", text = error.text, type = "error"
        )
        return()
      } 
      if (nrow(df.loc$data) <= 1) {
        error.text <- paste('A minimum of two ring borders on each path',
                            'was required to generate a ring-width series')
        sendSweetAlert(
          session = session, title = "Error", text = error.text, type = "error"
        )
        return()
      } 
      sample_yr <- as.numeric(input$sample_yr)
      if (is.na(sample_yr)) {
        error.text <- paste('Please check the argument \'Sampling year\' ')
        sendSweetAlert(
          session = session, title = "Error", text = error.text, type = "error"
        )
        return()
      }
      
      dpi <- path.info$dpi
      dp <- dpi/25.4
      
      df <- f.rw(df.loc$data, sample_yr, dpi)
      if (!is.null(calibration_profile$data)) {
        df <- f.yrho(df, calibration_profile$data, path.info, 
                     calibration_profile$coords.x)
        if (!is.null(el_wood.loc$data)) {
          df <- f.elrho(df, calibration_profile$data, el_wood.loc$data, 
                        path.info, calibration_profile$coords.x)
          if (length(df$elw.x[is.na(df$elw.x)]) > 1) {
            showNotification(paste("WARNING: Skipping duplicate or missing 
                                   early-late wood borders."), duration = 5)
          }
        }
      }
      write.csv(df, filename, quote = FALSE, na = '')
      
    },
    contentType = 'text/csv'
  )
  
  output$RingWidth.xlsx <- downloadHandler(
    filename =  function() {
      if (is.null(img.file$data)) {
        img.name <- 'Download Fail'
      } else {
        img.name <- input$tuid
      }
      if (input$excel.name != '')
        img.name <- input$excel.name
      return(paste0(img.name, '.xlsx'))
    },
    content = function(filename) {
      if (is.null(df.loc$data)) {
        error.text <- 'Ring border was not found along the path'
        sendSweetAlert(
          session = session, title = "Error", text = error.text, type = "error"
        )
        return()
      } 
      if (nrow(df.loc$data) <= 1) {
        error.text <- paste('A minimum of two ring borders on each path',
                            'was required to generate a ring-width series')
        sendSweetAlert(
          session = session, title = "Error", text = error.text, type = "error"
        )
        return()
      } 
      sample_yr <- as.numeric(input$sample_yr)
      if (is.na(sample_yr)) {
        error.text <- paste('Please check the argument \'Sampling year\' ')
        sendSweetAlert(
          session = session, title = "Error", text = error.text, type = "error"
        )
        return()
      }
      
      dpi <- path.info$dpi
      dp <- dpi/25.4
      
      df <- f.rw(df.loc$data, sample_yr, dpi)
      if (!is.null(calibration_profile$data)) {
        df <- f.yrho(df, calibration_profile$data, path.info, 
                     calibration_profile$coords.x)
        if (!is.null(el_wood.loc$data)) {
          df <- f.elrho(df, calibration_profile$data, el_wood.loc$data, 
                        path.info, calibration_profile$coords.x)
          if (length(df$elw.x[is.na(df$elw.x)]) > 1) {
            showNotification(paste("WARNING: Skipping duplicate or missing 
                                   early-late wood borders."), duration = 5)
          }
        }
      }
      core.id <- input$tuid
      site.id <- input$sample_site_id
      site.name <- input$sample_site
      plot.name <- input$sample_parcel
      country <- input$sample_country
      species <- input$sample_species
      species.code <- input$sample_species_code
      elevation <- input$sample_elevation
      latitude <- input$sample_latitude
      longitude <- input$sample_longitude
      first.year <- df$year[length(df$year)]
      last.year <- df$year[1]
      investigator <- input$sample_investigator
      date <- input$sample_date
      
      dpi <- input$dpi
      thickness <- input$sample_thickness
      path.width <- input$pixelspath
      
      value <- c(core.id, site.id, site.name, plot.name, country, species, 
                 species.code, elevation, latitude, longitude, first.year, 
                 last.year, investigator, date, dpi, thickness, path.width)
      variable <- c('CORE ID', 'SITE ID', 'SITE NAME', 'PLOT NAME', 'COUNTRY',
                    'SPECIES', 'SPECIES CODE', 'ELEVATION', 'LATITUDE', 
                    'LONGITUDE', 'FIRST YEAR', 'LAST YEAR', 'INVESTIGATOR', 
                    'DATE', 'DPI', 'SAMPLE THICKNESS', 'PATH WIDTH')
      tree_info <- data.frame(variable, value)
      list_of_datasets <- list("TreeInfo" = tree_info, "Data" = df)
      write.xlsx(list_of_datasets, file = filename)
      
    },
    contentType = 'application/xlsx'
  )
  
  output$Project.rds <- downloadHandler(
    filename =  function() {
      if (is.null(img.file$data)) {
        img.name <- 'Download Fail'
        return(paste0(img.name, '.rds'))
      } else {
        img.name <- input$tuid
      }
      if (input$rds_project.name != '')
        img.name <- input$rds_project.name
      return(paste0(img.name, '.rds'))
    },
    content = function(filename) {
      img.file.data <- img.file$data
      img.file.copy.data <- img.file.copy$data
      img.file.crop.data <- img.file.crop$data
      
      files <- list(img.file.data = img.file.data,
                    img.file.copy.data = img.file.copy.data,
                    img.file.crop.data = img.file.crop.data,
                    img.file.max.value = img.file$max.value, 
                    img.file.min.value = img.file$min.value,
                    img.file.data.type = img.file$data.type, 
                    tuid = input$tuid,
                    sample.yr = input$sample_yr,
                    dpi = input$dpi,
                    sample.thickness = input$sample_thickness,
                    plot1_ranges.x = plot1_ranges$x, 
                    plot1_ranges.y = plot1_ranges$y, 
                    plot2_ranges.x = plot2_ranges$x, 
                    plot2_ranges.y = plot2_ranges$y, 
                    path.info.x = path.info$x, 
                    path.info.y = path.info$y, 
                    path.info.type = path.info$type, 
                    path.info.ID = path.info$ID, 
                    path.info.horizontal = path.info$horizontal, 
                    path.info.dpi = path.info$dpi, 
                    path.info.max = path.info$max, 
                    path.info.df = path.info$df, 
                    rw.dataframe.data = rw.dataframe$data, 
                    df.loc.data = df.loc$data,
                    df.loc.ID = df.loc$ID, 
                    el_wood.loc.data = el_wood.loc$data,
                    density = input$density,
                    reg.model = input$reg_model,
                    calibration.values.min_max.min.value =
                      calibration.values.min_max$min.value, 
                    calibration.values.min_max.max.value =
                      calibration.values.min_max$max.value,
                    calibration.density.min_max.min.value =
                      calibration.density.min_max$min.value, 
                    calibration.density.min_max.max.value =
                      calibration.density.min_max$max.value,
                    calibration_profile.data = calibration_profile$data,
                    calibration_profile.coords.x = calibration_profile$coords.x,
                    calibration.model.data = calibration.model$data,
                    calibration.curve.thickness = calibration.curve$thickness,
                    calibration.curve.grayscale = calibration.curve$grayscale,
                    sel.sin.mul = input$sel_sin_mul,
                    hor.path = input$hor_path,
                    num.seg = input$num_seg,
                    pixels.path = input$pixelspath,
                    sample.site.id = input$sample_site_id,
                    sample.site = input$sample_site,
                    sample.parcel = input$sample_parcel,
                    sample.country = input$sample_country,
                    sample.species = input$sample_species,
                    sample.species.code = input$sample_species_code,
                    sample.elevation = input$sample_elevation,
                    sample.latitude = input$sample_latitude,
                    sample.longitude = input$sample_longitude,
                    #sample.first.year=input$sample_first_year,
                    #sample.last.year=input$sample_last_year,
                    sample.investigator = input$sample_investigator,
                    sample.date = input$sample_date
      )
      saveRDS(files, filename)
    },
    contentType = 'application/rds'
  )
  
  output$RingWidth.rwl <- downloadHandler(
    filename = function() {
      if (is.null(df.loc$data)) {
        img.name <- 'Download Unavailable'
        return(paste0(img.name, '.rwl'))
      } else {
        img.name <- input$tuid
      }
      if (input$rwl.name != '')
        img.name <- input$rwl.name
      return(paste0(img.name, '.rwl'))
    }, 
    content = function(filename) {
      seriesID <- df.loc$ID
      miss.id1 <- seriesID == ''
      if (miss.id1) {
        rt <- 'Please enter a series ID'
        sendSweetAlert(
          session = session, title = "Error", text = rt, type = "error"
        )
        return()
      }
      if (is.null(df.loc$data)) {
        error.text <- 'Ring border was not found along the path'
        sendSweetAlert(
          session = session, title = "Error", text = error.text, type = "error"
        )
        return()
      } 
      if (nrow(df.loc$data) <= 1) {
        error.text <- paste('A minimum of two ring borders on each path',
                            'was required to generate a ring-width series')
        sendSweetAlert(
          session = session, title = "Error", text = error.text, type = "error"
        )
        return()
      } 
      sample_yr <- as.numeric(input$sample_yr)
      if (is.na(sample_yr)) {
        error.text <- paste('Please check the argument \'Sampling year\' ')
        sendSweetAlert(
          session = session, title = "Error", text = error.text, type = "error"
        )
        return()
      }
      
      dpi <- path.info$dpi
      dp <- dpi/25.4
      df.rw <- NULL
      
      df.rw <- f.rw(df.loc$data, sample_yr, dpi)
      
      df.rwl <- data.frame(df.rw$ring.width, row.names = df.rw$year)
      tuprec <- as.numeric(input$tuprec)
      tuheader <- TRUE 
      tuhdr1 <- input$sample_site_id
      tuhdr2 <- input$sample_site
      tuhdr3 <- input$sample_species_code # species code
      tuhdr4 <- input$sample_country
      tuhdr5 <- input$sample_species
      tuhdr6 <- input$sample_elevation
      tuhdr7 <- input$sample_latitude
      tuhdr8 <- input$sample_longitude
      tuhdr9 <- df.rw$year[length(df.rw$year)]
      tuhdr10 <- df.rw$year[1]
      tuhdr11 <- input$sample_investigator
      tuhdr12 <- input$sample_date
      colnames(df.rwl) <- seriesID
      hdr.list <- NULL
      if (tuheader) {
        hdr <- c(tuhdr1, tuhdr2, tuhdr3, tuhdr4, tuhdr5, tuhdr6, 
                 tuhdr7, tuhdr8, tuhdr9, tuhdr10, tuhdr11, tuhdr12)
        hdr.name <- c('site.id','site.name', 'spp.code', 'state.country', 
                      'spp','elev', 'lat', 'long', 'first.yr', 'last.yr',
                      'lead.invs', 'comp.date')
        which.not.empty <- hdr != ''
        if (any(which.not.empty)) {
          hdr.list <- lapply(hdr, function(x) x)
          names(hdr.list) <- hdr.name
        }
      }
      write.rwl(rwl.df = df.rwl, fname = filename,
                format = "tucson", header = hdr.list,
                append = FALSE, prec = tuprec)
    }, contentType = "rwl"
  )
}

shinyApp(ui = createUI(), server = createServer)
