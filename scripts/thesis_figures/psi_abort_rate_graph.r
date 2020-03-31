#!/usr/bin/env Rscript

packages.to.install <- c("lemon", "grid", "gridExtra", "ggplot2")
for(p in packages.to.install) {
    print(p)
    if (suppressWarnings(!require(p, character.only = TRUE))) {
        install.packages(p, repos = "http://lib.stat.cmu.edu/R/CRAN")
        library(p, character.only=TRUE)
    }
}

# TODO: Revisit this one and the other of read aborts following the style of Eiger.
# With lines and dots we can use log scale on the Y axis, but not with geom_bar

df <- read.csv("../../read_aborts/psi_read_abort.csv")

psi_color <- "#F2818F"
partitions <- ggplot(df[df$exp == "p", ]) +
    geom_bar(aes(x=factor(ring), y=(1-commit_r)), fill=psi_color, colour="black", size=0.25, width=0.8, position="dodge2", stat="identity") +
    scale_y_continuous(breaks=seq(0,1,0.1), expand=c(0,0), sec.axis=dup_axis(name=NULL, labels=NULL)) +
    labs(title="Partitions number effect on abort ratio",
        subtitle="4 reads / 4 writes",
        x="Partitions\n\n(c)",
        y="Abort ratio") +
    coord_cartesian(ylim=c(0,1.001)) +
    theme_minimal(base_size=10) +
    theme(plot.title = element_text(color="black", size=9, hjust=1),
          plot.subtitle = element_text(color="black", size=8, hjust=1),
          plot.margin = margin(10,20,10,10),
          panel.border = element_rect(colour = "black", fill=NA, size=0.5),

          axis.title.x = element_text(size=10, margin=margin(0,5,0,10)),
          axis.title.y = element_text(size=10, margin=margin(0,5,0,10)),

          axis.text.x = element_text(color="black", size=9, margin=margin(5,0,8,0)),
          axis.text.y = element_text(color="black", size=9, margin=margin(0,8,0,3)),

          strip.text.x =    element_text(size=10),
          strip.placement = "outside",
          panel.spacing =    unit(1, "lines"),

          axis.ticks.y = element_line(color="black"),
          axis.ticks.length.y = unit(-2.75, "pt"),

          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(colour="#EBEBEB", size=0.5),

          legend.position = "none")


psi_color <- "#F2818F"
partitions_throughput <- ggplot(df[df$exp == "p", ], aes(x=factor(ring),
                                                         y=throughput,
                                                         group=exp)) +

    geom_point(size=2.5, colour=psi_color) + geom_line(colour=psi_color) +

    scale_y_continuous(breaks=seq(0, 30000, 5000),
                       expand=c(0,0),
                       labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +

    labs(title="Partitions number effect on throughput",
        subtitle="4 reads / 4 writes",
        x="Partitions",
        y="Throughput (tps)") +

    coord_cartesian(ylim=c(0, 32500)) +

    theme_minimal(base_size=10) +

    theme(plot.title = element_text(color="black", size=9, hjust=1),
          plot.subtitle = element_text(color="black", size=8, hjust=1),
          plot.margin = margin(10,20,10,10),

          axis.title.x = element_text(size=10, margin=margin(0,0,0,0)),
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

written_keys <- ggplot(df[df$exp == "wk", ]) +
    geom_bar(aes(x=factor(write_keys), y=(1-commit_r)), fill=psi_color, colour="black", size=0.25, width=0.8, position="dodge2", stat="identity") +
    scale_y_continuous(breaks=seq(0,1,0.1), expand=c(0,0), sec.axis=dup_axis(name=NULL, labels=NULL)) +
    labs(title="Written keys effect on abort ratio",
         subtitle="4 reads / 64 partitions",
         x="Written Keys\n\n(b)",
         y="Abort ratio") +
    coord_cartesian(ylim=c(0,0.3001)) +
    theme_minimal(base_size=10) +
    theme(plot.title = element_text(color="black", size=9, hjust=1),
          plot.subtitle = element_text(color="black", size=8, hjust=1),
          plot.margin = margin(10,20,10,10),
          panel.border = element_rect(colour = "black", fill=NA, size=0.5),

          axis.title.x = element_text(size=10, margin=margin(0,5,0,10)),
          axis.title.y = element_text(size=10, margin=margin(0,5,0,10)),

          axis.text.x = element_text(color="black", size=9, margin=margin(5,0,8,0)),
          axis.text.y = element_text(color="black", size=9, margin=margin(0,8,0,3)),

          strip.text.x =    element_text(size=10),
          strip.placement = "outside",
          panel.spacing =    unit(1, "lines"),

          axis.ticks.y = element_line(color="black"),
          axis.ticks.length.y = unit(-2.75, "pt"),

          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(colour="#EBEBEB", size=0.5),

          legend.position = "none")

read_keys <- ggplot(df[df$exp == "rk", ]) +
    geom_bar(aes(x=factor(read_keys), y=(1-commit_r)), fill=psi_color, colour="black", size=0.25, width=0.8, position="dodge2", stat="identity") +
    scale_y_continuous(breaks=seq(0,1,0.025), expand=c(0,0), sec.axis=dup_axis(name=NULL, labels=NULL)) +
    labs(title="Read keys effect on abort ratio (Two keys written) ",
         subtitle="2 writes / 64 partitions",
         x="Read Keys\n\n(a)",
         y="Abort ratio") +
    coord_cartesian(ylim=c(0,0.3001)) +
    theme_minimal(base_size=10) +
    theme(plot.title = element_text(color="black", size=9, hjust=1),
          plot.subtitle = element_text(color="black", size=8, hjust=1),
          plot.margin = margin(10,20,10,10),
          panel.border = element_rect(colour = "black", fill=NA, size=0.5),

          axis.title.x = element_text(size=10, margin=margin(0,5,0,10)),
          axis.title.y = element_text(size=10, margin=margin(0,5,0,10)),

          axis.text.x = element_text(color="black", size=9, margin=margin(5,0,8,0)),
          axis.text.y = element_text(color="black", size=9, margin=margin(0,8,0,3)),

          strip.text.x =    element_text(size=10),
          strip.placement = "outside",
          panel.spacing =    unit(1, "lines"),

          axis.ticks.y = element_line(color="black"),
          axis.ticks.length.y = unit(-2.75, "pt"),

          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(colour="#EBEBEB", size=0.5),

          legend.position = "none")

gt_ring <- ggplot_gtable(ggplot_build(partitions))
gt_written <- ggplot_gtable(ggplot_build(written_keys))
gt_read <- ggplot_gtable(ggplot_build(read_keys))

gt_ring$layout$clip[gt_ring$layout$name == "panel"] <- "off"
gt_written$layout$clip[gt_written$layout$name == "panel"] <- "off"
gt_read$layout$clip[gt_read$layout$name == "panel"] <- "off"

combined <- grid.arrange(gt_read, gt_written, gt_ring, ncol=3, widths=c(1,1,1))
ggsave(filename = "./out/psi_read_abort_bench.pdf",
       plot = combined,
       device = "pdf",
       width = 12,
       height = 4,
       dpi = 600)

ggsave(filename = "./out/psi_partitions_throughput.pdf",
       plot = partitions_throughput,
       device = "pdf",
       width = 5,
       height = 4,
       dpi = 600)
