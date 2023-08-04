import { useState, useEffect } from "react";

export default function fetchGlobalStatistics() {
  const [globalStats, setGlobalStats] = useState({
    holes: 111,
    rabbits: 555,
    depth: 1234,
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
