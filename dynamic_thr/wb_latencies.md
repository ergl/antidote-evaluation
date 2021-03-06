# Dynamic Throughput Benchmark

## Summary

|       |         SER |          PSI |             RC |
| :---: | ----------: | -----------: | -------------: |
| 90/10 | 30,001.7600 | 105,568.1155 | 1,048,113.3187 |
| 80/20 | 36,810.6883 | 104,087.6907 | 1,032,519.6909 |
| 70/30 | 38,441.2538 | 101,996.2980 | 1,003,586.5394 |
| 50/50 | 42,073.0000 |  96,439.9036 |   930,069.6112 |

| Protocol | Workload | Maximum Commit Throughput |
| :------: | -------: | ------------------------: |
|   SER    |    90/10 |               30,001.7600 |
|   SER    |    80/20 |               36,810.6883 |
|   SER    |    70/30 |               38,441.2538 |
|   SER    |    50/50 |               42,073.0000 |
| ======== | ======== | ========================= |
|   PSI    |    90/10 |              105,568.1155 |
|   PSI    |    80/20 |              104,087.6907 |
|   PSI    |    70/30 |              101,996.2980 |
|   PSI    |    50/50 |               96,439.9036 |
| ======== | ======== | ========================= |
|    RC    |    90/10 |            1,048,113.3187 |
|    RC    |    80/20 |            1,032,519.6909 |
|    RC    |    70/30 |            1,003,586.5394 |
|    RC    |    50/50 |              930,069.6112 |

## Note on SER throughput

I noticed that changing the amount of writes not only does _not_ decrease the throughput, it actually slightly increases. After thinking about it, I came to the conclusion that it's to be expected. On SER, both read-only and update transactions go through the 2pc path, although they have slightly different conflict detection checks. This means that the commit latency for both should be `~~about~~` the same. Since on Workload B update transactions have less reads, overall their latency should be lower than read-only transactions, since they perform less round-trips. Also, since we don't fix the number of transactions in a benchmark, and use a time-based approach, it means that by increasing the number of update transactions we are able to fit more of them in the same time range (since their latency is lower). Thus, this is reflected in the results. To test this:

| R/W Ratio | Commit Throughput | Commit Ratio |
| --------: | ----------------: | -----------: |
|     90/10 |       35,472.0000 |     0.274029 |
|     80/20 |       36,810.6883 |     0.293788 |
|     70/30 |       38,441.2538 |     0.303421 |
|     50/50 |       42,073.0000 |     0.329188 |
|     10/90 |       51,343.7545 |     0.412513 |

## Sites = 3

Ring=64
Vsn=500-250
R=4 & R/W 3/1
Preloaded
Latency=10ms

For this experiment, we fix the number of sites, and vary the workload type

## Workload B, 10/90

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| SER  | 2,000 (24,000)  |  127,495.1042  | 51,343.7545 |    83.580492     |     67.547825     |   0.412513   |

## Workload B, 90/10

Repeat (even if done already in [sites_latencies.md](./sites_latencies.md)),
because SER looks wonky (the only protocol that increases throughput with more writes).

| Prot | Clients (Total)  | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :--------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| SER  |  1,750 (21,000)  |  118,682.5579  | 35,377.6094 |    72.465533     |     57.929348     |   0.295872   |
| SER  |  1,875 (22,500)  |  123,407.8710  | 35,138.7493 |    72.411997     |     57.959536     |   0.282837   |
| SER  |  2,000 (24,000)  |  126,548.5340  | 35,381.0886 |    72.940423     |     58.421026     |   0.272989   |
| SER  | 2,000-1 (24,000) |  127,971.8607  | 35,289.2588 |    72.664254     |     58.200318     |   0.271350   |
| SER  | 2,000-2 (24,000) |  126,981.8730  | 35,472.0000 |    73.080439     |     58.505284     |   0.274029   |
| SER  |  2,250 (27,000)  |  124,758.9673  | 34,864.0406 |    76.218041     |     60.863711     |   0.277122   |
| SER  |  2,500 (30,000)  |  132,722.4023  | 34,540.1714 |    79.352443     |     63.070154     |   0.259345   |
| SER  |  3,000 (36,000)  |  145,905.1005  | 34,148.9063 |    81.206621     |     64.661159     |   0.232045   |

## Workload B, 80/20

| Prot | Clients (Total)  | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :--------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| SER  |   250 (3,000)    |  16,021.4817   | 10,175.8897 |    70.679628     |     57.010680     |   0.634628   |
| SER  |   500 (6,000)    |  28,458.5472   | 14,462.4867 |    71.944251     |     58.049356     |   0.508022   |
| SER  |  1,000 (12,000)  |  77,564.2877   | 27,499.2419 |    70.835677     |     57.292449     |   0.361219   |
| SER  |  2,000 (24,000)  |  128,689.5743  | 36,810.6883 |    74.911995     |     59.945146     |   0.293788   |
| SER  | 2,000-1 (24,000) |  128,963.0328  | 36,772.8501 |    74.733187     |     59.811318     |   0.291900   |
| SER  | 2,000-2 (24,000) |  128,602.2603  | 37,050.6887 |    74.944659     |     59.967497     |   0.292894   |
| SER  |  3,000 (36,000)  |  142,959.5430  | 35,178.9648 |    83.657225     |     66.586600     |   0.243479   |

