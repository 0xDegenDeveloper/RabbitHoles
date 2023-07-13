/// function to convert string to felt array/felt
export function stringToFelts(str) {
  const chunkSize = 31;
  const utf8Encoder = new TextEncoder();
  const utf8Array = utf8Encoder.encode(str);
  const numChunks = Math.ceil(utf8Array.length / chunkSize);

  const felts = numChunks == 0 ? "" : [];

  for (let chunkIndex = 0; chunkIndex < numChunks; chunkIndex++) {
    let num = BigInt(0);
    const startIndex = chunkIndex * chunkSize;
    const endIndex = Math.min(startIndex + chunkSize, utf8Array.length);

    for (let i = startIndex; i < endIndex; i++) {
      num = (num << BigInt(8)) + BigInt(utf8Array[i]);
    }

    felts.push(num.toString());
  }

  return felts.length === 1 ? felts[0] : felts;
}
