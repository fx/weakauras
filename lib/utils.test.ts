import { describe, expect, it } from "vitest";
import { decodeHash, encodeHash } from "./utils";

describe("utils", () => {
  describe("encode/decode", () => {
    const encoded = "eJxzy89XSMxLUXBKLNJRSMzJUUgsUSjJSFUoTsxNVSjJzE1VBADCFAs-";
    const decoded = "Foo and Bar, all at the same time!";

    it("should encode", () => expect(encodeHash(decoded)).toEqual(encoded));
    it("should decode", () => expect(decodeHash(encoded)).toEqual(decoded));
    it("should not throw, but returned undefined when decoding invalid input", () =>
      expect(decodeHash("foo")).toBeUndefined());
  });
});
