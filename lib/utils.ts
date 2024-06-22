import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import pako from "pako";
import { base64URLToBytes, bytesToBase64URL } from "./base64";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const encodeHash = (source: string) => {
  const input = new TextEncoder().encode(source);
  const output = pako.deflate(input);
  return bytesToBase64URL(output);
};

export const decodeHash = (hash: string) => {
  try {
    const input = base64URLToBytes(hash.replace(/^#/, ""));
    const output = pako.inflate(input);
    return new TextDecoder().decode(output);
  } catch (e) {
    console.log("Failed to decode hash: ", e, hash);
    return undefined;
  }
};
