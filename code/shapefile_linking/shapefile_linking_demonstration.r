
library(sf)   # library for handling shapefiles
library(rgdal)# 
library(raster) # for handling rasters - note that there is a newer "terra"
library(tidyverse) 
library(readxl) # for import of .xlsx files
library(ggspatial)
library(gridExtra)

# define PROJ4 string for the two projections that may come handy
WGS84 <- "+proj=longlat +datum=WGS84 +no_defs "
KROVAK <- "+proj=krovak +lat_0=49.5 +lon_0=24.8333333333333 +alpha=30.2881397527778 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +towgs84=589,76,480,0,0,0,0 +units=m +no_defs" 

# ------------------------------------------------------------------------------

# read CZ boundary shapefile 
cz <- st_read("../../CZ_border_shapefile/CZE_adm0.shp")

# transform cz boundary from WGS84 to KROVAK
cz <- st_transform(cz, crs=KROVAK)

# read the data shapefile
pls <- st_read("../../SPARSE_shapefiles/SPARSE CZ birds pg.shp",
               fid_column_name = "shapefileFID")

# read the points
pts <- st_read("../../SPARSE_shapefiles/SPARSE CZ birds p.shp",
               fid_column_name = "shapefileFID")
plot(pts)

# read the lines
lns <- st_read("../../SPARSE_shapefiles/SPARSE CZ birds l.shp",
               fid_column_name = "shapefileFID")
plot(lns)

# plot the shapefiles
fig_sites <- ggplot() + 
        geom_sf(data = cz, lwd = 0.5) + 
        geom_sf(data = pls, fill = "black", lwd = 1, colour = "black") + 
        geom_sf(data = lns, colour = "black", lwd = 1) + 
        geom_sf(data = pts, colour = "black",  lwd = 1) +
        theme_minimal() +
        annotation_scale() + labs(title = "(a)")
fig_sites

# read the .csv from sparse
dat <- read.csv(file="Q1 static species richness.csv",
                fileEncoding="UTF-8-BOM")
sum(duplicated(dat$shapefileFID))
which(duplicated(dat$shapefileFID))

summary(dat)
head(dat)


# keep only polygons (1) and remove points (3) and transects (2)
dat <- dat[dat$siteShapeID == 1, ]


# histogram of area
fig_A_hist <- ggplot(data = dat, aes(x = totalAreaSampledInSquareKilometers)) + 
  geom_histogram(fill="grey", colour = "black") +
  xlab("Area [km^2]") + ylab("Count") +
  scale_x_log10() +
  theme_minimal() + labs(title = "(b)")
fig_A_hist



# check for duplicated values
sum(duplicated(dat$shapefileFID))
which(duplicated(dat$shapefileFID))


# histogram of species richness
fig_S_hist <- ggplot(data = dat, aes(x = verbatimIdentificationPerSite_Count)) + 
  geom_histogram(fill="grey", colour = "black") +
  xlab("# of Species") + ylab("Count") +
  theme_minimal() + labs(title = "(c)")
fig_S_hist

# species-area relationship
fig_SAR <- ggplot(data = dat, aes(x = totalAreaSampledInSquareKilometers,
                                  y = verbatimIdentificationPerSite_Count)) + 
  geom_point(shape = 1) +  
  scale_x_log10() +        # x axis is logarithmic
  scale_y_log10() +        # y axis is logarithmic
  #annotation_logticks() +  # show logarithmic tickmarks
  geom_smooth(method=lm, colour = "black") + # show linear regression
  xlab("Area [km^2]") + ylab("# of Species") +
  theme_minimal() + labs(title = "(d)")
fig_SAR

png(filename="Fig2.png", res= 250, width = 2400, height= 1600)
grid.arrange(fig_sites, fig_A_hist, fig_S_hist, fig_SAR)
dev.off()

# ------------------------------------------------------------------------------
# Events in time

evnt <- read_csv("3_EVENT.csv")
evnt <- data.frame(evnt, timeSpan = evnt$endYear-evnt$startYear + 1)

fig_time <- ggplot(evnt, aes(x = startYear)) + 
            geom_rect(xmin=1973, xmax=1977, ymin=0, ymax=Inf, fill = "#a6cee3") + 
            geom_rect(xmin=1985, xmax=1989, ymin=0, ymax=Inf, fill = "#a6cee3") + 
            geom_rect(xmin=2001, xmax=2003, ymin=0, ymax=Inf, fill = "#a6cee3") + 
            geom_rect(xmin=2014, xmax=2017, ymin=0, ymax=Inf, fill = "#a6cee3") + 
            geom_histogram(bins = 100, fill="grey", colour = "black") +
            xlim(c(1950, 2020)) +
            scale_y_log10() +
            xlab("Year")+ ylab("Count") +
            theme_minimal() + labs(title = "(a)")
fig_time

# Histogram of temporal durations of events
fig_timespan <- ggplot(evnt, aes(x = timeSpan)) +
                geom_histogram(fill="grey", colour = "black") +
                scale_x_log10() + 
                scale_y_log10() + 
                xlab("# of years") + ylab("Count") +
                theme_minimal() + labs(title = "(b)")
fig_timespan

png(filename="Fig3.png", res= 250, width = 2400, height= 800)
grid.arrange(fig_time, fig_timespan, nrow=1, ncol=2, widths = c(2,1))
dev.off()
