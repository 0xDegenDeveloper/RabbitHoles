import { useState, useEffect } from "react";

export default function fetchGlobalStats() {
  const [globalStats, setGlobalStats] = useState({
    holes: 0,
    rabbits: 0,
    depth: 0,
    totalSupply: 0,
    digFee: 0,
    digReward: 0,
    diggerBps: 0,
  });

  useEffect(() => {
    setGlobalStats({
      holes: 111,
      rabbits: 555,
      depth: 1234,
      totalSupply: "12,3456",
      digFee: 0.001,
      digReward: "25",
      diggerBps: 2500,
    });
  }, []);

  /// make contract read

  return globalStats;
}
