# Dynamic Throughput Benchmark

## Workload B, 90/10

For this experiment, we fix everything and vary the number of sites

## Summary

| Protocol | Sites | Maximum Commit Throughput |
| :------: | :---: | ------------------------: |
|   SER    |   1   |               24,050.2038 |
|   SER    |   2   |               24,898.9829 |
|   SER    |   3   |               30,001.7600 |
|   SER    |   4   |               39,843.3450 |
| ======== | ===== | ========================= |
|   PSI    |   1   |               69,262.7401 |
|   PSI    |   2   |               93,002.5637 |
|   PSI    |   3   |              105,568.1155 |
|   PSI    |   4   |              108,781.7523 |
| ======== | ===== | ========================= |
|    RC    |   1   |              367,947.2665 |
|    RC    |   2   |              801,495.7678 |
|    RC    |   3   |            1,048,113.3187 |
|    RC    |   4   |              808,030.8285 |

### Sites = 1

Ring=32
Vsn=500-250
R=4 & R/W 3/1

Preloaded

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| SER  |    100 (400)    |   2,169.6305   | 1,782.1536  |    149.777164    |    110.684215     |   0.822725   |
| SER  |   250 (1,000)   |  27,273.1255   | 17,229.4793 |    125.585110    |    107.745500     |   0.684315   |
| SER  |   500 (2,000)   |  49,365.9026   | 24,050.2038 |    33.685810     |     26.829244     |   0.499957   |
| SER  |  1,000 (4,000)  |  58,377.7184   | 23,558.6087 |    35.451116     |     28.213939     |   0.402972   |
| SER  |  2,000 (8,000)  |  66,267.7972   | 22,233.5418 |    39.326446     |     31.230366     |   0.334556   |

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| PSI  |   250 (1,000)   |  38,213.2704   | 38,211.8705 |    26.455349     |     25.819408     |   0.999575   |
| PSI  |   500 (2,000)   |  69,386.7526   | 69,262.7401 |    29.718510     |     28.054182     |   0.999316   |
| PSI  |   625 (2,500)   |  70,679.9910   | 70,435.9461 |    36.708279     |     34.056949     |   0.998296   |
| PSI  |   750 (3,000)   |  71,159.9155   | 71,052.9273 |    43.763848     |     40.642713     |   0.998776   |
| PSI  |  1,000 (4,000)  |  71,486.0010   | 71,355.0314 |    58.260448     |     54.485461     |   0.998411   |

| Prot | Clients (Total) | Max Throughput | Ronly Lat (Mean) | RW Latency (Mean) |
| :--: | :-------------: | :------------: | :--------------: | :---------------: |
|  RC  |   750 (3,000)   |  117,964.7958  |    25.814762     |     25.964305     |
|  RC  |  1,000 (4,000)  |  155,975.8186  |    26.041280     |     26.203885     |
|  RC  |  1,500 (6,000)  |  235,691.1225  |    25.913949     |     26.070587     |
|  RC  |  2,000 (8,000)  |  320,005.4483  |    26.262074     |     26.433107     |
|  RC  | 2,500 (10,000)  |  367,947.2665  |    28.094275     |     28.553775     |
|  RC  | 3,000 (12,000)  |  386,941.9785  |    32.266331     |     32.726344     |

### Sites = 2, with 10ms latency

Ring=32
Vsn=500-250
R=4 & R/W 3/1

Preloaded

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| SER  | 2,000 (16,000)  |  76,976.0924   | 22,152.1791 |    59.571485     |     47.737807     |   0.288016   |
| SER  | 3,000 (24,000)  |  102,592.4001  | 24,898.9829 |    64.681103     |     51.020807     |   0.235764   |
| SER  | 4,000 (32,000)  |  117,664.3185  | 26,254.3895 |    72.714821     |     56.911600     |   0.217797   |

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| PSI  |   500 (4,000)   |  94,306.1071   | 93,002.5637 |    44.068248     |     43.017266     |   0.993124   |
| PSI  |  1,000 (8,000)  |  94,871.2949   | 93,995.6188 |    85.977864     |     75.358067     |   0.991054   |

| Prot | Clients (Total) | Max Throughput | Ronly Lat (Mean) | RW Latency (Mean) |
| :--: | :-------------: | :------------: | :--------------: | :---------------: |
|  RC  | 3,000 (24,000)  |  507,907.8592  |    47.777110     |     47.499790     |
|  RC  | 4,000 (32,000)  |  728,446.9489  |    44.482275     |     44.606059     |
|  RC  | 5,000 (40,000)  |  801,495.7678  |    50.424575     |     50.813407     |
|  RC  | 6,000 (48,000)  |  837,255.8521  |    58.092954     |     58.930526     |
|  RC  | 6,500 (52,000)  |  862,807.6431  |    61.943602     |     62.876974     |
|  RC  | 8,000 (64,000)  |  893,247.3985  |    73.681308     |     74.853595     |

Ring=64

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| PSI  |   250 (2,000)   |  46,528.4882   | 46,077.2931 |    43.405984     |     42.695234     |   0.992857   |
| PSI  |   500 (4,000)   |  82,992.0351   | 81,945.7892 |    49.341056     |     46.252579     |   0.991127   |
| PSI  |  1,000 (8,000)  |  82,290.7606   | 81,747.1962 |    100.061054    |     75.016607     |   0.996443   |

Ring=64, 3 machines per site

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| PSI  |   500 (4,000)   |  66,881.2775   | 65,590.7725 |    61.641879     |     57.253713     |   0.991460   |

