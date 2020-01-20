# Dynamic Throughput Benchmark

## Sites = 3

Ring=64
Vsn=500-250
R=4 & R/W 3/1
Preloaded
Latency=10ms

For this experiment, we fix the number of sites, and vary the workload type

## Workload B, 80/20

| Prot | Clients (Total) | Max Throughput | Max Commit | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :--------: | :--------------: | :---------------: | :----------: |
| SER  |

| Prot | Clients (Total) | Max Throughput | Max Commit | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :--------: | :--------------: | :---------------: | :----------: |
| PSI  |

| Prot | Clients (Total) | Max Throughput | Ronly Lat (Mean) | RW Latency (Mean) |
| :--: | :-------------: | :------------: | :--------------: | :---------------: |
|  RC  |   500 (6,000)   |  99,029.8377   |    60.837216     |     60.794416     |
|  RC  | 1,000 (12,000)  |  208,232.5700  |    59.088915     |     59.036659     |
|  RC  | 2,000 (24,000)  |  410,848.8244  |    58.765320     |     58.590300     |
|  RC  | 4,000 (48,000)  |  885,900.3884  |    54.496141     |     54.220918     |
|  RC  | 5,000 (60,000)  | 1,032,519.6909 |    58.808038     |     58.888889     |
|  RC  | 6,000 (72,000)  | 1,095,685.6593 |    66.416246     |     66.842561     |
|  RC  | 8,000 (96,000)  | 1,158,309.2143 |    83.555003     |     84.055530     |
