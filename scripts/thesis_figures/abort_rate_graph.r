#!/usr/bin/env Rscript

packages.to.install <- c("lemon", "grid", "gridExtra", "ggplot2")
for(p in packages.to.install) {
    print(p)
    if (suppressWarnings(!require(p, character.only = TRUE))) {
        install.packages(p, repos = "http://lib.stat.cmu.edu/R/CRAN")
        library(p, character.only=TRUE)
    }
}

df <- read.csv("../../read_aborts/abort_comparison.csv")
df <- df[df$workload != "a", ]
df$protocol_numeric[df$protocol == "ser"] <- 0
df$protocol_numeric[df$protocol == "psi"] <- 1
df$protocol <- factor(df$protocol, levels=c("ser", "psi"))

format_protocol <- function(p_n) {
    return(ifelse(p_n == 0, "SER", "PSI"))
}

# Grayscale
ser_color <- "#BDBDBD"
psi_color <- "#6E6E6E"
legend_title <- "" # No title
legend_labels <- c("naiveSER", "fastPSI")
legend_breaks <- c("ser", "psi")
legend_values <- c(ser_color, psi_color)

plot_aborts <- function(df, title, aes_kind, ylab, ybreaks, ylim) {
    d <- ggplot(df) +
        geom_bar(aes_kind, colour="black", size=0.25, width=0.8, position="dodge2", stat="identity") +
        scale_x_continuous(breaks=seq(0,1,1), labels=format_protocol, sec.axis=dup_axis(name=NULL, labels=NULL)) +
        scale_y_continuous(breaks=ybreaks, expand=c(0,0), sec.axis=dup_axis(name=NULL, labels=NULL)) +
        scale_fill_manual(name=legend_title, labels=legend_labels, values=legend_values) +
        coord_cartesian(ylim=ylim) +
        labs(title=title, y=ylab) +
        theme_minimal(base_size=10) +
        theme(plot.title = element_text(color="black", size=9, hjust=1),
              plot.margin = margin(10,20,10,10),

              axis.title.x = element_blank(),
              axis.title.y = element_text(size=10, margin=margin(0,5,0,10)),
              axis.line = element_line(color="black", size=0.5),

              axis.text.x = element_text(color="black", size=9, margin=margin(25,0,0,0)),
              axis.text.y = element_text(color="black", size=9, margin=margin(0,8,0,3)),

              strip.text.x = element_text(size=10),
              strip.placement = "outside",
              panel.spacing = unit(1, "lines"),

              axis.ticks.y = element_line(color="black"),
              axis.ticks.length.y = unit(-2.75, "pt"),

              panel.grid.major.x = element_blank(),
              panel.grid.minor.x = element_blank(),
              panel.grid.minor.y = element_blank(),
              panel.grid.major.y = element_line(colour="#EBEBEB", size=0.5),

              legend.position = "none")

    return(d)
}

