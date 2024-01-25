import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import pako from "pako";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const encode = (source: string) => {
  const input = new TextEncoder().encode(source);
  const output = pako.deflate(input);
  return Buffer.from(output).toString("base64");
};

export const decode = (hash: string) => {
  const input = Buffer.from(hash, "base64");
  const output = pako.inflate(input);
  return new TextDecoder().decode(output);
};
