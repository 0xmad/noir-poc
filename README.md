# Noir circuits PoC for MACI

Go to `circuits` folder and run `nargo test` or `nargo fuzz --timeout {TIMEOUT}`
Run `nargo info` or `bb gates -b ./target/circuits.json` to see the contraint number and circuit size.

## Benchmarks

### Noir

MacBook Pro, 16 GB RAM

```
Witness generation: 343.35 ms
Proof generation: 6545.14 ms
Verification: 2355.06 ms
```

Ubuntu, 32 GB RAM

```
Witness generation: 251.25 ms
Proof generation: 4794.79 ms
Verification: 1692.36 ms
```

```
··············································································································
|  Solidity and Network Configuration                                                                        │
························|················|····················|················|······························
|  Solidity: 0.8.29     ·  Optim: true   ·  Runs: 100000000   ·  viaIR: false  ·    Block: 30,000,000 gas    │
························|················|····················|················|······························
|  Network: ETHEREUM    ·  L1: 0.52500 gwei                   ·                ·       3818.02 usd/eth       │
························|················|····················|················|···············|··············
|  Contracts / Methods  ·  Min           ·  Max               ·  Avg           ·  # calls      ·  usd (avg)  │
························|················|····················|················|···············|··············
|  Poll                 ·                                                                                    │
························|················|····················|················|···············|··············
|      updateValue      ·             -  ·                 -  ·     1,926,489  ·            2  ·       3.86  │
························|················|····················|················|···············|··············
|  Deployments                           ·                                     ·  % of limit   ·             │
························|················|····················|················|···············|··············
|  HonkVerifier         ·             -  ·                 -  ·     5,253,489  ·       17.5 %  ·      10.53  │
························|················|····················|················|···············|··············
|  Poll                 ·             -  ·                 -  ·       274,886  ·        0.9 %  ·       0.55  │
························|················|····················|················|···············|··············
|  Key                                                                                                       │
··············································································································
|  ◯  Execution gas for this method does not include intrinsic gas overhead                                  │
··············································································································
|  △  Cost was non-zero but below the precision setting for the currency display (see options)               │
··············································································································
|  Toolchain:  hardhat                                                                                       │
··············································································································
```

### Circom

