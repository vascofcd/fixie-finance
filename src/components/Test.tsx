"use client";

import { useReadContract } from "wagmi";
import { parseAbi } from "viem";

export function Test() {
  const { data: number } = useReadContract({
    address: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
    abi: parseAbi(["function number() view returns (uint256)"]),
    functionName: "number",
  });
  console.log("number", number);
  return (
    <div>
      <h2>Number</h2>
      <p>{number}</p>
    </div>
  );
}
