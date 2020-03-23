#!/usr/bin/env Rscript

packages.to.install <- c("plyr",
                         "grid",
                         "getopt",
                         "proto",
                         "gridExtra",
                         "ggplot2",
                         "scales")

for(p in packages.to.install) {
    print(p)
    if (suppressWarnings(!require(p, character.only = TRUE))) {
        install.packages(p, repos = "http://lib.stat.cmu.edu/R/CRAN")
        library(p, character.only=TRUE)
    }
}

df <- read.csv("./dynamic_thr/vary_sites_90pp.csv")
# Manually reorder protocols
df$protocol <- factor(df$protocol, levels=c("ser", "psi", "rc"))

x_format <- function(x) {
    return(paste(format(x), "Sites", sep=" "))
}

y_format_thousand_comma <- function(x) {
    return(format(x/1000, big.mark = ",", scientific = FALSE))
}

y_seq <- seq(0, 2000000, by=100000)

# If using legend, use these colors
ser_color <- "#1C5BD0"
psi_color <- "#DA5F6D"
rc_color <- "#30A84F"

# Otherwise, use grayscale?
ser_color <- "#B3B3B3"
psi_color <- "#6E6E6E"
rc_color <- "#323232"

df_mapping <- aes(x=throughput, y=latency)
legend_title <- "" # No title
legend_breaks <- c("ser", "psi", "rc")
legend_labels <- c("naiveSER", "fastPSI", "naiveRC")
legend_values <- c(ser_color, psi_color, rc_color)

d <- ggplot(df) +
    # # Assign colors, shapes and lines to each grouping
    aes(x=sites, y=throughput, fill=protocol) +

    geom_bar(width=0.8, position="dodge2", stat="identity") +

    scale_x_continuous(breaks=1:3,
                       labels=x_format,
                       sec.axis=dup_axis(name=NULL, labels=NULL)) +

    scale_y_continuous(breaks=y_seq,
                       labels=y_format_thousand_comma,
                       expand=c(0,0), # Force at zero
                       sec.axis=dup_axis(name=NULL, labels=NULL)) +

    scale_fill_manual(name=legend_title,
                      breaks=legend_breaks,
                      labels=legend_labels,
                      values=legend_values) +

    coord_cartesian(ylim=c(0,1150000)) +

    labs(title = "Workload B with 90% Read-only Transactions",
         x = "",
         y = "Throughput (Ktps)") +

    theme_minimal(base_size=10) +

    theme(plot.title =      element_text(size=12, margin=margin(10,0,10,0), hjust=0.5),

          axis.title.x = element_text(size=12, margin=margin(10,0,10,0)),
          axis.title.y = element_text(size=10, margin=margin(0,0,0,10)),
          axis.text.x =  element_text(size=9, margin=margin(40,0,-20,0)),
          axis.text.y =  element_text(size=9, margin=margin(0,8,0,3)),
          axis.line =    element_line(color="black", size=0.5),
          axis.ticks.y =   element_line(color="black"),

          strip.text.x =    element_text(size=12),
          strip.placement = "outside",

          axis.ticks.length = unit(-2.75, "pt"),

          panel.grid.minor.y = element_line(colour="#EBEBEB", size=0.5),
          panel.grid.major.y = element_line(colour="#EBEBEB", size=0.5),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.spacing =    unit(1, "lines"),

        #   Remove legend, we'll do it with annotations
          legend.position = "none"
        #   Or maybe not?
        #   legend.spacing =        unit(-0.2, "cm"),
        #   legend.position =       c(0.3, 0.9),
        #   legend.direction =      "horizontal",
        #   legend.title =          element_text(size=6),
        #   legend.text =           element_text(size=6),
        #   legend.box.just =       "left",
        #   legend.box.background = element_rect(color="white", fill="white")
          )


easy_annotation <- function(text, x, y) {
    return(annotation_custom(grob=text, xmin=x, xmax=x, ymin=y, ymax=y))
}

ann_color <- "#4D4D4D"
ser_ann <- textGrob(label="naiveSER", rot=-45, gp=gpar(fontsize=7, col=ann_color))
psi_ann <- textGrob(label="fastPSI", rot=-45, gp=gpar(fontsize=7, col=ann_color))
rc_ann <- textGrob(label="naiveRC", rot=-45, gp=gpar(fontsize=7, col=ann_color))
y_level <- -100000
# EW
d <- d +
    easy_annotation(text=ser_ann, x=0.825, y_level) +
    easy_annotation(text=ser_ann, x=1.825,y_level) +
    easy_annotation(text=ser_ann, x=2.825,y_level) +
    easy_annotation(text=psi_ann, x=1.07, y_level) +
    easy_annotation(text=psi_ann, x=2.07, y_level) +
    easy_annotation(text=psi_ann, x=3.07, y_level) +
    easy_annotation(text=rc_ann, x=1.35, y_level) +
    easy_annotation(text=rc_ann, x=2.35, y_level) +
    easy_annotation(text=rc_ann, x=3.35, y_level)

gt <- ggplot_gtable(ggplot_build(d))
gt$layout$clip[gt$layout$name == "panel"] <- "off"

ggsave(filename = "sites_bench.pdf",
       plot = gt,
       device = "pdf",
       width = 5,
       height = 4,
       dpi = 600)