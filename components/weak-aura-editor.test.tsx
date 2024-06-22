import { wrapper } from "@/vitest.setup";
import { cleanup, render, waitFor } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { WeakAuraEditor, defaultSource } from "./weak-aura-editor";

describe("WeakAuraEditor", () => {
  afterEach(cleanup);
  afterEach(() => {
    vi.clearAllMocks();
  });

  it("should not update hash with default source", async () => {
    vi.spyOn(history, "pushState");
    const { getByRole } = render(<WeakAuraEditor />, { wrapper });
    const source = await waitFor(
      () => getByRole("textbox") as HTMLTextAreaElement
    );
    await waitFor(() => expect(source.value).toMatch(defaultSource));
    expect(history.pushState).not.toHaveBeenCalled();
  });

  it("should set source to hash upon change", async () => {
    const encoded = "eJxzy89XSMxLUXBKLNJRSMzJUUgsUSjJSFUoTsxNVSjJzE1VBADCFAs-";
    const decoded = "Foo and Bar, all at the same time!";
    window.location.hash = encoded;

    const { getByRole } = render(<WeakAuraEditor />, { wrapper });
    await waitFor(() =>
      expect((getByRole("textbox") as HTMLTextAreaElement).value).toMatch(
        decoded
      )
    );
  });
});
