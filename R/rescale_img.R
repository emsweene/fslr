#' @title Image Rescaler
#' @name rescale_img
#' @param filename filename of image to be read into R or nifti object 
#' @param pngname filename of png of histogram of values of image to be made. For no
#' png - set to NULL (default)
#' @param write.nii logical - should the image be written.  
#' filename must be character if this is TRUE (default)
#' @param min.val minimum value of image (default -1024 (for CT)).  If no thresholding
#' set to -Inf
#' @param max.val maximum value of image (default 3071 (for CT)).  If no thresholding
#' set to Inf
#' @param ROIformat if TRUE, any values $< 0$ will be set to 0
#' @param writer character value to add to description slot of NIfTI header
#' @param ... extra methods to be passed to \code{\link{writeNIfTI}}
#' @description Rescales an image to be in certain value range.  This was created
#' as sometimes DICOM scale and slope parameters may be inconsistent across sites
#' and the data need to be value restricted
#' @return Object of class nifti
#' @export
rescale_img = function(filename, 
                       pngname = NULL, 
                       write.nii = TRUE,
                       min.val = -1024,
                       max.val = 3071,
                       ROIformat=FALSE, 
                       writer= "dcm2nii", ...){
  
  img = check_nifti(filename)
    # inter = as.numeric(img@scl_inter)
  # slope = as.numeric(img@scl_slope)
  # img = (img * slope + inter)
  img[img < min.val] = min.val
  img[img > max.val] = max.val
  img = zero_trans(img)
  if (ROIformat) img[img < 0] = 0
  img = cal_img(img)
  img@descrip = paste0("written by ", writer, " - ", img@descrip)
  
  #### create histograms
  if (!is.null(pngname)){
    options(bitmapType = 'cairo') 
    print(pngname)
    ### remove random percents
    pngname = gsub("%", "", pngname)
    png(pngname)
    hist(img)
    dev.off()
  }
  filename = nii.stub(filename)
  
  if (write.nii) {
    writeNIfTI(img, file=filename, ...)
  }
  return(img)
}




#' @title Change Data type for img
#' @return object of type nifti
#' @param img nifti object (or character of filename)
#' @param datatype (NULL) character of datatype see 
#' \code{\link{convert.datatype}}
#' @param bitpix (NULL) character of bitpix see 
#' \code{\link{convert.bitpix}} 
#' @param trybyte (logical) Should you try to make a byte (UINT8) if image in
#' c(0, 1)?
#' @description Tries to figure out the correct datatype for image.  Useful 
#' for image masks - makes them binary if
#' @name datatype
#' @export
datatype = function(img, datatype=NULL, bitpix=NULL, trybyte=TRUE){
  img = check_nifti(img)
  if (!is.null(datatype) & !is.null(bitpix)){
    img@datatype <- datatype
    img@bitpix <- bitpix
  }
  if (!is.null(datatype) & is.null(bitpix)){
    stop("Both bitipx and datatype need to be specified if oneis")
  }
  if (is.null(datatype) & !is.null(bitpix)){
    stop("Both bitipx and datatype need to be specified if oneis")
  }
  #### logical - sign to unsigned int 8
  is.log = inherits(img@.Data[1], "logical")
  if (is.log){
    img@datatype <- convert.datatype()$UINT8
    img@bitpix <- convert.bitpix()$UINT8
    return(img)
  }
  #### testing for integers
  testInteger <- function(img){
    x = c(img@.Data)
    test <- all.equal(x, as.integer(x), check.attributes = FALSE)
    return(isTRUE(test))
  }  
  is.int = testInteger(img)
  if (is.int){
    rr = range(img, na.rm=TRUE)
    ##### does this just for binary mask
    if (all(rr == c(0, 1)) & trybyte){
      if (all(img %in% c(0, 1))){
          img@datatype <- convert.datatype()$UINT8
          img@bitpix <- convert.bitpix()$UINT8
          return(img)
      }
    }
    signed= FALSE
    if (any(rr) < 0){
      signed = TRUE
    }
    trange = diff(rr)
    num = 8
    if (trange > 255) num = 16
    if (trange > 65535) num = 32
    if (trange > 4294967295) num = 64
    mystr= "INT"
    if (!signed) mystr = paste0("U", mystr)
    mystr = paste0(mystr, num)
    img@datatype <- convert.datatype()[[mystr]]
    img@bitpix <- convert.bitpix()[[mystr]]
    return(img)
  } else {
    warning("Assuming FLOAT32")
    mystr= "FLOAT32"
    img@datatype <- convert.datatype()[[mystr]]
    img@bitpix <- convert.bitpix()[[mystr]]
    return(img)
  }
}



#' @title Resets image parameters for a copied nifti object
#' @return object of type nifti
#' @param img nifti object (or character of filename)
#' @param ... arguments to be passed to \code{\link{datatype}}
#' @description Resets the slots of a nifti object, usually because an image
#' was loaded, then copied and filled in with new data instead of making a 
#' nifti object from scratch.  Just a wrapper for smaller functions 
#' @export
newnii = function(img, ...){
  img = check_nifti(img)
  img = zero_trans(img)
  img = cal_img(img)
  img = datatype(img, ...)
  return(img)
}


#' @title Check if nifti image or read in
#' @import oro.nifti
#' @description Simple check to see if input is character or of class nifti
#' @return nifti object
#' @seealso \link{readNIfTI}
#' @param x character path of image or 
#' an object of class nifti
#' @param reorient (logical) passed to \code{\link{readNIfTI}} if the image
#' is to be re-oriented
#' @export
check_nifti = function(x, reorient=FALSE){
  if (inherits(x, "character")) {
    img = readNIfTI(x, reorient=reorient)
  } else {
    if (inherits(x, "nifti")){
      img = x
    } else {
      stop("x has unknown class - not char or nifti")
    }
  }
  return(img)
}