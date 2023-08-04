import { useState, useEffect } from "react";
import sample from "../../assets/sample-data";

import REGISTRY_ABI from "../../assets/rabbitholes_ERC20.sierra.json";

const ABI = REGISTRY_ABI.abi;

const MANAGER_ADDRESS =
  "0x026a60f9b16975e44c11550c2baff45ac4c52d399cdccab5532dccc73ffa3298";
const RBITS_ADDRESS =
  "0x06a3e59fce87072a652e7d67df0782e89b337b65ff50f1d8553e990dd3c95cef";
const REGISTRY_ADDRESS =
  "0x026377bcc9b973eae8500eca7f916e42a645ffd4b15146e62b69e57e958502fc";
const V1_ADDRESS =
  "0x01c8ca977ca1c5721fb5150f63b1ae5b75e6155ef9b4e0f19acc9082d8c7fff3";

export default function fetchIdFromTitle(title) {
  const [id, setId] = useState(0);
  // const { data, isLoading, error, refetch } = useContractRead({
  //     address: REGISTRY_ADDRESS,
  //     abi: ABI,
  //     functionName: "is_minting",
  //     args: [],
  //     // args: [stringToFelts(title)],
  //     watch: true,
  //     blockIdentifier: "11111",
  //   });

  useEffect(() => {
    for (let key in sample) {
      if (sample[key].title === title) {
        setId(key);
      }
    }
  }, [title]);

  return { id };
  // return { data, isLoading, isError };
}
