#' Print run summary in Xpose 4
#' 
#' Function to build Xpose run summaries.
#' 
#' 
#' @param object An xpose.data object.
#' @param dir The directory to look for the model and output file of a NONMEM
#' run.
#' @param modfile The name of the NONMEM control stream associated with the
#' current run.
#' @param listfile The name of the NONMEM output file associated with the
#' current run.
#' @param main A string giving the main heading. \code{NULL} if none.
#' @param subset A string giving the subset expression to be applied to the
#' data before plotting. See \code{\link{xsubset}}.
#' @param show.plots Logical indicating if GOF plots should be shown in the run
#' summary.
#' @param txt.cex Number indicating the size of the txt in the run summary.
#' @param txt.font Font of the text in the run summary.
#' @param show.ids Logical indicating if IDs should be plotted in the plots for
#' the run summary.
#' @param param.table Logical indicating if the parameter table should be shown
#' in the run summary.
#' @param txt.columns The number of text columns in the run summary.
#' @param force.wres Plot the WRES even if other residuals are available.
#' @param \dots Other arguments passed to the various functions.
#' @return A compound plot containing an Xpose run summary is created.
#' @author Niclas Jonsson and Andrew Hooker
#' @keywords methods
#' @examples
#' od = setwd(tempdir()) # move to a temp directory
#' (cur.files <- dir()) # current files in temp directory
#' 
#' simprazExample(overwrite=TRUE) # write files
#' (new.files <- dir()[!(dir() %in% cur.files)])  # what files are new here?
#' 
#' xpdb <- xpose.data(1)
#' runsum(xpdb)
#' 
#' 
#' file.remove(new.files) # remove these files
#' setwd(od)  # restore working directory
#' 
#' 
#' @export runsum
#' @family specific functions 
runsum <-
  function(object,
           dir="",
           modfile=paste(dir,"run",object@Runno,".mod",sep=""),
           listfile=paste(dir,"run",object@Runno,".lst",sep=""),
           main=NULL,
           subset=xsubset(object),
           show.plots=TRUE,
           txt.cex=0.7,
           txt.font=1,
           show.ids=FALSE,
           param.table=TRUE,
           txt.columns=2,
           force.wres=FALSE,
           ...)
{
  
  
  ## Read model file
  if(is.readable.file(modfile)) {
    modfile <- scan(modfile,sep="\n",what=character(),quiet=TRUE)
    mod.file.lines <- length(modfile)
  } else {
    cat(paste("model file",modfile,"not found, run summary not created!\n"))
    return()
  }

  ## Global settings concerning number of lines, number of columns etc.

                                        #txtnrow  <- 63       # Number of rows in each column

  parameter.list <- create.parameter.list(listfile)
  #attach(parameter.list,warn.conflicts=F)


  ## Set up screen
  grid.newpage()
  gr.width <- par("din")[1]
  gr.height <- par("din")[2]
  title.size <- 0.05
  graph.size <- 0.25
  graph2.size <- 0
  if (gr.width < gr.height){
    graph.size <- graph.size*gr.width/gr.height
    graph2.size <- graph2.size*gr.width/gr.height
  }
  text.size <- 1 - (graph.size + graph2.size + title.size)
  title.vp <- viewport(x=0, y=1, just=c("left","top"),
                       width=1, height=title.size,
                       name="title.vp")

  graph.1.vp <-(viewport(x=0, y=1-title.size, just=c("left","top"),
                         width=.25, height=graph.size,
                                        #layout=grid.layout(1,4),
                         name="graph.1.vp"))
  graph.2.vp <-(viewport(x=.25, y=1-title.size, just=c("left","top"),
                         width=.25, height=graph.size,
                                        #layout=grid.layout(1,4),
                         name="graph.2.vp"))
  graph.3.vp <-(viewport(x=.50, y=1-title.size, just=c("left","top"),
                         width=.25, height=graph.size,
                                        #layout=grid.layout(1,4),
                         name="graph.3.vp"))
  graph.4.vp <-(viewport(x=.75, y=1-title.size, just=c("left","top"),
                         width=.25, height=graph.size,
                                        #layout=grid.layout(1,4),
                         name="graph.4.vp"))
  graph.5.vp <-(viewport(x=0, y=1-title.size-graph.size, just=c("left","top"),
                         width=1, height=graph2.size,
                                        #layout=grid.layout(1,4),
                         name="graph.5.vp"))


  ## create text column viewports
  textColumnList <- vector("list",txt.columns) # empty list for viewports
  for(col.num in 1:txt.columns){
    txt.margin <- 0.015
    x.val <- 1/txt.columns*(col.num-1) + txt.margin
    w.val <- 1/txt.columns - (txt.margin)
    ##cat(paste(x.val,w.val,"\n"))
    textColumnList[[col.num]] <- viewport(x=x.val,
                                          y=text.size,
                                          just=c("left","top"),
                                          width=w.val,
                                          height=text.size,
                                          gp=gpar(lineheight=1.0,
                                            cex=txt.cex,font=txt.font
                                            ),
                                          name=paste("text",col.num,"vp",
                                            sep="."))
  }

  ## text.1.vp <- viewport(x=0.015, y=text.size, just=c("left","top"),
  ##                         w=0.485, h=text.size,gp=gpar(lineheight=1.0,
  ##                                                cex=txt.cex,font=2),
  ##                         name="text.1.vp")
  ##   text.2.vp <- viewport(x=0.515, y=text.size, just=c("left","top"),
  ##                         w=0.485, h=text.size,gp=gpar(lineheight=1.0,
  ##                                                cex=txt.cex,font=2),
  ##                         name="text.2.vp")

  ##   ## to look at how page is set up:
  ##   ##
  ##    grid.show.viewport(
  ##                        viewport(x=0.515, y=text.size, just=c("left","top"),
  ##                         w=0.485, h=text.size,gp=gpar(lineheight=1.0,
  ##                                                cex=txt.cex,font=2),
  ##                         name="text.2.vp")
  ##                       )


  ## add the title
  pushViewport(title.vp)

  if(!is.null(subset)) {
    maintit <- paste("Summary of run ",object@Runno,
                     ", ",subset,sep="")
  } else {
    maintit <- paste("Summary of run ",object@Runno,sep="")
  }

  title.gp=gpar(cex=1.2,fontface="bold") # title fontsize
  grid.text(maintit,gp=title.gp)

  upViewport()


  ## Add the plots
  if(show.plots){

    ## create plots
    lw <- list(left.padding = list(x = -0.05, units="snpc"))
    lw$right.padding <- list(x = -0.05,units="snpc")
    lh <- list(bottom.padding = list(x = -0.05,units="snpc"))
    lh$top.padding <- list(x = -0.05,units="snpc")


    if(show.ids) plt.id=TRUE else plt.id=FALSE

    ##grid.rect(gp=gpar(col="grey"))
    pushViewport(graph.1.vp)

    ##xplot1 <- dv.vs.pred(object,runsum=TRUE,
    xplot1 <- dv.vs.pred(object,main=NULL,xlb=NULL,ylb=NULL,
                         ##main=list("DV vs PRED",cex=0.00005),
                         aspect="fill",
                         subset=subset,
                         type="b",
                         ids=plt.id,
                         lty=8,
                         abllwd=2,
                         ##xlb=list("",cex=0.00001),ylb=list("",cex=0.00001),
                         cex=0.5,lwd=0.1,
                         scales=list(cex=0.7,tck=c(0.3),y=list(rot=90)),
                         lattice.options = list(layout.widths = lw,
                           layout.heights = lh),
                         ...)

    print(xplot1,newpage=FALSE)
    grid.text("DV vs PRED",x=0.5,y=1,just=c("center","top"),gp=gpar(cex=0.5))
    upViewport()

    pushViewport(graph.2.vp)
    xplot2 <- dv.vs.ipred(object,
                          main=NULL,xlb=NULL,ylb=NULL,
                                        #runsum=TRUE,
                          ##main=list("DV vs PRED",cex=0.00005),
                          aspect="fill",
                          subset=subset,
                          type="b",
                          ids=plt.id,
                          lty=8,
                          abllwd=2,
                          ##xlb=list("",cex=0.00001),
                          ##ylb=list("",cex=0.00001),
                          cex=0.5,lwd=0.1,
                          scales=list(cex=0.7,tck=c(0.3),
                            y=list(rot=90)),
                          lattice.options = list(layout.widths = lw,
                            layout.heights = lh),
                          ...)
    print(xplot2,newpage=FALSE)
    grid.text("DV vs IPRED",x=0.5,y=1,
              just=c("center","top"),
              gp=gpar(cex=0.5))
    upViewport()

    pushViewport(graph.3.vp)
    xplot3 <- absval.iwres.vs.ipred(object,
                                    main=NULL,xlb=NULL,ylb=NULL,
                                    ##runsum=TRUE,
                                    ##main=list("DV vs PRED",cex=0.00005),
                                    aspect="fill",
                                    subset=subset,
                                    ##type="b",
                                    ids=F,
                                    ##lty=8,
                                    ##abllwd=2,
                                    ##xlb=list("",cex=0.00001),
                                    ##ylb=list("",cex=0.00001),
                                    cex=0.5,lwd=0.1,
                                    scales=list(cex=0.7,tck=c(0.3),
                                      y=list(rot=90)),
                                    lattice.options = list(layout.widths = lw,
                                      layout.heights = lh),
                                    ...)
    print(xplot3,newpage=FALSE)
    grid.text("|IWRES| vs IPRED",x=0.5,y=1,
              just=c("center","top"),gp=gpar(cex=0.5))
    upViewport()

    pushViewport(graph.4.vp)
    use.cwres=TRUE
    if(force.wres){
      use.cwres=FALSE
    } else {
      if(is.null(check.vars(c("cwres"),object,silent=TRUE))) {
        use.cwres=FALSE
      }
    }
    if(use.cwres){
      xplot4 <- cwres.vs.idv(object,
                             main=NULL,xlb=NULL,ylb=NULL,
                             ##runsum=TRUE,
                             ##main=list("DV vs PRED",cex=0.00005),
                             aspect="fill",
                             subset=subset,
                             type="b",
                             ids=plt.id,
                             lty=8,
                             abllwd=2,
                             ##xlb=list("",cex=0.00001),
                             ##ylb=list("",cex=0.00001),
                             cex=0.5,lwd=0.1,
                             scales=list(cex=0.7,tck=c(0.3),y=list(rot=90)),
                             lattice.options = list(layout.widths = lw,
                               layout.heights = lh),
                             ...)
      res.txt <- "CWRES"

    }else{
      xplot4 <- wres.vs.idv(object,
                            main=NULL,xlb=NULL,ylb=NULL,
                            ##runsum=TRUE,
                            ##main=list("DV vs PRED",cex=0.00005),
                            aspect="fill",
                            subset=subset,
                            type="b",
                            ids=plt.id,
                            lty=8,
                            abllwd=2,
                            ##xlb=list("",cex=0.00001),
                            ##ylb=list("",cex=0.00001),
                            cex=0.5,lwd=0.1,
                            scales=list(cex=0.7,tck=c(0.3),y=list(rot=90)),
                            lattice.options = list(layout.widths = lw,
                              layout.heights = lh),
                            ...)
      res.txt <- "WRES"
    }
      print(xplot4,newpage=FALSE)
      grid.text(paste(res.txt,"vs",xvardef("idv",object)),
                x=0.5,y=1,
                just=c("center","top"),gp=gpar(cex=0.5))
      upViewport()


    ##       pushViewport(graph.5.vp)
    ##       xplot5 <- dv.preds.vs.idv(object,
    ##                             runsum=TRUE,
    ##                             ##main=list("DV vs PRED",cex=0.00005),
    ##                             aspect="fill",
    ##                             subset=subset,
    ##                             type="b",
    ##                             ids=plt.id,
    ##                             lty=8,
    ##                             abllwd=2,
    ##                             ##xlb=list("",cex=0.00001),ylb=list("",cex=0.00001),
    ##                             cex=0.5,lwd=0.1,
    ##                             #scales=list(cex=0.7,tck=c(0.3),y=list(rot=90)),
    ##                             lattice.options = list(layout.widths = lw, layout.heights = lh),
    ##                             ...)
    ##       print(xplot5,newpage=FALSE)
    ##       grid.text(paste("WRES vs",xvardef("idv",xpdb)),x=0.5,y=1,just=c("center","top"),gp=gpar(cex=0.5))
    ##       upViewport()


  } # end show plots

  ## add text
                                        #text.vp.list <- list(text.1.vp,text.2.vp)
  text.vp.list <- textColumnList
  ystart <- unit(1,"npc")
  vp.num <- 1
  space.avail <- TRUE

  ## Add the termination messages
  
  if(parameter.list$seenterm == 1 && space.avail) {

    termtxt <- parameter.list$term

    txt.marker <- add.grid.text(txt=termtxt,
                                ystart=ystart,
                                vp=text.vp.list,
                                vp.num=vp.num,
                                spaces.before=1,
                                ...)
    ystart <- txt.marker$ystart
    space.avail <- is.null(txt.marker$stop.pt)
    vp.num <- txt.marker$vp.num
  }

  ## Add objective
  if(parameter.list$seenobj == 1 && space.avail) {
    obj.txt <- paste("Objective:",parameter.list$ofv)
    txt.marker <- add.grid.text(txt=obj.txt,
                                ystart=ystart,
                                vp=text.vp.list,
                                vp.num=vp.num,
                                spaces.before=1,
                                ...)
    ystart <- txt.marker$ystart
    space.avail <- is.null(txt.marker$stop.pt)
    vp.num <- txt.marker$vp.num
  }


###############################
  ## Table of parameters and RSEs
################################

  table.txt <- list(parameter.list$parnam,format(parameter.list$parval,digits=3))
  table.col.names <- c("Par","Val")

  have.ses   <- 0
  if(parameter.list$seenseth ==1 || parameter.list$seenseom==1 || parameter.list$seensesi==1) {
    have.ses     <- 1
    table.txt <- list(parameter.list$parnam,format.default(parameter.list$parval,digits=3),parameter.list$separval)
    table.col.names <- c("Par","Val","RSE")
  }

  ##ystart <- unit(3,"lines")
  txt.marker <- add.grid.table(table.txt,
                               col.nams=table.col.names,
                               ystart=ystart,
                               vp=text.vp.list,
                               vp.num=vp.num,
                               ##center.table=TRUE,
                               ##col.optimize=FALSE,
                               ##equal.widths=TRUE,
                               ##mult.col.padding=2,
                               ...)
  ystart <- txt.marker$ystart
  space.avail <- is.null(txt.marker$stop.pt)
  vp.num <- txt.marker$vp.num





  ## Add model file
  if(space.avail) {
    txt.marker <- add.grid.text(txt=modfile,
                                ystart=ystart,
                                vp=text.vp.list,
                                vp.num=vp.num,
                                spaces.before=1,
#                                spaces.before=0,
                                ...)
    ystart <- txt.marker$ystart
    space.avail <- is.null(txt.marker$stop.pt)
    vp.num <- txt.marker$vp.num
  }

  #detach(parameter.list)
  invisible()

                                        #return()

}
