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

# If using legend, use these colors
psi_color <- "#F2818F"
ser_color <- "#1C5BD0"
rc_color <- "#4DE481"

# Otherwise, use grayscale?
# rc_color <- "#323232"
# psi_color <- "#6E6E6E"
# ser_color <- "#B3B3B3"

legend_title <- "" # No title
legend_breaks <- c("ser", "psi", "rc")
legend_labels <- c("naiveSER", "fastPSI", "naiveRC")
legend_values <- c(ser_color, psi_color, rc_color)

sites_format <- function(x) {
    return(paste(format(x), "Sites", sep=" "))
}

comma_thousand_format <- function(x) {
    return(comma_format(x/1000))
}

comma_format <- function(x) {
    return(format(x, big.mark = ",", scientific = FALSE))
}

easy_annotation <- function(text, x, y) {
    return(annotation_custom(grob=text, xmin=x, xmax=x, ymin=y, ymax=y))
}

sites_as_bar <- function(df) {
    df$protocol <- factor(df$protocol, levels=c("ser", "psi", "rc"))
    d <- ggplot(df) +
        aes(x=sites, y=throughput, fill=protocol) +

        geom_bar(colour="black", size=0.25, width=0.8, position="dodge2", stat="identity") +

        scale_x_continuous(breaks=1:3,
                        labels=sites_format,
                        sec.axis=dup_axis(name=NULL, labels=NULL)) +

        scale_y_continuous(breaks=seq(0, 2000000, by=100000),
                        labels=comma_thousand_format,
                        expand=c(0,0), # Force at zero
                        sec.axis=dup_axis(name=NULL, labels=NULL)) +

        scale_fill_manual(name=legend_title,
                        breaks=legend_breaks,
                        labels=legend_labels,
                        values=legend_values) +

        coord_cartesian(ylim=c(0,1150000)) +

        labs(title = "Workload B with 90% Read-only Transactions",
            y = "Throughput (Ktps)") +

        theme_minimal(base_size=10) +

        theme(plot.title = element_text(size=12, margin=margin(10,0,10,0), hjust=0.5),
            plot.margin = margin(0,10,0,0),
            axis.title.x = element_text(size=12, margin=margin(10,0,10,0)),
            axis.title.y = element_text(size=10, margin=margin(0,0,0,10)),
            axis.text.x = element_text(color="black", size=9, margin=margin(40,0,-20,0)),
            axis.text.y = element_text(color="black", size=9, margin=margin(0,8,0,3)),
            axis.line = element_line(color="black", size=0.5),
            axis.ticks.y = element_line(color="black"),
            strip.text.x = element_text(size=12),
            strip.placement = "outside",
            axis.ticks.length = unit(-2.75, "pt"),
            panel.grid.minor.y = element_line(colour="#EBEBEB", size=0.5),
            panel.grid.major.y = element_line(colour="#EBEBEB", size=0.5),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.x = element_blank(),
            panel.spacing =    unit(1, "lines"),
            legend.position = "none")

    ann_color <- "black"
    ser_ann <- textGrob(label="naiveSER", rot=-45, gp=gpar(fontsize=7, col=ann_color))
    psi_ann <- textGrob(label="fastPSI", rot=-45, gp=gpar(fontsize=7, col=ann_color))
    rc_ann <- textGrob(label="naiveRC", rot=-45, gp=gpar(fontsize=7, col=ann_color))
    y_level <- -100000

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

    # Remove clipping to show annotations

    gt <- ggplot_gtable(ggplot_build(d))
    gt$layout$clip[gt$layout$name == "panel"] <- "off"
    return(gt)
}

sites_as_lines <- function(df) {
    d <- ggplot(df,
                aes(x=factor(sites),
                    y=throughput,
                    linetype=protocol,
                    shape=protocol,
                    group=protocol,
                    color=protocol)) +

        geom_point(size=3) + geom_line() +

        scale_x_discrete(expand=c(0.05,0.05), labels=sites_format) +

        scale_y_log10(breaks=c(10000, 25000, 50000, 100000, 250000, 500000, 750000, 1000000, 1250000),
                      limits=c(10000, 1050000),
                      labels=comma_thousand_format) +

        scale_colour_manual(name=legend_title,
                        breaks=legend_breaks,
                        labels=legend_labels,
                        values=legend_values) +

        scale_shape_discrete(name=legend_title,
                             breaks=legend_breaks,
                             labels=legend_labels) +

        scale_linetype_discrete(name=legend_title,
                                breaks=legend_breaks,
                                labels=legend_labels) +

        labs(title = "Workload B, 90% read-only transactions",
             y = "Throughput (Ktps) (log)") +

        theme_minimal(base_size=10) +

        theme(plot.title = element_text(size=12, margin=margin(10,0,10,0), hjust=1),
              plot.margin = margin(0,20,0,0),
              axis.title.x = element_blank(),
              axis.title.y = element_text(size=10, margin=margin(0,5,0,15)),
              axis.text.x = element_text(color="black", size=9, margin=margin(8,0,-10,0)),
              axis.text.y = element_text(color="black", size=9, margin=margin(0,8,0,0)),
              axis.line = element_line(color="black", size=0.5),
              axis.ticks = element_line(color="black"),
              strip.text.x = element_text(size=12),
              strip.placement = "outside",
              axis.ticks.length = unit(-2.75, "pt"),
              panel.grid.minor.y = element_line(colour="#EBEBEB", size=0.5),
              panel.grid.major.y = element_line(colour="#EBEBEB", size=0.5),
              panel.grid.minor.x = element_blank(),
              panel.grid.major.x = element_line(colour="#EBEBEB", size=0.5),
              legend.position = "bottom",
              legend.direction = "horizontal",
              legend.title = element_text(size=6),
              legend.text = element_text(size=6),
              legend.box.background = element_rect(color="white", fill="white"))

    return(d)
}

df <- read.csv("../../dynamic_thr/vary_sites_90pp.csv")
d <- sites_as_lines(df)


ggsave(filename = "./out/sites_bench.pdf",
       plot = d,
       device = "pdf",
       width = 4.5,
       height = 3.5,
       dpi = 600)
