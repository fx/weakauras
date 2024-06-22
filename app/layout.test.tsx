import {
  afterAll,
  afterEach,
  beforeAll,
  describe,
  expect,
  it,
  vi,
} from "vitest";
import Layout, { defaultSource } from "./layout";
import { cleanup, render } from "@testing-library/react";
import { useContext } from "react";
import { GlobalContext } from "./providers";

const SourceTestComponent = () => {
  const { source } = useContext(GlobalContext);
  return (
    <div data-url={window.location.hash} data-testid="source">
      {source}
    </div>
  );
};

describe("Layout", () => {
  afterEach(cleanup);
  afterEach(() => {
    vi.clearAllMocks();
  });

  it("renders", async () => {
    const { getByText } = render(
      <Layout>
        <p>hi</p>
      </Layout>
    );
    expect(getByText("hi")).toBeDefined();
  });

  it("should not update hash with default source", async () => {
    vi.spyOn(history, "pushState");
    const { getByTestId } = render(
      <Layout>
        <SourceTestComponent />
      </Layout>
    );
    const source = getByTestId("source");
    expect(source.innerHTML).toMatch(defaultSource);
    expect(history.pushState).not.toHaveBeenCalled();
  });

  it("should set source to hash upon change", async () => {
    const encoded = "eJxzy89XSMxLUXBKLNJRSMzJUUgsUSjJSFUoTsxNVSjJzE1VBADCFAs-";
    const decoded = "Foo and Bar, all at the same time!";
    window.location.hash = encoded;

    const { getByTestId } = render(
      <Layout>
        <SourceTestComponent />
      </Layout>
    );
    const source = getByTestId("source");
    expect(source.innerHTML).toMatch(decoded);
  });
});
