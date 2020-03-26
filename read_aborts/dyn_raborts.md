# Check which parameters affect read aborts

In a single site, we explore how read aborts occur for different parameters

We start with changing how many written keys are in update transactions.

Fixed parameters:

Sites=1
Ring=64
Vsn=500-250
Preloaded

## param=written_keys

We vary:
R=4 & R/W 4/1 => 4/4, 50/50

We vary from R/W 4/1 to 4/4 and observe both the net abort rate, and how many of
those aborts are read aborts, and how many are 2PC aborts.

There's a big difference between 4/1 and 4/4 (5% more aborts, and a 92% increase
of read aborts)

| Prot | Written Keys | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | RW Commit Latency (Mean) | Commit Ratio |  Read P  | Confl. P | Reborts in Ronly | Reborts in Upd |
| :--: | :----------: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------------------: | :----------: | :------: | :------: | :--------------: | :------------: |
| PSI  |      1       |  1,000 (4,000)  |  42,227.2165   | 39,403.5165 |    88.019297     |    107.781724     |        21.040659         |   0.955804   | 0.000000 | 1.000000 |     0.000000     |    0.000000    |
| PSI  |      2       |  1,000 (4,000)  |  40,427.9071   | 36,206.3534 |    40.305192     |     52.789124     |        12.649532         |   0.895979   | 0.924913 | 0.075087 |     0.461505     |    0.463407    |
| PSI  |      3       |  1,000 (4,000)  |  39,247.4354   | 32,000.5937 |    34.414986     |     46.357935     |        11.952449         |   0.812988   | 0.965528 | 0.034472 |     0.483381     |    0.482147    |
| PSI  |      4       |  1,000 (4,000)  |  39,025.0975   | 28,357.2896 |    32.699635     |     44.502389     |        11.791746         |   0.727591   | 0.975525 | 0.024475 |     0.488073     |    0.487452    |

Next experiment should be, default 2 written keys W=2 (always), then vary the keys
read from 2 to 4, see how the amount of read aborts goes. The more keys we read, the
more opportunity we have of observing the forked state.

## param=read_keys

We vary:
R=2 & R/W 2/2 => R=4 & R/W 4/2, 50/50

Default write is 2 keys

| Prot | Read Keys | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | RW Commit Latency (Mean) | Commit Ratio |  Read P  | Confl. P | Reborts in Ronly | Reborts in Upd |
| :--: | :-------: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------------------: | :----------: | :------: | :------: | :--------------: | :------------: |
| PSI  |     2     |  1,000 (4,000)  |  78,332.9163   | 75,136.2177 |    23.046168     |     37.307095     |        14.244159         |   0.959437   | 0.800807 | 0.199193 |     0.398194     |    0.402614    |
| PSI  |     3     |  1,000 (4,000)  |  53,093.4951   | 49,497.6080 |    29.942351     |     42.589419     |        12.644527         |   0.930740   | 0.900628 | 0.099372 |     0.448997     |    0.451631    |
| PSI  |     4     |  1,000 (4,000)  |  40,491.4989   | 36,227.4042 |    40.378546     |     52.840043     |        12.663997         |   0.895672   | 0.928068 | 0.071932 |     0.462913     |    0.465155    |

## param=partitions

We have R=4 & R/W 4/4, and vary the number of partitions from 8 to ??? (default is 64)

| Prot | Ring | Clients (Total) | Max Throughput | Max Commit  | Ronly Lat (Mean) | RW Latency (Mean) | RW Commit Latency (Mean) | Commit Ratio |  Read P  | Confl. P | Reborts in Ronly | Reborts in Upd |
| :--: | :--: | :-------------: | :------------: | :---------: | :--------------: | :---------------: | :----------------------: | :----------: | :------: | :------: | :--------------: | :------------: |
| PSI  |  8   |  1,000 (4,000)  |  61,000.1286   | 18,906.1857 |    25.971189     |     33.865970     |         7.878352         |   0.313892   | 0.997913 | 0.002087 |     0.499241     |    0.498672    |
| PSI  |  16  |  1,000 (4,000)  |  68,994.9036   | 24,169.5626 |    26.276384     |     34.378827     |         8.083108         |   0.357866   | 0.996852 | 0.003148 |     0.498544     |    0.498308    |
| PSI  |  32  |  1,000 (4,000)  |  60,165.5137   | 29,689.8826 |    27.191095     |     35.937005     |         8.724433         |   0.497082   | 0.992019 | 0.007981 |     0.495994     |    0.496026    |
| PSI  |  64  |  1,000 (4,000)  |  38,855.5730   | 28,300.0717 |    32.791332     |     44.650314     |        11.838178         |   0.726583   | 0.975792 | 0.024208 |     0.487657     |    0.488135    |
| PSI  | 128  |  1,000 (4,000)  |  21,444.7657   | 18,438.7705 |    155.324189    |    167.591622     |        28.419262         |   0.860567   | 0.840699 | 0.159301 |     0.419091     |    0.421608    |
| PSI  | 256  |  1,000 (4,000)  |  10,305.4252   | 8,965.8701  |    332.576162    |    451.844568     |        131.260159        |   0.895259   | 0.379433 | 0.620567 |     0.184357     |    0.195075    |
