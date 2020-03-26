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

df <- read.csv("./read_aborts/psi_read_abort.csv")

pdf(file = "psi_read_abort_bench.pdf", width = 15, height = 4)

partitions <- ggplot(df[df$exp == "p", ]) +
    geom_bar(aes(x=factor(ring), y=(1-commit_r)), colour="black", size=0.25, width=0.8, position="dodge2", stat="identity") +
    scale_y_continuous(breaks=seq(0,1,0.1), expand=c(0,0), sec.axis=dup_axis(name=NULL, labels=NULL)) +
    labs(title="Partitions number effect on abort ratio", x="Partitions", y="Abort ratio") +
    coord_cartesian(ylim=c(0,1.0025)) +
    theme_minimal(base_size=10) +
    theme(plot.title = element_text(color="black", size=9, hjust=1),
              plot.margin = margin(10,20,10,10),
              panel.border = element_rect(colour = "black", fill=NA, size=1),

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

written_keys <- ggplot(df[df$exp == "wk", ]) +
    geom_bar(aes(x=factor(write_keys), y=(1-commit_r)), colour="black", size=0.25, width=0.8, position="dodge2", stat="identity") +
    scale_y_continuous(breaks=seq(0,1,0.1), expand=c(0,0), sec.axis=dup_axis(name=NULL, labels=NULL)) +
    labs(title="Written keys effect on abort ratio", x="Written Keys", y="Abort ratio") +
    coord_cartesian(ylim=c(0,0.301)) +
    theme_minimal(base_size=10) +
    theme(plot.title = element_text(color="black", size=9, hjust=1),
              plot.margin = margin(10,20,10,10),
              panel.border = element_rect(colour = "black", fill=NA, size=1),

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
    geom_bar(aes(x=factor(read_keys), y=(1-commit_r)), colour="black", size=0.25, width=0.8, position="dodge2", stat="identity") +
    scale_y_continuous(breaks=seq(0,1,0.025), expand=c(0,0), sec.axis=dup_axis(name=NULL, labels=NULL)) +
    labs(title="Read keys effect on abort ratio", x="Read Keys", y="Abort ratio") +
    coord_cartesian(ylim=c(0,0.301)) +
    theme_minimal(base_size=10) +
    theme(plot.title = element_text(color="black", size=9, hjust=1),
              plot.margin = margin(10,20,10,10),
              panel.border = element_rect(colour = "black", fill=NA, size=1),

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

grid.newpage()

pushViewport(viewport(layout = grid.layout(1, 3)))

vplayout <- function(x,y) viewport(layout.pos.row = x, layout.pos.col = y)
print(partitions, vp = vplayout(1,1))
print(written_keys, vp = vplayout(1,2))
print(read_keys, vp = vplayout(1,3))

dev.off()
