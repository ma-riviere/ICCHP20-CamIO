project_packages <- c()

"%ni%" <- Negate("%in%")

options(install.packages.check.source = "no")

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
    library(pkg_name, character.only = TRUE)
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
          remotes::install_github(pkg)
        } else {
          install.packages(pkg, character.only = TRUE, type = "binary")
        }
      
    }
    activate_package(pkg)
  }
  renv::snapshot(type="all", prompt=F)
  #knitr::write_bib(c(.packages(), project_packages), here::here("res/bib", "packages.bib"))
}

update_packages(c("knitr", "renv", "here", "glue", "styler", "remotes"))

# ----------------------------------------------------------------------------