MacBook Pro, 16 GB RAM (can't run rapidsnark on my system)

```
Witness generation: 67.23 ms
Proof generation: -
Verification: -
```

Ubuntu, 32 GB RAM

```
Witness generation: 48.35 ms
Proof generation: 389.20 ms
Verification: 419.06 ms
```

```
··············································································································
|  Solidity and Network Configuration                                                                        │
························|················|····················|················|······························
|  Solidity: 0.8.29     ·  Optim: true   ·  Runs: 100000000   ·  viaIR: false  ·    Block: 30,000,000 gas    │
························|················|····················|················|······························
|  Network: ETHEREUM    ·  L1: 0.52500 gwei                   ·                ·       3818.02 usd/eth       │
························|················|····················|················|···············|··············
|  Contracts / Methods  ·  Min           ·  Max               ·  Avg           ·  # calls      ·  usd (avg)  │
························|················|····················|················|···············|··············
|  Poll                 ·                                                                                    │
························|················|····················|················|···············|··············
|      updateValue      ·             -  ·                 -  ·     1,926,489  ·            2  ·       3.86  │
························|················|····················|················|···············|··············
|  Deployments                           ·                                     ·  % of limit   ·             │
························|················|····················|················|···············|··············
|  HonkVerifier         ·             -  ·                 -  ·     5,253,489  ·       17.5 %  ·      10.53  │
························|················|····················|················|···············|··············
|  Poll                 ·             -  ·                 -  ·       274,886  ·        0.9 %  ·       0.55  │
························|················|····················|················|···············|··············
|  Key                                                                                                       │
··············································································································
|  ◯  Execution gas for this method does not include intrinsic gas overhead                                  │
··············································································································
|  △  Cost was non-zero but below the precision setting for the currency display (see options)               │
··············································································································
|  Toolchain:  hardhat, total price: 14.94                                                                  │
··············································································································
```

Tested in MACI repo

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { SnarkCommon } from "./crypto/SnarkCommon.sol";
import { Verifier } from "./crypto/Verifier.sol";
import { Params } from "./utilities/Params.sol";
import { Utilities } from "./utilities/Utilities.sol";

import { LazyIMTData, InternalLazyIMT } from "./trees/LazyIMT.sol";
import { CurveBabyJubJub } from "./crypto/BabyJubJub.sol";

contract Test is Params, Utilities, SnarkCommon {
  Verifier public immutable verifier;

  uint256 public value;

  error InvalidPollJoinedProof();

  constructor(address verifierAddress) {
    verifier = Verifier(verifierAddress);
  }

  function updateValue(uint256[8] memory proof, VerifyingKey memory verifyingKey, uint256 root) public {
    if (!verifyPollJoined(proof, verifyingKey, root)) {
      revert InvalidPollJoinedProof();
    }

    value += 1;
  }

  function verifyPollJoined(
    uint256[8] memory proof,
    VerifyingKey memory verifyingKey,
    uint256 root
  ) public view returns (bool) {
    uint256[] memory publicInputs = new uint256[](1);
    publicInputs[0] = root;

    return verifier.verify(proof, verifyingKey, publicInputs);
  }
}
```

```typescript
import { expect } from "chai";

import type { IVerifyingKeyStruct } from "../ts/types";

import {
  createContractFactory,
  deployContractWithLinkedLibraries,
  deployPoseidonContracts,
  deployVerifier,
} from "../ts/deploy";
import { getDefaultSigner } from "../ts/utils";
import { type Verifier, type Test, Test__factory as TestFactory } from "../typechain-types";

describe("Poll", () => {
  let verifier: Verifier;
  let poll: Test;

  const defaultProof = [
    "14109906387846213722268079681407592378212296584519828021593925655184406105625",
    "8631562295381789979363955366934308889426531023533544399499166590536383120017",
    "7834858189981227607522666208515254897594827034992472666129472569351133343399",
    "4439516227786847507033060887291315047180359102595600604919384305757526610392",
    "9414891605362342984811250346376758652450189903822038090741445329849206639864",
    "3556684436614961820087330669810034380252435413354127784673885845495909551990",
    "5310631136047747485862316678979952381889761309597487504429318725200425590254",
    "17140167519918194777657531233629181361550732466477892757292290532443023193028",
  ];

  const defaultPublicInputs = ["16434683143777714407455388466094552957416110238104597540795554276262687639887"];

  const verifyingKey = {
    alpha1: {
      x: "20491192805390485299153009773594534940189261866228447918068658471970481763042",
      y: "9383485363053290200918347156157836566562967994039712273449902621266178545958",
    },
    beta2: {
      x: [
        "4252822878758300859123897981450591353533073413197771768651442665752259397132",
        "6375614351688725206403948262868962793625744043794305715222011528459656738731",
      ],
      y: [
        "21847035105528745403288232691147584728191162732299865338377159692350059136679",
        "10505242626370262277552901082094356697409835680220590971873171140371331206856",
      ],
    },
    gamma2: {
      x: [
        "11559732032986387107991004021392285783925812861821192530917403151452391805634",
        "10857046999023057135944570762232829481370756359578518086990519993285655852781",
      ],
      y: [
        "4082367875863433681332203403145435568316851327593401208105741076214120093531",
        "8495653923123431417604973247489272438418190587263600148770280649306958101930",
      ],
    },
    delta2: {
      x: [
        "11559732032986387107991004021392285783925812861821192530917403151452391805634",
        "10857046999023057135944570762232829481370756359578518086990519993285655852781",
      ],
      y: [
        "4082367875863433681332203403145435568316851327593401208105741076214120093531",
        "8495653923123431417604973247489272438418190587263600148770280649306958101930",
      ],
    },
    ic: [
      {
        x: "1629095352768097199652977056475761030800820174729983889807674948414713337125",
        y: "6467650901911759592752406178725588875848751433957339598488903881425535172880",
      },
      {
        x: "11453856308358934805322354753673340780450823864474426592721588892180973444080",
        y: "12033483519667937538319018601058143480970553057573234593387722779283812258415",
      },
    ],
  } as IVerifyingKeyStruct;

  before(async () => {
    const signer = await getDefaultSigner();

    const { PoseidonT3Contract, PoseidonT4Contract, PoseidonT5Contract, PoseidonT6Contract } =
      await deployPoseidonContracts(signer);

    const poseidonAddrs = await Promise.all([
      PoseidonT3Contract.getAddress(),
      PoseidonT4Contract.getAddress(),
      PoseidonT5Contract.getAddress(),
      PoseidonT6Contract.getAddress(),
    ]).then(([poseidonT3, poseidonT4, poseidonT5, poseidonT6]) => ({
      poseidonT3,
      poseidonT4,
      poseidonT5,
      poseidonT6,
    }));

    verifier = await deployVerifier();

    const pollFactory = await createContractFactory(
      TestFactory.abi,
      TestFactory.linkBytecode({
        "contracts/crypto/PoseidonT3.sol:PoseidonT3": poseidonAddrs.poseidonT3,
        "contracts/crypto/PoseidonT4.sol:PoseidonT4": poseidonAddrs.poseidonT4,
        "contracts/crypto/PoseidonT5.sol:PoseidonT5": poseidonAddrs.poseidonT5,
        "contracts/crypto/PoseidonT6.sol:PoseidonT6": poseidonAddrs.poseidonT6,
      }),
    );

    poll = await deployContractWithLinkedLibraries<Test>(pollFactory, signer, await verifier.getAddress());
  });

  it("should verify proof onchain", async () => {
    const isValid = await poll.verifyPollJoined(defaultProof, verifyingKey, defaultPublicInputs[0]);

    expect(isValid).to.eq(true);
  });

  it("should update poll state with valid proof", async () => {
    const previousValue = await poll.value();
    await poll.updateValue(defaultProof, verifyingKey, defaultPublicInputs[0]).then((tx) => tx.wait());
    const newValue = await poll.value();

    expect(previousValue + 1n).to.eq(newValue);
  });

  it("should fail if trying to update poll state with invalid proof", async () => {
    await expect(poll.updateValue(defaultProof, verifyingKey, "9000")).to.be.revertedWithCustomError(
      poll,
      "InvalidPollJoinedProof",
    );
  });
});
```

