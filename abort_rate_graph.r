#!/usr/bin/env Rscript

packages.to.install <- c("grid", "ggplot2")
for(p in packages.to.install) {
    print(p)
    if (suppressWarnings(!require(p, character.only = TRUE))) {
        install.packages(p, repos = "http://lib.stat.cmu.edu/R/CRAN")
        library(p, character.only=TRUE)
    }
}

df <- read.csv("./read_aborts/abort_comparison.csv")
df <- df[df$workload == "e", ]
df$protocol_numeric[df$protocol == "ser"] <- 0
df$protocol_numeric[df$protocol == "psi"] <- 1
df$protocol <- factor(df$protocol, levels=c("ser", "psi"))

format_protocol <- function(p_n) {
    return(ifelse(p_n == 0, "SER", "PSI"))
}

ser_color <- "#1C5BD0"
psi_color <- "#DA5F6D"
# Grayscale
ser_color <- "#BDBDBD"
psi_color <- "#6E6E6E"
legend_title <- "" # No title
legend_labels <- c("naiveSER", "fastPSI")
legend_values <- c(ser_color, psi_color)

d <- ggplot(df) +
    aes(x=protocol_numeric, y=1-commit_r, fill=protocol) +

    geom_bar(colour="black", size=0.25, width=0.8, position="dodge2", stat="identity") +

    scale_x_continuous(breaks=seq(0,1,1),
                       labels=format_protocol,
                       sec.axis=dup_axis(name=NULL, labels=NULL)) +

    scale_y_continuous(breaks=seq(0,1,0.05),
                       expand=c(0,0), # Force at zero
                       sec.axis=dup_axis(name=NULL, labels=NULL)) +

    scale_fill_manual(name=legend_title,
                      labels=legend_labels,
                      values=legend_values) +

    coord_cartesian(ylim=c(0,0.4)) +

    labs(y = "Abort ratio") +

    theme_minimal(base_size=10) +

    theme(plot.title = element_blank(),
          plot.margin = margin(10,20,10,10),

          axis.title.x = element_blank(),
          axis.title.y = element_text(size=10, margin=margin(0,5,0,10)),
          axis.line = element_line(color="black", size=0.5),

          axis.text.x = element_text(color="black", size=9, margin=margin(30,0,0,0)),
          axis.text.y = element_text(color="black", size=9, margin=margin(0,8,0,3)),

          axis.ticks.y = element_line(color="black"),
          axis.ticks.length.y = unit(-2.75, "pt"),

          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(colour="#EBEBEB", size=0.5),

          legend.position = "none")


easy_annotation <- function(text, x, y) {
    return(annotation_custom(grob=text, xmin=x, xmax=x, ymin=y, ymax=y))
}

ann_color <- "black"
subtitle <- textGrob(label="Transaction Abort Ratio", gp=gpar(fontsize=10, col=ann_color))
ann_10 <- textGrob(label="10%", rot=-50, gp=gpar(fontsize=7, col=ann_color))
ann_20 <- textGrob(label="20%", rot=-50, gp=gpar(fontsize=7, col=ann_color))
ann_30 <- textGrob(label="30%", rot=-50, gp=gpar(fontsize=7, col=ann_color))
ann_40 <- textGrob(label="40%", rot=-50, gp=gpar(fontsize=7, col=ann_color))
ann_50 <- textGrob(label="50%", rot=-50, gp=gpar(fontsize=7, col=ann_color))

update_ann_y_level <- -0.02
# EW
d <- d +
    easy_annotation(text=subtitle,  x=1,        y=0.375) +
    easy_annotation(text=ann_10,    x=-0.3,     y=update_ann_y_level) +
    easy_annotation(text=ann_20,    x=-0.15,    y=update_ann_y_level) +
    easy_annotation(text=ann_30,    x=0.015,    y=update_ann_y_level) +
    easy_annotation(text=ann_40,    x=0.175,    y=update_ann_y_level) +
    easy_annotation(text=ann_50,    x=0.325,    y=update_ann_y_level) +

    easy_annotation(text=ann_10,    x=0.7,      y=update_ann_y_level) +
    easy_annotation(text=ann_20,    x=0.85,     y=update_ann_y_level) +
    easy_annotation(text=ann_30,    x=1.015,    y=update_ann_y_level) +
    easy_annotation(text=ann_40,    x=1.175,    y=update_ann_y_level) +
    easy_annotation(text=ann_50,    x=1.325,    y=update_ann_y_level)

gt <- ggplot_gtable(ggplot_build(d))
gt$layout$clip[gt$layout$name == "panel"] <- "off"

ggsave(filename = "abort_rate_bench.pdf",
       plot = gt,
       device = "pdf",
       width = 5,
       height = 4,
       dpi = 600)