import { describe, expect, it } from "vitest";
import { decode, encode } from "./utils";

describe("utils", () => {
  describe("decode", () => {
    const encoded = "eJxzy89XSMxLUXBKLNJRSMzJUUgsUSjJSFUoTsxNVSjJzE1VBADCFAs+";
    const decoded = "Foo and Bar, all at the same time!";

    it("should encode", () => expect(encode(decoded)).toEqual(encoded));
    it("should decode", () => expect(decode(encoded)).toEqual(decoded));
  });
});
