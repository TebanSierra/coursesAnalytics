##################################################
## Project: Course Analytics
## Script purpose: gather information of the courses by EDX 
## Date: Nov 9, 2017
## Version: 0.0.1
## Author: Esteban Sierra Munera
##################################################
options(encoding = "UTF-8") 
library(httr)
library(foreach)

params1 <- "page_size=9&partner=edx&hidden=0&content_type[]=courserun&content_type[]=program&featured_course_ids=course-v1:AdelaideX+Project101x+1T2017,course-v1:Microsoft+DAT222x+4T2017,course-v1:UCSanDiegoX+Parenting101x+2T2017,course-v1:Microsoft+DEV276x+4T2017,course-v1:W3Cx+JS.0x+3T2017,course-v1:IDBx+IDB10.1x+3T2017&featured_programs_uuids=98b7344e-cd44-4a99-9542-09dfdb11d31b,be3e00d2-0680-4771-aea5-1fa0dc8ada2a,482dee71-e4b9-4b42-a47b-3e16bb69e8f2,a015ce08-a727-46c8-92d1-679b23338bc1,8ac6657e-a06a-4a47-aba7-5c86b5811fa1,d220390a-7506-4961-9828-e3594f60a925"

params2 <- strsplit(params1, "&")

params3 <- NULL
k <- 1
foreach(i = 1:length(params2[[1]])) %do% {
  paramsAux <- strsplit(params2[[1]][i], "=")
  params3[[k]] <- paramsAux[[1]][2]
  k <- k+1
}


page <- 1
r <- GET("https://www.edx.org/api/v1/catalog/search", query = list('page'=page, 'page_size'=params3[[1]], 'partner'=params3[[2]], 
                                                                    'hidden'=params3[[3]], "content_type[]"=params3[[4]], 
                                                                    'content_type[]'=params3[[5]], 'featured_course_ids'= params3[[6]], 
                                                                    'featured_programs_uuids'=params3[[7]]))
courses2 <- NULL

while(status_code(r) != 404) {
  
  r <- GET("https://www.edx.org/api/v1/catalog/search", query = list('page'=page, 'page_size'=params3[[1]], 'partner'=params3[[2]], 
                                                                      'hidden'=params3[[3]], 'content_type[]'=params3[[4]], 
                                                                      'content_type[]'=params3[[5]], 'featured_course_ids'= params3[[6]], 
                                                                      'featured_programs_uuids'=params3[[7]]))

  Sys.sleep(1.5)
  
  if (status_code(r) == 200) {
    data <- content(r)
    courses <- data$objects$results
    
    foreach(i = 1:length(courses)) %do% {
      courses2 <- rbind(courses2, c(courses[[i]]$title,
                                    gsub("[[:punct:]]", " ",courses[[i]]$org),
                                    gsub("[[:punct:]]", " ",courses[[i]]$language),
                                    gsub("[[:punct:]]", " ",courses[[i]]$weeks_to_complete),
                                    gsub("[[:punct:]]", " ",courses[[i]]$min_effort),
                                    gsub("[[:punct:]]", " ",courses[[i]]$max_effort)))
      
    }
    
    page <- page + 1
  }
}

colnames(courses2) <- colnames(courses2, do.NULL = FALSE)
colnames(courses2) <-c("Course Title", "Author Org", "Language", "Time to Complete (Weeks)", "Min hours per Week", "Max hours per Week")
