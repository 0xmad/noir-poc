import { expect } from "chai";
import hre, { ethers } from "hardhat";

import type { HonkVerifier, Poll } from "typechain-types";

describe("Poll", () => {
  let verifier: HonkVerifier;
  let poll: Poll;

  const defaultProofArgs = {
    private_key:
      "0x027c154dbbbc64d27be2ec794003ba42138827d08d200ddd0d10afc9f539bcb5",
    voice_credits_balance: "100",
    state_root:
      "0x25166ece8315f6a3b9a3be418bd225dee9c85cb35608dcee64583dcd2898267e",
    actual_state_tree_depth: "6",
    index: "2",
    siblings: [
      "0x19ce4238de2f70198652072a6fc1d13e88dbb8338091878c892cfffd95b3b870",
      "0x19f9a4410e14a1b1a3a7e9b03a55c518c712fb78fd34feadebc55749d2351ac8",
      "0x28f1a6f8e2afd3b4bdb2354b1878c03fbc0689f59f2506ec9c1a07f3ae43eb8e",
      "0x1475250f14274b35bf6f3f21fb0b92c7429da64a16f9e14a76b42e13278671e3",
      "0x16205c1b6fef76c5f3ebeeb65fb9d03870de9406b4553c230a0967e54c778236",
      "0x21c60230ea583db469b0241e9b4b1fed912978ea94e8fd7943d70d66f054c850",
      "0",
      "0",
      "0",
      "0",
    ],
  };

  before(async () => {
    // Deploy a verifier contract
    const [verifierContractFactory, pollContractFactory] = await Promise.all([
      ethers.getContractFactory("HonkVerifier"),
      ethers.getContractFactory("Poll"),
    ]);

    verifier = (await verifierContractFactory.deploy()) as HonkVerifier;
    await verifier.waitForDeployment();

    poll = await pollContractFactory.deploy(verifier);
    await poll.waitForDeployment();
  });

  it("should generate proof and verify it onchain", async () => {
    const { noir, backend } = await hre.noir.getCircuit("circuits");
    const { witness } = await noir.execute(defaultProofArgs);
    const { proof, publicInputs } = await backend.generateProof(witness, {
      keccak: true,
    });

    const isValidOnchain = await poll.verifyPollJoined(
      proof,
      defaultProofArgs.state_root
    );
    const isValidOffchain = await backend.verifyProof(
      { proof, publicInputs: [defaultProofArgs.state_root] },
      { keccak: true }
    );

    expect(isValidOnchain).to.eq(true);
    expect(isValidOffchain).to.eq(true);
    expect(publicInputs.length).to.eq(1);
    expect(publicInputs[0]).to.eq(
      ethers.solidityPacked(["uint256"], [defaultProofArgs.state_root])
    );
  });

  it("should update poll state with valid proof", async () => {
    const { noir, backend } = await hre.noir.getCircuit("circuits");
    const { witness } = await noir.execute(defaultProofArgs);
    const { proof } = await backend.generateProof(witness, {
      keccak: true,
    });

    const previousValue = await poll.value();
    await poll
      .updateValue(proof, defaultProofArgs.state_root)
      .then((tx) => tx.wait());
    const newValue = await poll.value();

    expect(previousValue + 1n).to.eq(newValue);
  });

  it("should fail if trying to update poll state with invalid proof", async () => {
    const { noir, backend } = await hre.noir.getCircuit("circuits");
    const { witness } = await noir.execute(defaultProofArgs);
    const { proof } = await backend.generateProof(witness, {
      keccak: true,
    });

    await expect(poll.updateValue(proof, "9000")).to.be.revertedWithCustomError(
      verifier,
      "SumcheckFailed"
    );
  });
});
