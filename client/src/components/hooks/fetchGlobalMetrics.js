import { useState, useEffect } from "react";

export default function fetchGlobalMetrics() {
  const [globalMetrics, setGlobalMetrics] = useState({
    totalSupply: 0,
    digFee: 0,
    digReward: 0,
    diggerBps: 0,
  });

  useEffect(() => {
    /// place contract call
    setGlobalMetrics({
      totalSupply: "12,3456",
      digFee: 0.001,
      digReward: "25",
      diggerBps: 2500,
    });
  }, []);

  /// make contract read

  return globalMetrics;
}