| Prot | Clients (Total) | Max Throughput |  Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :----------: | :--------------: | :---------------: | :----------: |
| PSI  |   400 (4,800)   |  94,836.0498   | 92,787.2307  |    50.972864     |     50.026211     |   0.973465   |
| PSI  |   450 (5,400)   |  104,716.1936  | 101,681.5561 |    52.502169     |     51.500849     |   0.969698   |
| PSI  |   500 (6,000)   |  108,427.1634  | 104,087.6907 |    57.960369     |     56.605054     |   0.975075   |
| PSI  |   625 (7,500)   |  106,611.0507  | 102,122.3984 |    73.758252     |     67.450730     |   0.978299   |
| PSI  |   750 (9,000)   |  104,029.7516  | 100,765.5878 |    89.962687     |     77.242231     |   0.978979   |
| PSI  | 1,000 (12,000)  |  102,402.8614  | 98,890.3604  |    122.454684    |     95.572011     |   0.978071   |

| Prot | Clients (Total) | Max Throughput | Ronly Lat (Mean) | RW Latency (Mean) |
| :--: | :-------------: | :------------: | :--------------: | :---------------: |
|  RC  |   500 (6,000)   |  99,029.8377   |    60.837216     |     60.794416     |
|  RC  | 1,000 (12,000)  |  208,232.5700  |    59.088915     |     59.036659     |
|  RC  | 2,000 (24,000)  |  410,848.8244  |    58.765320     |     58.590300     |
|  RC  | 4,000 (48,000)  |  885,900.3884  |    54.496141     |     54.220918     |
|  RC  | 5,000 (60,000)  | 1,032,519.6909 |    58.808038     |     58.888889     |
|  RC  | 6,000 (72,000)  | 1,095,685.6593 |    66.416246     |     66.842561     |
|  RC  | 8,000 (96,000)  | 1,158,309.2143 |    83.555003     |     84.055530     |

## Workload B, 70/30

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| SER  |   250 (3,000)   |  16,229.8642   | 10,604.4600 |    70.853626     |     57.135661     |   0.653873   |
| SER  |   500 (6,000)   |  28,711.5646   | 15,208.2122 |    72.380200     |     58.363390     |   0.530519   |
| SER  | 1,000 (12,000)  |  72,813.2514   | 27,763.9721 |    71.163370     |     57.525075     |   0.385697   |
| SER  | 2,000 (24,000)  |  127,280.7383  | 38,441.2538 |    75.872323     |     60.850069     |   0.303421   |
| SER  | 2,500 (30,000)  |  137,270.7376  | 37,080.6297 |    80.652754     |     64.891077     |   0.268953   |

| Prot | Clients (Total) | Max Throughput |  Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :----------: | :--------------: | :---------------: | :----------: |
| PSI  |   400 (4,800)   |  95,005.9420   | 91,327.6767  |    50.947241     |     50.076618     |   0.956436   |
| PSI  |   450 (5,400)   |  105,386.4642  | 100,054.7799 |    52.835169     |     52.168651     |   0.954384   |
| PSI  |   500 (6,000)   |  109,376.7250  | 101,996.2980 |    58.536652     |     57.452092     |   0.964186   |
| PSI  |   600 (7,200)   |  107,615.5354  | 100,971.8100 |    71.152726     |     66.344028     |   0.968255   |

| Prot | Clients (Total) | Max Throughput | Ronly Lat (Mean) | RW Latency (Mean) |
| :--: | :-------------: | :------------: | :--------------: | :---------------: |
|  RC  | 3,000 (36,000)  |  667,913.6226  |    54.421498     |     54.071495     |
|  RC  | 4,000 (48,000)  |  901,283.8786  |    54.279005     |     54.076916     |
|  RC  | 5,000 (60,000)  | 1,003,586.5394 |    60.236482     |     60.397428     |
|  RC  | 6,000 (72,000)  | 1,059,161.7611 |    68.526674     |     68.920021     |

## Workload B, 50/50

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| SER  |   500 (6,000)   |  28,943.2692   | 16,681.9066 |    72.617370     |     58.581985     |   0.575998   |
| SER  | 1,000 (12,000)  |  71,592.8259   | 31,245.2876 |    71.711515     |     57.965248     |   0.440109   |
| SER  | 2,000 (24,000)  |  129,728.7535  | 42,073.0000 |    78.824743     |     63.680238     |   0.329188   |

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| PSI  |   400 (4,800)   |  94,934.5139   | 89,916.0736 |    51.404166     |     50.841770     |   0.939012   |
| PSI  |   450 (5,400)   |  106,004.4297  | 96,439.9036 |    53.872174     |     53.481251     |   0.924956   |
| PSI  |   500 (6,000)   |  110,815.1023  | 98,425.4465 |    60.199005     |     59.115149     |   0.939445   |

| Prot | Clients (Total) | Max Throughput | Ronly Lat (Mean) | RW Latency (Mean) |
| :--: | :-------------: | :------------: | :--------------: | :---------------: |
|  RC  | 4,000 (48,000)  |  882,957.2871  |    54.835585     |     54.763779     |
|  RC  | 4,500 (54,000)  |  930,069.6112  |    58.568395     |     58.611472     |
|  RC  | 5,000 (60,000)  |  958,363.8082  |    63.169895     |     63.294380     |
