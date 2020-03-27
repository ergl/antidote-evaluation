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

df <- read.csv("../../dynamic_thr/dynamic_bench.csv")

sites_format <- function(x) {
    return(paste(format(x), "Sites", sep=" "))
}

workload_format <- function(x) {
    return(format(x/100))
}

# If using legend, use these colors
# ser_color <- "#1C5BD0"
# psi_color <- "#DA5F6D"
# rc_color <- "#30A84F"
psi_color <- "#F2818F"
ser_color <- "#1C5BD0"
rc_color <- "#4DE481"

legend_title <- "" # No title
legend_breaks <- c("ser", "psi", "rc")
legend_labels <- c("naiveSER", "fastPSI", "naiveRC")
legend_values <- c(ser_color, psi_color, rc_color)

df_sites <- df[df$workload == "b_sites", ]
df_sites_rc <- df_sites[df_sites$protocol == "rc", ]
df_sites_normalized <- df_sites
# Match the row ids of df_sites_rc correspoding to df_sites$sites
# i.e., which rows in df_sites_rc should we divide by
# Then, denoms is an array of throughputs to map into
site_denoms <- df_sites_rc[match(df_sites$sites, df_sites_rc$site), ]$throughput
df_sites_normalized$throughput <- df_sites$throughput / site_denoms

df_workload <- df[df$workload == "b", ]
df_workload <- df_workload[df_workload$updates %in% c("10", "20", "30"), ]
df_workload_rc <- df_workload[df_workload$protocol == "rc", ]
df_workload_normalized <- df_workload
workload_denoms <- df_workload_rc[match(df_workload$updates, df_workload_rc$updates), ]$throughput
df_workload_normalized$throughput <- df_workload$throughput / workload_denoms

modify_sites_plot <- ggplot(df_sites_normalized) +
    aes(x=sites, y=throughput, color=protocol, shape=protocol, linetype=protocol) +

    geom_vline(xintercept=3, size=1, color="#807F80") +
    geom_point(size=2.5) + geom_line() +

    scale_x_continuous(breaks=1:3,
                       labels=sites_format) +


    scale_y_log10() +

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


    labs(x = "Number of Sites") +

    theme_minimal(base_size=10) +

    theme(plot.title =      element_blank(),
          plot.margin = margin(10,10,0,0),
          axis.title.x = element_text(size=10, margin=margin(10,0,10,0)),
          axis.title.y = element_blank(),
          axis.text.x =  element_text(color="black", size=9, margin=margin(5,0,0,0)),
          axis.text.y =  element_text(color="black", size=9, margin=margin(0,5,0,10)),
          axis.line =    element_line(color="black", size=0.5),
          axis.ticks =   element_line(color="black"),

          strip.text.x =    element_text(size=12),
          strip.placement = "outside",

          axis.ticks.length = unit(-1.5, "pt"),

          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_line(colour="#EBEBEB", size=0.5),
          panel.grid.major = element_line(colour="#EBEBEB", size=0.5),
          panel.spacing =    unit(1, "lines"),

          legend.position = "bottom",
          legend.direction =      "horizontal",
          legend.title =          element_text(size=7),
          legend.text =           element_text(size=7),
          legend.box.background = element_rect(color="white", fill="white")
          )

modify_workload_plot <- ggplot(df_workload_normalized) +
    aes(x=updates, y=throughput, color=protocol, shape=protocol, linetype=protocol) +
    geom_vline(xintercept=10, size=1, color="#807F80") +
    geom_point(size=2.5) + geom_line() +

    scale_x_continuous(breaks=seq(10,30,by=10),
                       labels=workload_format) +

    scale_y_log10() +

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

    labs(x = "Update Transaction Fraction") +

    theme_minimal(base_size=10) +

    theme(plot.title =      element_blank(),
          plot.margin = margin(0,10,0,0),

          axis.title.x = element_text(size=10, margin=margin(10,0,10,0)),
          axis.title.y = element_blank(),
          axis.text.x =  element_text(color="black", size=9, margin=margin(5,0,0,0)),
          axis.text.y =  element_text(color="black", size=9, margin=margin(0,5,0,10)),
          axis.line =    element_line(color="black", size=0.5),
          axis.ticks =   element_line(color="black"),

          strip.text.x =    element_text(size=12),
          strip.placement = "outside",

          axis.ticks.length = unit(-1.5, "pt"),

          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_line(colour="#EBEBEB", size=0.5),
          panel.grid.major = element_line(colour="#EBEBEB", size=0.5),
          panel.spacing =    unit(1, "lines"),
          legend.position = "none")

get_legend <- function(arg_plot) {
    tmp <- ggplot_gtable(ggplot_build(arg_plot))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    return(legend)
}

combined_legend <- get_legend(modify_sites_plot)

combined <- grid.arrange(combined_legend,
                         arrangeGrob(modify_sites_plot + theme(legend.position = "none"),
                                     modify_workload_plot,
                                     nrow=2,
                                     left = textGrob("Throughput (normalized)", rot = 90, vjust=1,
                                                     gp=gpar(fontsize=10))),
                         nrow=2,
                         heights=c(1,10))

ggsave(filename = "./out/dynamic_bench.pdf",
       plot = combined,
       device = "pdf",
       width = 5,
       height = 5,
       dpi = 600)