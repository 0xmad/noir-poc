import { useCallback, useState } from "react";

import type { CompiledCircuit } from "@noir-lang/noir_js";

export interface IUseNoirReturn {
  logs: { key: number; text: string }[];
  proof?: string;
  onSubmit: () => Promise<void>;
}

export const useNoir = (): IUseNoirReturn => {
  const [logs, setLogs] = useState<IUseNoirReturn["logs"]>([]);
  const [proof, setProof] = useState<string>();

  const appendLogs = useCallback(
    (text: string) => {
      setLogs((state) => state.concat({ key: state.length, text }));
    },
    [setLogs]
  );

  const clearLogs = useCallback(() => {
    setLogs([]);
  }, [setLogs]);

  const onSubmit = useCallback(async () => {
    clearLogs();

    const [{ UltraHonkBackend }, { Noir }, circuit] = await Promise.all([
      import("@aztec/bb.js"),
      import("@noir-lang/noir_js"),
      import("../circuits/target/circuits.json"),
    ]);

    const noir = new Noir(circuit as CompiledCircuit);
    const backend = new UltraHonkBackend(circuit.bytecode);

    const element = document.getElementById("age") as HTMLInputElement | null;

    if (!element) {
      appendLogs("Age element is not found");
      return;
    }

    appendLogs("Generating witness... ⏳");
    const { witness } = await noir.execute({ age: element.value });
    appendLogs("Generated witness... ✅");

    appendLogs("Generating proof... ⏳");
    const data = await backend.generateProof(witness);
    appendLogs("Generated proof... ✅");

    setProof(data.proof.toString());
  }, [appendLogs, clearLogs, setProof]);

  return {
    logs,
    proof,
    onSubmit,
  };
};
