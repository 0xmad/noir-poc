import circuit from "../circuits/target/circuits.json" assert { type: "json" };

import type { CompiledCircuit } from "@noir-lang/noir_js";

export const run = async (age: number) => {
  const [{ UltraHonkBackend }, { Noir }] = await Promise.all([
    import("@aztec/bb.js"),
    import("@noir-lang/noir_js"),
  ]);

  const noir = new Noir(circuit as CompiledCircuit);
  const backend = new UltraHonkBackend(circuit.bytecode);

  if (!age) {
    throw new Error("Age is not provided");
  }

  console.log("Generating witness... ⏳");
  const { witness } = await noir.execute({ age });
  console.log("Generated witness... ✅");

  console.log("Generating proof... ⏳");
  const data = await backend.generateProof(witness);
  console.log("Generated proof... ✅");

  console.log(JSON.stringify(data.proof, undefined, 2));

  const isValid = await backend.verifyProof(data);

  console.log(
    "Proof verification result:",
    isValid ? "✅ Valid" : "❌ Invalid"
  );
};

(async () => {
  try {
    const ageArg = process.argv[2] ? parseInt(process.argv[2], 10) : 0;
    await run(ageArg);
    process.exit(0); // Success
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1); // Failure
  }
})();
