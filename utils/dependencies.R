#########################
# Managing dependencies #
#########################

set.github_pat <- function(env.var) {
  github.pat <- Sys.getenv(env.var)
  if (github.pat != "") {
    print(paste("[INFO] Found GITHUB Access Token: ", github.pat))
    GITHUB_PAT <- github.pat
  }
}

set.install_type <- function() {
  sys.name <- Sys.info()[["sysname"]]
  if (sys.name == "Windows") {
    print("[INFO] Windows detected, installing packages as 'binary'")
    options(install.packages.check.source = "no")
    return("binary")
  } else if (sys.name == "Linux") {
    print("[INFO] Linux detected, installing packages as 'source'")
    options(install.packages.check.source = "yes")
    return("source")
  } else {
    print("[INFO] No install type setup for your system, using 'source' as default")
    options(install.packages.check.source = "yes")
    return("source")
  }
}

set.github_pat("GITHUB_PAT_R_INSTALL")
pkg.install.type <- set.install_type()

"%ni%" <- Negate("%in%")

Sys.setenv(MAKEFLAGS = "-j4")

# -------------------------------------------

project_packages <- c()

get_pkg_name <- function(pkg) {
  pkg_name <- pkg
  if (grepl("/", pkg, fixed = TRUE)) {
    pkg_path <- stringr::str_split(pkg, "/")[[1]]
    pkg_name <- pkg_path[length(pkg_path)]
  }
  return(pkg_name)
}

activate_packages <- function() {
  for (pkg in project_packages) {
    activate_package(pkg)
  }
}

activate_package <- function(pkg) {
  pkg_name <- get_pkg_name(pkg)
  if (pkg_name %in% installed.packages()) {
    library(pkg_name, character.only = TRUE, quiet=TRUE)
  }
}

update_packages <- function(pkgs) {
  for (pkg in pkgs) {
    if(pkg %ni% project_packages) {
      project_packages <<- c(project_packages, pkg)
    }
  }
  
  
  for (pkg in project_packages) {
    
    pkg_name <- get_pkg_name(pkg)
    
    if(!(pkg_name %in% installed.packages())) {
      if(grepl("/", pkg, fixed=TRUE)) {
        remotes::install_github(pkg, upgrade = "never", quiet = TRUE)
      } else {
        install.packages(pkg, character.only = TRUE, type = pkg.install.type, quiet = TRUE, verbose = FALSE)
      }
      
    }
    activate_package(pkg)
  }
  renv::snapshot(type="all", prompt=F)
  #knitr::write_bib(c(.packages(), project_packages), here::here("res/bib", "packages.bib"))
}

update_packages(c("knitr", "renv", "here", "glue", "styler", "remotes")) 

# ----------------------------------------------------------------------------