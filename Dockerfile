# R with the dataProfilerR package preinstalled.
#
# Run:  docker run --rm -it ghcr.io/mqfarooqi1/dataProfilerR
FROM rocker/r-ver:4.5.2

LABEL org.opencontainers.image.title="dataProfilerR"
LABEL org.opencontainers.image.description="R with dataProfilerR preinstalled: automated exploratory data analysis and dataset profiling."
LABEL org.opencontainers.image.source="https://github.com/mqfarooqi1/dataProfilerR"
LABEL org.opencontainers.image.licenses="MIT"

RUN Rscript -e 'install.packages(c("ggplot2","nortest"), repos = "https://cloud.r-project.org")'

COPY . /build/dataProfilerR
RUN R CMD INSTALL --clean /build/dataProfilerR && rm -rf /build
RUN Rscript -e 'library(dataProfilerR); cat("dataProfilerR installed\n")'

WORKDIR /work
CMD ["R"]
