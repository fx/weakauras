import { render } from "@testing-library/react";
import { describe, it } from "vitest";
import Page from "./page";

describe("Page", () => {
  it("renders", async () => {
    render(<Page />);
  });
});
