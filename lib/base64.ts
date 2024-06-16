// See https://gist.github.com/jordanbtucker/5a89c1d99099408c7c265a7462f60e1a

export interface Encoder {
  encode(input?: string): Iterable<number>;
}

export interface Decoder {
  decode(input?: Iterable<number> | ArrayBuffer | ArrayBufferView): string;
}

export function bytesToBase64(bytes: Iterable<number>): string {
  return btoa(String.fromCharCode(...bytes));
}

export function bytesToBase64URL(bytes: Iterable<number>): string {
  return bytesToBase64(bytes)
    .replaceAll("+", "-")
    .replaceAll("/", "_")
    .replaceAll("=", "");
}

export function base64ToBytes(str: string): Uint8Array {
  return Uint8Array.from(atob(str), (c) => c.charCodeAt(0));
}

export function base64URLToBytes(str: string): Uint8Array {
  return base64ToBytes(str.replaceAll("-", "+").replaceAll("_", "/"));
}

export function base64encode(
  str: string,
  encoder: Encoder = new TextEncoder()
): string {
  return bytesToBase64(encoder.encode(str));
}

export function base64URLencode(
  str: string,
  encoder: Encoder = new TextEncoder()
): string {
  return bytesToBase64URL(encoder.encode(str));
}

export function base64decode(
  str: string,
  decoder: Decoder = new TextDecoder()
): string {
  return decoder.decode(base64ToBytes(str));
}

export function base64URLdecode(
  str: string,
  decoder: Decoder = new TextDecoder()
): string {
  return decoder.decode(base64URLToBytes(str));
}
