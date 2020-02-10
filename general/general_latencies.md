# General Throughput Benchmark

For this benchmark, we pick Workload C, and run a standard throughput-latency chart. The difference is that we plot the commit latency of update transactions, instead of the entire latency. As such, we don't care for the amount of reads.

Fixed parameters:

Sites=3
Ring=64
Vsn=500-250
R=2 & R/W 1/1
Preloaded
Latency=10ms

## Workload C, 90/10

| Prot | Clients (Total) | Max Throughput |  Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | RW Commit Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :----------: | :--------------: | :---------------: | :----------------------: | :----------: |
| PSI  |   500 (6,000)   |  234,291.5874  | 232,672.4990 |    25.643910     |     25.763828     |        13.233443         |   0.991826   |
| PSI  | 1,000 (12,000)  |  291,476.0906  | 288,313.0307 |    43.554554     |     35.686069     |        17.486805         |   0.993115   |

| Prot | Clients (Total) | Max Throughput | Ronly Lat (Mean) | RW Latency (Mean) | RW Commit Latency (Mean) |
| :--: | :-------------: | :------------: | :--------------: | :---------------: | :----------------------: |

