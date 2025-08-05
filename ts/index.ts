import circuit from "../circuits/target/circuits.json" assert { type: "json" };

import type { CompiledCircuit, InputMap } from "@noir-lang/noir_js";

export const run = async (args: InputMap) => {
  const [{ UltraHonkBackend }, { Noir }] = await Promise.all([
    import("@aztec/bb.js"),
    import("@noir-lang/noir_js"),
  ]);

  const noir = new Noir(circuit as CompiledCircuit);
  const backend = new UltraHonkBackend(circuit.bytecode);

  const { witness } = await withPerformanceLog(
    "Witness generation",
    async () => {
      console.log("Generating witness... ⏳");
      const { witness } = await noir.execute(args);
      console.log("Generated witness... ✅");

      return { witness };
    }
  );

  const data = await withPerformanceLog("Proof generation", async () => {
    console.log("Generating proof... ⏳");
    const result = await backend.generateProof(witness);
    console.log("Generated proof... ✅");

    return result;
  });

  // console.log(JSON.stringify(data.proof, undefined, 2));

  const isValid = await withPerformanceLog("Verification", async () => {
    return await backend.verifyProof(data);
  });

  console.log(
    "Proof verification result:",
    isValid ? "✅ Valid" : "❌ Invalid"
  );
};

const withPerformanceLog = async <T>(
  operation: string,
  call: () => Promise<T>
): Promise<T> => {
  const start = performance.now();

  const result = await call();

  const end = performance.now();

  console.log(`${operation}: ${(end - start).toFixed(2)} ms`);

  return result;
};

(async () => {
  try {
    const args = {
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

    await run(args);
    process.exit(0); // Success
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1); // Failure
  }
})();