Ring=64, 4 machines per site, but 5 client machines per site

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| PSI  |   500 (5,000)   |  73,430.2769   | 72,858.6477 |    69.932595     |     63.077954     |   0.995380   |

### Sites = 3, with 10ms latency

Ring=64
Vsn=500-250
R=4 & R/W 3/1

Preloaded

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| SER  | 4,000 (48,000)  |  154,931.7183  | 30,001.7600 |    91.366715     |     72.639097     |   0.192457   |
| SER  | 5,000 (60,000)  |  166,034.0875  | 27,529.9061 |    102.446857    |     81.336752     |   0.165294   |

| Prot | Clients (Total) | Max Throughput |  Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :----------: | :--------------: | :---------------: | :----------: |
| PSI  |   500 (6,000)   |  106,656.9894  | 105,568.1155 |    57.760018     |     54.735643     |   0.989050   |
| PSI  |   500 (6,000)   |  105,813.0921  | 104,824.3920 |    58.221472     |     55.434393     |   0.988546   |
| PSI  |   500 (6,000)   |  105,673.2732  | 104,724.0743 |    58.581938     |     51.562525     |   0.992855   | (1ms cork) |
| PSI  |   750 (9,000)   |  106,679.4000  | 105,515.1026 |    86.945928     |     70.664005     |   0.992715   |
| PSI  |   750 (9,000)   |  105,075.5478  | 104,084.3710 |    88.189707     |     71.657643     |   0.992984   |
| PSI  |   750 (9,000)   |  105,688.7903  | 104,703.6128 |    88.361518     |     66.378579     |   0.993983   | (1ms cork) |
| PSI  | 1,000 (12,000)  |  106,195.7753  | 105,765.5575 |    116.023479    |     84.749248     |   0.993641   |
| PSI  | 1,000 (12,000)  |  105,066.3137  | 104,560.5083 |    117.522051    |     80.432120     |   0.994326   | (1ms cork) |

| Prot | Clients (Total) | Max Throughput | Ronly Lat (Mean) | RW Latency (Mean) |
| :--: | :-------------: | :------------: | :--------------: | :---------------: |
|  RC  | 2,500 (30,000)  |  512,921.9340  |    58.998115     |     58.812216     |
|  RC  | 5,000 (60,000)  | 1,048,113.3187 |    57.879662     |     58.011700     |
|  RC  | 6,250 (75,000)  | 1,145,304.9523 |    66.328043     |     66.819921     |
|  RC  | 7,500 (90,000)  | 1,226,344.2501 |    75.908198     |     76.837966     |

### Sites = 4, with 10ms latency

Ring=64
Vsn=500-250
R=4 & R/W 3/1

Preloaded

| Prot | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| SER  | 4,000 (32,000)  |  161,747.0498  | 39,843.3450 |    82.446875     |     65.230803     |   0.243892   |
| SER  | 6,000 (48,000)  |  180,890.1757  | 36,281.3977 |    96.260213     |     76.234318     |   0.200611   |

| Prot | Clients (Total) | Max Throughput |  Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :-------------: | :------------: | :----------: | :--------------: | :---------------: | :----------: |
| PSI  |   750 (6,000)   |  111,148.6664  | 108,781.7523 |    54.820641     |     53.434095     |   0.983401   |
| PSI  |  1,000 (8,000)  |  114,714.0653  | 111,922.7611 |    72.324205     |     64.809182     |   0.992235   |

| Prot | Clients (Total) | Max Throughput | Ronly Lat (Mean) | RW Latency (Mean) |
| :--: | :-------------: | :------------: | :--------------: | :---------------: |
|  RC  | 5,000 (40,000)  |  647,264.2617  |    62.344890     |     62.174205     |
|  RC  | 7,500 (60,000)  |  808,030.8285  |    76.237887     |     76.509384     |
|  RC  | 10,000 (80,000) |  868,661.5764  |    95.563441     |     95.905008     |

### Other results

3 site setting with other parameters:

| Prot | Ring | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| SER  |  32  | 2,000 (24,000)  |  78,570.9486   | 18,718.8696 |    74.872321     |     60.396874     |   0.237714   |
| SER  |  32  | 4,000 (48,000)  |  141,278.9855  | 25,538.5839 |    89.502530     |     71.397556     |   0.173971   |
| SER  |  32  | 5,000 (60,000)  |  162,573.4692  | 24,473.1021 |    103.792075    |     82.310941     |   0.148858   |
| PSI  | 128  |   500 (6,000)   |  75,523.5734   | 73,231.3803 |    86.664208     |     72.935215     |   0.991890   |
| PSI  | 128  | 2,000 (24,000)  |  74,940.0651   | 72,981.4686 |    351.124525    |    190.000246     |   0.991529   |

| Prot | Ring | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | Commit Ratio |
| :--: | :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------: |
| PSI  |  32  |   500 (6,000)   |  89,444.6426   | 87,428.6984 |    69.599187     |     63.709461     |   0.990442   |
| PSI  |  32  |   750 (9,000)   |  88,306.9289   | 86,521.3211 |    105.753926    |     84.855470     |   0.991780   |
| PSI  |  32  | 1,000 (12,000)  |  86,951.5826   | 86,489.7784 |    142.305475    |    104.268652     |   0.991715   |
| PSI  |  32  | 2,000 (24,000)  |  88,971.7587   | 88,284.7698 |    281.745574    |    173.831967     |   0.988877   |
