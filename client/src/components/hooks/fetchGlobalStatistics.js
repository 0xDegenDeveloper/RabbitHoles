import { useState, useEffect } from "react";

export default function fetchGlobalStatistics() {
  const [globalStats, setGlobalStats] = useState({
    holes: 0,
    rabbits: 0,
    depth: 0,
  });

  useEffect(() => {
    /// place contract call
    setGlobalStats({
      holes: 111,
      rabbits: 555,
      depth: 1234,
    });
  }, []);

  /// make contract read

  return globalStats;
}
