# Noir circuits PoC for MACI

Go to `circuits` folder and run `nargo test` or `nargo fuzz --timeout {TIMEOUT}`
Run `nargo info` or `bb gates -b ./target/circuits.json` to see the contraint number and circuit size.

## Benchmarks

### Noir

MacBook Pro (Retina, 15-inch, Mid 2015), 16 GB RAM

```
Witness generation: 343.35 ms
Proof generation: 6545.14 ms
Verification: 2355.06 ms
```

### Circom

```
Witness generation: 67.23 ms
Proof generation: 
Verification: 
```
