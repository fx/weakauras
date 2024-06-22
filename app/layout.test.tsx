import { describe, expect, it } from "vitest";
import Layout from "./layout";
import { render } from "@testing-library/react";

describe("Layout", () => {
  it("renders", async () => {
    const { getByText } = render(<Layout>hi</Layout>);
    expect(getByText("hi")).toBeDefined();
  });
});
