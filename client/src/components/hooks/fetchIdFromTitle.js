import { useState, useEffect } from "react";
import sample from "../../assets/sample-data";

export default function fetchIdFromTitle(title) {
  const [id, setId] = useState(0);

  useEffect(() => {
    for (let key in sample) {
      if (sample[key].title === title) {
        setId(key);
      }
    }
  }, [title]);

  return { id };
}
