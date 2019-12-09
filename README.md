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

## Parse file using "batches"
### File with 1m records
```
Time: 17.88
Memory: 326.99 MB
```
### File with ~3m records
```
Time: 66.42
Memory: 1076.65 MB
```
