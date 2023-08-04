import { useState, useEffect } from "react";

export default function fetchGlobalMetrics() {
  const [globalStats, setGlobalStats] = useState({
    totalSupply: 0,
    digFee: 0,
    digReward: 0,
    diggerBps: 0,
  });

  useEffect(() => {
    /// place contract call
    setGlobalStats({
      totalSupply: "12,3456",
      digFee: 0.001,
      digReward: "25",
      diggerBps: 2500,
    });
  }, []);

  /// make contract read

  return globalStats;
}
