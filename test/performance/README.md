# Performance Tests

## Running tests

To run the performance tests, execute the following from the root of the repository:

```bash
kind create cluster
bash hack/quick-install.sh
bash test/performance/run.sh
```

**Note**: this requires at least Python 3.10

The tests are run with [Locust](https://docs.locust.io/en/stable/) in order and they
are the following:

1. `create`: (Sink) POST / to create Pods from a template, aprox ~3k Pods are inserted
1. `get`: (API) GET /api/v1/pods

The results of the tests are on `./perf-results/`, relative to the root of the repository.
Their name reference the test where they come from, currently `get-*.csv` and `create-*.csv`

-   `.txt` files contain summaries of Locust, the time unit is milliseconds.
-   `.csv` files contain values from Prometheus, the CPU unit is in milliCPU, the memory unit is bytes.

## Merging results from GitHub Workflows

To merge test results from GitHub Workflows you need to run the following command:

```bash
export GH_TOKEN="a personal github token"  # Needs read permission for workflows so it can download artifacts
bash test/performance/merge.sh
```

A bunch of output will get printed into stdout, but to visualize the results run:

```
# You need to install `gnuplot` first
gnuplot -e "name='Memory during GET'; filename='merge/get-memory.csv'; outfile='get-memory.png'" test/performance/memory.gnuplot
gnuplot -e "name='Memory during POST'; filename='merge/create-memory.csv'; outfile='create-memory.png'" test/performance/memory.gnuplot
gnuplot -e "name='CPU during GET'; filename='merge/get-cpu.csv'; outfile='get-cpu.png'" test/performance/cpu.gnuplot
gnuplot -e "name='CPU during POST'; filename='merge/create-cpu.csv'; outfile='create-cpu.png'" test/performance/cpu.gnuplot
```

This will create four PNGs in the root of the repository. Results may vary but you should see
something similar to:

![CPU Get Plot](./example-plots/get-cpu.png)
![Memory Get Plot](./example-plots/get-memory.png)
![CPU Create Plot](./example-plots/create-cpu.png)
![Memory Create Plot](./example-plots/create-memory.png)
