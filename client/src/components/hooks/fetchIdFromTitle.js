import { useState, useEffect } from "react";
import sample from "../../assets/sample-data";

export default function fetchIdFromTitle(title) {
  const [id, setId] = useState(0);

  useEffect(() => {
    for (let key in sample) {
      console.log(key);
      // If the title matches the input title, return the key
      console.log(key, sample[key].title, title);
      if (sample[key].title === title) {
        // data = key;
        console.log("found at ", key);
        setId(key);
      }
    }
  }, [title]);

  return { id };
}
