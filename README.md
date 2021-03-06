# Optimization of file parser

## Usage

`bin/make_report.rb <file>`

## First results

### File with 1m records
```
Time: 22.33s
Memory: 956.42 MB
```
### File with ~3m records
```
Time: 90.11s
Memory: 2760.09 MB
```

## Fill users and session arrays using awk
### File with 1m records
```
Time: 17.55
Memory: 952.29 MB
```
### File with ~3m records
```
Time: 73.99
Memory: 2829.38 MB
```

## Parse file using File.foreach
### File with 1m records
```
Time: 17.88
Memory: 326.99 MB
```
### File with ~3m records
```
Time: 53.66
Memory: 928.3 MB
```

## Parse file using "batches"
### File with 1m records
```
Time: 14.15
Memory: 156.3 MB
```
### File with ~3m records
```
Time: 53.79
Memory: 484.47 MB
```

## Final results
### File with 1m records
```
Time: 10.63
Memory: 1.27 MB
```
### File with ~3m records
```
Time: 34.05105560601805
Memory: 1.25 MB
```

## Results on 30000 lines in data.txt (remove extra lines from data_large.txt)
### Task.rb
```
Time: 32.97
Memory: 88.21 MB
```
### My solution
```
Time: 0.36
Memory: 1.01 MB
```
