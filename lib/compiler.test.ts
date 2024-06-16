// import { DefaultRubyVM } from "@ruby/wasm-wasi/dist/node";
import { RubyVM } from "@ruby/wasm-wasi";
import { beforeEach, describe, expect, it } from "vitest";
import { compile, initRuby, rubyInit } from "./compiler";

declare module "vitest" {
  export interface TestContext {
    vm?: RubyVM;
  }
}

describe("compiler", () => {
  beforeEach(async (context) => {
    const { vm } = await initRuby({ root_uri: "/public/" });
    await vm?.evalAsync(rubyInit);
    context.vm = vm;
  });

  it("returns valid JSON", async ({ vm }) => {
    const response = await compile(vm, "");
    const result = response.toString();
    const json = JSON.parse(result);
    expect(json).toBeTypeOf("object");
  });

  describe("debuff_missing", () => {
    it("return a valid debuff missing trigger", async ({ vm }) => {
      const source = `debuff_missing 'Shadow Word: Pain'`;
      const response = await compile(vm, source);
      const result = JSON.parse(response.toString());
      expect(result.c[0].triggers["1"].trigger.auranames[0]).toEqual(
        "Shadow Word: Pain"
      );
    });
  });
});
