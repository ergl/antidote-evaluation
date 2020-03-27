#!/usr/bin/env Rscript

packages.to.install <- c("lemon",
                         "plyr",
                         "grid",
                         "getopt",
                         "proto",
                         "ggplot2",
                         "scales")

for(p in packages.to.install) {
    print(p)
    if (suppressWarnings(!require(p, character.only = TRUE))) {
        install.packages(p, repos = "http://lib.stat.cmu.edu/R/CRAN")
        library(p, character.only=TRUE)
    }
}

df <- read.csv("../../general/general.csv")

x_format_thousand_comma <- function(x) {
    return(format(x/1000, big.mark = ",", scientific = FALSE))
}

y_format_thousand_comma <- function(x) {
    return(format(x, big.mark = ",", scientific = FALSE))
}

x_seq <- seq(0, 2500000, by=250000)
y_seq <- seq(0, 50, by=5)


# Fancy colors
psi_color <- "#F2818F"
ser_color <- "#1C5BD0"
rc_color <- "#4DE481"
# Grayscale colors
# rc_color <- "#323232"
# psi_color <- "#6E6E6E"
# ser_color <- "#B3B3B3"
df_mapping <- aes(x=throughput, y=latency)
legend_title <- "" # No title
legend_breaks <- c("ser", "psi", "rc")
legend_labels <- c("naiveSER", "fastPSI", "naiveRC")
legend_values <- c(ser_color, psi_color, rc_color)

d <- ggplot(df) +
    # Assign colors, shapes and lines to each grouping
    aes(x=throughput, y=latency,
        color=protocol, shape=protocol, linetype=protocol) +

    geom_point(size=2.5) + geom_line() +

    scale_x_continuous(breaks=x_seq,
                       labels=x_format_thousand_comma, # Format as Ktps, with comma
                       expand=c(0,0), # Force at zero
                       sec.axis=dup_axis(name=NULL, labels=NULL)) + # Dup axis with no text

    scale_y_continuous(breaks=y_seq,
                       labels=y_format_thousand_comma,
                       expand=c(0,0), # Force at zero
                       sec.axis=dup_axis(name=NULL, labels=NULL)) + # Dup axis with no text


    # For some reason, we need to specify this for _every_ mapping, ugh.
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

    coord_cartesian(xlim=c(0,2150000), ylim=c(0,25)) +

    # Place side by side, grouped by update %, from the `lemon` package,
    # allows to put the text on top of duplicated X-axis
    facet_rep_wrap(~updates, ncol=3, scales="free", labeller=labeller(
        updates = c(
            `10` = "90% Read-only Transactions",
            `20` = "80% Read-only Transactions",
            `30` = "70% Read-only Transactions")
    )) +

    labs(title = "Workload C on 3 sites",
         x = "Throughput (Ktps)",
         y = "Termination Latency of Updt. txn (ms)") +

    theme_minimal(base_size=10) +

    theme(plot.title =      element_text(size=13, margin=margin(10,0,10,0), hjust=0.5),
          plot.margin = margin(0,10,0,0),

          axis.title.x = element_text(size=12, margin=margin(10,0,10,0)),
          axis.title.y = element_text(size=12, margin=margin(0,10,0,10)),
          axis.text.x =  element_text(size=9, margin=margin(10,0,0,0)),
          axis.text.y =  element_text(size=9, margin=margin(0,8,0,10)),
          axis.line =    element_line(color="black", size=0.5),
          axis.ticks =   element_line(color="black"),

          strip.text.x =    element_text(size=12),
          strip.placement = "outside",

          axis.ticks.length = unit(-2.75, "pt"),

          panel.grid.minor = element_line(colour="#EBEBEB", size=0.25),
          panel.grid.major = element_line(colour="#EBEBEB", size=0.25),
          panel.spacing =    unit(1, "lines"),

          legend.spacing =        unit(-0.2, "cm"),
          legend.position =       c(0.17, 0.15),
          legend.direction =      "horizontal",
          legend.title =          element_text(size=9),
          legend.text =           element_text(size=9),
          legend.box.just =       "left",
          legend.box.background = element_rect(color="white", fill="white"))

ggsave(filename = "./out/general_bench.pdf",
       plot = d,
       device = "pdf",
       width = 12,
       height = 3.5,
       dpi = 600)