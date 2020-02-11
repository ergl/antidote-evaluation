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
| SER  |   250 (3,000)   |  34,978.4711   | 33,113.9074  |    45.789718     |     27.908885     |        14.339036         |   0.945636   |
| SER  |   500 (6,000)   |  57,861.5975   | 53,217.2445  |    46.212456     |     28.204495     |        14.579877         |   0.916990   |
| SER  | 1,000 (12,000)  |  116,767.6933  | 103,933.1404 |    46.409346     |     28.262551     |        14.734900         |   0.889079   |
| SER  | 1,500 (18,000)  |  140,370.8919  | 117,876.9446 |    55.620415     |     32.939262     |        17.014449         |   0.845516   |
| SER  | 2,000 (24,000)  |  147,456.0515  | 117,706.8469 |    64.032757     |     37.110777     |        18.900480         |   0.799265   |
| SER  | 2,500 (30,000)  |  153,501.4415  | 114,442.2523 |    73.814589     |     41.919710     |        21.020559         |   0.751526   |

| Prot | Clients (Total) | Max Throughput |  Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | RW Commit Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :----------: | :--------------: | :---------------: | :----------------------: | :----------: |
| PSI  |   125 (1,500)   |  60,175.5450   | 59,904.0543  |    24.984644     |     25.048457     |        12.722157         |   0.991811   |
| PSI  |   250 (3,000)   |  116,769.3299  | 115,338.2071 |    25.969898     |     26.113910     |        13.352954         |   0.990963   |
| PSI  |   500 (6,000)   |  234,291.5874  | 232,672.4990 |    25.643910     |     25.763828     |        13.233443         |   0.991826   |
| PSI  | 1,000 (12,000)  |  291,476.0906  | 288,313.0307 |    43.554554     |     35.686069     |        17.486805         |   0.993115   |
| PSI  | 1,500 (18,000)  |  282,118.0962  | 278,846.8289 |    67.074108     |     45.172984     |        20.760967         |   0.993330   |

| Prot | Clients (Total) | Max Throughput | Ronly Lat (Mean) | RW Latency (Mean) | RW Commit Latency (Mean) |
| :--: | :-------------: | :------------: | :--------------: | :---------------: | :----------------------: |