plot_abort_dissect <- function(df, title, ylimits) {
    d <- ggplot(df,
                aes(x=factor(updates),
                y=conflict_r,
                linetype=protocol,
                shape=protocol,
                group=protocol,
                color=protocol)) +

    geom_point(size=2.5) + geom_line() +

    scale_y_log10(limits=ylimits,
                  labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +

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

    labs(title = title,
         x = "Update Transactions (%)",
         y = "Abort share")+

    theme_minimal(base_size=10) +
    theme(plot.title = element_text(color="black", size=9, hjust=1),
          plot.margin = margin(10,20,10,10),

          axis.title.x = element_text(size=10, margin=margin(0,0,-10,0)),
          axis.title.y = element_text(size=10, margin=margin(0,5,0,10)),
          axis.line = element_line(color="black", size=0.5),

          axis.text.x = element_text(color="black", size=9, margin=margin(8,0,5,0)),
          axis.text.y = element_text(color="black", size=9, margin=margin(0,8,0,3)),

          strip.text.x = element_text(size=10),
          strip.placement = "outside",
          panel.spacing = unit(1, "lines"),

          axis.ticks = element_line(color="black"),
          axis.ticks.length = unit(-2.75, "pt"),

          panel.grid.minor.x = element_blank(),
          panel.grid.major.x = element_line(colour="#EBEBEB", size=0.5),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(colour="#EBEBEB", size=0.5),

          legend.position = "bottom",
          legend.direction = "horizontal",
          legend.title = element_text(size=6),
          legend.text = element_text(size=6),
          legend.box.just = "left",
          legend.box.background = element_rect(color="white", fill="white"))

    return(d)
}

df_d <- df[df$workload == "d", ]
df_e <- df[df$workload == "e", ]

workload_d <- plot_aborts(df=df_d,
                          title="Workload D",
                          aes_kind=aes(x=protocol_numeric, y=(1-commit_r), fill=protocol),
                          ybreaks=seq(0,1,0.05),
                          ylab="Abort ratio",
                          ylim=c(0,0.4))

workload_e <- plot_aborts(df=df_e,
                          title="Workload E",
                          aes_kind=aes(x=protocol_numeric, y=(1-commit_r), fill=protocol),
                          ybreaks=seq(0,1,0.05),
                          ylab="Abort ratio",
                          ylim=c(0,0.4))

workload_d_2pc <- plot_abort_dissect(df=df_d,
                                     title="Workload D, aborts during validation",
                                     ylimits=c(0.003,1.01))

workload_e_2pc <- plot_abort_dissect(df=df_e,
                                     title="Workload E, aborts during validation",
                                     ylimits=c(0.006,0.09))


easy_annotation <- function(text, x, y) {
    return(annotation_custom(grob=text, xmin=x, xmax=x, ymin=y, ymax=y))
}

ann_color <- "black"
ann_10 <- textGrob(label="10%", rot=-50, gp=gpar(fontsize=7, col=ann_color))
ann_20 <- textGrob(label="20%", rot=-50, gp=gpar(fontsize=7, col=ann_color))
ann_30 <- textGrob(label="30%", rot=-50, gp=gpar(fontsize=7, col=ann_color))
ann_40 <- textGrob(label="40%", rot=-50, gp=gpar(fontsize=7, col=ann_color))
ann_50 <- textGrob(label="50%", rot=-50, gp=gpar(fontsize=7, col=ann_color))

# EW
workload_e <- workload_e +
    easy_annotation(text=ann_10,    x=-0.3,     y=-0.06) +
    easy_annotation(text=ann_20,    x=-0.15,    y=-0.06) +
    easy_annotation(text=ann_30,    x=0.015,    y=-0.06) +
    easy_annotation(text=ann_40,    x=0.175,    y=-0.06) +
    easy_annotation(text=ann_50,    x=0.325,    y=-0.06)

workload_d <- workload_d +
    easy_annotation(text=ann_10,    x=-0.3,     y=-0.06) +
    easy_annotation(text=ann_20,    x=-0.15,    y=-0.06) +
    easy_annotation(text=ann_30,    x=0.015,    y=-0.06) +
    easy_annotation(text=ann_40,    x=0.175,    y=-0.06) +
    easy_annotation(text=ann_50,    x=0.325,    y=-0.06)

gt_e <- ggplot_gtable(ggplot_build(workload_e))
gt_e_2pc <- ggplot_gtable(ggplot_build(workload_e_2pc))

gt_e$layout$clip[gt_e$layout$name == "panel"] <- "off"
gt_e_2pc$layout$clip[gt_e_2pc$layout$name == "panel"] <- "off"

gt_d <- ggplot_gtable(ggplot_build(workload_d))
gt_d_2pc <- ggplot_gtable(ggplot_build(workload_d_2pc))

gt_d$layout$clip[gt_d$layout$name == "panel"] <- "off"
gt_d_2pc$layout$clip[gt_d_2pc$layout$name == "panel"] <- "off"

combined_d <- grid.arrange(gt_d, gt_d_2pc, nrow=2, heights=c(5,5))
combined_e <- grid.arrange(gt_e, gt_e_2pc, nrow=2, heights=c(1,1))
combined <- grid.arrange(combined_d, combined_e, ncol=2, widths=c(5,5))

ggsave(filename = "./out/abort_rate_bench.pdf",
       plot = combined,
       device = "pdf",
       width = 5,
       height = 4,
       dpi = 600)
