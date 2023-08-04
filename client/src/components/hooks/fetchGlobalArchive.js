import { useState, useEffect } from "react";
import fetchHolesData from "./fetchHoleData";
import sample from "../../assets/sample-data.json";

export default function fetchGlobalArchive(totalHoles) {
  const array = Array.from({ length: totalHoles }, (_, i) => i + 1);

  const [globalArchive, setGlobalArchive] = useState(fetchHolesData(array));

  useEffect(() => {
    /// add constraints/indexes when replaced with contract call
    const holes = fetchHolesData(
      Array.from({ length: totalHoles }, (_, i) => i + 1)
    );

    setGlobalArchive(holes);
  }, []);

  return globalArchive;
}
